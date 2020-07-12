//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/GDECAL.pso /Fcshaderdump19/GDECAL.pso.dis
//
//
// Parameters:
//

float4 PSDecalOffsets : register(c15);
float4 TESR_SunDirection : register(c16);
float4 TESR_SunColor : register(c17);
float4 TESR_FogColor : register(c18);

sampler2D DecalMap : register(s1);
sampler2D TESR_DecalNormal : register(s2) < string ResourceName = "Effects\blooddecal_n.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

//
//
// Registers:
//
//   Name           Reg   Size
//   -------------- ----- ----
//   PSDecalOffsets const_15      1
//   DecalMap       texture_1       1
//


// Structures:

struct VS_OUTPUT {
    float3 DecalUV_0 : TEXCOORD0;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

// Code:

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

    float4 r0;
    float4 r1;
	float3 norm;
	float3 light;
	
    r1 = tex2D(DecalMap, (PSDecalOffsets.yw * saturate(IN.DecalUV_0.xy)) + PSDecalOffsets.xz);
    r0.rgb = r1.rgb;
    r0.a = IN.DecalUV_0.z;
    r0 = r0 * IN.DecalUV_0.z;
	norm = tex2D(TESR_DecalNormal, (PSDecalOffsets.yw * saturate(IN.DecalUV_0.xy)) + PSDecalOffsets.xz).rgb;
	norm = norm * 2 - 1;
	light = TESR_FogColor.rgb + TESR_SunColor.rgb * dot(TESR_SunDirection.xyz, normalize(norm.xyz));
	
    OUT.color_0.a = r1.a * r0.a;
    OUT.color_0.rgb = r0.rgb * light;
    return OUT;
};

// approximately 9 instruction slots used (1 texture, 8 arithmetic)
