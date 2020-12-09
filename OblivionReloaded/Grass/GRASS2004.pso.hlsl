//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   psa shaderdump19/GRASS2004.pso /Fcshaderdump19/GRASS2004.pso.dis
//
//
// Parameters:
//
float4 AlphaTestRef : register(c3);
float4 TESR_ShadowData : register(c5);
sampler2D DiffuseMap : register(s0);
sampler2D ShadowMap : register(s1);
sampler2D ShadowMaskMap : register(s2);
sampler2D TESR_ShadowMapBufferNear : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferFar : register(s5) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

//
//
// Registers:
//
//   Name          Reg   Size
//   ------------- ----- ----
//   AlphaTestRef  const_3       1
//   DiffuseMap    texture_0       1
//   ShadowMap     texture_1       1
//   ShadowMaskMap texture_2       1
//


// Structures:

struct VS_OUTPUT {
    float2 DiffuseUV : TEXCOORD0;
    float3 texcoord_4 : TEXCOORD4_centroid;
    float4 texcoord_5 : TEXCOORD5_centroid;
    float4 texcoord_6 : TEXCOORD6;
    float4 color_0 : COLOR0;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

#include "../Shadows/Includes/Shadow.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

    float3 Color;
    float4 ColorDiffuse;

    ColorDiffuse = tex2D(DiffuseMap, IN.DiffuseUV.xy);
    Color.rgb = (GetLightAmountGrass(IN.texcoord_6) * IN.texcoord_5.xyz) + IN.texcoord_4.xyz;
    OUT.color_0.a = (AlphaTestRef.x >= ColorDiffuse.a ? 0 : IN.texcoord_5.w);
    OUT.color_0.rgb = (ColorDiffuse.rgb * Color.rgb) + ((IN.color_0.rgb - (ColorDiffuse.rgb * Color.rgb)) * IN.color_0.a);

    return OUT;
};

// approximately 15 instruction slots used (3 texture, 12 arithmetic)
