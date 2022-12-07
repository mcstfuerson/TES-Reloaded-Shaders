// GodRays full screen shader for Oblivion/Skyrim Reloaded, adapted for Masser moon

float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4 TESR_ReciprocalResolution;
float4 TESR_CameraForward;
float4 TESR_MasserDirection;
float4 TESR_MasserAmount;
float4 TESR_MasserRaysRay;
float4 TESR_MasserRaysRayColor;
float4 TESR_MasserRaysData;
float4 TESR_RaysPhaseCoeff;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_SourceBuffer : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float4 sp = TESR_MasserDirection * 999999;
static const float2 texproj = 0.5f * float2(1.0f, -TESR_ReciprocalResolution.y / TESR_ReciprocalResolution.x) / tan(radians(TESR_ReciprocalResolution.w) * 0.5f);
static const float d = dot(TESR_CameraForward, sp);
static const float2 sunview_v = mul(sp / d, TESR_ViewTransform).xy;
static const float2 sunview = float2(0.5f, 0.5f) + sunview_v.xy * texproj;
static const float raspect = 1.0f / TESR_ReciprocalResolution.z;
static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float forward = dot(-TESR_MasserDirection, TESR_CameraForward);
static const int ShaftPasses = int(TESR_MasserRaysData.x);

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
	return (2.0f * nearZ) / (nearZ + farZ - posZ * (farZ - nearZ));
}

float4 DepthSkyMask(VSOUT IN) : COLOR0
{
	float3 sky = 0.0f;

	if (forward < 0.0f) {
		float depth = readDepth(IN.UVCoord);
		depth = step(0.99f, depth);
		sky = tex2D(TESR_SourceBuffer, IN.UVCoord).rgb * depth * TESR_MasserRaysData.y;
	}
	return float4(sky, 1.0f);
}

float3 BlendSoftLight(float3 a, float3 b)
{
	float3 c = 2.0f * a * b * (1.0f + a * (1.0f - b));
	float3 a_sqrt = sqrt(a);
	float3 d = (a + b * (a_sqrt - a)) * 2.0f - a_sqrt;
	return (b < 0.5f) ? c : d;
}

float4 LightShaftSunCombine(VSOUT IN) : COLOR0
{
	float2 DeltaTexCoord = IN.UVCoord - sunview.xy;
	float screendist = length(DeltaTexCoord * float2(1.0f, raspect));
	DeltaTexCoord /= screendist;
	DeltaTexCoord *= 0.5f * min(0.3f, screendist) * (1.0f / TESR_MasserRaysData.x) * TESR_MasserRaysRay.z;
	float3 Color = tex2D(TESR_RenderedBuffer, IN.UVCoord).rgb;
	float3 ori = tex2D(TESR_SourceBuffer, IN.UVCoord).rgb;
	float IlluminationDecay = 1.0f;
	float2 samplepos = IN.UVCoord;

	[unroll(50)]
	for (int i = 0; i < ShaftPasses; i++)
	{
		samplepos -= DeltaTexCoord;
		float3 Sample = tex2D(TESR_RenderedBuffer, samplepos).rgb;
		Sample *= IlluminationDecay * TESR_MasserRaysRay.w;
		Color += Sample;
		IlluminationDecay *= TESR_MasserRaysRay.y;
	}
	Color *= TESR_MasserRaysRay.x / TESR_MasserRaysData.x;
	
	if (forward > 0.0f) Color = 0.0f;

	float Amount = saturate(TESR_MasserAmount.x * TESR_RaysPhaseCoeff.x);
	float3 shaft = Color * TESR_MasserRaysData.z * Amount;
	float3 ray = TESR_MasserRaysRayColor.rgb;
	shaft.rgb *= (-forward) * ray * saturate(1.0f - ori);

	float3 color = ori + shaft.rgb;
	color.rgb = BlendSoftLight(color.rgb, (ray * TESR_MasserRaysRayColor.a * Amount + 0.5f));
	return float4(color.rgb, 1.0f);
}

technique
{
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 DepthSkyMask();
	}

	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		Pixelshader = compile ps_3_0 LightShaftSunCombine();
	}
}