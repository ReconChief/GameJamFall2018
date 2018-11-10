Shader "2kPS/Custom Tessellated Shader" {
	Properties {
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo", 2D) = "white" {}
		_UniformTessFactor ("Uniform Tesselation Factor", Range(1, 16)) = 1
	}

	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex tessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain

			#pragma target 4.6

			#include "UnityCG.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _UniformTessFactor;

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput {
				float4 vertex : SV_POSITION;
				float3 worldNormal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			VertexInput tessVert(VertexInput v) {
				return v;
			}

			VertexOutput vert(VertexInput v) {
				VertexOutput o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}

			struct TessellationFactors {
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			[UNITY_domain("tri")] //Says we're working with triangles -- The hull and domain shader act on the same domain (input) which is a triangle!!
			[UNITY_outputcontrolpoints(3)] //Says we're outputting 3 control points per patch, one per vertex of the triangle
			[UNITY_outputtopology("triangle_cw")] //The newly cut triangles will be in clockwise order

			//Possible modes are: integer, fractional_odd, fractional_even -- fractional_odd is most often used cause it supports a factor of 1, while fractional_even is forced to use a minimum level of 2
			[UNITY_partitioning("fractional_odd")] //How the GPU should cut up the patch -- integer mode for now
			[UNITY_patchconstantfunc("patchConstantFunction")] //How many parts the patch should be cut -- may cary, can use a function to evaluate this (aka a patch constant function)
			VertexInput hull(InputPatch<VertexInput, 3> patch, uint id : SV_OutputControlPointID) {
				return patch[id];
			}

			/*
			Even though the tessellation stage in the hull shader determines how the patch should
			be subdivided, it DOESN'T generate any new vertices. Instead, it comes up with barycentric
			coordinates for those new theoretical vertices at that point.

			It's up to the domain shader to use those coordinates to derive the actual final vertices.
			To make this possible, the domain shader is called once per vertex, and is provided the barycentric
			coordinates for it. The barycentric coords are given the SV_DomainLocation semantic.
			*/

			//Takes an input parameter and outputs the tessellation factors -- 3 for the 3 edges of the triangle, and 1 for the inside of the tri
			TessellationFactors patchConstantFunction(InputPatch<VertexInput, 3> patch) {
				TessellationFactors f;

				//Value of 1 instructs the tessellation stage NOT to subdivide the patch
				f.edge[0] = _UniformTessFactor;
				f.edge[1] = _UniformTessFactor;
				f.edge[2] = _UniformTessFactor;
				f.inside = _UniformTessFactor;
				return f;
			}

			#define DOMAIN_INTERPOLATE(vertexData, fieldName, bCoords) \
				vertexData.fieldName = patch[0].fieldName * bCoords.x + patch[1].fieldName * bCoords.y + patch[2].fieldName * bCoords.z; \

			//Inside the domain shader, we have to generate the final vertex data. The "bCoords" stands for the barycentric coordinates.
			[UNITY_domain("tri")]
			VertexOutput domain(TessellationFactors f,
				OutputPatch<VertexInput, 3> patch,
				float3 bCoords : SV_DomainLocation) {
				VertexInput v;

				//We're going to have to interpolate all the vertex data the same way with barycentric coordinates... so let's make a macro for that
				//v.vertex = patch[0].vertex * bCoords.x + patch[1].vertex * bCoords.y + patch[2].vertex * bCoords.z;
				DOMAIN_INTERPOLATE(v, vertex, bCoords);
				DOMAIN_INTERPOLATE(v, normal, bCoords);
				DOMAIN_INTERPOLATE(v, uv, bCoords);

				/*The domain shader will then send stuff to either the geometry program or the interpolator after this stage.
				But these stages need the interpolated data, just like after the vertex program! So the vertex program
				actually needs to process this stuff, and we invoke the vertex program in the domain shader,
				THEN return THAT result!!*/
				return vert(v);
			}

			fixed4 frag(VertexOutput i) : SV_Target {
				fixed4 color = _Color * tex2D(_MainTex, i.uv) * max(0, dot(float3(0, 1, 0), i.worldNormal));

				return color;
			}




			ENDCG
			
		}
	}
	
}