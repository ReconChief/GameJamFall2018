Shader "2kPS/Learning/Flat Shaded World Normals" {
	Properties {
		
	}

	SubShader {
		Tags { "Queue"="Transparent" }
		ZTest On
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct VertexInput {
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float4 color : COLOR;
				float3 normal : NORMAL;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float4 uv : TEXCOORD0;
				float4 color : COLOR;
				float3 worldNormal : NORMAL;
			};

			uniform float4 _WireColor;
			uniform float _BoundaryThreshold;

			VertexOutput vert(VertexInput v) {
				VertexOutput o;

				o.uv = v.uv;
				o.color = v.color;
				o.worldNormal = mul((float3x3) unity_ObjectToWorld, v.normal);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			/*Calculates a tiny difference in world position across neighboring fragments!!
			inout is required to "pass the argument by reference" basically,
			so the caller gets the changes to the worldNormal that we set in here*/
			void InitializeFragmentNormal(inout VertexOutput i) {
				float3 dpdx = ddx(i.worldPos);
				float3 dpdy = ddy(i.worldPos);
				i.worldNormal = normalize(cross(dpdy, dpdx));
			}

			fixed4 frag(VertexOutput i) : SV_Target {
				fixed4 color = 0;

				InitializeFragmentNormal(i);

				return fixed4(i.worldNormal.xyz, 1);
			}

			ENDCG
		}
	}
}