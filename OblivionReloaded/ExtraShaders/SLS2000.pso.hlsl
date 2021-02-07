//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SLS2000.pso /Fcshaderdump19/SLS2000.pso.dis
//
//
// Parameters:

float4 AmbientColor : register(c1);
float4 PSLightColor[4] : register(c2);
float4 Toggles : register(c7);
sampler2D BaseMap : register(s0);
sampler2D NormalMap : register(s1);
float4 TESR_ShadowData : register(c10);
float4 TESR_ShadowLightPosition[12] : register(c14);
float4 TESR_ShadowCubeMapBlend : register(c11);
float4 TESR_ShadowCubeMapBlend2 : register(c12);
float4 TESR_ShadowCubeMapBlend3 : register(c13);
samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s3) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer1 : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
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

// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   AmbientColor const_1       1
//   PSLightColor[0] const_2        1
//   Toggles      const_7       1
//   BaseMap      texture_0       1
//   NormalMap    texture_1       1
//


// Structures:

struct VS_OUTPUT {
    float2 BaseUV : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1_centroid;
    float4 texcoord_7 : TEXCOORD7;
    float3 LCOLOR_0 : COLOR0;
    float4 LCOLOR_1 : COLOR1;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

#include "../Shadows/Includes/ShadowCube.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {

    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)		saturate(dot(n, l))

    float3 q0;
    float3 q2;
    float3 q3;
    float3 q4;
    float4 r0;
    float4 r1;
    float Shadow;

    r1.xyzw = tex2D(NormalMap, IN.BaseUV.xy);
    r0.xyzw = tex2D(BaseMap, IN.BaseUV.xy);
    q0.xyz = (shades(normalize(expand(r1.xyz)), IN.texcoord_1.xyz) * PSLightColor[0].rgb) + AmbientColor.rgb;
    q2.xyz = (Toggles.x <= 0.0 ? r0.xyz : (r0.xyz * IN.LCOLOR_0.xyz));
    Shadow = GetLightAmount(IN.texcoord_7);
    q3.xyz = Shadow * max(q0.xyz, 0) * q2.xyz;
    q4.xyz = (Toggles.y <= 0.0 ? q3.xyz : ((IN.LCOLOR_1.w * (IN.LCOLOR_1.xyz - (q2.xyz * max(q0.xyz, 0)))) + q3.xyz));
    OUT.color_0.a = r0.w * AmbientColor.a;
    OUT.color_0.rgb = q4.xyz;
    return OUT;

};

// approximately 19 instruction slots used (2 texture, 17 arithmetic)
