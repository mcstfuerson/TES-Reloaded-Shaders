#ifndef __SHADOW_EXTERIOR_DEPENDENCY__
#define __SHADOW_EXTERIOR_DEPENDENCY__

float4 TESR_SunAmount : register(c223);
float4 TESR_ShadowLightDir : register(c222);
float4 TESR_ShadowBiasForward : register(c221);

#endif // __SHADOW_EXTERIOR_DEPENDENCY__

float LookupFar(float4 ShadowPos, float2 OffSet) {
	float Shadow = tex2D(TESR_ShadowMapBufferFar, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.w, OffSet.y * TESR_ShadowData.w)).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.w) return 0.1f;
	return TESR_ShadowLightDir.w;
}

float GetLightAmountFar(float4 ShadowPos) {

	float Shadow = 0.0f;
	float x;
	float y;

	ShadowPos.xyz /= ShadowPos.w;
	if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
		return 1.0f;

	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	for (y = -0.5f; y <= 0.5f; y += 0.5f) {
		for (x = -0.5f; x <= 0.5f; x += 0.5f) {
			Shadow += LookupFar(ShadowPos, float2(x, y));
		}
	}
	Shadow /= 9.0f;
	return Shadow;

}

float Lookup(float4 ShadowPos, float2 OffSet) {
	float Shadow = tex2D(TESR_ShadowMapBufferNear, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.z, OffSet.y * TESR_ShadowData.z)).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.z) return 0.1f;
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

	for (y = -0.5f; y <= 0.5f; y += 0.5f) {
		for (x = -0.5f; x <= 0.5f; x += 0.5f) {
			Shadow += Lookup(ShadowPos, float2(x, y));
		}
	}
	Shadow /= 9.0f;

	for (int j = 0; j < 6; j++) {
		if (TESR_ShadowLightPosition[j].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowLightPosition[j].xyz);
			if (distToExternalLight < TESR_ShadowLightPosition[j].w) {
				Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowLightPosition[j].w))) * TESR_SunAmount.w);
			}
		}
	}
	return saturate(Shadow);

}

float GetLightAmountGrass(float4 ShadowPos, float4 InvPos) {

	float Shadow = 0.0f;
	float x;
	float y;
	float distToExternalLight = 0.0f;

	ShadowPos.xyz /= ShadowPos.w;
	if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
		return 1.0f;

	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	Shadow = Lookup(ShadowPos, float2(0.0f, 0.0f));

	for (int j = 0; j < 6; j++) {
		if (TESR_ShadowLightPosition[j].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowLightPosition[j].xyz);
			if (distToExternalLight < TESR_ShadowLightPosition[j].w) {
				Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowLightPosition[j].w))) * TESR_SunAmount.w);
			}
		}
	}
	return saturate(Shadow);

}