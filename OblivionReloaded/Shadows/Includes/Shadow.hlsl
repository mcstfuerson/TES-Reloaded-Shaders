#ifndef __SHADOW_EXTERIOR_DEPENDENCY__
#define __SHADOW_EXTERIOR_DEPENDENCY__

float4 TESR_SunAmount : register(c223);
float4 TESR_ShadowLightDir : register(c222);
float4 TESR_ShadowBiasForward : register(c221);
float4 TESR_ShadowCullLightPosition[18] : register(c203);

#include "../Shadows/Includes/DirectionalSamples.hlsl"

#endif // __SHADOW_EXTERIOR_DEPENDENCY__


float LookupFar(float4 ShadowPos) {
	float Shadow = tex2D(TESR_ShadowMapBufferFar, ShadowPos.xy).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.w) return TESR_ShadowData.y;
	return TESR_ShadowLightDir.w;
}

float LookupLeaves(float4 ShadowPos) {
	float Shadow = tex2D(TESR_ShadowMapBufferNear, ShadowPos.xy).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.z) return min(TESR_ShadowLightDir.w + 0.4f, TESR_ShadowData.y + 0.6f);
	return saturate(TESR_ShadowLightDir.w + 0.4f);
}

float LookupFarLeaves(float4 ShadowPos) {
	float Shadow = tex2D(TESR_ShadowMapBufferFar, ShadowPos.xy).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.w) return min(TESR_ShadowLightDir.w + 0.4f, TESR_ShadowData.y + 0.6f);
	return saturate(TESR_ShadowLightDir.w + 0.4f);
}

float GetLightAmountFar(float4 ShadowPos) {

	float Shadow = 0.0f;
	float x;
	float y;

	ShadowPos.xyz /= ShadowPos.w;
	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	for (uint s = 0; s < SAMPLE_NUM_FAR; s++) {
		ShadowPos.xy += (POISSON_SAMPLES[s] * RADIUS_FAR);
		Shadow += LookupFar(ShadowPos);
	}

	Shadow /= SAMPLE_NUM_FAR;
	return Shadow;

}

float GetLightAmountFarLeaves(float4 ShadowPos) {

	float Shadow = 0.0f;
	float x;
	float y;

	ShadowPos.xyz /= ShadowPos.w;
	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	Shadow = LookupFarLeaves(ShadowPos);

	return Shadow;

}

float Lookup(float4 ShadowPos) {
	float Shadow = tex2D(TESR_ShadowMapBufferNear, ShadowPos.xy).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.z) return TESR_ShadowData.y;
	return TESR_ShadowLightDir.w;
}

float GetLightAmount(float4 ShadowPos, float4 ShadowPosFar, float4 InvPos) {

	float Shadow = 0.0f;
	float x;
	float y;
	float distToExternalLight = 0.0f;

	ShadowPos.xyz /= ShadowPos.w;
	if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
		return GetLightAmountFar(ShadowPosFar);

	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;

	for (uint s = 0; s < SAMPLE_NUM; s++) {
		ShadowPos.xy += (POISSON_SAMPLES[s] * RADIUS);
		Shadow += Lookup(ShadowPos);
	}
	Shadow /= SAMPLE_NUM;

	for (int i = 0; i < 12; i++) {
		if (TESR_ShadowLightPosition[i].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowLightPosition[i].xyz);
			Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowLightPosition[i].w))) * TESR_SunAmount.w);
		}
	}

	for (int j = 0; j < 18; j++) {
		if (TESR_ShadowCullLightPosition[j].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowCullLightPosition[j].xyz);
			Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowCullLightPosition[j].w))) * TESR_SunAmount.w);
		}
	}
	return saturate(Shadow);

}

float GetLightAmountLeaves(float4 ShadowPos, float4 ShadowPosFar, float4 InvPos) {

	float Shadow = 0.0f;
	float x;
	float y;
	float distToExternalLight = 0.0f;

	ShadowPos.xyz /= ShadowPos.w;
	if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
		return GetLightAmountFarLeaves(ShadowPosFar);

	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	Shadow = LookupLeaves(ShadowPos);

	for (int i = 0; i < 12; i++) {
		if (TESR_ShadowLightPosition[i].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowLightPosition[i].xyz);
			Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowLightPosition[i].w))) * TESR_SunAmount.w);
		}
	}

	for (int j = 0; j < 18; j++) {
		if (TESR_ShadowCullLightPosition[j].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowCullLightPosition[j].xyz);
			Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowCullLightPosition[j].w))) * TESR_SunAmount.w);
		}
	}
	return saturate(Shadow);

}


float GetLightAmountFarGrass(float4 ShadowPos) {

	float Shadow = 0.0f;
	float x;
	float y;

	ShadowPos.xyz /= ShadowPos.w;
	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	Shadow = LookupFar(ShadowPos);
	return Shadow;

}

float GetLightAmountGrass(float4 ShadowPos, float4 ShadowPosFar, float4 InvPos) {

	float Shadow = 0.0f;
	float x;
	float y;
	float distToExternalLight = 0.0f;

	ShadowPos.xyz /= ShadowPos.w;
	if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
		return GetLightAmountFarGrass(ShadowPosFar);

	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	Shadow = Lookup(ShadowPos);

	for (int i = 0; i < 12; i++) {
		if (TESR_ShadowLightPosition[i].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowLightPosition[i].xyz);
			Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowLightPosition[i].w))) * TESR_SunAmount.w);
		}
	}

	for (int j = 0; j < 18; j++) {
		if (TESR_ShadowCullLightPosition[j].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowCullLightPosition[j].xyz);
			Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowCullLightPosition[j].w))) * TESR_SunAmount.w);
		}
	}
	return saturate(Shadow);

}