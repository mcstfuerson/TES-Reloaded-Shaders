//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/PAR2032.vso /Fcshaderdump19/PAR2032.vso.dis
//
//
// Parameters:
//
float4 EyePosition : register(c25);
float3 LightDirection[3] : register(c13);
row_major float4x4 ModelViewProj : register(c0);
row_major float4x4 ShadowProj : register(c28);
float4 ShadowProjData : register(c32);
float4 ShadowProjTransform : register(c33);
//
//
// Registers:
//
//   Name                Reg   Size
//   ------------------- ----- ----
//   ModelViewProj[0]       const_0        1
//   ModelViewProj[1]       const_1        1
//   ModelViewProj[2]       const_2        1
//   ModelViewProj[3]       const_3        1
//   LightDirection[0]      const_13       1
//   EyePosition         const_25      1
//   ShadowProj[0]          const_28       1
//   ShadowProj[1]          const_29       1
//   ShadowProj[2]          const_30       1
//   ShadowProj[3]          const_31       1
//   ShadowProjData      const_32      1
//   ShadowProjTransform const_33      1
//

// Structures:

struct VS_INPUT {
    float4 Position : POSITION;
    float3 Tangent : TANGENT;
    float3 BiNormal : BINORMAL;
    float3 Normal : NORMAL;
    float4 BaseUV : TEXCOORD0;

#define	TanSpaceProj	float3x3(IN.Tangent.xyz, IN.BiNormal.xyz, IN.Normal.xyz)
};

struct VS_OUTPUT {
    // PAR2024.pso

    float4 Position : POSITION;
    float2 BaseUV : TEXCOORD0;
    float3 Light0Dir : TEXCOORD1;
    float3 Light0Spc : TEXCOORD3;
    float4 ShadowUV : TEXCOORD6;
    float3 CameraDir : TEXCOORD7;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

    /* original shader --------------------------------------- */

    float3 eye0;
    float3 spc0;
    float4 shw;

    shw.xyzw = mul(ShadowProj, IN.Position.xyzw);

    eye0.xyz = EyePosition.xyz - IN.Position.xyz;
    spc0.xyz = normalize(eye0.xyz) + LightDirection[0].xyz;

    OUT.Position.xyzw = mul(ModelViewProj, IN.Position.xyzw);
    OUT.Light0Dir.xyz = mul(TanSpaceProj, LightDirection[0].xyz);
    OUT.Light0Spc.xyz = mul(TanSpaceProj, spc0);
    OUT.CameraDir.xyz = mul(TanSpaceProj, eye0.xyz);

    OUT.BaseUV.xy = IN.BaseUV.xy;
    OUT.ShadowUV.xy = ((shw.w * ShadowProjTransform.xy) + shw.xy) / (shw.w * ShadowProjTransform.w);
    OUT.ShadowUV.zw = ((shw.xy - ShadowProjData.xy) / ShadowProjData.w) * float2(1, -1) + float2(0, 1);

    OUT.Light0Dir.xyz = normalize(OUT.Light0Dir.xyz);
    OUT.Light0Spc.xyz = normalize(OUT.Light0Spc.xyz);

    return OUT;
};

// approximately 40 instruction slots used
