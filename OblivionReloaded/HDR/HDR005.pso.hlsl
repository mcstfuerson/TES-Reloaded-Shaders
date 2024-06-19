//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/HDR005.pso /Fcshaderdump19/HDR005.pso.dis
//
//
// Parameters:
//
float4 HDRParam : register(c1);
float4 TESR_ToneMapping : register(c19);
float4 TESR_ReciprocalResolution : register(c20);

sampler2D ScreenSpace : register(s0);

#define ar float(TESR_ReciprocalResolution.z)
//
//
// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   HDRParam     const_1       1
//   ScreenSpace         texture_0       1
//

#include "Includes/Color.hlsl"
#include "Includes/Common.hlsl"

// Structures:

struct VS_OUTPUT {
    float2 ScreenOffset : TEXCOORD0;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

/**
 *Credits/Sources:
 *
 *noonemusteverknow: https://www.nexusmods.com/oblivion/mods/50563
 *luluco250: https://github.com/luluco250
**/
PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

    float3 color;
	float3 result;

    color = tex2D(ScreenSpace, scale_uv(IN.ScreenOffset.xy, float2(1.0, ar), 0.5));	
	color = max(color, 0.0);
	color = GAMMA2LINEAR(color);
    result = GetRGBfromXYZ(max(GetXYZfromRGB(color), 0));
	
    OUT.color_0.a = 1;
    OUT.color_0.rgb = result;

    return OUT;
};

// approximately 6 instruction slots used (1 texture, 5 arithmetic)
