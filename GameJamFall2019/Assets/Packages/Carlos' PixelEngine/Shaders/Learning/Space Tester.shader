Shader "2kPS/Learning/Space Tester" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	SubShader {
		Tags { "Queue" = "Geometry" }
		Pass {
			//Tags { "LightMode" = "Deferred" }
			Fog { Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct VertexInput {
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
			};

			struct VertexOutput {
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 actualClipPos : TEXCOORD1;
				float4 viewPos : TEXCOORD2;
			};

			uniform sampler2D _MainTex;

			VertexOutput vert(VertexInput v) {
				VertexOutput o;

				o.uv = v.uv;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.actualClipPos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(VertexOutput i) : SV_Target {
				fixed4 color;
				//color = tex2D(_MainTex, i.uv);
				color = i.vertex;
				float maxColor = max(max(color.r, color.g), color.b);
				/*if (maxColor >= 0.9)
					color = fixed4(1, 1, 1, 1);
				else if (maxColor <= 0.1)
					color = fixed4(0, 0, 1, 1);*/
				return color;
			}

			ENDCG
		}
	}
}