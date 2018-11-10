Shader "Hidden/Calculate Light Shafts" {
	
	CGINCLUDE
	#include "UnityCG.cginc"

	struct VertexInput {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct VertexOutput {
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 cameraRay : TEXCOORD1;
	};

	//Variables
	float4x4 _InverseViewMatrix;

	sampler2D _LowResDepthTexture;
	UNITY_DECLARE_SHADOWMAP(_LightShadowMap);
	float _MaxRayDistance;

	float _LightIntensity = 1;
	float3 _LightColor;
	float3 _ShadowedFogColor;

	int _FogFadesOut; //1 is true, 0 is false
	float _FogFadeOutDistance;
	float _FogMaxStrengthRadius;

	#define NUM_SAMPLES 128
	#define NUM_SAMPLES_RCP (1.0 / NUM_SAMPLES)

	VertexOutput vert(VertexInput v) {
		VertexOutput o;

		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;

		float4 clipPos = float4(v.uv * 2 - 1, 1, 1);
		o.cameraRay = mul(unity_CameraInvProjection, clipPos);
		o.cameraRay = o.cameraRay / o.cameraRay.w;

		return o;
	}

	float4 frag(VertexOutput i) : SV_Target {
		float linearDepth = Linear01Depth(tex2D(_LowResDepthTexture, i.uv));

		float4 viewPos = float4(i.cameraRay.xyz * linearDepth, 1);
		float3 worldPos = mul(_InverseViewMatrix, viewPos).xyz;

		float3 rayDir = _WorldSpaceCameraPos.xyz - worldPos;
		float rayDistance = length(rayDir);
		rayDir /= rayDistance; //This normalizes rayDir

		rayDistance = min(rayDistance, _MaxRayDistance);
		
		float stepSize = rayDistance / NUM_SAMPLES;


		float3 currentPos = worldPos;
		float3 result = 0;

		float4 viewZ = -viewPos.z;
		float4 zNear = float4(viewZ  >= _LightSplitsNear);
		float4 zFar = float4(viewZ < _LightSplitsFar);
		float4 weights = zNear * zFar;

		float3 litFogColor = _LightIntensity * _LightColor;

		float transmittance = 1;

		for (int i = 0; i < NUM_SAMPLES; i++) {
			float fogDensity = 0.3;

			float scattering = 0.25;
			float extinction = 0.01;

			float3 shadowCoord0 = mul(unity_WorldToShadow[0], float4(currentPos, 1)).xyz;
			float3 shadowCoord1 = mul(unity_WorldToShadow[1], float4(currentPos, 1)).xyz;
			float3 shadowCoord2 = mul(unity_WorldToShadow[2], float4(currentPos, 1)).xyz;
			float3 shadowCoord3 = mul(unity_WorldToShadow[3], float4(currentPos, 1)).xyz;

			float4 shadowCoord = float4(
				shadowCoord0 * weights.x
				+ shadowCoord1 * weights.y
				+ shadowCoord2 * weights.z
				+ shadowCoord3 * weights.w, 1
			);

			float shadow = UNITY_SAMPLE_SHADOW(_LightShadowMap, shadowCoord);
			//return shadow;
			transmittance *= exp(- extinction * stepSize);

			float3 fogColor = lerp(_ShadowedFogColor, litFogColor, shadow);

			result += (scattering * transmittance * stepSize) * fogColor;

			currentPos += rayDir * stepSize;

		}

		return _FogFadesOut * lerp(float4(0, 0, 0, 0), float4(result, transmittance), (_FogFadeOutDistance - clamp(linearDepth * _ProjectionParams.z - _FogMaxStrengthRadius, 0, _FogFadeOutDistance)) / _FogFadeOutDistance)
		+ (1 - _FogFadesOut) * float4(result, transmittance);
	}

	ENDCG

	SubShader {
		Pass {
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}