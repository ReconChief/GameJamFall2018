Shader "2kPS/Custom Physics/Vertex Weights" {
	Properties {
		[PerRendererData] _Color("Color", Color) = (1, 1, 1, 1)
		//_Color("Color", Color) = (1, 1, 1, 1)
	}

	SubShader {
		Tags {
			//"RenderType" = "Transparent"
			"RenderType" = "Opaque"
			"ForceNoShadowCasting" = "True"
			"IgnoreProjector" = "True"
		}
		Pass {
			Tags { "LightMode" = "Always" }
			//Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite On
			
			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma target 3.0

			//Without this line, this shader will not work with Unity's GPU instancing (like Graphics.DrawMeshInstanced(...)
			#pragma multi_compile_instancing
			
			#pragma vertex vertex
			#pragma fragment fragment
			
			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
			UNITY_INSTANCING_BUFFER_END(Props)

			struct VertexInput {
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput {
				float4 clipPos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			VertexOutput vertex(VertexInput v) {
				VertexOutput o;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.clipPos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 fragment(VertexOutput i) : SV_Target{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 c = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
				return c;
			}
			
			ENDCG
		}
	}
}