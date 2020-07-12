
static const float BIAS = 0.0005f;
static const float xPixelOffset = 1.0f / TESR_ShadowData.w;
static const float yPixelOffset = 1.0f / TESR_ShadowData.w;

float Lookup(float4 ShadowPos, float2 OffSet) {
	
	float Shadow = tex2D(TESR_ShadowMapBuffer, ShadowPos.xy + float2(OffSet.x * xPixelOffset, OffSet.y * yPixelOffset)).r;
	if (Shadow < ShadowPos.z - BIAS) return TESR_ShadowData.z;
	return 1;
	
}

float GetLightAmount(float4 ShadowPos) {
					
	float Shadow = 0.0f;
	float x;
	float y;
	
	ShadowPos.xyz /= ShadowPos.w;
    if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
        ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
        ShadowPos.z <  0.0f || ShadowPos.z > 1.0f)
		return 1.0f;
 
    ShadowPos.x = ShadowPos.x *  0.5f + 0.5f;
    ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	if (TESR_ShadowData.y == 0.0f) {
		for (y = -1.5f; y <= 1.5f; y += 1.0f) {
			for (x = -1.5f; x <= 1.5f; x += 1.0f) {
				Shadow += Lookup(ShadowPos, float2(x, y));
			}
		}
		Shadow /= 16.0f;
	}
	else if (TESR_ShadowData.y == 1.0f) {
		for (y = -1.0f; y <= 1.0f; y += 0.5f) {
			for (x = -1.0f; x <= 1.0f; x += 0.5f) {
				Shadow += Lookup(ShadowPos, float2(x, y));
			}
		}
		Shadow /= 25.0f;
	}
	else {
		for (y = -3.5f; y <= 3.5f; y += 1.0f) {
			for (x = -3.5f; x <= 3.5f; x += 1.0f) {
				Shadow += Lookup(ShadowPos, float2(x, y));
			}
		}
		Shadow /= 64.0f;
	}
	return Shadow;
	
}

float GetLightAmountSkin(float4 ShadowPos) {
					
	float Shadow = 0.0f;
	float x;
	float y;
	
	ShadowPos.xyz /= ShadowPos.w;
    if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
        ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
        ShadowPos.z <  0.0f || ShadowPos.z > 1.0f)
		return 1.0f;
 
    ShadowPos.x = ShadowPos.x *  0.5f + 0.5f;
    ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	for (y = -0.1f; y <= 0.1f; y += 0.05f) {
		for (x = -0.1f; x <= 0.1f; x += 0.05f) {
			Shadow += Lookup(ShadowPos, float2(x, y));
		}
	}
	Shadow /= 25.0f;
	return Shadow;
	
}