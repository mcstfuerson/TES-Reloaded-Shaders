//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SLS2020.pso /Fcshaderdump19/SLS2020.pso.dis
//
//
// Parameters:

float4 AmbientColor : register(c1);
float4 PSLightColor[4] : register(c2);
float4 EmittanceColor : register(c6);
float4 Toggles : register(c7);
float4 TESR_ShadowData : register(c8);

sampler2D BaseMap : register(s0);
sampler2D NormalMap : register(s1);
sampler2D GlowMap : register(s4);
sampler2D ShadowMap : register(s6);
sampler2D ShadowMaskMap : register(s7);
sampler2D TESR_ShadowMapBufferNear : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferFar : register(s9) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

// Registers:
//
//   Name           Reg   Size
//   -------------- ----- ----
//   AmbientColor   const_1       1
//   PSLightColor[0]   const_2        1
//   EmittanceColor const_6       1
//   Toggles        const_7       1
//   BaseMap        texture_0       1
//   NormalMap      texture_1       1
//   GlowMap        texture_4       1
//   ShadowMap      texture_6       1
//   ShadowMaskMap  texture_7       1
//


// Structures:

struct VS_OUTPUT {
    float2 BaseUV : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1_centroid;
    float3 texcoord_3 : TEXCOORD3_centroid;
	float4 texcoord_6 : TEXCOORD6;
    float4 texcoord_7 : TEXCOORD7;
    float2 LCOLOR_0 : COLOR0;
    float4 LCOLOR_1 : COLOR1;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

#include "../Shadows/Includes/Shadow.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)

    const float4 const_4 = {0, 0, 1, 0.5};

    float1 q10;
    float3 q11;
    float3 q12;
    float3 q13;
    float3 q16;
    float3 q3;
    float1 q4;
    float4 r0;
    float4 r1;
    float2 r2;
    float1 r6;

    r0.xyzw = tex2D(NormalMap, IN.BaseUV.xy);
    r0.xyz = normalize(expand(r0.xyz));
    r2.xy = r0.xy * 0.5;
    r6.x = dot(r0.xyz, IN.texcoord_1.xyz);
    q3.xyz = GetLightAmount(IN.texcoord_6, IN.texcoord_7);
    r1.xyz = (0.5 * r0.xyz) + const_4.xyz;
    q16.xyz = r1.xyz / sqrt((((r0.z * 0.5) + 1) * r1.z) + ((r2.y * r1.y) + (r2.x * r1.x)));
    r1.xyzw = tex2D(GlowMap, IN.BaseUV.xy);
    q4.x = 1 - saturate(abs(dot(q16.xyz, IN.texcoord_1.xyz) - dot(q16.xyz, normalize(IN.texcoord_3.xyz))));
    q10.x = (r0.w * 0.7) * pow(abs(q4.x), 30);
    r0.xyzw = tex2D(BaseMap, IN.BaseUV.xy);
    q11.xyz = saturate((0.2 >= r6.x ? (q10.x * max(r6.x + 0.5, 0)) : q10.x) * PSLightColor[0].rgb) * q3.xyz;
    q12.xyz = (2 * ((IN.LCOLOR_0.y * (EmittanceColor.rgb - 0.5)) + 0.5)) * lerp(r0.xyz, r1.xyz, r1.w);	// [0,1] to [-1,+1]
    q13.xyz = (q12.xyz * max((q3.xyz * (saturate(r6.x) * PSLightColor[0].rgb)) + AmbientColor.rgb, 0)) + q11.xyz;
    OUT.color_0.a = r0.w * AmbientColor.a;
    OUT.color_0.rgb = (Toggles.y <= 0.0 ? q13.xyz : lerp(q13.xyz, IN.LCOLOR_1.xyz, IN.LCOLOR_1.w));

    return OUT;
};

// approximately 60 instruction slots used (5 texture, 55 arithmetic)
