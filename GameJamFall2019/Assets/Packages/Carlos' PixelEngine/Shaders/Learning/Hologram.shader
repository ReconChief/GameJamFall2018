Shader "2kPS/Hologram" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		[MaterialToggle] _UseTexture ("Use Texture", Int) = 0
		_Color ("Color", Color) = (1, 1, 1, 1)
		_ScanningSpeed ("Scanning Speed", Float) = 10
		_ScanningFrequency ("Scanning Frequency", Float) = 50
		_Bias ("Bias", Range(-1, 1)) = 0
	}

	SubShader {
		Tags { "Queue"="Transparent" "RenderType" = "Transparent"}
		Blend SrcAlpha One
		ZWrite Off
		Cull Off

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			uniform int _UseTexture;

			uniform float4 _Color;
			uniform float _ScanningSpeed;
			uniform float _ScanningFrequency;
			uniform float _Bias;


			struct VertexInput {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct VertexOutput {
				float4 clipPos : SV_POSITION;
				float3 worldNormal : NORMAL;

				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 localVertex : TEXCOORD2;
			};

			VertexOutput vert(VertexInput vInput) {
				VertexOutput o;

				o.uv = TRANSFORM_TEX(vInput.uv, _MainTex);
				//o.worldVertex = mul(unity_ObjectToWorld, vInput.vertex);
				o.localVertex = vInput.vertex;
				o.worldNormal = mul(unity_ObjectToWorld, vInput.normal);

				o.clipPos = UnityObjectToClipPos(vInput.vertex);
				UNITY_TRANSFER_FOG(o, o.clipPos)
				return o;
			}

			fixed4 frag(VertexOutput i) : SV_Target {
				fixed4 color = _UseTexture * tex2D(_MainTex, i.uv) + (1 - _UseTexture) * _Color;
				float angle = _Time.y * 3;
				float sinA;
				float cosA;
				sincos(angle, sinA, cosA);
				/*float3x3 rotationMatrix = float3x3(
					cosA, sinA, 0,
					0, 1, 0,
					-sinA, 0, cosA
				);
				float3 rotatedPos = mul(rotationMatrix, i.localVertex.xyz);*/
				float3 rotatedPos = float3(i.localVertex.x * cosA, i.localVertex.y, i.localVertex.z * sinA);
				float xFactor = saturate(sin(i.localVertex.x * _ScanningFrequency + _Time[1] * _ScanningSpeed) + _Bias);
				float yFactor = saturate(sin(i.localVertex.y * _ScanningFrequency / -10 + _Time[1] * _ScanningSpeed) + _Bias);
				float zFactor = saturate(sin(i.localVertex.z * _ScanningFrequency + _Time[1] * _ScanningSpeed) + _Bias);
				color *= yFactor * xFactor * zFactor;

				UNITY_APPLY_FOG(i.fogCoord, color);

				return color;
			}

			ENDCG
		}
	}
}
