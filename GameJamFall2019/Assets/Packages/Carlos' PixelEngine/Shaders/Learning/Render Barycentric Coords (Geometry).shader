Shader "2kPS/Learning/Render Barycentric Coords (Geometry)" {
	Properties {
		
	}

	SubShader {
		Tags { "Queue"="Transparent" }
		ZTest On
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			CGPROGRAM
			#pragma target 4.0 //Geometry shaders require at least shader model 4.0

			#pragma vertex vert
			#pragma geometry geometry //Omg like hi!?! I love you!
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

			struct GeometryOutput {
				VertexOutput data;
				float2 barycentricCoordinates : TEXCOORD9;
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

			//Must declare how many vertices it will output -- this num can vary, so we must provide a maximum
			[maxvertexcount(3)]
			void geometry(triangle VertexOutput i[3], inout TriangleStream<GeometryOutput> stream) {
				GeometryOutput g0, g1, g2;
				g0.data = i[0];
				g1.data = i[1];
				g2.data = i[2];

				//It doesn't matter which vertex gets what coordinate, as long as they are valid.
				//The 3rd coordinate w is 1 - u - v, so let's only store and have the first 2 coordinates interpolated.
				g0.barycentricCoordinates = float2(1, 0);
				g1.barycentricCoordinates = float2(0, 1);
				g2.barycentricCoordinates = float2(0, 0);
				
				//Accessing 3 vertices at the same time is like heaven... this is what that looks like:
				float3 triWorldNormal = normalize(cross(i[1].worldPos - i[0].worldPos, i[2].worldPos - i[0].worldPos));
				i[0].worldNormal = triWorldNormal;
				i[1].worldNormal = triWorldNormal;
				i[2].worldNormal = triWorldNormal;

				//We need to put the data back into the triangle stream :)
				stream.Append(g0);
				stream.Append(g1);
				stream.Append(g2);
			}

			fixed4 frag(GeometryOutput g) : SV_Target {
				fixed4 color = 0;

				return fixed4(g.barycentricCoordinates.xy, 1 - g.barycentricCoordinates.x - g.barycentricCoordinates.y, 1);
			}

			ENDCG
		}
	}
}