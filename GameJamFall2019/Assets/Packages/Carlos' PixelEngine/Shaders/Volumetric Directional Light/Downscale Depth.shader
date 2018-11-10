Shader "Hidden/Downscale Depth" {
	
	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _CameraDepthTexture;
	float4 _CameraDepthTexture_TexelSize;

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

	float frag(VertexOutput i) : SV_Target {
		/* Dividing by 2 because we're using a quarter resolution -- half the width, and half the height.
		_CameraDepthTexture_TexelSize.xy are 1 / width and 1 / height of the texture.
		You can think of 1 as the width and height of UV space, divided by the pixel dimensions
		*/
		float2 texelSize = _CameraDepthTexture_TexelSize.xy / 2;
		//return tex2D(_CameraDepthTexture, i.uv);
		return min(tex2D(_CameraDepthTexture, i.uv + float2(1, 1) * texelSize), 
				min(tex2D(_CameraDepthTexture, i.uv + float2(-1, 1) * texelSize),
				min(tex2D(_CameraDepthTexture, i.uv + float2(-1, -1) * texelSize),
				tex2D(_CameraDepthTexture, i.uv + float2(1, -1) * texelSize))));
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

	Fallback Off
}