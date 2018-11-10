// Upgrade NOTE: replaced 'UNITY_PASS_TEXCUBE(unity_SpecCube1)' with 'UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0)'

Shader "2kPS/Learning/Cube Sampler" {
	Properties {
		_Cube ("Cubemap", CUBE) = "" {}
	}

	SubShader {
		Tags { "Queue" = "Geometry" }
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityPBSLighting.cginc"

			//samplerCUBE  _Cube;

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct VertexOutput {
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			VertexOutput vert(VertexInput v) {
				VertexOutput o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				return o;
			}

			samplerCUBE _Cube;
			float4 _Cube_HDR;

			fixed4 frag(VertexOutput i) : SV_Target {
				fixed4 color = 1;
				float3 normal = normalize(i.normal);

				//These 2 lines both work with the scene's reflection probe0, but NOT with the second probe1.
				//color = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, normal);
				//color.rgb = DecodeHDR(UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, normal), unity_SpecCube0_HDR);

				//This is if you have a custom cubemap in your shader
				color.rgb = DecodeHDR(texCUBE(_Cube, normal), _Cube_HDR);
				color.a = 1;

				//This is if you want to blend between the 2 most important reflection probes in the scene, as well as the skybox.
				//Requires UnityPBSLighting.cginc
				Unity_GlossyEnvironmentData envData;
				envData.roughness = 0;
				envData.reflUVW = normalize(i.normal);
				
				float3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
				float3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube0_HDR, envData);

				//unity_SpecCube0_BoxMin.w is set to 1 when only probe0 is used, and lower if there's a blend.
				float3 reflColor = lerp(probe1, probe0, unity_SpecCube0_BoxMin.w);
				color.rgb = reflColor;

				return color;
			}

			ENDCG
		}
	}
}