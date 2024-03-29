//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SLS2039.pso /Fcshaderdump19/SLS2039.pso.dis
//
//
// Parameters:

sampler2D NormalMap : register(s0);
float4 PSLightColor[4] : register(c2);
sampler2D ShadowMap : register(s4);
sampler2D ShadowMaskMap : register(s5);
float4 Toggles : register(c7);
float4 TESR_ShadowData : register(c8);
float4 TESR_ShadowSkinData : register(c21);
float4 TESR_ShadowLightPosition[12] : register(c9);
sampler2D TESR_ShadowMapBufferNear : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferFar : register(s9) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferSkin : register(s10) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

// Registers:
//
//   Name          Reg   Size
//   ------------- ----- ----
//   PSLightColor[0]  const_2        1
//   Toggles       const_7       1
//   NormalMap     texture_0       1
//   ShadowMap     texture_4       1
//   ShadowMaskMap texture_5       1
//


// Structures:

struct VS_OUTPUT {
    float2 NormalUV : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1_centroid;
    float3 texcoord_3 : TEXCOORD3_centroid;
    float4 texcoord_6 : TEXCOORD6;
    float4 texcoord_7 : TEXCOORD7;
    float4 texcoord_8 : TEXCOORD8;
    float4 texcoord_9 : TEXCOORD9;
    float4 LCOLOR_2 : COLOR2;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

//
#include "../Shadows/Includes/Shadow.hlsl"
#include "../Shadows/Includes/ShadowSkin.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)		saturate(dot(n, l))
#define	weight(v)		dot(v, 1)
#define	sqr(v)			((v) * (v))

    float1 q11;
    float1 q4;
    float3 q7;
    float4 r0;
    float shadow;

    if (IN.LCOLOR_2.x < -10.0f) {
        shadow = GetLightAmount(IN.texcoord_6, IN.texcoord_7, IN.texcoord_8);
    }
    else {
        shadow = GetLightAmountSkin(IN.texcoord_9, IN.texcoord_6, IN.texcoord_8);
    }

    r0.xyzw = tex2D(NormalMap, IN.NormalUV.xy);
    q11.x = r0.w * pow(abs(shades(normalize(expand(r0.xyz)), normalize(IN.texcoord_3.xyz))), Toggles.z);
    q4.x = dot(normalize(expand(r0.xyz)), normalize(IN.texcoord_1.xyz));
    q7.xyz = ((0.2 >= q4.x ? (q11.x * max(q4.x + 0.5, 0)) : q11.x) * PSLightColor[0].rgb) * shadow;
    OUT.color_0.a = weight(q7.xyz);
    OUT.color_0.rgb = saturate(q7.xyz);

    return OUT;
};

// approximately 34 instruction slots used (3 texture, 31 arithmetic)
