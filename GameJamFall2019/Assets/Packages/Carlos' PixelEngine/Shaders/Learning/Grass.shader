// Upgrade NOTE: upgraded instancing buffer 'Properties' to new syntax.

Shader "2kPS/Grass" {
	Properties {
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader {
		Tags { "Queue" = "Transparent" }

		Pass {
			Name "Base"
			Tags { "LightMode" = "ForwardBase" }

			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			struct VertexInput {
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput {
				float4 clipPos : SV_POSITION;
				float4 uv : TEXCOORD0;
				//UNITY_FOG_COORDS(1)
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			UNITY_INSTANCING_BUFFER_START(InstanceProperties)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				#define _Color_arr InstanceProperties
			UNITY_INSTANCING_BUFFER_END(InstanceProperties)

			VertexOutput vert(VertexInput vInput) {
				VertexOutput vOutput;

				UNITY_SETUP_INSTANCE_ID(vInput);
				UNITY_TRANSFER_INSTANCE_ID(vInput, vOutput); //Only needed if you want access to instanced properties in fragment shader

				vOutput.uv = vInput.uv;
				vOutput.clipPos = UnityObjectToClipPos(vInput.vertex);
				//UNITY_TRANSFER_FOG(vOutput, vOutput.clipPos);
				return vOutput;
			}

			fixed4 frag(VertexOutput vOutput) : SV_Target {
				UNITY_SETUP_INSTANCE_ID(vOutput); //Needed to access instanced properties in the fragment shader
				fixed4 color = tex2D(_MainTex, vOutput.uv * _MainTex_ST.xy + _MainTex_ST.zw);
				
				color = color * UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color); //UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color);

				return color; //return UNITY_APPLY_FOG(vOutput.fogCoord, color);
			}

			ENDCG
		}
	}
}