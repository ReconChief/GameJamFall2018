Shader "Hidden/Apply Screen Distort Particles" {
	
	SubShader {
		Pass {
			ZTest Always
			Cull Off
			ZWrite Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D  _ScreenDistortionMap;
			float _TexelDistance;
			float _BlendFactor;

			#define SAMPLE_COUNT 2

			struct VertexInput {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			VertexOutput vert(VertexInput v) {
				VertexOutput o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _CameraDepthTexture; //Primary camera's depth texture
			sampler2D _LastCameraDepthTexture; //Last rendered camera's depth texture

			fixed4 frag(VertexOutput i) : SV_Target {
				fixed4 color = tex2D(_MainTex, i.uv);
				float primaryDepth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv));
				float secondaryDepth = Linear01Depth(tex2D(_LastCameraDepthTexture, i.uv));
				if (primaryDepth - secondaryDepth < 0)
					return color;
				
				fixed4 sampleColor = tex2D(_ScreenDistortionMap, i.uv);
				//Some close enough approximation -- This is encoded into the texture by other shaders to be (normal.x + normal.y / 2)
				float normalLength = sampleColor.w;
				if (normalLength < 0.005)
					return color;

				float2 normal = sampleColor.xy * 2 - 1;


				sampleColor = 0;
				for (int j = 0; j < SAMPLE_COUNT; j++) {
					sampleColor += tex2D(_MainTex, i.uv + normal * normalLength * (_TexelDistance / (j + 1)) * _MainTex_TexelSize.xy);
				}
				sampleColor /= SAMPLE_COUNT;

				return lerp(color, sampleColor, _BlendFactor);
			}



			ENDCG
		}
	}
}