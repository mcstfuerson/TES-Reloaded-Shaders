// Volumetric Light shader for Oblivion Reloaded E3

/**
 *Credits/Sources:
 *
 *Volumetrics: https://www.alexandre-pestana.com/volumetric-lights/, https://andrew-pham.blog/2019/10/03/volumetric-lighting/
 *Dithering: https://shader-tutorial.dev/advanced/color-banding-dithering/
 *Downsampling: Mathieu C
 *Blur & other various mechanics: Alenet, OBGE Team, OR Codebase
**/

float4x4 TESR_WorldViewProjectionTransform;
float4x4 TESR_ShadowCameraToLightTransformNear;
float4x4 TESR_ShadowCameraToLightTransformFar;
float4x4 TESR_ProjectionTransform;
float4x4 TESR_ViewTransform;
float4 TESR_ReciprocalResolution;
float4 TESR_CameraPosition;
float4 TESR_ShadowData;
float4 TESR_ShadowLightDir;
float4 TESR_WaterSettings;

float4 TESR_VolumetricLightData1;
//x = Accum R
//y = Accum G
//z = Accum B
//w = Accum Distance

float4 TESR_VolumetricLightData2;
//x = Base R
//y = Base G
//z = Base B
//w = Base Distance

float4 TESR_VolumetricLightData3;
//x = UNUSED
//y = Accum cutoff
//z = Blur
//w = Accum height Cutoff

float4 TESR_VolumetricLightData4;
//x = Base height Cutoff
//y = Sun coeff
//z = Screen Res X
//w = Screen Res Y 

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};
sampler2D TESR_DepthBuffer : register(s1) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};
sampler2D TESR_SourceBuffer : register(s2) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};
sampler2D TESR_ShadowMapBufferNear : register(s3) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};
sampler2D TESR_ShadowMapBufferFar : register(s4) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};

static const float4x4 DITHER_PATTERN = { 0.0f, 0.5f, 0.125f, 0.625f, 0.75f, 0.22f, 0.875f, 0.375f, 0.1875f, 0.6875f, 0.0625f, 0.5625f, 0.9375f, 0.4375f, 0.8125f, 0.3125f };
static const float resPercent = 0.5f;

static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;

static const float BIAS = 0.001f;
static const float darkness = 0.8f;

static const int MARCH_NUM = 40;
static const float SCATTERING = 0.1f;
static const float SCATTERING_SKY = 0.6f;
static const float PI = 3.1415926538f;
static const float NOISE_GRANULARITY = 0.5 / 255.0;

static const float2 OffsetMaskH = float2(1.0f, 0.0f);
static const float2 OffsetMaskV = float2(0.0f, 1.0f);

static const float accumLightStrength = 3.0f; //TODO shouldnt have to use this but dont touch it for now

static const float3 eyepos = float3(TESR_CameraPosition.x, TESR_CameraPosition.y, TESR_CameraPosition.z - TESR_WaterSettings.x);

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
    VSOUT OUT = (VSOUT) 0.0f;
    OUT.vertPos = IN.vertPos;
    OUT.UVCoord = IN.UVCoord;
    return OUT;
}

static const int cKernelSize = 13;

static const float BlurWeights[cKernelSize] =
{
    0.002216,
	0.008764,
	0.026995,
	0.064759,
	0.120985,
	0.176033,
	0.199471,
	0.176033,
	0.120985,
	0.064759,
	0.026995,
	0.008764,
	0.002216,
};

