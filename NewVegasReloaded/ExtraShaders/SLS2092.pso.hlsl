//
// Generated by Microsoft (R) HLSL Shader Compiler 9.23.949.2378
//
// Parameters:

float4 AmbientColor : register(c1);
sampler2D BaseMap[7] : register(s0);
sampler2D NormalMap[7] : register(s7);
float4 PSLightColor[10] : register(c3);
float4 PSLightDir : register(c18);
float4 TESR_ShadowData : register(c32);
sampler2D TESR_ShadowMapBuffer : register(s14) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   AmbientColor const_1       1
//   PSLightColor[0] const_3       1
//   PSLightDir   const_18      1
//   BaseMap      texture_0       1
//   NormalMap    texture_7       1
//


// Structures:

struct VS_INPUT {
	float3 LCOLOR_0 : COLOR0;
    float2 BaseUV : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1_centroid;
    float3 texcoord_3 : TEXCOORD3_centroid;
    float3 texcoord_4 : TEXCOORD4_centroid;
    float3 texcoord_5 : TEXCOORD5_centroid;
	float4 texcoord_6 : TEXCOORD6;
    float4 texcoord_7 : TEXCOORD7_centroid;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

#include "../Shadows/Includes/Shadow.hlsl"

PS_OUTPUT main(VS_INPUT IN) {
    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)		saturate(dot(n, l))

    float3 m20;
    float3 noxel1;
    float3 q0;
    float3 q2;
    float3 q3;
    float3 r0;
    float4 r1;

    noxel1.xyz = tex2D(NormalMap[0], IN.BaseUV.xy).xyz;
    r1.xyzw = tex2D(BaseMap[0], IN.BaseUV.xy);
    q3.xyz = normalize(IN.texcoord_5.xyz);
    q0.xyz = normalize(IN.texcoord_4.xyz);
    q2.xyz = normalize(IN.texcoord_3.xyz);
    m20.xyz = mul(float3x3(q2.xyz, q0.xyz, q3.xyz), PSLightDir.xyz);
    r1.w = shades(normalize(2 * ((noxel1.xyz - 0.5) * IN.LCOLOR_0.x)), m20.xyz);	// [0,1] to [-1,+1]
    r0.xyz = ((GetLightAmount(IN.texcoord_6) * (r1.w * PSLightColor[0].rgb)) + AmbientColor.rgb) * (r1.xyz * IN.LCOLOR_0.x);
    r1.xyz = r0.xyz * IN.texcoord_1.xyz;
    OUT.color_0.a = 1;
    OUT.color_0.rgb = (IN.texcoord_7.w * (IN.texcoord_7.xyz - (IN.texcoord_1.xyz * r0.xyz))) + r1.xyz;

    return OUT;
};

// approximately 31 instruction slots used (2 texture, 29 arithmetic)