// Upgrade NOTE: replaced 'UNITY_PASS_TEXCUBE(unity_SpecCube1)' with 'UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0)'

Shader "2kPS/Learning/Simple Mirror" {
	Properties {
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_Smoothness ("Smoothness", Range(0, 1)) = 1
		_NormalMapScale ("Normal Map Scale", Float) = 1
	}
	
	SubShader {
		Tags { "Queue" = "Transparent" }
		Pass {
			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityPBSLighting.cginc"
			#include "UnityCG.cginc"
			//#include "UnityShaderVariables.cginc"

			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			uniform float _Smoothness;
			uniform float _NormalMapScale;

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput {
				float4 clipPos : SV_POSITION;
				float3 worldPos : COLOR;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldTangent : TEXCOORD2;
				float3 worldBinormal : TEXCOORD3;
			};

			VertexOutput vert(VertexInput vInput) {
				VertexOutput vOutput;

				vOutput.worldPos = mul(unity_ObjectToWorld, vInput.vertex);
				vOutput.worldNormal = mul(unity_ObjectToWorld, vInput.normal);
				vOutput.worldTangent = mul(unity_ObjectToWorld, vInput.tangent);
				vOutput.worldBinormal = cross(vOutput.worldNormal, vOutput.worldTangent); //Why do we multiply by this?

				vOutput.uv = vInput.uv;

				vOutput.clipPos = UnityObjectToClipPos(vInput.vertex);
				return vOutput;
			}

			fixed4 frag(VertexOutput vOutput) : SV_Target {
				float4 texNormal = tex2D(_NormalMap, _NormalMap_ST.xy *  vOutput.uv.xy + _NormalMap_ST.zw);
				float3 unpackedNormal = float3(2 * texNormal.ag - float2(1, 1), 1); //UnpackNormal(texNormal);
				unpackedNormal.xy *= _NormalMapScale;
				//unpackedNormal.z = 1 - 0.5 * dot(unpackedNormal.xy, unpackedNormal.xy);

				//Each of these become a row in the matrix
				float3x3 localNormalToWorldTranspose = float3x3(
					vOutput.worldTangent,
					vOutput.worldBinormal,
					vOutput.worldNormal);

				float3 finalWorldNormal = normalize(mul(unpackedNormal, localNormalToWorldTranspose));
				/* This is the same as...

				float3 finalWorldNormal;
				finalWorldNormal.x = unpackedNormal.x * vOutput.worldTangent;
				finalWorldNormal.y = unpackedNormal.y * vOutput.worldBinormal;
				finalWorldNormal.z = unpackedNormal.z * vOutput.worldNormal;
				*/



				float3 worldViewDir = _WorldSpaceCameraPos - vOutput.worldPos;
				float3 reflectedViewDir = reflect(- worldViewDir, finalWorldNormal);

				Unity_GlossyEnvironmentData envData;
				envData.roughness = 1 - _Smoothness;
				envData.reflUVW = reflectedViewDir;

				//Defined in UnityGlobalIllumination.cginc!
				float3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
				float3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube0_HDR, envData);
				
				return fixed4(lerp(probe1, probe0, unity_SpecCube0_BoxMin.w).rgb, 1);
			}

			ENDCG
		}
	}
}