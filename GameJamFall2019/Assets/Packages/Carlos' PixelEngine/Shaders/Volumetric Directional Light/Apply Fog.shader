Shader "Hidden/Apply Fog" {
	
	CGINCLUDE

	#include "UnityCG.cginc"

	struct VertexInput {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct VertexOutput {
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	sampler2D _FogTex;
	float _FogIntensity;

	VertexOutput vert(VertexInput v) {
		VertexOutput o;

		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}

	fixed4 frag(VertexOutput i) : SV_Target {
		fixed4 original = tex2D(_MainTex, i.uv);
		fixed4 color = original + _FogIntensity * fixed4(tex2D(_FogTex, i.uv).rgb, 1);
		return color;
	}

	ENDCG

	SubShader {
		Pass {
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}