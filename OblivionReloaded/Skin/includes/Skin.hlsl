float halfLambert(float3 vec1, float3 vec2) {
	float product = dot(vec1, vec2);
	product *= 0.5;
	product += 0.5;
	return product;
}

float blinnPhongSpecular(float3 tsNormal, float3 tsLightDir) {
	float3 halfAngle = tsNormal + tsLightDir;
	return pow(saturate(dot(tsNormal, halfAngle)), TESR_SkinData.y);
}

float3 psSkin(float3 SkinColor, float3 LightColor, float3 tsCameraDir, float3 tsLightDir, float3 tsNormal) {

	float4 dotLN = halfLambert(tsLightDir, tsNormal) * TESR_SkinData.x;
	float3
	indirectLightComponent  = TESR_SkinData.z * max(0, dot(-tsNormal, tsLightDir));
	indirectLightComponent += TESR_SkinData.z * halfLambert(-tsCameraDir, tsLightDir);
	indirectLightComponent *= TESR_SkinData.x;
	indirectLightComponent *= pow(SkinColor, 2);

	float3 rim = (float3)(1.0f - max(0.0f, dot(tsNormal, tsCameraDir)));
	rim = pow(rim, 3);
	rim *= max(0.0f, dot(tsNormal, tsLightDir)) * LightColor;
	rim *= TESR_SkinData.w;

	float4 finalCol = dotLN * 0.5 + float4(indirectLightComponent, 1.0f);

	finalCol.rgb += finalCol.a * TESR_SkinData.x * rim;
	finalCol.rgb += finalCol.a * TESR_SkinData.x * blinnPhongSpecular(tsNormal, tsLightDir) * TESR_SkinColor.rgb * 0.05f;
	finalCol.rgb *= LightColor;
	
	return finalCol.rgb;
};