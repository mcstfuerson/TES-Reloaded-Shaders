//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SLS1004.pso /Fcshaderdump19/SLS1004.pso.dis
//
//
// Parameters:

sampler2D DiffuseMap : register(s0);
float4 TESR_ShadowData : register(c8);
float4 TESR_ShadowLightPosition[4] : register(c9);
float4 TESR_ShadowCubeMapFarPlanes : register(c13);
float4 TESR_ShadowCubeMapBlend : register(c14);

samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer1 : register(s9) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer2 : register(s10) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer3 : register(s11) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   DiffuseMap   texture_0       1
//


// Structures:

struct VS_OUTPUT {
    float2 DiffuseUV : TEXCOORD0;
    float3 LCOLOR_0 : COLOR0;
	float4 texcoord_7 : TEXCOORD7;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

#include "../Shadows/Includes/ShadowCube.hlsl"

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

    float4 r0;
	float Shadow;
	
    r0 = tex2D(DiffuseMap, IN.DiffuseUV.xy);
	Shadow = GetLightAmount(TESR_ShadowCubeMapBuffer0, IN.texcoord_7, TESR_ShadowLightPosition[0], TESR_ShadowCubeMapFarPlanes.x, TESR_ShadowCubeMapBlend.x) * GetLightAmount(TESR_ShadowCubeMapBuffer1, IN.texcoord_7, TESR_ShadowLightPosition[1], TESR_ShadowCubeMapFarPlanes.y, TESR_ShadowCubeMapBlend.y);
	if (TESR_ShadowLightPosition[2].w) Shadow *= GetLightAmount(TESR_ShadowCubeMapBuffer2, IN.texcoord_7, TESR_ShadowLightPosition[2], TESR_ShadowCubeMapFarPlanes.z, TESR_ShadowCubeMapBlend.z);
	if (TESR_ShadowLightPosition[3].w) Shadow *= GetLightAmount(TESR_ShadowCubeMapBuffer3, IN.texcoord_7, TESR_ShadowLightPosition[3], TESR_ShadowCubeMapFarPlanes.w, TESR_ShadowCubeMapBlend.w);
    OUT.color_0.a = r0.w;
    OUT.color_0.rgb = Shadow * r0.xyz * IN.LCOLOR_0.xyz;
    return OUT;
	
};

// approximately 3 instruction slots used (1 texture, 2 arithmetic)
