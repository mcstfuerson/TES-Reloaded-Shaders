//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SM3001.vso /Fcshaderdump19/SM3001.vso.dis
//
//
// Parameters:
//
float4 Bones[54] : register(c31);
float4 FogColor : register(c16);
float4 FogParam : register(c15);
row_major float4x4 SkinModelViewProj : register(c1);
row_major float4x4 TESR_InvViewProjectionTransform : register(c86);
//
//
// Registers:
//
//   Name              Reg   Size
//   ----------------- ----- ----
//   SkinModelViewProj[0] const_1        1
//   SkinModelViewProj[1] const_2        1
//   SkinModelViewProj[2] const_3        1
//   SkinModelViewProj[3] const_4        1
//   FogParam          const_15      1
//   FogColor          const_16      1
//   Bones[0]             const_31      18
//   Bones[1]             const_32      18
//   Bones[2]             const_33      18
//


// Structures:

struct VS_INPUT {
    float4 position : POSITION;
    float3 tangent : TANGENT;
    float3 binormal : BINORMAL;
    float3 normal : NORMAL;
    float4 texcoord_0 : TEXCOORD0;
    float3 blendweight : BLENDWEIGHT;
    float4 blendindices : BLENDINDICES;
};

struct VS_OUTPUT {
    float4 position : POSITION;
    float2 texcoord_0 : TEXCOORD0;
    float4 color_0 : COLOR0;
    float3 texcoord_3 : TEXCOORD3;
    float3 texcoord_4 : TEXCOORD4;
    float3 texcoord_5 : TEXCOORD5;
    float3 texcoord_6 : TEXCOORD6;
    float4 texcoord_7 : TEXCOORD7;
    float4 texcoord_8 : TEXCOORD8;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	weight(v)		dot(v, 1)
#define	sqr(v)			((v) * (v))

    const float4 const_0 = {1, 765.01001, 0, 0};

    float3 mdl31;
    float4 offset;
    float1 q0;
    float4 q1;
    float3 q10;
    float3 q11;
    float3 q12;
    float3 q13;
    float3 q14;
    float3 q15;
    float3 q16;
    float3 q17;
    float3 q18;
    float3 q19;
    float1 q2;
    float3 q21;
    float3 q22;
    float3 q23;
    float3 q24;
    float3 q25;
    float3 q26;
    float3 q27;
    float3 q28;
    float3 q29;
    float3 q30;
    float4 r0;

    offset.xyzw = 765.01001 * IN.blendindices.zyxw;
    q19.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.tangent.xyz);
    q17.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.tangent.xyz);
    q16.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.tangent.xyz);
    q15.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.tangent.xyz);
    q14.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.normal.xyz);
    q12.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.normal.xyz);
    q11.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.normal.xyz);
    q10.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.normal.xyz);
    q25.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.binormal.xyz);
    q23.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.binormal.xyz);
    q22.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.binormal.xyz);
    q21.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.binormal.xyz);
    q0.x = 1 - weight(IN.blendweight.xyz);
    r0.w = 1;
    OUT.color_0.rgba = 1;
    OUT.texcoord_0.xy = IN.texcoord_0.xy;
    q24.xyz = (IN.blendweight.z * q23.xyz) + ((IN.blendweight.x * q22.xyz) + (q21.xyz * IN.blendweight.y));
    q18.xyz = (IN.blendweight.z * q17.xyz) + ((IN.blendweight.x * q16.xyz) + (q15.xyz * IN.blendweight.y));
    OUT.texcoord_3.xyz = normalize((q0.x * q19.xyz) + q18.xyz);
    OUT.texcoord_4.xyz = normalize((q0.x * q25.xyz) + q24.xyz);
    q13.xyz = (IN.blendweight.z * q12.xyz) + ((IN.blendweight.x * q11.xyz) + (q10.xyz * IN.blendweight.y));
    OUT.texcoord_5.xyz = normalize((q0.x * q14.xyz) + q13.xyz);
    q1.xyzw = (IN.position.xyzx * const_0.xxxz) + const_0.zzzx;
    q30.xyz = mul(float3x4(Bones[0 + offset.w].xyzw, Bones[1 + offset.w].xyzw, Bones[2 + offset.w].xyzw), q1.xyzw);
    q28.xyz = mul(float3x4(Bones[0 + offset.z].xyzw, Bones[1 + offset.z].xyzw, Bones[2 + offset.z].xyzw), q1.xyzw);
    q27.xyz = mul(float3x4(Bones[0 + offset.x].xyzw, Bones[1 + offset.x].xyzw, Bones[2 + offset.x].xyzw), q1.xyzw);
    q26.xyz = mul(float3x4(Bones[0 + offset.y].xyzw, Bones[1 + offset.y].xyzw, Bones[2 + offset.y].xyzw), q1.xyzw);
    q29.xyz = (IN.blendweight.z * q28.xyz) + ((IN.blendweight.x * q27.xyz) + (q26.xyz * IN.blendweight.y));
    r0.xyz = (q0.x * q30.xyz) + q29.xyz;
    mdl31.xyz = mul(float3x4(SkinModelViewProj[0].xyzw, SkinModelViewProj[1].xyzw, SkinModelViewProj[2].xyzw), r0.xyzw);
    OUT.position.w = dot(SkinModelViewProj[3].xyzw, r0.xyzw);
    OUT.position.xyz = mdl31.xyz;
    OUT.texcoord_6.xyz = r0.xyz;
    q2.x = 1 - saturate((FogParam.x - length(mdl31.xyz)) / FogParam.y);
    OUT.texcoord_7.xyz = FogColor.rgb;
    OUT.texcoord_7.w = q2.x * FogParam.z;
    OUT.texcoord_8 = mul(OUT.position, TESR_InvViewProjectionTransform);

    return OUT;
};

// approximately 98 instruction slots used
