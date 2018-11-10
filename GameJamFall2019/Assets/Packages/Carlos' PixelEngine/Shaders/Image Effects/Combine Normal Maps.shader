Shader "Hidden/Combine Normal Maps" {
	CGINCLUDE
	#include "UnityCG.cginc"

	#define DEFAULT_NORMAL float3(0, 0, 1)
	#define DEFAULT_NORMAL_COLOR float4(0.5, 0.5, 1, 1)

	uniform sampler2D _NormalMap1;
	uniform sampler2D _NormalMap2;

	uniform float _Weights[2];
	uniform float _FinalStrength;

	float3 GetNormal(float4 color) {
		return 2 * color.rgb - 1;
	}

	float4 GetColor(float3 normal) {
		return float4((normal.xyz + 1) / 2, 1);
	}

	struct VertexInput {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct VertexOutput {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	VertexOutput vert(VertexInput v) {
		VertexOutput o;

		o.uv = v.uv;
		o.pos = UnityObjectToClipPos(v.vertex);

		return o;
	}

	ENDCG

	SubShader {
		Pass {
			Name "Average"
			Cull Off
			ZTest Always
			ZWrite Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragAverage

			float4 fragAverage(VertexOutput i) : SV_Target {
				float3 normal1 = GetNormal(tex2D(_NormalMap1, i.uv));
				float3 normal2 = GetNormal(tex2D(_NormalMap2, i.uv));

				float3 finalNormal = _Weights[0] * normal1 + _Weights[1] * normal2;
				float4 color = GetColor(finalNormal);
				return lerp(DEFAULT_NORMAL_COLOR, color, _FinalStrength);
			}

			ENDCG
		}

		Pass {
			Name "Direction-Based Average"
			Cull Off
			ZTest Always
			ZWrite Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragDirectionAverage

			float4 fragDirectionAverage(VertexOutput i) : SV_Target {
				float3 normal1 = GetNormal(tex2D(_NormalMap1, i.uv));
				float3 normal2 = GetNormal(tex2D(_NormalMap2, i.uv));

				//This will be 1 when normal1 is not really changing the surface normals (when it's aligned with (0, 0, 1))
				float factor = dot(normal1, float3(0, 0, 1));
				float3 finalNormal = lerp(normal1, (normal1 + normal2) / 2, factor);

				float4 color = GetColor(normalize(finalNormal));
				return lerp(DEFAULT_NORMAL_COLOR, color, _FinalStrength);
			}

			ENDCG
		}
	}
}