static const float2 BlurOffsets[cKernelSize] =
{
    float2(-2.4f * TESR_ReciprocalResolution.x, -2.4f * TESR_ReciprocalResolution.y),
	float2(-2.0f * TESR_ReciprocalResolution.x, -2.0f * TESR_ReciprocalResolution.y),
	float2(-1.6f * TESR_ReciprocalResolution.x, -1.6f * TESR_ReciprocalResolution.y),
	float2(-1.2f * TESR_ReciprocalResolution.x, -1.2f * TESR_ReciprocalResolution.y),
	float2(-0.8f * TESR_ReciprocalResolution.x, -0.8f * TESR_ReciprocalResolution.y),
	float2(-0.4f * TESR_ReciprocalResolution.x, -0.4f * TESR_ReciprocalResolution.y),
	float2(0.0f * TESR_ReciprocalResolution.x, 0.0f * TESR_ReciprocalResolution.y),
	float2(0.4f * TESR_ReciprocalResolution.x, 0.4f * TESR_ReciprocalResolution.y),
	float2(0.8f * TESR_ReciprocalResolution.x, 0.8f * TESR_ReciprocalResolution.y),
	float2(1.2f * TESR_ReciprocalResolution.x, 1.2f * TESR_ReciprocalResolution.y),
	float2(1.6f * TESR_ReciprocalResolution.x, 1.6f * TESR_ReciprocalResolution.y),
	float2(2.0f * TESR_ReciprocalResolution.x, 2.0f * TESR_ReciprocalResolution.y),
	float2(2.4f * TESR_ReciprocalResolution.x, 2.4f * TESR_ReciprocalResolution.y)
};

static const float2 BlurOffsetsSky[cKernelSize] =
{
    float2(-1.2f * TESR_ReciprocalResolution.x, -1.2f * TESR_ReciprocalResolution.y),
	float2(-1.0f * TESR_ReciprocalResolution.x, -1.0f * TESR_ReciprocalResolution.y),
	float2(-0.8f * TESR_ReciprocalResolution.x, -0.8f * TESR_ReciprocalResolution.y),
	float2(-0.6f * TESR_ReciprocalResolution.x, -0.6f * TESR_ReciprocalResolution.y),
	float2(-0.4f * TESR_ReciprocalResolution.x, -0.4f * TESR_ReciprocalResolution.y),
	float2(-0.2f * TESR_ReciprocalResolution.x, -0.2f * TESR_ReciprocalResolution.y),
	float2(0.0f * TESR_ReciprocalResolution.x, 0.0f * TESR_ReciprocalResolution.y),
	float2(0.2f * TESR_ReciprocalResolution.x, 0.2f * TESR_ReciprocalResolution.y),
	float2(0.4f * TESR_ReciprocalResolution.x, 0.4f * TESR_ReciprocalResolution.y),
	float2(0.6f * TESR_ReciprocalResolution.x, 0.6f * TESR_ReciprocalResolution.y),
	float2(0.8f * TESR_ReciprocalResolution.x, 0.8f * TESR_ReciprocalResolution.y),
	float2(1.0f * TESR_ReciprocalResolution.x, 1.0f * TESR_ReciprocalResolution.y),
	float2(1.2f * TESR_ReciprocalResolution.x, 1.2f * TESR_ReciprocalResolution.y)
};

