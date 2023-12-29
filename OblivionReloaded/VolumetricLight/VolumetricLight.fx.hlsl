// Volumetric Light shader for Oblivion Reloaded E3

/**
 *Credits/Sources:
 *
 *Volumetrics: https://www.alexandre-pestana.com/volumetric-lights/, https://andrew-pham.blog/2019/10/03/volumetric-lighting/
 *Dithering: https://shader-tutorial.dev/advanced/color-banding-dithering/
 *Flow Noise: https://www.shadertoy.com/view/MtcGRl
 *Downsampling: Mathieu C
 *Blur & other various mechanics: Alenet, OBGE Team, OR Codebase
**/

float4x4 TESR_WorldViewProjectionTransform;
float4x4 TESR_WorldTransform;
float4x4 TESR_ShadowCameraToLightTransformNear;
float4x4 TESR_ShadowCameraToLightTransformFar;
float4x4 TESR_ProjectionTransform;
float4x4 TESR_ViewTransform;
float4 TESR_ReciprocalResolution;
float4 TESR_CameraPosition;
float4 TESR_ShadowData;
float4 TESR_ShadowLightDir;
float4 TESR_WaterSettings;
float4 TESR_GameTime;
float4 TESR_Tick;

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
//x = Unused
//y = Accum cutoff
//z = Blur
//w = Accum height Cutoff

float4 TESR_VolumetricLightData4;
//x = Unused
//y = Animated fog toggle
//z = Screen Res X
//w = Screen Res Y 

float4 TESR_VolumetricLightData5;
//x = Wind Direction x
//y = Wind Direction y
//z = Wind Direction z
//w = Fog Power

float4 TESR_VolumetricLightData6;
//x = Sun Scatter R
//y = Sun Scatter G
//z = Sun Scatter B
//w = UNUSED

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

static const int MARCH_NUM = 25;
static const float SCATTERING = 0.1f;
static const float SCATTERING_SKY = 0.6f;
static const float PI = 3.1415926538f;
static const float NOISE_GRANULARITY = 0.5 / 255.0;
static const float RAY_LENGTH_MAX = 20000.0f;
static const float HEIGHT = TESR_VolumetricLightData3.w;

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

float2 GetGradient(float2 pos, float t)
{
    //also can do texture based rand, may be faster according to author
    float rand = random(pos);
    
    // Rotate gradient: random starting rotation, random rotation rate
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return float2(cos(angle), sin(angle));
}


