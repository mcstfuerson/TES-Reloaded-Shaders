//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   psa shaderdump19/GRASS2005.pso /Fcshaderdump19/GRASS2005.pso.dis
//
//
// Parameters:
//
float4 AlphaTestRef : register(c3);
sampler2D AttMap : register(s1);
sampler2D DiffuseMap : register(s0);
float4 PointLightColor : register(c2);
sampler2D ShadowMap : register(s2);
sampler2D ShadowMaskMap : register(s3);
float4 TESR_ShadowData : register(c5);
float4 TESR_ShadowLightPosition[12] : register(c6);
sampler2D TESR_ShadowMapBufferNear : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferFar : register(s5) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
row_major float4x4 TESR_InvViewProjectionTransform : register(c20);
row_major float4x4 TESR_ShadowCameraToLightTransformFar : register(c24);
//
//
// Registers:
//
//   Name            Reg   Size
//   --------------- ----- ----
//   PointLightColor const_2       1
//   AlphaTestRef    const_3       1
//   DiffuseMap      texture_0       1
//   AttMap          texture_1       1
//   ShadowMap       texture_2       1
//   ShadowMaskMap   texture_3       1
//


// Structures:

struct VS_OUTPUT {
    float2 DiffuseUV : TEXCOORD0;
    float3 texcoord_4 : TEXCOORD4_centroid;
    float4 texcoord_5 : TEXCOORD5_centroid;
    float4 texcoord_1 : TEXCOORD1;
    float4 texcoord_2 : TEXCOORD2;
    float3 texcoord_3 : TEXCOORD3;
    float4 texcoord_6 : TEXCOORD6;
    float4 texcoord_8 : TEXCOORD8;
    float4 color_0 : COLOR0;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

// Code:

#include "../Shadows/Includes/Shadow.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

    #define	compress(v)		(((v) * 0.5) + 0.5)

    float1 att0;
    float1 att4;
    float1 attCustom0;
    float1 attCustom4;
    float3 q3;
    float3 q5;
    float3 q6;
    float4 r0;

    r0.xyzw = tex2D(DiffuseMap, IN.DiffuseUV.xy);
    att4.x = tex2D(AttMap, IN.texcoord_1.zw);
    att0.x = tex2D(AttMap, IN.texcoord_1.xy);

    attCustom4.x = tex2D(AttMap, IN.texcoord_2.zw);
    attCustom0.x = tex2D(AttMap, IN.texcoord_2.xy);


    q3.xyz = (GetLightAmountGrass(IN.texcoord_6, mul(IN.texcoord_8, TESR_ShadowCameraToLightTransformFar), mul(IN.texcoord_8, TESR_InvViewProjectionTransform)) * IN.texcoord_5.xyz) + IN.texcoord_4.xyz;
    q5.xyz = (saturate((1 - att0.x) - att4.x) * (0.4 * PointLightColor.xyz));
    q5.xyz += (saturate((1 - attCustom0.x) - attCustom4.x) * (0.4 * IN.texcoord_3.xyz));
    q5.xyz += q3.xyz;
    OUT.color_0.a = (AlphaTestRef.x >= r0.w ? 0 : IN.texcoord_5.w);
    OUT.color_0.rgb = (r0.xyz * q5.xyz) + ((IN.color_0.rgb - (r0.xyz * q5.xyz)) * IN.color_0.a);
    return OUT;
};

// approximately 24 instruction slots used (5 texture, 19 arithmetic)
