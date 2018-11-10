Shader "2kPS/Triplanar Textures" {
	Properties {
		_TopTex ("Top Texture", 2D) = "white" {}
		_BottomTex ("Bottom Texture", 2D) = "white" {}
		_SideTex ("Side Texture", 2D) = "white" {}

		//[NoScaleOffset] _TopNormalMap ("Top Normal Map", 2D) = "bump" {}
		//[NoScaleOffset] _BottomNormalMap ("Bottom Normal Map", 2D) = "bump" {}
		//[NoScaleOffset] _SideNormalMap ("Side Normal Map", 2D) = "bump" {}
	}

	SubShader {
		Tags {
			"RenderType" = "Opaque"
		}
		LOD 200

		CGPROGRAM
		//#pragma surface surface Standard vertex:vertex fullforwardshadows
		#pragma surface surface Standard fullforwardshadows
		#pragma target 3.0
		//#pragma shader_feature __ NORMAL_MAP

		uniform sampler2D _TopTex;
		uniform sampler2D _BottomTex;
		uniform sampler2D _SideTex;

		uniform float4 _TopTex_ST;
		uniform float4 _BottomTex_ST;
		uniform float4 _SideTex_ST;

		//#if NORMAL_MAP
			//uniform sampler2D _TopNormalMap;
			//uniform sampler2D _BottomNormalMap;
			//uniform sampler2D _SideNormalMap;
		//#endif

		struct VertexInput {
			float4 vertex : POSITION;
			float3 normal : NORMAL;

			//float2 rawUv : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1; //Baked GI
			float2 texcoord2 : TEXCOORD2; //Realtime GI
		};

		struct Input {
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA

			//float2 rawUv : TEXCOORD0;
		};

		void vertex(inout VertexInput v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);

			//o.rawUv = v.rawUv;
		}

		void surface(Input IN, inout SurfaceOutputStandard o) {
			//o.Normal = fixed3(0, 0, 1);

			float3 objNormal = mul((float3x3) unity_WorldToObject, IN.worldNormal);
			//float3 objNormal = mul((float3x3) unity_WorldToObject, WorldNormalVector(IN, fixed3(0, 0, 1)));
			float3 objPos = mul(unity_WorldToObject, float4(IN.worldPos, 1)).xyz;
			
			float2 uvX = float2(objPos.z, objPos.y);
			float2 uvY = float2(objPos.x, objPos.z);
			float2 uvZ = float2(-objPos.x, objPos.y);
			
			float2 uvTY = TRANSFORM_TEX(uvY, _TopTex);
			float2 uvTy = TRANSFORM_TEX(uvY, _BottomTex);
			float2 uvTX = TRANSFORM_TEX(uvX, _SideTex);
			float2 uvTZ = TRANSFORM_TEX(uvZ, _SideTex);
			
			fixed topWeight = max(0, objNormal.y);
			fixed bottomWeight = max(0, -objNormal.y);
			fixed sideXWeight = abs(objNormal.x);
			fixed sideZWeight = abs(objNormal.z);
			
			fixed3 top = topWeight * tex2D(_TopTex, uvTY);
			fixed3 bottom = bottomWeight * tex2D(_BottomTex, uvTy);
			fixed3 side = sideXWeight * tex2D(_SideTex, uvTX)
				+ sideZWeight * tex2D(_SideTex, uvTZ);
			
			o.Albedo = top + bottom + side;

			//#if NORMAL_MAP
			//o.Normal = 2 * (topWeight * lerp(fixed3(0, 0, 1), UnpackNormal(tex2D(_TopNormalMap, uvTY)), topWeight)
			//	+ bottomWeight * lerp(fixed3(0, 0, 1), UnpackNormal(tex2D(_BottomNormalMap, uvTy)), bottomWeight)
			//	+ sideXWeight * lerp(fixed3(0, 0, 1), UnpackNormal(tex2D(_SideNormalMap, uvTX)), sideXWeight)
			//	+ sideZWeight * lerp(fixed3(0, 0, 1), UnpackNormal(tex2D(_SideNormalMap, uvTZ)), sideZWeight));
			//#endif

		}

		ENDCG
	}
}