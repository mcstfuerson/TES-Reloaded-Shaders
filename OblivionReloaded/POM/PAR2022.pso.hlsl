//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/PAR2022.pso /Fcshaderdump19/PAR2022.pso.dis
//
//
// Parameters:
//
sampler2D TESR_samplerBaseMap : register(s0) = sampler_state { MINFILTER = LINEAR; };
float4 Toggles : register(c7);
float4 TESR_ShadowData : register(c10);
float4 TESR_ShadowLightPosition[12] : register(c14);
float4 TESR_ShadowCubeMapBlend : register(c11);
float4 TESR_ShadowCubeMapBlend2 : register(c12);
float4 TESR_ShadowCubeMapBlend3 : register(c13);
samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer1 : register(s5) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer2 : register(s6) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer3 : register(s7) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer4 : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer5 : register(s9) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer6 : register(s10) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer7 : register(s11) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer8 : register(s12) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer9 : register(s13) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer10 : register(s14) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer11 : register(s15) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

//
//
// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   Toggles      const_7       1
//   BaseMap      texture_0       1
//


// Structures:

struct VS_OUTPUT {
    float2 BaseUV : TEXCOORD0;
    float3 texcoord_6 : TEXCOORD6_centroid;
    float3 color_0 : COLOR0;
    float4 ShadowUV0 : TEXCOORD4;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

// Code:

#include "../Shadows/Includes/ShadowCube.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

#define	uvtile(w)		(((w) * 0.04) - 0.02)

    float4 r0;
    float2 uv0;
    float Shadow;

    Shadow = GetLightAmount(IN.ShadowUV0);

    r0.xyzw = tex2D(TESR_samplerBaseMap, IN.BaseUV.xy);			// partial precision
    uv0.xy = (uvtile(r0.w) * (IN.texcoord_6.xy / length(IN.texcoord_6.xyz))) + IN.BaseUV.xy;
    r0.xyzw = tex2D(TESR_samplerBaseMap, uv0.xy);			// partial precision
    OUT.color_0.a = 1;			// partial precision
    OUT.color_0.rgb = (Toggles.x <= 0.0 ? r0.xyz * Shadow : (r0.xyz * IN.color_0.rgb)) * Shadow;

    return OUT;
};

// approximately 11 instruction slots used (2 texture, 9 arithmetic)
