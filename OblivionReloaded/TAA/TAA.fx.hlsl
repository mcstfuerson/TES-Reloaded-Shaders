// TAA for Oblivion Reloaded E3

/**
 *Credits/Sources:
 *
 * https://github.com/TheRealMJP/MSAAFilter
 * https://www.elopezr.com/temporal-aa-and-the-quest-for-the-holy-trail/
 *
**/

float4 TESR_ReciprocalResolution;
float4 TESR_CameraPosition;
float4 TESR_TAAData;
float4x4 TESR_ProjectionTransform;;
float4x4 TESR_ViewTransform;
float4x4 TESR_PrevWorldViewProjectionTransform;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};
sampler2D TESR_SourceBuffer : register(s1) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};
sampler2D TESR_TAABuffer : register(s2) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};
sampler2D TESR_DepthBuffer : register(s3) = sampler_state
{
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
};
 
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

static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;

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

float readDepthWorld(in float2 coord : TEXCOORD0)
{
    float posZ = tex2D(TESR_DepthBuffer, coord).x;
    posZ = Zmul / ((posZ * Zdiff) - farZ);
    return posZ;
}

float4 getWorldPos(in float2 coord : TEXCOORD0)
{
    float depthWorld = readDepthWorld(coord);
    float3 cameraVector = toWorld(coord) * depthWorld;
    return float4(TESR_CameraPosition.xyz + cameraVector, 1.0f);
}

float2 getReprojectUV(in float4 pos)
{
    float4 worldPosProj = mul(pos, TESR_PrevWorldViewProjectionTransform);
    float3 ndcSpacePos = worldPosProj.xyz / worldPosProj.w;
    return ((float2(ndcSpacePos.x, -ndcSpacePos.y)) / 2.0) + float2(0.5, 0.5);
}
// The following code is licensed under the MIT license: https://gist.github.com/TheRealMJP/bc503b0b87b643d3505d41eab8b332ae

// Samples a texture with Catmull-Rom filtering, using 9 texture fetches instead of 16.
// See http://vec3.ca/bicubic-filtering-in-fewer-taps/ for more details
float4 SampleTextureCatmullRom(in sampler2D tex, in float2 uv, in float2 texSize)
{
    // We're going to sample a a 4x4 grid of texels surrounding the target UV coordinate. We'll do this by rounding
    // down the sample location to get the exact center of our "starting" texel. The starting texel will be at
    // location [1, 1] in the grid, where [0, 0] is the top left corner.
    float2 samplePos = uv / texSize;
    float2 texPos1 = floor(samplePos - 0.5f) + 0.5f;

    // Compute the fractional offset from our starting texel to our original sample location, which we'll
    // feed into the Catmull-Rom spline function to get our filter weights.
    float2 f = samplePos - texPos1;

    // Compute the Catmull-Rom weights using the fractional offset that we calculated earlier.
    // These equations are pre-expanded based on our knowledge of where the texels will be located,
    // which lets us avoid having to evaluate a piece-wise function.
    float2 w0 = f * (-0.5f + f * (1.0f - 0.5f * f));
    float2 w1 = 1.0f + f * f * (-2.5f + 1.5f * f);
    float2 w2 = f * (0.5f + f * (2.0f - 1.5f * f));
    float2 w3 = f * f * (-0.5f + 0.5f * f);

    // Work out weighting factors and sampling offsets that will let us use bilinear filtering to
    // simultaneously evaluate the middle 2 samples from the 4x4 grid.
    float2 w12 = w1 + w2;
    float2 offset12 = w2 / (w1 + w2);

    // Compute the final UV coordinates we'll use for sampling the texture
    float2 texPos0 = texPos1 - 1;
    float2 texPos3 = texPos1 + 2;
    float2 texPos12 = texPos1 + offset12;

    texPos0 *= texSize;
    texPos3 *= texSize;
    texPos12 *= texSize;

    float4 result = 0.0f;
    result += tex2D(tex, float2(texPos0.x, texPos0.y)) * w0.x * w0.y;
    result += tex2D(tex, float2(texPos12.x, texPos0.y)) * w12.x * w0.y;
    result += tex2D(tex, float2(texPos3.x, texPos0.y)) * w3.x * w0.y;

    result += tex2D(tex, float2(texPos0.x, texPos12.y)) * w0.x * w12.y;
    result += tex2D(tex, float2(texPos12.x, texPos12.y)) * w12.x * w12.y;
    result += tex2D(tex, float2(texPos3.x, texPos12.y)) * w3.x * w12.y;

    result += tex2D(tex, float2(texPos0.x, texPos3.y)) * w0.x * w3.y;
    result += tex2D(tex, float2(texPos12.x, texPos3.y)) * w12.x * w3.y;
    result += tex2D(tex, float2(texPos3.x, texPos3.y)) * w3.x * w3.y;

    return result;
}

float4 Resolve(VSOUT IN) : COLOR0
{ 
    float4 worldPos = getWorldPos(IN.UVCoord);
    float2 reprojectedUV = getReprojectUV(worldPos);

    float3 previousColor = SampleTextureCatmullRom(TESR_TAABuffer, reprojectedUV, TESR_ReciprocalResolution.xy * (1 + TESR_TAAData.z)).rgb;
    float3 currentColor = SampleTextureCatmullRom(TESR_SourceBuffer, IN.UVCoord, TESR_ReciprocalResolution.xy * (1 + TESR_TAAData.z)).rgb;
    
    if (any(reprojectedUV != saturate(reprojectedUV)))
    {
        return float4(currentColor, 1.0f);
    }
    
    float depth = readDepth(IN.UVCoord);
    float dist = distance(worldPos.xyz, TESR_CameraPosition.xyz);
    float offset = lerp(0, TESR_TAAData.y, saturate(dist / 800.0f));
    
    float3 minColor = 9999.0, maxColor = -9999.0;
    [unroll(3)]
    for (float x = -offset; x <= offset; x += offset)
    {
        [unroll(3)]
        for (float y = -offset; y <= offset; y += offset)
        {
            float3 neighborColor = tex2D(TESR_SourceBuffer, (IN.UVCoord + float2(x, y) * TESR_ReciprocalResolution.xy));
            minColor = min(minColor, neighborColor);
            maxColor = max(maxColor, neighborColor);
        }
    }
    
    previousColor = clamp(previousColor, minColor, maxColor);
    
    float3 color;
    float distMin = 50.0f;
    float weightPrevious = TESR_TAAData.x;
    float weightCurrent = 1 - weightPrevious;

    if (dist < distMin)
    {
        color = currentColor;       
    }
    else
    {      
        color = previousColor * weightPrevious + currentColor * weightCurrent;
    }
    
    return float4(color, 1.0f);
}
 
technique
{
    pass
    {
        VertexShader = compile vs_3_0 FrameVS();
        PixelShader = compile ps_3_0 Resolve();
    }

}