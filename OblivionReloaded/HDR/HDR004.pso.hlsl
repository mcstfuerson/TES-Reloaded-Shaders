//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/HDR004.pso /Fcshaderdump19/HDR004.pso.dis
//
//
// Parameters:
//
float4 HDRParam : register(c1);
float4 TESR_ToneMapping : register(c19);
float4 TESR_ReciprocalResolution : register(c20);

sampler2D ScreenSpace : register(s0);
sampler2D DestBlend : register(s1);
sampler2D AvgLum : register(s2);


#define ar float(TESR_ReciprocalResolution.z)
#define inv_ar (1.0 / ar)


//
// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   HDRParam     const_1       1
//   ScreenSpace         texture_0       1
//   DestBlend    texture_1       1
//   AvgLum       texture_2       1
//

#include "Includes/Color.hlsl"
#include "Includes/Common.hlsl"

// Structures:

struct VS_OUTPUT
{
    float2 ScreenOffset : TEXCOORD0;
    float2 texcoord_1 : TEXCOORD1;
};

struct PS_OUTPUT
{
    float4 color_0 : COLOR0;
};

/**
 *Credits/Sources:
 *
 *noonemusteverknow: https://www.nexusmods.com/oblivion/mods/50563
 *luluco250: https://github.com/luluco250
**/
PS_OUTPUT main(VS_OUTPUT IN)
{
    PS_OUTPUT OUT;

#define	weight(v)		dot(v, 1)

    float3 reslt;
    float3 color;
    float3 avlum;
    float3 blurc;
    float luma, lumc, amplify;

    blurc = tex2D(ScreenSpace, scale_uv(IN.ScreenOffset.xy, float2(1.0, inv_ar), 0.5)).rgb;
    color = tex2D(DestBlend, IN.texcoord_1.xy).rgb;
    avlum = tex2D(AvgLum, IN.ScreenOffset.xy).rgb;
    color = max(color, 0.0);
    avlum = max(0.1, avlum);
    color = GAMMA2LINEAR(color);	
    float exposure = TESR_ToneMapping.x / get_luma(avlum);
    exposure *= GetWhitePoint();
    color *= exposure;
    blurc *= (TESR_ToneMapping.y / get_luma(avlum)) * GetWhitePoint();
    color += blurc;
    luma = get_luma(avlum);
    lumc = get_luma_linear(color);
    amplify = log(2.2 + 4.2 * luma + 1.0 + min(lumc * 64.0, (0.001 / pow(luma, 2.2)))) / log(2.2 + 4.2 * luma + 1.0 + lumc);
    color *= max(1.0, amplify);
    luma = get_luma(avlum);
    lumc = get_luma_linear(color);
    color = lerp(lerp(0, color * BlueShift / length(BlueShift), saturate(sqrt(luma) * 2)), color, saturate(sqrt(lumc) * 2));
    reslt = TimothyTonemapper(color, max(1.0125f, amplify));
    reslt = LINEAR2GAMMA(reslt);
    
    OUT.color_0.a = 1;
    OUT.color_0.rgb = reslt;

    return OUT;
};

// approximately 13 instruction slots used (3 texture, 10 arithmetic)