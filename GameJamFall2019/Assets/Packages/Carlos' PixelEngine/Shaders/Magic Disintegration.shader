Shader "2kPS/Magic Disintegration" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_GrayscaleTex ("Grayscale Texture", 2D) = "white" {}

		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_GlowSpread ("Glow Spread", Range(0, 1)) = 0.3
		_InnerGlowColor ("Inner Glow Color", Color) = (1, 0, 0, 1)
		_OuterGlowColor ("Outer Glow Color", Color) = (1, 1, 0, 1)
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		fixed4 _Color;

		sampler2D _MainTex;
		sampler2D _GrayscaleTex;

		half _Glossiness;
		half _Metallic;

		float _TestValue;
		float _GlowSpread;
		float4 _InnerGlowColor;
		float4 _OuterGlowColor;

		struct Input {
			float2 uv_MainTex;
			float2 uv_GrayscaleTex;
			float4 vertexColor : COLOR;
		};

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		float3 rgbToHsv(float3 rgb) {
			float3 hsv;
			float cMax = max(max(rgb.r, rgb.g), rgb.b);
			float cMin = min(min(rgb.r, rgb.g), rgb.b);
			float delta = cMax - cMin;

			hsv.z = cMax; //v

			if (cMax == 0) {
				hsv.y = 0; //s
				hsv.x = 0; //h
				return hsv;
			}
			hsv.y = delta / cMax; //s

			//h
			if (rgb.r == cMax)
				hsv.x = ((rgb.g - rgb.b) / delta) % 6;
			else if (rgb.g == cMax)
				hsv.x = ((rgb.b - rgb.r) / delta) + 2;
			else
				hsv.x = ((rgb.r - rgb.g) / delta) + 4;
			hsv.x *= 60;

			return hsv;
		}

		float3 hsvToRgb(float3 hsv) {
			float3 rgb;

			float H = hsv.x / 60;
			float C = hsv.z * hsv.y;
			float X = C * (1 - abs(H % 2 - 1));
			float m = hsv.y - C;

			//Sorry for the if statements in shader code!
			if (H < 0)
				return float3(0, 0, 0);
			if (H < 1)
				rgb = float3(C, X, 0);
			else if (H < 2)
				rgb = float3(X, C, 0);
			else if (H < 3)
				rgb = float3(0, C, X);
			else if (H < 4)
				rgb = float3(0, X, C);
			else if (H < 5)
				rgb = float3(X, 0, C);
			else if (H < 6)
				rgb = float3(C, 0, X);
			else
				return float3(0, 0, 0);

			rgb += m;
			return rgb;
		}

		float3 lerpHsv(float3 a, float3 b, float t) {
			return hsvToRgb(lerp(rgbToHsv(a), rgbToHsv(b), t));
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 mainColor = tex2D(_MainTex, IN.uv_MainTex);
			clip(mainColor.a - 0.5);

			//I Use a grayscale noise texture to tell which parts of the model will disintegrate when.
			fixed4 grayColor = tex2D(_GrayscaleTex, IN.uv_GrayscaleTex);
			fixed grayValue = (grayColor.r + grayColor.g + grayColor.b) / 3;

			//The clipping (disappearing of the pixels) depends on the vertex color alpha, the magic tint alpha, and the gray value of the grayscale texture.
			//The vertex color alpha is easily manipulated for particles using the color-related modules and settings.
			//However, for non-particle meshes, the magic tint's alpha can still be used to adjust this.
			fixed clipValue = (_Color.a * IN.vertexColor.a) - grayValue;
			clip(clipValue);

			//fixed edgeProximity = max(0, (_GlowSpread - clipValue) / _GlowSpread); //This is what The World of Zero wrote, but I didn't actually understand the formula.

			//The clip value will go from 0 right near the edges to 1 completely away from the edges.
			//I want to fade a color from full strength (1) out completely (0) from the edge out to the _GlowSpread value (for example, 0.3)
			//So I need to output a value from 1 to 0 as the input (being the clipValue) ranges from 0 to _GlowSpread
			fixed edgeProximity = saturate(1 + (clipValue - 0) / (_GlowSpread - 0) * (0 - 1));
			fixed3 magicColor = IN.vertexColor.rgb * lerpHsv(_OuterGlowColor.rgb, _InnerGlowColor.rgb, edgeProximity);

			o.Albedo = (mainColor * _Color * IN.vertexColor.rgb) + (edgeProximity * magicColor); 
			o.Emission = (edgeProximity * magicColor);

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
