//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SKIN2007.pso /Fcshaderdump19/SKIN2007.pso.dis
//
//
// Parameters:
//
float4 AmbientColor : register(c1);
float4 PSLightColor[4] : register(c2);
float4 TESR_SkinData : register(c6);
float4 TESR_SkinColor : register(c7);
float4 TESR_ShadowData : register(c10);
float4 TESR_ShadowLightPosition[12] : register(c11);
float4 TESR_ShadowSkinData : register(c24);

sampler2D BaseMap : register(s0);
sampler2D NormalMap : register(s1);
sampler2D AttenuationMap : register(s4);
sampler2D ShadowMap : register(s5);
sampler2D ShadowMaskMap : register(s6);
sampler2D TESR_ShadowMapBufferNear : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferSkin : register(s10) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
//
//
// Registers:
//
//   Name           Reg   Size
//   -------------- ----- ----
//   AmbientColor   const_1       1
//   PSLightColor[0]   const_2        1
//   PSLightColor[1]   const_3        1
//   PSLightColor[2]   const_4        1
//   BaseMap        texture_0       1
//   NormalMap      texture_1       1
//   AttenuationMap texture_4       1
//   ShadowMap      texture_5       1
//   ShadowMaskMap  texture_6       1
//


// Structures:

struct VS_OUTPUT {
    float2 BaseUV : TEXCOORD0;
    float4 Light0Dir : TEXCOORD1_centroid;
    float4 Light1Dir : TEXCOORD2_centroid;
    float4 Light2Dir : TEXCOORD3_centroid;
    float4 Att1UV : TEXCOORD4;
    float4 Att2UV : TEXCOORD5;
    float4 ShadowUV0 : TEXCOORD6;
	float4 ShadowUV1 : TEXCOORD7;
    float4 InvPos : TEXCOORD8;
    float4 ShadowUV2 : TEXCOORD9;
};

struct PS_OUTPUT {
    float4 Color : COLOR0;
};

// Code:

#include "../Skin/includes/Skin.hlsl"
#include "../Shadows/Includes/ShadowSkin.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)		saturate(dot(n, l))
#define	weight(v)		dot(v, 1)
#define	sqr(v)			((v) * (v))

    float att13;
    float att14;
    float att15;
    float att2;
    float3 norm;
	float3 camera = { IN.Light0Dir.w, IN.Light1Dir.w, IN.Light2Dir.w };
    float3 q1;
    float3 q10;
    float3 q12;
    float3 q27;
    float q6;
    float q7;
    float3 q9;
    float4 r0;

    norm = normalize(expand(tex2D(NormalMap, IN.BaseUV.xy).xyz));
    r0.xyzw = tex2D(BaseMap, IN.BaseUV.xy);
    att15 = tex2D(AttenuationMap, IN.Att2UV.zw).x;
    att13 = tex2D(AttenuationMap, IN.Att2UV.xy).x;
    att2 = tex2D(AttenuationMap, IN.Att1UV.xy).x;
    att14 = tex2D(AttenuationMap, IN.Att1UV.zw).x;
    q6 = 1 - shade(norm, camera);
    q7 = q6 * sqr(q6);
	q10 = (shade(norm, IN.Light0Dir.xyz) * PSLightColor[0].rgb) + ((q7 * PSLightColor[0].rgb) * 0.5);
	q9  = (shade(norm, IN.Light1Dir.xyz) * PSLightColor[1].rgb) + ((q7 * PSLightColor[1].rgb) * 0.5);
    q12 = (shade(norm, IN.Light2Dir.xyz) * PSLightColor[2].rgb) + ((q7 * PSLightColor[2].rgb) * 0.5);            

    q10 = psSkin(q10, PSLightColor[0].rgb, camera, IN.Light0Dir.xyz, norm);
    q9  = psSkin(q9,  PSLightColor[1].rgb, camera, IN.Light1Dir.xyz, norm);
    q12 = psSkin(q12, PSLightColor[2].rgb, camera, IN.Light2Dir.xyz, norm);

    q27  = GetLightAmountSkinDialog(IN.ShadowUV2, IN.ShadowUV0, IN.InvPos) * q10;
    q27 += saturate(1 - att13 - att15) * q12;
    q27 += saturate(1 - att2  - att14) * q9;

    OUT.Color.a = r0.w;
    OUT.Color.rgb = q27 + AmbientColor.rgb;

    return OUT;
};

// approximately 59 instruction slots used (8 texture, 51 arithmetic)
