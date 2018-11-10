Shader "2kPS/Surface Tessellation" {
	Properties {
		//_TessFactor("Tesselation Factor", Range(1, 16)) = 1
		_EdgeLength  ("Edge Length", Range(2, 200)) = 30
		_PhongStrength ("Phong Strength", Range(0, 1)) = 0.5
		_MinTessFactor ("Min Tessellation Factor", Range(1, 16)) = 1
		_MaxTessFactor ("Max Tessellation Factor", Range(1, 16)) = 5
		_TessFactorRoundDown ("Factor Round-Down", Range(0, 1)) = 0.5

		_MainTex ("Base (RGB)", 2D) = "white" {}
		_DisplacementMap ("Displacement Texture", 2D) = "black" {}
		_NormalMap ("Normalmap", 2D) = "bump" {}
		_Displacement ("Displacement", Float) = 0.3
		_Color ("Color", color) = (1,1,1,0)
		_SpecColor ("Specular Color", color) = (0.5,0.5,0.5,0.5)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 300
			
		CGPROGRAM
		#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:vert tessellate:tessEdge tessphong:_PhongStrength nolightmap
		#pragma target 4.6
		#include "Tessellation.cginc"

		struct VertexInput {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};

		//float _TessFactor;
		float _EdgeLength;
		float _PhongStrength;
		int _MinTessFactor;
		int _MaxTessFactor;
		float _TessFactorRoundDown;

		sampler2D _DisplacementMap;
		float _Displacement;

		/*float4 tessDistance(VertexInput v0, VertexInput v1, VertexInput v2) {
			float minDistance = 10;
			float maxDistance = 40;
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDistance, maxDistance, _TessFactor);
		}*/

		float4 tessEdge(VertexInput v0, VertexInput v1, VertexInput v2) {
			float4 factors = clamp(UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength), _MinTessFactor, _MaxTessFactor);
			return factors - min(_TessFactorRoundDown, (factors - floor(factors)));
		}

		void vert(inout VertexInput v) {
			float d = tex2Dlod(_DisplacementMap, float4(v.texcoord.xy,0,0)).r * _Displacement;
			v.vertex.xyz += v.normal * d;
		}

		struct Input {
			float2 uv_MainTex;
		};

		sampler2D _MainTex;
		sampler2D _NormalMap;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Specular = 0.2;
			o.Gloss = 1.0;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
