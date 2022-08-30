float4 TESR_SunAmount : register(c223);
float4 TESR_ShadowSkinData : register(c222);

static const float BIAS = 0.001f;
static const float farMaxInc = 0.2f;
static const float nearMaxInc = 1.0f;

float Lookup(samplerCUBE buffer, float3 LightDir, float Distance, float Blend, float3 OffSet) {
	float Shadow = texCUBE(buffer, LightDir + float3(OffSet.x * TESR_ShadowCubeData.z, OffSet.y * TESR_ShadowCubeData.z, OffSet.z * TESR_ShadowCubeData.z)).r;
	if (Shadow > 0.0f && Shadow < 1.0f && Shadow < Distance - BIAS) return saturate(Blend + (1 - TESR_SunAmount.w));
	return 1.0f;
}

float LookupLightAmount(samplerCUBE buffer, float4 WorldPos, float4 LightPos) {

	float Shadow = 0.0f;
	float3 LightDir;
	float Distance;
	float x = 0;
	float y = 0;
	float z = 0;

	LightDir = WorldPos.xyz - LightPos.xyz;
	LightDir.z *= -1;
	Distance = length(LightDir);
	LightDir = LightDir / Distance;
	Distance = Distance / LightPos.w;

	for (z = -1.5; z <= 1.5; z += 1.5) {
		for (y = -1.5; y <= 1.5; y += 1.5) {
			for (x = -1.5; x <= 1.5; x += 1.5) {
				Shadow += Lookup(buffer, LightDir, Distance, saturate(Distance), float3(x, y, z));
			}
		}
	}
	Shadow /= 27.0f;

	return Shadow;

}

float GetLightAmount(float4 pos) {

	float shadows[11];
	if (TESR_ShadowLightPosition[0].w) shadows[0] = LookupLightAmount(TESR_ShadowCubeMapBuffer0, pos, TESR_ShadowLightPosition[0]);
	if (TESR_ShadowLightPosition[1].w) shadows[1] = LookupLightAmount(TESR_ShadowCubeMapBuffer1, pos, TESR_ShadowLightPosition[1]);
	if (TESR_ShadowLightPosition[2].w) shadows[2] = LookupLightAmount(TESR_ShadowCubeMapBuffer2, pos, TESR_ShadowLightPosition[2]);
	if (TESR_ShadowLightPosition[3].w) shadows[3] = LookupLightAmount(TESR_ShadowCubeMapBuffer3, pos, TESR_ShadowLightPosition[3]);
	if (TESR_ShadowLightPosition[4].w) shadows[4] = LookupLightAmount(TESR_ShadowCubeMapBuffer4, pos, TESR_ShadowLightPosition[4]);
	if (TESR_ShadowLightPosition[5].w) shadows[5] = LookupLightAmount(TESR_ShadowCubeMapBuffer5, pos, TESR_ShadowLightPosition[5]);
	if (TESR_ShadowLightPosition[6].w) shadows[6] = LookupLightAmount(TESR_ShadowCubeMapBuffer6, pos, TESR_ShadowLightPosition[6]);
	if (TESR_ShadowLightPosition[7].w) shadows[7] = LookupLightAmount(TESR_ShadowCubeMapBuffer7, pos, TESR_ShadowLightPosition[7]);
	if (TESR_ShadowLightPosition[8].w) shadows[8] = LookupLightAmount(TESR_ShadowCubeMapBuffer8, pos, TESR_ShadowLightPosition[8]);
	if (TESR_ShadowLightPosition[9].w) shadows[9] = LookupLightAmount(TESR_ShadowCubeMapBuffer9, pos, TESR_ShadowLightPosition[9]);
	if (TESR_ShadowLightPosition[10].w) shadows[10] = LookupLightAmount(TESR_ShadowCubeMapBuffer10, pos, TESR_ShadowLightPosition[10]);

	float fShadow = 1;
	float tShadow = 1;
	float tShadowMax = 1;
	float distToProximityLight;
	float farCutOffDist;
	float farClamp;
	float farScaler;
	float nearClamp;
	float nearScaler;

	for (int i = 0; i < 11; i++) {

		if (TESR_ShadowLightPosition[i].w) {
			tShadowMax = shadows[i];

			for (int j = 0; j < 11; j++) {
				tShadow = shadows[i];

				if (tShadow >= 1.0f) {
					break;
				}

				if (i == j) {
					continue;
				}

				if (TESR_ShadowLightPosition[j].w) {
					distToProximityLight = distance(pos.xyz, TESR_ShadowLightPosition[j].xyz);
					if (distToProximityLight < TESR_ShadowLightPosition[j].w && shadows[j]>shadows[i]) {
						tShadow += (1.000f - (distToProximityLight / (TESR_ShadowLightPosition[j].w)));
					}
				}

				tShadowMax = max(tShadow, tShadowMax);

			}
			tShadowMax = saturate(tShadowMax);
			fShadow *= tShadowMax;
		}
	}

	return max(0.5f, fShadow);
}

