
static const float BIAS = 0.001f;

float Lookup(samplerCUBE ShadowCubeMapBuffer, float3 LightDir, float Distance, float Blend, float2 OffSet) {

	float Shadow = texCUBE(ShadowCubeMapBuffer, LightDir + float3(OffSet.x * TESR_ShadowData.z, OffSet.y * TESR_ShadowData.z, 0.0f)).r;
	if (Shadow > 0.0f && Shadow < 1.0f && Shadow < Distance - BIAS) return Blend;
	return 1.0f;

}

float LookupLightAmount(samplerCUBE ShadowCubeMapBuffer, float4 WorldPos, float4 LightPos, float FarPlane, float Blend) {

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

	Blend = max(1.0f - Blend, saturate(Distance) * TESR_ShadowData.y);

	for (y = -0.5f; y <= 0.5f; y += 0.5f) {
		for (x = -0.5f; x <= 0.5f; x += 0.5f) {
			Shadow += Lookup(ShadowCubeMapBuffer, LightDir, Distance, Blend, float2(x, y));
		}
	}
	Shadow /= 9.0f;
	return Shadow;

}

float IsSameLight(float4 light1, float4 light2) {

	if (light1.x == light2.x) {
		if (light1.y == light2.y) {
			return true;
		}
	}
	return false;
}

float AddProximityLight(float4 WorldPos, float4 LightPos, float4 ProximityLightPos, float Shadow) {

	if (ProximityLightPos.w && !IsSameLight(ProximityLightPos, LightPos)) {
		float distToProximityLight = distance(WorldPos.xyz, ProximityLightPos.xyz);
		if (distToProximityLight < ProximityLightPos.w) {
			float farCutOffDist = ProximityLightPos.w * 0.5f;
			float farMaxInc = 0.2f;
			float farClamp = Shadow + farMaxInc;
			float farScaler = (farMaxInc * 2) / (ProximityLightPos.w - farCutOffDist);
			if (distToProximityLight > farCutOffDist) {
				Shadow += (farCutOffDist - (distToProximityLight - farCutOffDist)) * farScaler;
				Shadow = clamp(Shadow, 0.0f, farClamp);
			}
			else {
				float nearMaxInc = 1.0f;
				float nearClamp = farClamp + nearMaxInc;
				float nearScaler = (nearMaxInc * 2.0) / farCutOffDist;
				Shadow = farClamp;
				Shadow += (farCutOffDist - distToProximityLight) * nearScaler;
				Shadow = clamp(Shadow, 0.0f, nearClamp);
			}
		}
	}
	return Shadow;
}

float GetLightAmount(samplerCUBE ShadowCubeMapBuffer, float4 WorldPos, float4 LightPos, float FarPlane, float Blend) {

	float Shadow = LookupLightAmount(ShadowCubeMapBuffer, WorldPos, LightPos, FarPlane, Blend);
	float updatedShadow1 = AddProximityLight(WorldPos, LightPos, TESR_ShadowLightPosition[0], Shadow);
	float updatedShadow2 = AddProximityLight(WorldPos, LightPos, TESR_ShadowLightPosition[1], Shadow);
	float updatedShadow3 = AddProximityLight(WorldPos, LightPos, TESR_ShadowLightPosition[2], Shadow);
	float updatedShadow4 = AddProximityLight(WorldPos, LightPos, TESR_ShadowLightPosition[3], Shadow);
	float max1 = max(updatedShadow1, updatedShadow2);
	float max2 = max(updatedShadow3, updatedShadow4);
	return saturate(max(max1, max2));
}