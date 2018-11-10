// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "2kPS/3D Text" {
	Properties{
		_MainTex ("Font Texture", 2D) = "white" {}
		_Color ("Text Color", Color) = (1,1,1,1)

		[HideInInspector]
		[Enum(CompareFunction)]
		_ZTestMode ("ZTest", Int) = 4 //LEqual = 4
	}

	SubShader{

		Tags {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
		}
		Lighting Off
		Cull Off
		ZTest [_ZTestMode]
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ UNITY_SINGLE_PASS_STEREO STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON
			#include "UnityCG.cginc"

			#pragma multi_compile __ BILLBOARD_EFFECT

			struct VertexInput {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform fixed4 _Color;

			VertexOutput vert(VertexInput v) {
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				#if defined (BILLBOARD_EFFECT)
					//float4 orientation = mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1));
					//float3 localOriginInViewSpace = UnityObjectToViewPos(float4(0, 0, 0, 1));
					float4 localVert = v.vertex;

					//UnityObjectToViewPos is said to be better for performance than multiplying by UNITY_MATRIX_MV
					//float4(UnityObjectToViewPos(float4(0, 0, 0, 1)), 1) is the local origin (0, 0, 0) as a position transformed into view space
					//We take that and add the distances along x and y from local space, but directly into the view space.
					//Finally, the result is carried on through the projection matrix into screen space 
					o.vertex = mul(UNITY_MATRIX_P,
						float4(UnityObjectToViewPos(float4(0, 0, 0, 1)), 1)
						+ float4(localVert.x, localVert.y, 0, 0)
						);
				#else
					o.vertex = UnityObjectToClipPos(v.vertex);
				#endif

				o.color = v.color * _Color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag(VertexOutput i) : SV_Target {
				fixed4 col = i.color;
				col.a *= tex2D(_MainTex, i.texcoord).a;
				return col;
			}
			ENDCG
		}
	}

	CustomEditor "ZTested3DTextShaderGUI"
}
