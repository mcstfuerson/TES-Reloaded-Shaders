#ifndef __SHADOW_EXTERIOR_DEPENDENCY__
#define __SHADOW_EXTERIOR_DEPENDENCY__

float4 TESR_SunAmount : register(c223);
float4 TESR_ShadowLightDir : register(c222);
float4 TESR_ShadowBiasForward : register(c221);
float4 TESR_ShadowCullLightPosition[18] : register(c203);

#endif // __SHADOW_EXTERIOR_DEPENDENCY__

float LookupFar(float4 ShadowPos, float2 OffSet) {
	float Shadow = tex2D(TESR_ShadowMapBufferFar, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.w, OffSet.y * TESR_ShadowData.w)).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.w) return 0.1f;
	return TESR_ShadowLightDir.w;
}

float LookupLeaves(float4 ShadowPos, float2 OffSet) {
	float Shadow = tex2D(TESR_ShadowMapBufferNear, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.z, OffSet.y * TESR_ShadowData.z)).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.z) return 0.75f;
	return TESR_ShadowLightDir.w;
}

float LookupFarLeaves(float4 ShadowPos, float2 OffSet) {
	float Shadow = tex2D(TESR_ShadowMapBufferFar, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.w, OffSet.y * TESR_ShadowData.w)).r;
	if (Shadow < ShadowPos.z - TESR_ShadowBiasForward.w) return 0.75f;
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

float GetLightAmountFarLeaves(float4 ShadowPos) {

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
			Shadow += LookupFarLeaves(ShadowPos, float2(x, y));
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

	for (y = -0.5f; y <= 0.5f; y += 0.5f) {
		for (x = -0.5f; x <= 0.5f; x += 0.5f) {
			Shadow += LookupLeaves(ShadowPos, float2(x, y));
		}
	}
	Shadow /= 9.0f;

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

float GetLightAmountGrass(float4 ShadowPos, float4 ShadowPosFar, float4 InvPos) {

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
	Shadow = Lookup(ShadowPos, float2(0.0f, 0.0f));

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