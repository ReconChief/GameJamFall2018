Shader "Hidden/Simple Fog" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Fog Color", Color) = (0.5, 0.5, 0.5, 1)
		_FogMin ("Fog Min", Float) = 0
		_FogMax ("Fog Max", Float) = 100
	}
	SubShader {
		// No culling or depth
		Cull Off
		ZWrite Off
		ZTest Always

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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			VertexOutput vert(VertexInput v) {
				VertexOutput o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}
			
			uniform sampler2D _MainTex;
			uniform sampler2D _CameraDepthTexture;
			uniform float4 _Color;
			uniform float _FogMin;
			uniform float _FogMax;

			fixed4 frag(VertexOutput i) : SV_Target {
				fixed4 color = tex2D(_MainTex, i.uv);
				
				float depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv));
				if (depth >= 1)
					return color;
				float distance = depth * _ProjectionParams.z;
				
				color = lerp(color, _Color, _Color.a * saturate((distance - _FogMin) / _FogMax));
				return color;
			}
			ENDCG
		}
	}
}
