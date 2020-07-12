//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SLS2031.pso /Fcshaderdump19/SLS2031.pso.dis
//
//
// Parameters:

float4 AmbientColor : register(c1);
float4 PSLightColor[4] : register(c2);
float4 TESR_ShadowData : register(c8);
float4 TESR_ShadowLightPosition[4] : register(c9);
float4 TESR_ShadowCubeMapFarPlanes : register(c13);

sampler2D BaseMap : register(s0);
sampler2D NormalMap : register(s1);
sampler2D AttenuationMap : register(s4);
samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer1 : register(s9) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer2 : register(s10) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer3 : register(s11) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

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
//


// Structures:

struct VS_OUTPUT {
    float2 BaseUV : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1_centroid;
    float3 texcoord_2 : TEXCOORD2_centroid;
    float3 texcoord_3 : TEXCOORD3_centroid;
    float4 texcoord_4 : TEXCOORD4;
    float4 texcoord_5 : TEXCOORD5;
	float4 texcoord_7 : TEXCOORD7;
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

    float1 att0;
    float1 att1;
    float1 att2;
    float1 att8;
    float3 q3;
    float3 q4;
    float4 r0;
	float3 r1;
    float3 r3;
    float4 r5;
	float Shadow;
	
    r5.xyzw = tex2D(NormalMap, IN.BaseUV.xy);
    r0.xyzw = tex2D(BaseMap, IN.BaseUV.xy);
    att8.x = tex2D(AttenuationMap, IN.texcoord_5.zw).x;
    att0.x = tex2D(AttenuationMap, IN.texcoord_5.xy).x;
    att2.x = tex2D(AttenuationMap, IN.texcoord_4.zw).x;
    att1.x = tex2D(AttenuationMap, IN.texcoord_4.xy).x;
    q3.xyz = normalize(expand(r5.xyz));
    r1.xyz = shades(q3.xyz, normalize(IN.texcoord_3.xyz)) * PSLightColor[2].rgb;
    q4.xyz = saturate((1 - att1.x) - att2.x) * (shades(q3.xyz, normalize(IN.texcoord_2.xyz)) * PSLightColor[1].rgb);
    r3.xyz = (shades(q3.xyz, IN.texcoord_1.xyz) * PSLightColor[0].rgb) + q4.xyz;
	r0.xyz = ((saturate((1 - att0.x) - att8.x) * r1.xyz) + r3.xyz) + AmbientColor.rgb;
	Shadow = GetLightAmount(TESR_ShadowCubeMapBuffer0, IN.texcoord_7, TESR_ShadowLightPosition[0], TESR_ShadowCubeMapFarPlanes.x) * GetLightAmount(TESR_ShadowCubeMapBuffer1, IN.texcoord_7, TESR_ShadowLightPosition[1], TESR_ShadowCubeMapFarPlanes.y);
	if (TESR_ShadowLightPosition[2].w) Shadow *= GetLightAmount(TESR_ShadowCubeMapBuffer2, IN.texcoord_7, TESR_ShadowLightPosition[2], TESR_ShadowCubeMapFarPlanes.z);
	if (TESR_ShadowLightPosition[3].w) Shadow *= GetLightAmount(TESR_ShadowCubeMapBuffer3, IN.texcoord_7, TESR_ShadowLightPosition[3], TESR_ShadowCubeMapFarPlanes.w);
    OUT.color_0.a = r0.w;
    OUT.color_0.rgb = Shadow * r0.xyz;
    return OUT;
	
};

// approximately 35 instruction slots used (6 texture, 29 arithmetic)
