// Image space shadows shader for Oblivion Reloaded

float4x4 TESR_WorldTransform;
float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4 TESR_CameraPosition;
float4 TESR_WaterSettings;
float4 TESR_ShadowCubeData;
float4 TESR_ShadowLightPosition0;
float4 TESR_ShadowLightPosition1;
float4 TESR_ShadowLightPosition2;
float4 TESR_ShadowCubeMapFarPlanes;
float4 TESR_SunAmount;
float4 TESR_ShadowBiasDeferred;
float4 TESR_FogData;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer1 : register(s3) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer2 : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;
static const float BIAS = 0.001f;
static const float farMaxInc = 0.2f;
static const float nearMaxInc = 1.0f;

#include "../Shadows/Includes/PointSamples.hlsl"

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

float Lookup(samplerCUBE buffer, float3 LightDir, float Distance, float Blend) {
	float Shadow = texCUBE(buffer, LightDir).r;
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

	float3 ShadowCoord = LightDir;
	float darkness = saturate(Distance);
	float darknessStart = 0.9f;
	float darknessEnd = 0.75f;

	float modifier = smoothstep(darknessEnd, darknessStart, darkness);
	float darknessRange = 1 - TESR_ShadowCubeData.y;
	float darknessMod = 1 - ((1 - modifier) * darknessRange);
	darkness = darkness * darknessMod;

	for (uint i = 0; i < SAMPLE_NUM_SKIN; i++) {
		Shadow += Lookup(buffer, (ShadowCoord + (POISSON_SAMPLES_SKIN[i] * .004)), Distance, darkness);
	}

	Shadow /= SAMPLE_NUM_SKIN;

	return max(0.5f, Shadow);
}

float4 Shadow(VSOUT IN) : COLOR0{

	float3 color = tex2D(TESR_RenderedBuffer, IN.UVCoord).rgb;

	if (length(color) > 1.0f) {
		return float4(color, 1.0f);
	}

	float depth = readDepth(IN.UVCoord);
	float3 camera_vector = toWorld(IN.UVCoord) * depth;
	float4 world_pos = float4(TESR_CameraPosition.xyz + camera_vector, 1.0f);
	float4 pos = mul(world_pos, TESR_WorldTransform);
	float fogCoeff = (saturate((distance(world_pos, TESR_CameraPosition.xyz) - ((TESR_FogData.y - 3000))) / 1000)) + 1.0f;

	float shadows[3];
	shadows[0] = 1.0f;
	shadows[1] = 1.0f;
	shadows[2] = 1.0f;
	float4 lightPos[3];
	lightPos[0] = TESR_ShadowLightPosition0;
	lightPos[1] = TESR_ShadowLightPosition1;
	lightPos[2] = TESR_ShadowLightPosition2;
	if (lightPos[0].w) shadows[0] = LookupLightAmount(TESR_ShadowCubeMapBuffer0, pos, lightPos[0]);
	if (lightPos[1].w) shadows[1] = LookupLightAmount(TESR_ShadowCubeMapBuffer1, pos, lightPos[1]);
	if (lightPos[2].w) shadows[2] = LookupLightAmount(TESR_ShadowCubeMapBuffer2, pos, lightPos[2]);

	float fShadow = 1;
	float tShadow = 1;
	float tShadowMax = 1;
	float distToProximityLight;
	float farCutOffDist;
	float farClamp;
	float farScaler;
	float nearClamp;
	float nearScaler;

	for (int i = 0; i < 3; i++) {

		if (lightPos[i].w) {
			tShadowMax = shadows[i];
			for (int j = 0; j < 3; j++) {

				tShadow = shadows[i];

				if (tShadow >= 1.0f) {
					break;
				}

				if (i == j) {
					continue;
				}

				if (lightPos[j].w) {
					distToProximityLight = distance(pos.xyz, lightPos[j].xyz);
					tShadow += (1.000f - (distToProximityLight / (lightPos[j].w)));
				}

				tShadowMax = max(tShadow, tShadowMax);
			}
			tShadowMax = saturate(tShadowMax);
			fShadow *= tShadowMax;
		}
	}

	color.rgb *= saturate(fShadow * fogCoeff);
	return float4(color, 1.0f);

}

technique {

	pass {
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Shadow();
	}

}