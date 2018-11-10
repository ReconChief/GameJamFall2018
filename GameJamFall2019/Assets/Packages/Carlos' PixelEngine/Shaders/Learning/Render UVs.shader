Shader "2kPS/Learning/Render UV Space" {
	Properties {
	
	}

	SubShader {
		Tags { "Queue" = "Geometry" }
		ZTest On
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

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

			fixed4 frag(VertexOutput i) : SV_Target {
				return fixed4(i.uv, 0, 1);
			}

			ENDCG
		}
	}
}