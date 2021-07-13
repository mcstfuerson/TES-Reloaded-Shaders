// Image space shadows shader for Oblivion Reloaded

float4x4 TESR_WorldTransform;
float4x4 TESR_WorldViewProjectionTransform;
float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4x4 TESR_ShadowCameraToLightTransformNear;
float4x4 TESR_ShadowCameraToLightTransformFar;
float4 TESR_CameraPosition;
float4 TESR_WaterSettings;
float4 TESR_ShadowData;
float4 TESR_ShadowLightPosition0;
float4 TESR_ShadowLightPosition1;
float4 TESR_ShadowLightPosition2;
float4 TESR_ShadowLightPosition3;
float4 TESR_ShadowLightPosition4;
float4 TESR_ShadowLightPosition5;
float4 TESR_SunAmount;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferNear : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferFar : register(s3) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_SourceBuffer : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;
static const float BIAS = 0.001f;
static const float cullModifier = 1.0f;

struct VSOUT
{
	float4 vertPos : POSITION;
	float2 UVCoord : TEXCOORD0;
};

struct VSIN
{
	float4 vertPos : POSITION0;
	float2 UVCoord : TEXCOORD0;
};

VSOUT FrameVS(VSIN IN)
{
	VSOUT OUT = (VSOUT)0.0f;
	OUT.vertPos = IN.vertPos;
	OUT.UVCoord = IN.UVCoord;
	return OUT;
}

float readDepth(in float2 coord : TEXCOORD0)
{
	float posZ = tex2D(TESR_DepthBuffer, coord).x;
	posZ = Zmul / ((posZ * Zdiff) - farZ);
	return posZ;
}

float3 toWorld(float2 tex)
{
	float3 v = float3(TESR_ViewTransform[0][2], TESR_ViewTransform[1][2], TESR_ViewTransform[2][2]);
	v += (1 / TESR_ProjectionTransform[0][0] * (2 * tex.x - 1)).xxx * float3(TESR_ViewTransform[0][0], TESR_ViewTransform[1][0], TESR_ViewTransform[2][0]);
	v += (-1 / TESR_ProjectionTransform[1][1] * (2 * tex.y - 1)).xxx * float3(TESR_ViewTransform[0][1], TESR_ViewTransform[1][1], TESR_ViewTransform[2][1]);
	return v;
}

float LookupFar(float4 ShadowPos, float2 OffSet) {

	float Shadow = tex2D(TESR_ShadowMapBufferFar, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.w, OffSet.y * TESR_ShadowData.w)).r;
	if (Shadow < ShadowPos.z - BIAS) return TESR_ShadowData.y;
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
	for (x = -0.5f; x <= 0.5f; x += 0.5f) {
		for (y = -0.5f; y <= 0.5f; y += 0.5f) {
			Shadow += LookupFar(ShadowPos, float2(x, y));
		}
	}
	Shadow /= 9.0f;
	return Shadow;

}

float Lookup(float4 ShadowPos, float2 OffSet) {

	float Shadow = tex2D(TESR_ShadowMapBufferNear, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.z, OffSet.y * TESR_ShadowData.z)).r;
	if (Shadow < ShadowPos.z - BIAS) return TESR_ShadowData.y;
	return 1.0f;

}

float AddProximityLight(float4 WorldPos, float4 ExternalLightPos, float Shadow) {

	if (ExternalLightPos.w) {
		float distToExternalLight = distance(WorldPos.xyz, ExternalLightPos.xyz);
		if (distToExternalLight < ExternalLightPos.w) {
			Shadow += (saturate(1.000f - (distToExternalLight / (ExternalLightPos.w))) * TESR_SunAmount.w);
		}
	}
	return Shadow;
}


float GetLightAmount(float4 WorldPos, float4 ShadowPos, float4 ShadowPosFar) {

	float Shadow = 0.0f;
	float x;
	float y;

	ShadowPos.xyz /= ShadowPos.w;
	if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
		return GetLightAmountFar(ShadowPosFar);

	ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
	ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;
	for (x = -0.5f; x <= 0.5f; x += 0.5f) {
		for (y = -0.5f; y <= 0.5f; y += 0.5f) {
			Shadow += Lookup(ShadowPos, float2(x, y));
		}
	}
	Shadow /= 9.0f;

	Shadow = AddProximityLight(WorldPos, TESR_ShadowLightPosition0, Shadow);
	Shadow = AddProximityLight(WorldPos, TESR_ShadowLightPosition1, Shadow);
	Shadow = AddProximityLight(WorldPos, TESR_ShadowLightPosition2, Shadow);
	Shadow = AddProximityLight(WorldPos, TESR_ShadowLightPosition3, Shadow);
	Shadow = AddProximityLight(WorldPos, TESR_ShadowLightPosition4, Shadow);
	Shadow = AddProximityLight(WorldPos, TESR_ShadowLightPosition5, Shadow);
	return saturate(Shadow);

}

float4 Shadow(VSOUT IN) : COLOR0{

	float3 color = tex2D(TESR_RenderedBuffer, IN.UVCoord).rgb;
	float depth = readDepth(IN.UVCoord);
	float3 camera_vector = toWorld(IN.UVCoord) * depth;
	float4 world_pos = float4(TESR_CameraPosition.xyz + camera_vector, 1.0f);

	if (world_pos.z > TESR_WaterSettings.x) {
		float4 pos = mul(world_pos, TESR_WorldViewProjectionTransform);
		float4 world_pos_trans = mul(world_pos, TESR_WorldTransform);
		float4 ShadowNear = mul(pos, TESR_ShadowCameraToLightTransformNear);
		float4 ShadowFar = mul(pos, TESR_ShadowCameraToLightTransformFar);
		float Shadow = GetLightAmount(world_pos_trans, ShadowNear, ShadowFar);
		color.rgb *= Shadow * float3(1.0f, 1.0f, 1.0f);
	}
	return float4(color, 1.0f);

}

technique {

	pass {
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Shadow();
	}

}
