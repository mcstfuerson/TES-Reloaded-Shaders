// Image space shadows shader for Oblivion Reloaded

float4x4 TESR_WorldTransform;
float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4 TESR_CameraPosition;
float4 TESR_WaterSettings;
float4 TESR_ShadowData;
float4 TESR_ShadowLightPosition0;
float4 TESR_ShadowLightPosition1;
float4 TESR_ShadowLightPosition2;
float4 TESR_ShadowLightPosition3;
float4 TESR_ShadowLightPosition4;
float4 TESR_ShadowLightPosition5;
float4 TESR_ShadowLightPosition6;
float4 TESR_ShadowLightPosition7;
float4 TESR_ShadowLightPosition8;
float4 TESR_ShadowLightPosition9;
float4 TESR_ShadowLightPosition10;
float4 TESR_ShadowLightPosition11;
float4 TESR_ShadowCubeMapFarPlanes;
float4 TESR_ShadowCubeMapBlend;
float4 TESR_ShadowCubeMapBlend2;
float4 TESR_ShadowCubeMapBlend3;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer1 : register(s3) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer2 : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer3 : register(s5) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer4 : register(s6) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer5 : register(s7) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer6 : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer7 : register(s9) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer8 : register(s10) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer9 : register(s11) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer10 : register(s12) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer11 : register(s13) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;
static const float BIAS = 0.001f;
static const float farMaxInc = 0.2f;
static const float nearMaxInc = 1.0f;

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

float Lookup(samplerCUBE buffer, float3 LightDir, float Distance, float Blend, float2 OffSet) {
	float Shadow = texCUBE(buffer, LightDir + float3(OffSet.x * TESR_ShadowData.z, OffSet.y * TESR_ShadowData.z, 0.0f)).r;
	if (Shadow > 0.0f && Shadow < 1.0f && Shadow < Distance - BIAS) return Blend;
	return 1.0f;
}

float LookupLightAmount(samplerCUBE buffer, float4 WorldPos, float4 LightPos, float Blend) {

	float Shadow = 0.0f;
	float3 LightDir;
	float Distance;
	float x;
	float y;

	LightDir = WorldPos.xyz - LightPos.xyz;
	LightDir.z *= -1;
	Distance = length(LightDir);
	LightDir = LightDir / Distance;
	Distance = Distance / LightPos.w;

	Blend = max(1.0f - Blend, saturate(Distance) * TESR_ShadowData.y);

	for (y = -2.5f; y <= 2.5f; y += 1.0f) {
		for (x = -2.5f; x <= 2.5f; x += 1.0f) {
			Shadow += Lookup(buffer, LightDir, Distance, Blend, float2(x, y));
		}
	}
	Shadow /= 36.0f;
	return Shadow;

}