float random(float2 coords)
{
    return frac(sin(dot(coords.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float3 toWorld(float2 tex)
{
    float3 v = float3(TESR_ViewTransform[0][2], TESR_ViewTransform[1][2], TESR_ViewTransform[2][2]);
    v += (1 / TESR_ProjectionTransform[0][0] * (2 * tex.x - 1)).xxx * float3(TESR_ViewTransform[0][0], TESR_ViewTransform[1][0], TESR_ViewTransform[2][0]);
    v += (-1 / TESR_ProjectionTransform[1][1] * (2 * tex.y - 1)).xxx * float3(TESR_ViewTransform[0][1], TESR_ViewTransform[1][1], TESR_ViewTransform[2][1]);
    return v;
}

float readDepth(in float2 coord : TEXCOORD0)
{
    float posZ = tex2D(TESR_DepthBuffer, coord).x;
    return (2.0f * nearZ) / (nearZ + farZ - posZ * (farZ - nearZ));
}

float readDepthShadow(in float2 coord : TEXCOORD0)
{
    float posZ = tex2D(TESR_DepthBuffer, coord).x;
    posZ = Zmul / ((posZ * Zdiff) - farZ);
    return posZ;
}

float LookupFar(float4 ShadowPos, float2 OffSet)
{
    float Shadow = tex2D(TESR_ShadowMapBufferFar, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.w, OffSet.y * TESR_ShadowData.w)).r;
    if (Shadow < ShadowPos.z - BIAS)
        return darkness;
    return 1.0f;
}

float GetLightAmountFar(float4 ShadowPos)
{
    ShadowPos.xyz /= ShadowPos.w;
    if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
        return 1.0f;

    ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
    ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;

    return LookupFar(ShadowPos, float2(0, 0));
}

float Lookup(float4 ShadowPos, float2 OffSet)
{
    float Shadow = tex2D(TESR_ShadowMapBufferNear, ShadowPos.xy + float2(OffSet.x * TESR_ShadowData.z, OffSet.y * TESR_ShadowData.z)).r;
    if (Shadow < ShadowPos.z - BIAS)
        return darkness;
    return 1.0f;
}

float GetLightAmount(float4 ShadowPos, float4 ShadowPosFar)
{

    float Shadow = 0.0f;
    ShadowPos.xyz /= ShadowPos.w;
    if (ShadowPos.x < -1.0f || ShadowPos.x > 1.0f ||
		ShadowPos.y < -1.0f || ShadowPos.y > 1.0f ||
		ShadowPos.z < 0.0f || ShadowPos.z > 1.0f)
        return GetLightAmountFar(ShadowPosFar);

    ShadowPos.x = ShadowPos.x * 0.5f + 0.5f;
    ShadowPos.y = ShadowPos.y * -0.5f + 0.5f;

    return Lookup(ShadowPos, float2(0, 0));
}

float ComputeScatteringSky(float lightDotView)
{
    float result = 1.0f - SCATTERING_SKY * SCATTERING_SKY;
    result /= (4.0f * PI * pow(1.0f + SCATTERING_SKY * SCATTERING_SKY - (2.0f * SCATTERING_SKY) * lightDotView, 1.5f));
    return result;
}

float ComputeScattering(float lightDotView)
{
    float result = 1.0f - SCATTERING * SCATTERING;
    result /= (4.0f * PI * pow(1.0f + SCATTERING * SCATTERING - (2.0f * SCATTERING) * lightDotView, 1.5f));
    return result;
}

float4 VolumetricLightBaseSky(VSOUT IN) : COLOR0
{
    float3 baseFogColor = TESR_VolumetricLightData2.xyz;
    float fullBaseFogDistance = TESR_VolumetricLightData2.w;

    float3 accumLightColor = TESR_VolumetricLightData1.xyz;
    float fullAccumLightDistance = TESR_VolumetricLightData1.w;

    float accumLightDistanceCutoff = TESR_VolumetricLightData3.y;

    float heightCutoff = TESR_VolumetricLightData4.x;
    float sunIntensity = TESR_VolumetricLightData4.y - 1;

    float2 uv = IN.UVCoord.xy;
    float3 color = tex2D(TESR_RenderedBuffer, uv).rgb;
    float depth = readDepth(uv);
    float shadowDepth = readDepthShadow(uv);
    float3 shadowCameraVector = toWorld(uv) * shadowDepth;
    float4 shadowWorldPosition = float4(TESR_CameraPosition.xyz + shadowCameraVector, 1.0f);

    float3 startPosition = TESR_CameraPosition.xyz;
    float3 rayVector = shadowWorldPosition.xyz - startPosition;
    float rayLength = length(rayVector);
    float3 rayDirection = rayVector / rayLength;
    float stepLength = rayLength / MARCH_NUM;
    float3 step = rayDirection * stepLength;

    float3 currentPosition = startPosition;
    currentPosition += step * DITHER_PATTERN[int(abs(uv.x) * TESR_VolumetricLightData4.z) % 4][int(abs(uv.y) * TESR_VolumetricLightData4.w) % 4];
    float3 accumLight = 0.0f.xxx;

    for (int i = 0; i < MARCH_NUM; i++)
    {
        accumLight += (ComputeScatteringSky(dot(rayDirection, TESR_ShadowLightDir)).xxx * ((sunIntensity * float3(1.0f, 1.0f, 1.0f)) * TESR_ShadowLightDir.w));
        currentPosition += step;
    }

    accumLight /= (MARCH_NUM / 0.4f); //TODO eliminate the magic number here

    float4 pos = float4(TESR_CameraPosition.xyz + shadowCameraVector, 1.0f);
    float baseFogCoeff = saturate(distance(pos, TESR_CameraPosition.xyz) / fullBaseFogDistance) + 1.0f;
    baseFogCoeff = abs(baseFogCoeff - 1.0f);

    if (depth >= 0.99)
    {
        accumLight *= accumLightStrength;
        accumLight += lerp(-NOISE_GRANULARITY, NOISE_GRANULARITY, random(uv));
        color += accumLight;
        color = saturate(color);

        //taper effect as we reach the height cutoff
        float heightBasedCoeff = max(0.0f, 1 - smoothstep(30000, heightCutoff, pos.z));

        if (pos.z < 20000)
        {
            //low horizon needs stronger influence because most weathers look strange
            heightBasedCoeff = lerp(2, 1, smoothstep(0, 20000, pos.z));
        }

        baseFogCoeff = heightBasedCoeff;
    }
    
    if (eyepos.z < 0.0f)
    {
        baseFogCoeff = 0.0f;
    }

    return float4(color + (baseFogColor * baseFogCoeff), 1.0f);

}

float4 VolumetricLight(VSOUT IN) : COLOR0
{
    float3 accumLightColor = TESR_VolumetricLightData1.xyz;
    float fullAccumLightDistance = TESR_VolumetricLightData1.w;

    float accumLightDistanceCutoff = TESR_VolumetricLightData3.y;

    float heightCutoff = TESR_VolumetricLightData3.w;

    float2 uv = IN.UVCoord.xy;
    clip((IN.UVCoord.x < resPercent && IN.UVCoord.y < resPercent) - 1);
    uv *= 1 / resPercent;

    float3 color = tex2D(TESR_RenderedBuffer, uv).rgb;
    float depth = readDepth(uv);
    float shadowDepth = readDepthShadow(uv);
    float3 shadowCameraVector = toWorld(uv) * shadowDepth;
    float4 shadowWorldPosition = float4(TESR_CameraPosition.xyz + shadowCameraVector, 1.0f);

    float Shadow = 0.0f;

    float3 startPosition = TESR_CameraPosition.xyz;
    float3 rayVector = shadowWorldPosition.xyz - startPosition;
    float rayLength = length(rayVector);
    float3 rayDirection = rayVector / rayLength;
    float stepLength = rayLength / MARCH_NUM;
    float3 step = rayDirection * stepLength;

    float3 currentPosition = startPosition;
    currentPosition += step * DITHER_PATTERN[int(abs(uv.x) * (TESR_VolumetricLightData4.z * resPercent)) % 4][int(abs(uv.y) * (TESR_VolumetricLightData4.w * resPercent)) % 4];
    float3 accumLight = 0.0f.xxx;
    
    for (int i = 0; i < MARCH_NUM; i++)
    {
        float4 pos = mul(float4(currentPosition, 1.0f), TESR_WorldViewProjectionTransform);
        float4 ShadowNear = mul(pos, TESR_ShadowCameraToLightTransformNear);
        float4 ShadowFar = mul(pos, TESR_ShadowCameraToLightTransformFar);
        float4 cpos = float4(currentPosition + shadowCameraVector, 1.0f);
        Shadow = GetLightAmount(ShadowNear, ShadowFar);

        if (Shadow >= 1.0f)
        {
            accumLight += (ComputeScattering(dot(rayDirection, TESR_ShadowLightDir)).xxx * (accumLightColor * TESR_ShadowLightDir.w));
        }
        else
        {
            accumLight += (ComputeScattering(dot(rayDirection, TESR_ShadowLightDir)).xxx * (accumLightColor * TESR_ShadowLightDir.w)) * (1 - saturate(accumLightDistanceCutoff / distance(cpos, TESR_CameraPosition.xyz)));
        }

        currentPosition += step;
    }

    accumLight /= (MARCH_NUM);

    float4 pos = float4(TESR_CameraPosition.xyz + shadowCameraVector, 1.0f);
    float fogCoeff = saturate(distance(pos, TESR_CameraPosition.xyz) / fullAccumLightDistance) + 1.0f;

    fogCoeff = abs(fogCoeff - 1.0f);

    if (depth < 0.99)
    {
        accumLight *= accumLightStrength;
    }
    else
    {
        //taper effect as we reach the height cutoff
        float heightBasedCoeff = max(0.5f, 1 - smoothstep(30000, heightCutoff, pos.z));

        if (pos.z < 20000)
        {
            //low horizon needs stronger influence because most weathers look strange
            heightBasedCoeff = lerp(2, 1, smoothstep(0, 20000, pos.z));
        }

        accumLight *= (accumLightStrength * saturate(heightBasedCoeff));
    }

    accumLight *= fogCoeff;
    accumLight += lerp(-NOISE_GRANULARITY, NOISE_GRANULARITY, random(uv));
    
    if (eyepos.z < 0.0f)
    {
        accumLight *= 0.3f;
    }

    return float4(accumLight, 1.0f);
}

float4 Expand(VSOUT IN) : COLOR0
{
    float2 coord = IN.UVCoord * resPercent;
    return tex2D(TESR_RenderedBuffer, coord);
}

float4 CombineLight(VSOUT IN) : COLOR0
{
    float3 Color = tex2D(TESR_SourceBuffer, IN.UVCoord).rgb;
    float3 VolumeLight = tex2D(TESR_RenderedBuffer, IN.UVCoord);
    return float4(Color + VolumeLight, 1.0f);
}

float4 Blur(VSOUT IN) : COLOR0
{
    float3 Color1 = 0;
    float3 Color2 = 0;
    float3 VolumeLight = tex2D(TESR_RenderedBuffer, IN.UVCoord);
    float depth = readDepthShadow(IN.UVCoord);
    float depth2 = readDepth(IN.UVCoord);
    float3 shadowCameraVector = toWorld(IN.UVCoord) * depth;
    float4 pos = float4(TESR_CameraPosition.xyz + shadowCameraVector, 1.0f);
    float blurDistance = TESR_VolumetricLightData3.z;
    float blurCoeff = saturate((distance(pos, TESR_CameraPosition.xyz) / blurDistance));
    float2 blur[cKernelSize];

    if (depth2 < 0.99f)
    {
        blur = BlurOffsets;
    }
    else
    {
        blur = BlurOffsetsSky;
    }
		
    for (int i = 0; i < cKernelSize; i++)
    {
        Color1 += tex2D(TESR_RenderedBuffer, IN.UVCoord + blur[i] * OffsetMaskH).rgb * BlurWeights[i];
        Color2 += tex2D(TESR_RenderedBuffer, IN.UVCoord + blur[i] * OffsetMaskV).rgb * BlurWeights[i];
    }

    Color1 = Color1 - VolumeLight;
    Color2 = Color2 - VolumeLight;

    VolumeLight.rgb = lerp(VolumeLight, (VolumeLight.rgb + Color1 + Color2), blurCoeff);
    return float4(VolumeLight, 1.0f);
}

technique
{
    pass
    {
        VertexShader = compile vs_3_0 FrameVS();
        PixelShader = compile ps_3_0 VolumetricLight();
    }
    pass
    {
        VertexShader = compile vs_3_0 FrameVS();
        PixelShader = compile ps_3_0 Expand();
    }
    pass
    {
        VertexShader = compile vs_3_0 FrameVS();
        PixelShader = compile ps_3_0 VolumetricLightBaseSky();
    }
    pass
    {
        VertexShader = compile vs_3_0 FrameVS();
        PixelShader = compile ps_3_0 CombineLight();
    }
    pass
    {
        VertexShader = compile vs_3_0 FrameVS();
        PixelShader = compile ps_3_0 Blur();
    }
}