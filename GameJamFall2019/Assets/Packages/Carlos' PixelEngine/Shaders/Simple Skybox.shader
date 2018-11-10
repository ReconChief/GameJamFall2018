Shader "2kPS/Simple Skybox" {
	Properties {
		//_Cube ("Environment Map", Cube) = "white" { }
		_TopColor ("Top Color", Color) = (0.1, 0.6, 1, 1)
		_MiddleColor ("Middle Color", Color) = (0.5, 0.78, 1, 1)
		_BottomColor ("Bottom Color", Color) = (0, 0.3, 0.7, 1)
	}

	CGINCLUDE
	uniform samplerCUBE _Cube;
	uniform float4 _TopColor;
	uniform float4 _MiddleColor;
	uniform float4 _BottomColor;

	struct VertexInput {
		float4 vertex : POSITION;
		float3 texcoord : TEXCOORD0;
	};

	struct VertexOutput {
		float4 clipPos : SV_POSITION;
		float3 texcoord : TEXCOORD0;
		float3 viewDir : TEXCOORD1; //normalized
	};

	VertexOutput vertex(VertexInput v) {
		VertexOutput o;

		o.viewDir = normalize(mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos);
		o.texcoord = v.texcoord;
		o.clipPos = UnityObjectToClipPos(v.vertex);
		return o;
	}

	fixed4 fragment(VertexOutput i) : SV_Target{
		fixed4 c = saturate(i.viewDir.y) * _TopColor
		+ (1 - saturate(abs(2 * i.viewDir.y))) * _MiddleColor
		+ saturate(-i.viewDir.y) * _BottomColor;

		//c = texCUBE(_Cube, i.texcoord);
		//c.rgb = i.viewDir;
		return c;
	}

	//Begin Surface Shader section
	//#include "UnityPBSLighting.cginc"

	//half4 LightingSimpleSkybox(SurfaceOutput s, half3 viewDir, UnityGI gi) {
	//	return 1;
	//}
	//
	//half4 LightingSimpleSkybox_Deferred(SurfaceOutput s, UnityGI gi, out half4 diffuseOcclusion, out half4 specSmoothness, out half4 normal) {
	//	return 1;
	//}
	//
	//inline void LightingSimpleSkybox_GI(SurfaceOutput s, UnityGIInput data, inout UnityGI gi) {
	//	//gi = UnityGlobal
	//}
	//
	//struct Input {
	//	float3 viewDir;
	//};
	//
	//void surf(Input IN, inout SurfaceOutput o) {
	//	o.Albedo = IN.viewDir;
	//}
	//End Surface Shader section
	ENDCG

	SubShader {
		Tags{
			"Queue" = "Background"
			"RenderType"="Background"
			"PreviewType"="Skybox"
		}

		//CGPROGRAM
		//#pragma surface surf SimpleSkybox
		//ENDCG
		Pass {
			Cull Off
			ZWrite Off
			
			CGPROGRAM
			#pragma vertex vertex
			#pragma fragment fragment

			#pragma target 3.0
			ENDCG
		}
	}

	Fallback "Diffuse"
}