float4 Shadow(VSOUT IN) : COLOR0{

	float3 color = tex2D(TESR_RenderedBuffer, IN.UVCoord).rgb;
	float depth = readDepth(IN.UVCoord);
	float3 camera_vector = toWorld(IN.UVCoord) * depth;
	float4 world_pos = float4(TESR_CameraPosition.xyz + camera_vector, 1.0f);
	float4 pos = mul(world_pos, TESR_WorldTransform);

	float blend[12];
	float shadows[12];
	float4 lightPos[12];
	lightPos[0] = TESR_ShadowLightPosition0;
	lightPos[1] = TESR_ShadowLightPosition1;
	lightPos[2] = TESR_ShadowLightPosition2;
	lightPos[3] = TESR_ShadowLightPosition3;
	lightPos[4] = TESR_ShadowLightPosition4;
	lightPos[5] = TESR_ShadowLightPosition5;
	lightPos[6] = TESR_ShadowLightPosition6;
	lightPos[7] = TESR_ShadowLightPosition7;
	lightPos[8] = TESR_ShadowLightPosition8;
	lightPos[9] = TESR_ShadowLightPosition9;
	lightPos[10] = TESR_ShadowLightPosition10;
	lightPos[11] = TESR_ShadowLightPosition11;
	blend[0] = TESR_ShadowCubeMapBlend.x;
	blend[1] = TESR_ShadowCubeMapBlend.y;
	blend[2] = TESR_ShadowCubeMapBlend.z;
	blend[3] = TESR_ShadowCubeMapBlend.w;
	blend[4] = TESR_ShadowCubeMapBlend2.x;
	blend[5] = TESR_ShadowCubeMapBlend2.y;
	blend[6] = TESR_ShadowCubeMapBlend2.z;
	blend[7] = TESR_ShadowCubeMapBlend2.w;
	blend[8] = TESR_ShadowCubeMapBlend3.x;
	blend[9] = TESR_ShadowCubeMapBlend3.y;
	blend[10] = TESR_ShadowCubeMapBlend3.z;
	blend[11] = TESR_ShadowCubeMapBlend3.w;
	if (lightPos[0].w) shadows[0] = LookupLightAmount(TESR_ShadowCubeMapBuffer0, pos, lightPos[0], blend[0]);
	if (lightPos[1].w) shadows[1] = LookupLightAmount(TESR_ShadowCubeMapBuffer1, pos, lightPos[1], blend[1]);
	if (lightPos[2].w) shadows[2] = LookupLightAmount(TESR_ShadowCubeMapBuffer2, pos, lightPos[2], blend[2]);
	if (lightPos[3].w) shadows[3] = LookupLightAmount(TESR_ShadowCubeMapBuffer3, pos, lightPos[3], blend[3]);
	if (lightPos[4].w) shadows[4] = LookupLightAmount(TESR_ShadowCubeMapBuffer4, pos, lightPos[4], blend[4]);
	if (lightPos[5].w) shadows[5] = LookupLightAmount(TESR_ShadowCubeMapBuffer5, pos, lightPos[5], blend[5]);
	if (lightPos[6].w) shadows[6] = LookupLightAmount(TESR_ShadowCubeMapBuffer6, pos, lightPos[6], blend[6]);
	if (lightPos[7].w) shadows[7] = LookupLightAmount(TESR_ShadowCubeMapBuffer7, pos, lightPos[7], blend[7]);
	if (lightPos[8].w) shadows[8] = LookupLightAmount(TESR_ShadowCubeMapBuffer8, pos, lightPos[8], blend[8]);
	if (lightPos[9].w) shadows[9] = LookupLightAmount(TESR_ShadowCubeMapBuffer9, pos, lightPos[9], blend[9]);
	if (lightPos[10].w) shadows[10] = LookupLightAmount(TESR_ShadowCubeMapBuffer10, pos, lightPos[10], blend[10]);
	if (lightPos[11].w) shadows[11] = LookupLightAmount(TESR_ShadowCubeMapBuffer11, pos, lightPos[11], blend[11]);

	float fShadow = 1;
	float tShadow = 1;
	float tShadowMax = 1;
	float distToProximityLight;
	float farCutOffDist;
	float farClamp;
	float farScaler;
	float nearClamp;
	float nearScaler;

	for (int i = 0; i < 12; i++) {

		if (lightPos[i].w) {
			tShadowMax = shadows[i];
			for (int j = 0; j < 12; j++) {

				tShadow = shadows[i];
				if (lightPos[j].w && i != j) {
					distToProximityLight = distance(pos.xyz, lightPos[j].xyz);
					if (distToProximityLight < lightPos[j].w) {
						farCutOffDist = lightPos[j].w * 0.5f;
						farClamp = tShadow + farMaxInc;
						farScaler = (farMaxInc * 2) / (lightPos[j].w - farCutOffDist);
						if (distToProximityLight > farCutOffDist) {
							tShadow += (farCutOffDist - (distToProximityLight - farCutOffDist)) * farScaler;
							tShadow = clamp(tShadow, 0.0f, farClamp);
						}
						else {
							nearClamp = farClamp + nearMaxInc;
							nearScaler = (nearMaxInc * 2.0) / farCutOffDist;
							tShadow = farClamp;
							tShadow += (farCutOffDist - distToProximityLight) * nearScaler;
							tShadow = clamp(tShadow, 0.0f, nearClamp);
						}
					}
				}

				if (tShadow > tShadowMax) {
					tShadowMax = tShadow;
				}
			}
			tShadowMax = saturate(tShadowMax);
			fShadow *= tShadowMax;
		}
	}

	color.rgb *= fShadow * float3(0.96f, 0.98f, 1.0f);
	return float4(color, 1.0f);

}

technique {

	pass {
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Shadow();
	}

}