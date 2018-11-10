Shader "2kPS/Basic Billboard" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_ScaleX ("Scale X", Float) = 1
		_ScaleY ("Scale Y", Float) = 1
	}

	SubShader {
		Tags { "Queue" = "Transparent" }
		Pass {
			Name "Base"
			Tags { "LightMode" = "ForwardBase" }
			
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _MainTex;
			uniform float _ScaleX;
			uniform float _ScaleY;

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 uv : TEXCOORD0;
			};

			struct VertexOutput {
				float4 clipPos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			VertexOutput vert(VertexInput vInput) {
				VertexOutput vOutput;

				vOutput.clipPos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)) + float4(vInput.vertex.x, vInput.vertex.y, 0, 0) + float4(_ScaleX, _ScaleY, 1, 1));
				vOutput.uv = vInput.uv;

				return vOutput;
			}

			fixed4 frag(VertexOutput vOutput) : SV_Target {
				return tex2D(_MainTex, vOutput.uv.xy);
			}

			ENDCG
		}
	}
}