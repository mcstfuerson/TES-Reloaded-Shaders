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
float4 TESR_ShadowCubeMapFarPlanes;
float4 TESR_ShadowCubeMapBlend;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer1 : register(s3) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer2 : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer3 : register(s5) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;
static const float BIAS = 0.001f;

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
	float updatedShadow1 = AddProximityLight(WorldPos, LightPos, TESR_ShadowLightPosition0, Shadow);
	float updatedShadow2 = AddProximityLight(WorldPos, LightPos, TESR_ShadowLightPosition1, Shadow);
	float updatedShadow3 = AddProximityLight(WorldPos, LightPos, TESR_ShadowLightPosition2, Shadow);
	float updatedShadow4 = AddProximityLight(WorldPos, LightPos, TESR_ShadowLightPosition3, Shadow);
	float max1 = max(updatedShadow1, updatedShadow2);
	float max2 = max(updatedShadow3, updatedShadow4);
	return saturate(max(max1, max2));
}

float4 Shadow(VSOUT IN) : COLOR0{

	float3 color = tex2D(TESR_RenderedBuffer, IN.UVCoord).rgb;
	float depth = readDepth(IN.UVCoord);
	float3 camera_vector = toWorld(IN.UVCoord) * depth;
	float4 world_pos = float4(TESR_CameraPosition.xyz + camera_vector, 1.0f);

	float4 pos = mul(world_pos, TESR_WorldTransform);
	float Shadow = GetLightAmount(TESR_ShadowCubeMapBuffer0, pos, TESR_ShadowLightPosition0, TESR_ShadowCubeMapFarPlanes.x, TESR_ShadowCubeMapBlend.x);
	if (TESR_ShadowLightPosition1.w) Shadow *= GetLightAmount(TESR_ShadowCubeMapBuffer1, pos, TESR_ShadowLightPosition1, TESR_ShadowCubeMapFarPlanes.y, TESR_ShadowCubeMapBlend.y);
	if (TESR_ShadowLightPosition2.w) Shadow *= GetLightAmount(TESR_ShadowCubeMapBuffer2, pos, TESR_ShadowLightPosition2, TESR_ShadowCubeMapFarPlanes.z, TESR_ShadowCubeMapBlend.z);
	if (TESR_ShadowLightPosition3.w) Shadow *= GetLightAmount(TESR_ShadowCubeMapBuffer3, pos, TESR_ShadowLightPosition3, TESR_ShadowCubeMapFarPlanes.w, TESR_ShadowCubeMapBlend.w);
	color.rgb *= Shadow * float3(0.96f, 0.98f, 1.0f);
	return float4(color, 1.0f);

}

technique {

	pass {
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Shadow();
	}

}
