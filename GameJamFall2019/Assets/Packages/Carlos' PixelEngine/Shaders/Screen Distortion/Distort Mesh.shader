Shader "2kPS/Distort Mesh" {
	Properties {
		[MaterialToggle] _uvBorderFade ("Fade UV Border", Int) = 1
		[MaterialToggle] _CullOn ("Cull Back Faces", Int) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	uniform int _uvBorderFade;

	struct CustomVertexInput {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float4 color : COLOR;
		float3 normal : NORMAL;
	};

	struct VertexOutput {
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 color : COLOR;
		float3 viewNormal : NORMAL;
	};

	VertexOutput vert(CustomVertexInput v) {
		VertexOutput o;

		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		o.color = v.color;
		o.viewNormal = UnityObjectToViewPos(float4(v.normal, 0));

		return o;
	}

	fixed4 frag(VertexOutput i) : SV_Target {
		float3 viewNormal = i.viewNormal;

		if (_uvBorderFade == 1) {
			/*//put i.uv in the range 0 to 1 without modulus
			float2 factor = sign(i.uv) / 2 + 0.5;
			i.uv -= factor * floor(i.uv) + (1 - factor) * ceil(x);*/
			i.uv %= 1.0;
			//Represents the distance from this uv coord to the nearest uv-space repeat boundary (like x=0, 1, 2, ... and y=0, 1, 2, ...)
			float2 uvEdgeDelta = float2(min(i.uv, 1 - i.uv));

			/*I could multiply by the length of the uvEdgeDelta so that if it's a really small
			distance from the uv-space repeat boundaries, it'll be a less strong effect. But instead,
			I'm multiplying by the same of the x and y components (which has a min of 0, max of 1) as
			a good approximation */
			viewNormal.xy *= uvEdgeDelta.x + uvEdgeDelta.y;
		}
		viewNormal.xy *= i.color.a;
		return fixed4(viewNormal.xy / 2 + 0.5, 1, (viewNormal.x + viewNormal.y) / 2);
	}

	ENDCG

	SubShader {
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }
		Pass {
			ZTest Always
			Cull [_CullOn]
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		// The ShadowCaster pass is required in order to write to the depth texture
		Pass {
			Tags { "LightMode" = "ShadowCaster" }
			ZTest LEqual
			Cull [_CullOn]
			ZWrite On
			CGPROGRAM
			#include "UnityStandardShadow.cginc"
			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			ENDCG
		}
	}
	Fallback Off
}