static const float BIAS = 0.001f;
static const float cullModifier = 1.0f;

float LookupFar(float4 ShadowPos, float2 OffSet) {

	float Shadow = tex2D(TESR_ShadowMapBufferFar, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.w, OffSet.y * TESR_ShadowData.w)).r;
	if (Shadow < ShadowPos.z - BIAS) return 0.1f;
	return 1.0f;

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
	if (Shadow < ShadowPos.z - BIAS) return 0.1f;
	return 1.0f;

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
				Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowLightPosition[j].w))) * cullModifier);
			}
		}
	}
	return saturate(Shadow);

}

float GetLightAmountSkinFar(float4 ShadowPos) {

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
			Shadow += Lookup(ShadowPos, float2(x, y));
		}
	}
	Shadow /= 9.0f;
	return Shadow;

}

float GetLightAmountSkin(float4 ShadowPos, float4 ShadowPosFar, float4 InvPos) {

	float Shadow = 0.0f;
	float x;
	float y;
	float distToExternalLight = 0.0f;

	ShadowPos.xyz /= ShadowPos.w;
	if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
		return GetLightAmountSkinFar(ShadowPosFar);

	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	for (y = -0.1f; y <= 0.1f; y += 0.05f) {
		for (x = -0.1f; x <= 0.1f; x += 0.05f) {
			Shadow += Lookup(ShadowPos, float2(x, y));
		}
	}
	Shadow /= 25.0f;

	for (int j = 0; j < 6; j++) {
		if (TESR_ShadowLightPosition[j].w) {
			distToExternalLight = distance(InvPos.xyz, TESR_ShadowLightPosition[j].xyz);
			if (distToExternalLight < TESR_ShadowLightPosition[j].w) {
				Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowLightPosition[j].w))) * cullModifier);
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
				Shadow += (saturate(1.000f - (distToExternalLight / (TESR_ShadowLightPosition[j].w))) * cullModifier);
			}
		}
	}
	return saturate(Shadow);

}