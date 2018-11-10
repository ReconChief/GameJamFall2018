Shader "2kPS/Learning/Wireframe (Geometry)" {
	Properties {
		_WireColor ("Wireframe Color", Color) = (0, 0, 0, 0)
		_WireThicknessFactor ("Wireframe Thickness", Range(0, 5)) = 2
	}

	SubShader {
		Tags { "Queue"="Transparent" }
		Cull Back
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
			uniform float _WireThicknessFactor;

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
				g0.data.worldNormal = triWorldNormal;
				g1.data.worldNormal = triWorldNormal;
				g2.data.worldNormal = triWorldNormal;

				//We need to put the data back into the triangle stream :)
				stream.Append(g0);
				stream.Append(g1);
				stream.Append(g2);
			}

			fixed4 frag(GeometryOutput g) : SV_Target {
				float3 bCoords = float3(g.barycentricCoordinates.xy, 1 - g.barycentricCoordinates.x - g.barycentricCoordinates.y);

				//The distance to the closest edge can be gauged by the smallest barycentric coordinate!
				float minCoord = min(min(bCoords.x, bCoords.y), bCoords.z);

				//return fixed4(minCoord, minCoord, minCoord, 1);

				//From 0 to 0.05 -- that's where the edge should be rendered, when the lowest bCoord is in that range.
				//When the minCoord goes above that (like up to 0.333) it'll be clamped to the highest output value of 1 out of the function's range of [0, 1].
				/*float adjustedValue = smoothstep(0, 0.05, minCoord);
				//float adjustedValue = saturate(lerp(0, 1, minCoord / 0.05)) //(minCoord - 0) / (0.05 - 0);
				return fixed4(adjustedValue, adjustedValue, adjustedValue, 1);*/

				//This is almost the same as the commented chunk above, but it uses the delta as its maximum barycentric distance from the nearest edge
				//This "maximum" is the maximum barycentric distance that the wireframe line extends to!
				//The delta is the sum of the screen space partial derivatives of the minimum barycentric coordinate with the x and y screen coordinates.
				//So the partial derivative gets the difference between this fragment's minCoord and the neighboring fragment's minCoord.
				/*float delta = (abs(ddx(minCoord)) + abs(ddy(minCoord))) / 2; //maximum difference of 0.33 each way -- I gotta divide by 2 to make sure I don't get differences of up to 0.666 -- which would no longer make sense with barycentric "units".
				float factor01 = smoothstep(0, delta, minCoord);
				//float factor01 = saturate(lerp(0, 1, minCoord / delta)); //(minCoord - 0) / (delta - 0)
				return fixed4(lerp(_WireColor.rgb, g.data.worldNormal.xyz, factor01), 1);*/


				//"We use the derivatives of the individual barycentric coordinates, blend them separately, and then grab the minimum after that"
				float3 deltas = (abs(ddx(bCoords)) + abs(ddy(bCoords))) / 2;
				bCoords = smoothstep(0, _WireThicknessFactor * deltas, bCoords);
				minCoord = min(min(bCoords.x, bCoords.y), bCoords.z);

				return fixed4(lerp(_WireColor.rgb, g.data.worldNormal.xyz, minCoord), 1);
			}

			ENDCG
		}
	}
}