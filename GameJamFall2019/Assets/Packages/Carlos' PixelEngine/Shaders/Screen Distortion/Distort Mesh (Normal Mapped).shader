Shader "2kPS/Distort Mesh (Normal Mapped)" {
	Properties {
		_BumpMap ("Normal Map", 2D) = "bump" {}
		[MaterialToggle] _uvBorderFade ("Fade UV Border", Int) = 1
		[MaterialToggle] _CullOn ("Cull Back Faces", Int) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	uniform sampler2D _BumpMap;
	uniform float4 _BumpMap_ST;
	uniform int _uvBorderFade;

	struct CustomVertexInput {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float4 color : COLOR;
		float3 normal : NORMAL;
		float3 tangent : TANGENT;
	};

	struct VertexOutput {
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 color : COLOR;
		float3 worldNormal : NORMAL;
		float3 worldTangent : TANGENT;
		float3 worldBitangent : BITANGENT;
		float4 projPos : TEXCOORD1;
	};

	VertexOutput vert(CustomVertexInput v) {
		VertexOutput o;

		o.vertex = UnityObjectToClipPos(v.vertex);
		o.projPos = ComputeScreenPos(o.vertex);

		o.uv = TRANSFORM_TEX(v.uv, _BumpMap);
		o.color = v.color;

		o.worldNormal = mul(unity_ObjectToWorld, fixed4(v.normal, 0));
		o.worldTangent = mul(unity_ObjectToWorld, fixed4(v.tangent, 0));
		o.worldBitangent = normalize(cross(-o.worldTangent, o.worldNormal));
		return o;
	}

	/*
	It is said that the matrix that transforms world space to tangent space is:

	[Tx  Ty  Tz]
	[Bx  By  Bz]
	[Nx  Ny  Nz]

	where T is the tangent vector in world space,
		B is the bitangent vector in world space,
		and N is the normal vector in world space.

	The 3 coordinate axes defined by T, B, and N are like the tangent space's local
	(x, y, z) coordinate axes, in that order!
	*/

	fixed4 frag(VertexOutput i) : SV_Target {
		float3 normalMapVector = normalize(UnpackNormal(tex2D(_BumpMap, i.uv)));
		float3x3 worldToTangentMatrix = float3x3(
			i.worldTangent,
			i.worldBitangent,
			i.worldNormal
		);

		//In view space
		float3 viewNormal = mul(UNITY_MATRIX_V, float4(mul(normalMapVector, worldToTangentMatrix), 0));

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
		return fixed4(viewNormal.xy / 2 + 0.5, 1, (abs(viewNormal.x) + abs(viewNormal.y)) / 2);
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