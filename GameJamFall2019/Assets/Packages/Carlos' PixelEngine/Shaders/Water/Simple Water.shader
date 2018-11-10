Shader "2kPS/Simple Water" {
	Properties {
		_MainColor ("Main Color", Color) = (1, 1, 1, 1)
		_Smoothness ("Smoothness", Range(0, 1)) = 1
		[NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
		_NormalMapIntensity ("Normal Map Intensity", Float) = 0.10
		[HideInInspector] _WaveScale ("Wave Scale", Float) = 0.03
		[HideInInspector] _WaveOffset ("Wave Offset", Float) = 0
	}

	SubShader {
		Tags { "Queue" = "Transparent" }
		Pass {
			Name "Base"
			Tags { "LightMode" = "ForwardBase" }

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#include "UnityPBSLighting.cginc"
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _MainColor;
			uniform float _Smoothness;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			uniform float _NormalMapIntensity;

			uniform float _WaveScale = 0.03;
			uniform float _WaveOffset = 0; //Accessible via Material.SetFloat!!

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv : TEXCOORD0;
			};
		
			struct VertexOutput {
				float4 clipPos : SV_POSITION;
				float3 worldPos : COLOR;
				float4 uv : TEXCOORD0;
				float3 worldNormal : NORMAL;
				float3 worldTangent : TANGENT;
				float3 worldBitangent : BITANGENT;
			};

			VertexOutput vert(VertexInput vInput) {
				VertexOutput vOutput;

				vOutput.uv = vInput.uv;
				vOutput.uv = vOutput.uv.xyxy;
				vOutput.uv *= _WaveScale;
				vOutput.uv += float4(_WaveOffset, _WaveOffset, -_WaveOffset, -_WaveOffset);

				vOutput.worldPos = mul(unity_ObjectToWorld, vInput.vertex);
				vOutput.worldNormal = mul((float3x3) unity_ObjectToWorld, vInput.normal);
				vOutput.worldTangent = mul((float3x3) unity_ObjectToWorld, vInput.tangent);
				vOutput.worldBitangent = vInput.tangent.w * cross(vOutput.worldNormal, vOutput.worldTangent);

				vOutput.clipPos = UnityObjectToClipPos(vInput.vertex);
				return vOutput;
			}

			fixed4 frag(VertexOutput vOutput) : SV_Target {
				float4 texNormalColorAverage =
					(tex2D(_NormalMap, vOutput.uv.xy)
					+ tex2D(_NormalMap, vOutput.uv.zw)) / 2;

				float3 unpackedNormal = float3(2 * texNormalColorAverage.ag - float2(1, 1), 1);
				unpackedNormal.xy *= _NormalMapIntensity;

				float3x3 localNormalToWorldTranspose = float3x3(
					vOutput.worldTangent,
					vOutput.worldBitangent,
					vOutput.worldNormal);

				float3 finalWorldNormal = normalize(mul(unpackedNormal, localNormalToWorldTranspose));

				float3 worldViewDir = _WorldSpaceCameraPos - vOutput.worldPos;
				float3 reflectedViewDir = reflect(- worldViewDir, finalWorldNormal);

				Unity_GlossyEnvironmentData envData;
				envData.roughness = 1 - _Smoothness;
				envData.reflUVW = reflectedViewDir;

				float3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
				float3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube0_HDR, envData);

				float3 color = lerp(probe1, probe0, unity_SpecCube0_BoxMin.w);
				//color = lerp(_MainColor.rgb, color, (color.r + color.g + color.b) / 3);
				color = lerp(_MainColor.rgb, color, 1 - length(color));

				return fixed4(color.rgb, _MainColor.a);
			}

			ENDCG
		}
	}
}