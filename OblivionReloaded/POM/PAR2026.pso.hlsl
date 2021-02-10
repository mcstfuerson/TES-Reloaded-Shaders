//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/PAR2026.pso /Fcshaderdump19/PAR2026.pso.dis
//
//
// Parameters:
//
float4 AmbientColor : register(c1);
sampler2D AttenuationMap : register(s5);
sampler2D BaseMap : register(s0);
sampler2D NormalMap : register(s1);
float4 PSLightColor[4] : register(c2);
float4 Toggles : register(c7);
sampler2D TESR_samplerBaseMap : register(s0) = sampler_state { MINFILTER = LINEAR; };
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

//
//
// Registers:
//
//   Name           Reg   Size
//   -------------- ----- ----
//   AmbientColor   const_1       1
//   PSLightColor[0]   const_2        1
//   PSLightColor[1]   const_3        1
//   Toggles        const_7       1
//   BaseMap        texture_0       1
//   NormalMap      texture_1       1
//   AttenuationMap texture_5       1
//


// Structures:

struct VS_OUTPUT {
    float2 BaseUV : TEXCOORD0;			// partial precision
    float3 texcoord_1 : TEXCOORD1_centroid;			// partial precision
    float3 texcoord_2 : TEXCOORD2_centroid;			// partial precision
    float3 texcoord_3 : TEXCOORD3_centroid;			// partial precision
    float3 texcoord_4 : TEXCOORD4_centroid;			// partial precision
    float4 texcoord_5 : TEXCOORD5;			// partial precision
    float3 texcoord_6 : TEXCOORD6_centroid;			// partial precision
    float3 color_0 : COLOR0;
    float4 color_1 : COLOR1;
    float4 texcoord_7 : TEXCOORD7;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

// Code:

#include "../Shadows/Includes/ShadowCube.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	uvtile(w)		(((w) * 0.04) - 0.02)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)		saturate(dot(n, l))

    float1 att0;
    float1 att1;
    float3 q10;
    float3 q11;
    float1 q17;
    float3 q26;
    float3 q3;
    float1 q4;
    float1 q6;
    float1 q7;
    float1 q8;
    float3 q9;
    float4 r0;
    float4 r1;
    float2 uv2;
    float Shadow;

    Shadow = GetLightAmount(IN.texcoord_7);

    r0.xyzw = tex2D(BaseMap, IN.BaseUV.xy);			// partial precision
    att1.x = tex2D(AttenuationMap, IN.texcoord_5.zw);			// partial precision
    att0.x = tex2D(AttenuationMap, IN.texcoord_5.xy);			// partial precision
    q7.x = saturate((1 - att0.x) - att1.x);			// partial precision
    uv2.xy = (uvtile(r0.w) * (IN.texcoord_6.xy / length(IN.texcoord_6.xyz))) + IN.BaseUV.xy;
    r1.xyzw = tex2D(NormalMap, uv2.xy);			// partial precision
    r0.xyzw = tex2D(BaseMap, uv2.xy);			// partial precision
    q3.xyz = normalize(expand(r1.xyz));			// partial precision
    q4.x = r1.w * pow(abs(shades(q3.xyz, normalize(IN.texcoord_4.xyz))), Toggles.z);			// partial precision
    q17.x = r1.w * pow(abs(shades(q3.xyz, normalize(IN.texcoord_3.xyz))), Toggles.z);			// partial precision
    q6.x = dot(q3.xyz, normalize(IN.texcoord_2.xyz));			// partial precision
    q9.xyz = saturate(q7.x * ((0.2 >= q6.x ? (q4.x * max(q6.x + 0.5, 0)) : q4.x) * PSLightColor[1].rgb));			// partial precision
    q8.x = dot(q3.xyz, IN.texcoord_1.xyz);			// partial precision
    q10.xyz = saturate((0.2 >= q8.x ? (q17.x * max(q8.x + 0.5, 0)) : q17.x) * PSLightColor[0].rgb);			// partial precision
    q11.xyz = (saturate(q8.x) * PSLightColor[0].rgb) + (q7.x * (saturate(q6.x) * PSLightColor[1].rgb));			// partial precision
    r1.xyz = (Toggles.x <= 0.0 ? r0.xyz : (r0.xyz * IN.color_0.rgb));			// partial precision
    q26.xyz = (r1.xyz * max(q11.xyz + AmbientColor.rgb, 0)) + (q9.xyz + q10.xyz);			// partial precision
    OUT.color_0.a = AmbientColor.a;			// partial precision
    OUT.color_0.rgb = (Toggles.y <= 0.0 ? q26.xyz * Shadow : lerp(q26.xyz, IN.color_1.rgb, IN.color_1.a)) * Shadow;			// partial precision

    return OUT;
};

// approximately 69 instruction slots used (5 texture, 64 arithmetic)