float noise(float3 pos)
{
    float2 i = floor(pos.xy);
    float2 f = pos.xy - i;
    float2 blend = f * f * (3.0 - 2.0 * f);
    float noiseVal =
        lerp(
            lerp(
                dot(GetGradient(i + float2(0, 0), pos.z), f - float2(0, 0)),
                dot(GetGradient(i + float2(1, 0), pos.z), f - float2(1, 0)),
                blend.x),
            lerp(
                dot(GetGradient(i + float2(0, 1), pos.z), f - float2(0, 1)),
                dot(GetGradient(i + float2(1, 1), pos.z), f - float2(1, 1)),
                blend.x),
        blend.y
    );
    return noiseVal / 0.7; // normalize to about [-1..1]
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

float flowNoise(float3 uvw)
{
    float blended = noise(uvw * 4.0);
    //blended += noise(uvw * 8.0) * 0.5;
    //blended /= 3.5;
    blended /= 3.0f;
    return blended;
}

float ComputeScatteringSky(float lightDotView)
{
    float result = 1.0f - SCATTERING_SKY * SCATTERING_SKY;
    result /= (4.0f * PI * pow(1.0f + SCATTERING_SKY * SCATTERING_SKY - (2.0f * SCATTERING_SKY) * lightDotView, 1.5f));
    return result;
}

float ComputeScatteringSkyInt(float lightDotView, float media)
{
    float scatter = min(SCATTERING + media, 1.0f);
    float result = 1.0f - scatter * scatter;
    result /= (4.0f * PI * pow(1.0f + scatter * scatter - (2.0f * scatter) * lightDotView, 1.5f));
    return result;
}

float ComputeScattering(float lightDotView, float media)
{
    float scatter = min(SCATTERING + media, 0.5f);
    float result = 1.0f - scatter * scatter;
    result /= (4.0f * PI * pow(1.0f + scatter * scatter - (2.0f * scatter) * lightDotView, 1.5f));
    return result;
}

float4 VolumetricLightBaseSky(VSOUT IN) : COLOR0
{
    float3 baseFogColor = TESR_VolumetricLightData2.xyz;
    float fullBaseFogDistance = TESR_VolumetricLightData2.w;

    float3 accumLightColor = TESR_VolumetricLightData1.xyz;
    float fullAccumLightDistance = TESR_VolumetricLightData1.w;

    float accumLightDistanceCutoff = TESR_VolumetricLightData3.y;
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
        accumLight += (ComputeScatteringSky(dot(rayDirection, TESR_ShadowLightDir)).xxx * ((TESR_VolumetricLightData6.xyz) * TESR_ShadowLightDir.w));
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
        color += accumLight * lerp(0, 1, saturate(abs(shadowWorldPosition.z) / 12500));;
        color = saturate(color);
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
    float fogPower = TESR_VolumetricLightData5.w;
    float3 fogDirection = TESR_VolumetricLightData5.xyz;

    float2 uv = IN.UVCoord.xy;
    clip((IN.UVCoord.x < resPercent && IN.UVCoord.y < resPercent) - 1);
    uv *= 1 / resPercent;

    float depth = readDepth(uv);
    float shadowDepth = readDepthShadow(uv);
    float3 shadowCameraVector = toWorld(uv) * shadowDepth;
    float4 shadowWorldPosition = float4(TESR_CameraPosition.xyz + shadowCameraVector, 1.0f);
    float Shadow = 0.0f;

    bool inFog = TESR_CameraPosition.z < HEIGHT;
    float stepHeight = 2500.0f;
    
    float3 startPosition = TESR_CameraPosition.xyz;
    float3 noiseStartPosition = startPosition;
    float3 endPosition = shadowWorldPosition.xyz;
    float3 rayVector = endPosition - startPosition;
    
    float rayLength = length(rayVector);
    float noiseRayLength = rayLength;
    float3 rayDirection = rayVector / rayLength;
    rayLength = min(rayLength, lerp(RAY_LENGTH_MAX, rayLength, smoothstep(HEIGHT - (stepHeight - 600), HEIGHT, TESR_CameraPosition.z)));
    noiseRayLength = min(noiseRayLength, RAY_LENGTH_MAX);
    float nearModifier = 0.0f;
    bool isSky = depth > .99f;
    if (isSky) //Could potentially eliminate this if you also eliminate the matching isSky check below
    {
        nearModifier = 3.5f; //this is useful for horizons only maybe lerp to 0 based on height;
    }
    float noiseStepLength = noiseRayLength / MARCH_NUM;
    float stepLength = rayLength / MARCH_NUM;
    float3 noiseStep = rayDirection * noiseStepLength;
    float3 step = rayDirection * stepLength;

    float3 currentPosition = startPosition;
    float3 noiseCurrentPosition = startPosition;
    
    if (!inFog)
    {
        currentPosition = startPosition + (step * MARCH_NUM);
        noiseCurrentPosition = startPosition + (noiseStep * MARCH_NUM);
        startPosition = currentPosition;
        noiseStartPosition = noiseCurrentPosition;
        step *= -1;
        noiseStep *= -1;
    }
    currentPosition += step * DITHER_PATTERN[int(abs(uv.x) * (TESR_VolumetricLightData4.z * resPercent)) % 4][int(abs(uv.y) * (TESR_VolumetricLightData4.w * resPercent)) % 4];
    noiseCurrentPosition += noiseStep * DITHER_PATTERN[int(abs(uv.x) * (TESR_VolumetricLightData4.z * resPercent)) % 4][int(abs(uv.y) * (TESR_VolumetricLightData4.w * resPercent)) % 4];
    float3 accumLight = 0.0f.xxx;
    fogDirection *= (TESR_Tick.y / 10000.0f).xxx;
   
    for (int i = 0; i < MARCH_NUM; i++)
    {
        float4 pos = mul(float4(currentPosition, 1.0f), TESR_WorldViewProjectionTransform);
        float4 ShadowNear = mul(pos, TESR_ShadowCameraToLightTransformNear);
        float4 ShadowFar = mul(pos, TESR_ShadowCameraToLightTransformFar);
        float4 cpos = float4(currentPosition + shadowCameraVector, 1.0f);
        Shadow = GetLightAmount(ShadowNear, ShadowFar);

        float3 noisePosition = (noiseCurrentPosition.xyz / 1500.0f);
        noisePosition -= fogDirection;
         
        //50000 is the cutoff for rendering animated fog
        float fog = lerp(saturate(flowNoise(noisePosition)), 0.1f, saturate((distance(cpos, TESR_CameraPosition.xyz) / 50000.0f) + abs(1 - TESR_VolumetricLightData4.y)));
        fog *= fogPower;
    
        float scatterFog = fog;
        fog = fog * (accumLightColor * 2);
        fog = fog * max(nearModifier, 1);
        fog = (fog / 6.0f) * TESR_ShadowLightDir.w;
        
        float heightTransition = lerp(1, 0, smoothstep(HEIGHT - stepHeight, HEIGHT, currentPosition.z));

        if (Shadow >= 1.0f)
        {
            if (isSky)
            {
                accumLight += ((ComputeScatteringSkyInt(dot(rayDirection, TESR_ShadowLightDir), scatterFog.x).xxx * (accumLightColor * TESR_ShadowLightDir.w)) + fog) * heightTransition;
            }
            else
            {
                accumLight += ((ComputeScattering(dot(rayDirection, TESR_ShadowLightDir), scatterFog.x).xxx * (accumLightColor * TESR_ShadowLightDir.w)) + fog) * heightTransition;
            }
        }
        else
        {
            accumLight += (((ComputeScattering(dot(rayDirection, TESR_ShadowLightDir), 0.0f).xxx * ((accumLightColor) * TESR_ShadowLightDir.w)) * (1 - saturate(accumLightDistanceCutoff / distance(cpos, TESR_CameraPosition.xyz)))) + fog) * heightTransition;
        }
        
        currentPosition += step;
        noiseCurrentPosition += noiseStep;
        
        if (currentPosition.z > HEIGHT && startPosition.z < HEIGHT)
        {
            //recalculate based off this position
            float3 vec = inFog ? currentPosition.xyz - startPosition.xyz : startPosition.xyz - currentPosition.xyz;
            float rLength = length(vec);
            float nrLength = min(rLength, RAY_LENGTH_MAX);
            float3 rDir = vec / rLength;
            float3 nrDir = vec / nrLength;
            float newStepLength = rLength / (MARCH_NUM - i);
            float noiseNewStepLength = nrLength / (MARCH_NUM - i);
            float3 newStep = rDir * newStepLength;
            float3 newNoiseStep = rDir * noiseNewStepLength;
            step = newStep;
            noiseStep = newNoiseStep;
            if (!inFog)
            {
                step *= -1;
                noiseStep *= -1;
            }
            currentPosition = startPosition;
            noiseCurrentPosition = noiseStartPosition;
            currentPosition += step;
            noiseCurrentPosition += noiseStep;
        }
        nearModifier -= 0.2f;
    }
    
    //Could potentially eliminate this if you also eliminate the near modifier
    //Then artiscally must decide if accumLight /= MARCH_NUM; fits better than accumLight /= lerp(MARCH_NUM * 1.10, MARCH_NUM * .85f, saturate(rayLength / RAY_LENGTH_MAX));
    if (isSky)
    {
        accumLight /= MARCH_NUM;
    }
    else
    {
        accumLight /= lerp(MARCH_NUM * 1.10, MARCH_NUM * .85f, saturate(rayLength / RAY_LENGTH_MAX));
    }

    float4 pos = float4(TESR_CameraPosition.xyz + shadowCameraVector, 1.0f);
    float fogCoeff = saturate(distance(pos, TESR_CameraPosition.xyz) / fullAccumLightDistance) + 1.0f;

    fogCoeff = abs(fogCoeff - 1.0f);

    accumLight *= accumLightStrength;
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
    return float4(Color * (1 - VolumeLight) + VolumeLight, 1.0f);
}

float4 Blur(VSOUT IN) : COLOR0
{
    float3 Color1 = 0;
    float3 Color2 = 0;
    float3 VolumeLight = tex2D(TESR_RenderedBuffer, IN.UVCoord);
    float depth = readDepthShadow(IN.UVCoord);
    float3 shadowCameraVector = toWorld(IN.UVCoord) * depth;
    float4 pos = float4(TESR_CameraPosition.xyz + shadowCameraVector, 1.0f);
    float blurDistance = TESR_VolumetricLightData3.z;
    float blurCoeff = saturate((distance(pos, TESR_CameraPosition.xyz) / blurDistance));
    float2 blur[cKernelSize];

    blur = BlurOffsets;
		
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