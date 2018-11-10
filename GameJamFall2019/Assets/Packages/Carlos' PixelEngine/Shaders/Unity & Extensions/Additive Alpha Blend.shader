Shader "Particles/Additive Alpha Blend" {
	Properties {
		_TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01, 3.0)) = 1.0
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Cull Off
		Lighting Off
		ZWrite Off

		SubShader {
			Pass {
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_particles
				#pragma multi_compile_fog

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;

				struct VertexInput {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 uv : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				float4 _MainTex_ST;

				struct VertexOutput {
					float4 clipPos : SV_POSITION;
					fixed4 color : COLOR;
					float2 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
						float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_OUTPUT_STEREO
				};

				VertexOutput vert(VertexInput vertexInput) {
					VertexOutput vertexOutput;
					UNITY_SETUP_INSTANCE_ID(vertexInput);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(vertexOutput);
					vertexOutput.clipPos = UnityObjectToClipPos(vertexInput.vertex);

					#ifdef SOFTPARTICLES_ON
						vertexOutput.projPos = ComputeScreenPos(vertexOutput.clipPos);
						//COMPUTE_EYEDEPTH(vertexOutput.projPos.z);
						UNITY_TRANSFER_DEPTH(vertexOutput);
					#endif

					vertexOutput.color = vertexInput.color;
					vertexOutput.uv = TRANSFORM_TEX(vertexInput.uv, _MainTex);
					UNITY_TRANSFER_FOG(vertexOutput, vertexOutput.clipPos);

					return vertexOutput;
				}

				UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
				float _InvFade;

				fixed4 frag(VertexOutput vertexOutput) : SV_Target {
					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(vertexOutput.projPos)));
						float fade = saturate(_InvFade * (sceneZ - vertexOutput.projPos.z));
						vertexOutput.color.a *= fade;
					#endif

					fixed4 texColor = tex2D(_MainTex, vertexOutput.uv);
					half maxComponent = max(texColor.r, max(texColor.g, texColor.b));
					//texColor /= maxComponent;
					//texColor *= clamp(dot(texColor, fixed4(1, 1, 1, 1)), 0, 1 / maxComponent);
					//texColor *= dot(texColor, fixed4(1, 1, 1, 1));

					if (dot(texColor.rgb, texColor.rgb) < 1.5)
						texColor = lerp(texColor, fixed4(1, 1, 1, texColor.a), 0.5);

					fixed4 col = 2 * vertexOutput.color * _TintColor * texColor;
					
					//UNITY_APPLY_FOG_COLOR(vertexOutput.fogCoord, col, fixed4(0, 0, 0, 0));
					UNITY_APPLY_FOG(vertexOutput.fogCoord, col);
					return col;
				}

				ENDCG
			}
		}
	}
}