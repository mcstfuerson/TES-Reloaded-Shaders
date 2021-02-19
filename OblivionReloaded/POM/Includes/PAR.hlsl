#define	INTERPOLATE_SIMPLIFIED
#define nolight

float4 TESR_ParallaxData : register(c8);
float4 TESR_TextureData : register(c9);

#define	g_fHeightMapScale	TESR_ParallaxData.x
#define	g_fShadowSoftening	TESR_ParallaxData.y
#define	g_nMinSamples		TESR_ParallaxData.z
#define	g_nMaxSamples		TESR_ParallaxData.w

#define	g_nLODThreshold 10
#define	bBlendThreshold	(g_nLODThreshold / 2)
#define	bBlendRange		(g_nLODThreshold - bBlendThreshold)
#define	bBlendMIPs		(fMipLevelFrac = fMipLevel - (float)bBlendThreshold) > 0
#define	bBlendFraction	(fMipLevelFrac / bBlendRange)

void psParallax(in float2 BaseUV, in float3 CameraDir, inout float2 uv, inout float ao) {}