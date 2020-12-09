
static const float BIAS = 0.001f;

float Lookup(samplerCUBE ShadowCubeMapBuffer, float3 LightDir, float Distance, float2 OffSet) {
	 
	float Shadow = texCUBE(ShadowCubeMapBuffer, LightDir + float3(OffSet.x * TESR_ShadowData.z, OffSet.y * TESR_ShadowData.z, 0.0f)).r;
	if (Shadow > 0.0f && Shadow < 1.0f && Shadow < Distance - BIAS) return TESR_ShadowData.y * saturate(Distance);
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
	
	if (TESR_ShadowData.x == 0.0f) {
		for (y = -0.5f; y <= 0.5f; y += 0.5f) {
			for (x = -0.5f; x <= 0.5f; x += 0.5f) {
				Shadow += Lookup(ShadowCubeMapBuffer, LightDir, Distance, float2(x, y));
			}
		}
		Shadow /= 9.0f;
	}
	else if (TESR_ShadowData.x == 1.0f) {
		for (y = -1.5f; y <= 1.5f; y += 1.0f) {
			for (x = -1.5f; x <= 1.5f; x += 1.0f) {
				Shadow += Lookup(ShadowCubeMapBuffer, LightDir, Distance, float2(x, y));
			}
		}
		Shadow /= 16.0f;
	}
	else if (TESR_ShadowData.x == 2.0f) {
		for (y = -1.0f; y <= 1.0f; y += 0.5f) {
			for (x = -1.0f; x <= 1.0f; x += 0.5f) {
				Shadow += Lookup(ShadowCubeMapBuffer, LightDir, Distance, float2(x, y));
			}
		}
		Shadow /= 25.0f;
	}
	else {
		for (y = -2.5f; y <= 2.5f; y += 1.0f) {
			for (x = -2.5f; x <= 2.5f; x += 1.0f) {
				Shadow += Lookup(ShadowCubeMapBuffer, LightDir, Distance, float2(x, y));
			}
		}
		Shadow /= 36.0f;
	}
	return Shadow;
	
}