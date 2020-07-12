
static const float BIAS = 0.0005f;
static const float xPixelOffset = 1.0f / TESR_ShadowData.w;
static const float yPixelOffset = 1.0f / TESR_ShadowData.w;


float Lookup(samplerCUBE ShadowCubeMapBuffer, float3 LightDir, float Distance, float2 OffSet) {
	 
	float Shadow = texCUBE(ShadowCubeMapBuffer, LightDir + float3(OffSet.x * xPixelOffset, OffSet.y * yPixelOffset, 0.0f)).r;
	if (Shadow > 0.0f && Shadow < 1.0f && Shadow < Distance - BIAS) return TESR_ShadowData.z * saturate(Distance);
	return 1.0f;
	
}

float GetLightAmount(samplerCUBE ShadowCubeMapBuffer, float4 WorldPos, float4 LightPos, float FarPlane) {
	
	float Shadow = 0.0f;
	float3 LightDir;
	float Distance;
	float x;
	float y;
	
	LightDir = WorldPos.xyz - LightPos.xyz; 
	LightDir.z *= -1;
	Distance = length(LightDir);
	LightDir = LightDir / Distance;
	Distance = Distance / FarPlane;
	
	if (TESR_ShadowData.y == 0.0f) {
		for (y = -1.5f; y <= 1.5f; y += 1.0f) {
			for (x = -1.5f; x <= 1.5f; x += 1.0f) {
				Shadow += Lookup(ShadowCubeMapBuffer, LightDir, Distance, float2(x, y));
			}
		}
		Shadow /= 16.0f;
	}
	else if (TESR_ShadowData.y == 1.0f) {
		for (y = -1.0f; y <= 1.0f; y += 0.5f) {
			for (x = -1.0f; x <= 1.0f; x += 0.5f) {
				Shadow += Lookup(ShadowCubeMapBuffer, LightDir, Distance, float2(x, y));
			}
		}
		Shadow /= 25.0f;
	}
	else {
		for (y = -3.5f; y <= 3.5f; y += 1.0f) {
			for (x = -3.5f; x <= 3.5f; x += 1.0f) {
				Shadow += Lookup(ShadowCubeMapBuffer, LightDir, Distance, float2(x, y));
			}
		}
		Shadow /= 64.0f;
	}
	return Shadow;
	
}