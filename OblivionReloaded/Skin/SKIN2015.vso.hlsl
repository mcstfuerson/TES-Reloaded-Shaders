//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SKIN2015.vso /Fcshaderdump19/SKIN2015.vso.dis
//
//
// Parameters:
//
float4 Bones[54] : register(c42);
float4 EyePosition : register(c25);
float3 LightDirection[3] : register(c13);
float4 LightPosition[3] : register(c16);
row_major float4x4 ShadowProj : register(c28);
float4 ShadowProjData : register(c32);
float4 ShadowProjTransform : register(c33);
row_major float4x4 SkinModelViewProj : register(c1);
row_major float4x4 TESR_ShadowCameraToLightTransform[2] : register(c34);
//
//
// Registers:
//
//   Name                Reg   Size
//   ------------------- ----- ----
//   SkinModelViewProj[0]   const_1        1
//   SkinModelViewProj[1]   const_2        1
//   SkinModelViewProj[2]   const_3        1
//   SkinModelViewProj[3]   const_4        1
//   LightDirection[0]      const_13       1
//   LightPosition[0]       const_16       1
//   LightPosition[1]       const_17       1
//   LightPosition[2]       const_18       1
//   EyePosition         const_25      1
//   ShadowProj[0]          const_28       1
//   ShadowProj[1]          const_29       1
//   ShadowProj[2]          const_30       1
//   ShadowProj[3]          const_31       1
//   ShadowProjData      const_32      1
//   ShadowProjTransform const_33      1
//   Bones[0]               const_42      18
//   Bones[1]               const_43      18
//   Bones[2]               const_44      18
//


// Structures:

struct VS_INPUT {
    float4 Position : POSITION;
    float3 tangent : TANGENT;
    float3 binormal : BINORMAL;
    float3 normal : NORMAL;
    float4 BaseUV : TEXCOORD0;
    float3 blendweight : BLENDWEIGHT;
    float4 blendindices : BLENDINDICES;
};

struct VS_OUTPUT {
    float4 Position : POSITION;
    float2 BaseUV : TEXCOORD0;
    float4 Light0Dir : TEXCOORD1;
    float4 Light1Dir : TEXCOORD2;
    float4 Light2Dir : TEXCOORD3;
    float4 Att1UV : TEXCOORD4;
    float4 Att2UV : TEXCOORD5;
    float4 ShadowUV0 : TEXCOORD6;
    float4 ShadowUV1 : TEXCOORD7;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	weight(v)		dot(v, 1)
#define	sqr(v)			((v) * (v))

    const float4 const_0 = {1, 765.01001, 0, 0.5};

    float3 eye129;
    float3 lit3;
    float3 lit5;
    float4 m157;
    float3 m95;
    float4 offset;
    float1 q0;
    float4 q1;
    float3 q23;
    float3 q24;
    float3 q25;
    float3 q26;
    float3 q27;
    float3 q28;
    float3 q29;
    float3 q30;
    float3 q31;
    float3 q32;
    float3 q33;
    float3 q34;
    float3 q35;
    float3 q36;
    float3 q37;
    float3 q38;
    float3 q39;
    float3 q40;
    float3 q41;
    float3 q42;
    float3 q43;
    float3 q44;
    float3 q45;
    float4 r0;
	float3 camera;
	
    offset.xyzw = IN.blendindices.zyxw * 765.01001;
    q32.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.tangent.xyz);
    q30.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.tangent.xyz);
    q29.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.tangent.xyz);
    q28.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.tangent.xyz);
    q44.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.normal.xyz);
    q42.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.normal.xyz);
    q41.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.normal.xyz);
    q40.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.normal.xyz);
    q38.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.binormal.xyz);
    q36.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.binormal.xyz);
    q35.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.binormal.xyz);
    q34.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.binormal.xyz);
    q0.x = 1 - weight(IN.blendweight.xyz);
    r0.w = 1;
    q1.xyzw = (IN.Position.xyzx * const_0.xxxz) + const_0.zzzx;
    q27.xyz = mul(float3x4(Bones[0 + offset.w].xyzw, Bones[1 + offset.w].xyzw, Bones[2 + offset.w].xyzw), q1.xyzw);
    q25.xyz = mul(float3x4(Bones[0 + offset.z].xyzw, Bones[1 + offset.z].xyzw, Bones[2 + offset.z].xyzw), q1.xyzw);
    q24.xyz = mul(float3x4(Bones[0 + offset.x].xyzw, Bones[1 + offset.x].xyzw, Bones[2 + offset.x].xyzw), q1.xyzw);
    q23.xyz = mul(float3x4(Bones[0 + offset.y].xyzw, Bones[1 + offset.y].xyzw, Bones[2 + offset.y].xyzw), q1.xyzw);
    q43.xyz = (IN.blendweight.z * q42.xyz) + ((IN.blendweight.x * q41.xyz) + (q40.xyz * IN.blendweight.y));
    q45.xyz = normalize((q0.x * q44.xyz) + q43.xyz);
    q37.xyz = (IN.blendweight.z * q36.xyz) + ((IN.blendweight.x * q35.xyz) + (q34.xyz * IN.blendweight.y));
    q39.xyz = normalize((q0.x * q38.xyz) + q37.xyz);
    q31.xyz = (IN.blendweight.z * q30.xyz) + ((IN.blendweight.x * q29.xyz) + (q28.xyz * IN.blendweight.y));
    q33.xyz = normalize((q0.x * q32.xyz) + q31.xyz);
    m95.xyz = mul(float3x3(q33.xyz, q39.xyz, q45.xyz), LightDirection[0].xyz);
    q26.xyz = (IN.blendweight.z * q25.xyz) + ((IN.blendweight.x * q24.xyz) + (q23.xyz * IN.blendweight.y));
    r0.xyz = (q0.x * q27.xyz) + q26.xyz;
	
    eye129.xyz = mul(float3x3(q33.xyz, q39.xyz, q45.xyz), normalize(EyePosition.xyz - r0.xyz));
    m157 = mul(SkinModelViewProj, r0.xyzw);
    lit5.xyz = LightPosition[2].xyz - r0.xyz;
    lit3.xyz = LightPosition[1].xyz - r0.xyz;
	OUT.Position = m157;
    OUT.BaseUV.xy = IN.BaseUV.xy;
    OUT.Light0Dir.xyz = normalize(m95.xyz);
    OUT.Light1Dir.xyz = normalize(mul(float3x3(q33.xyz, q39.xyz, q45.xyz), lit3.xyz));
    OUT.Light2Dir.xyz = normalize(mul(float3x3(q33.xyz, q39.xyz, q45.xyz), lit5.xyz));
	camera.xyz = normalize(eye129.xyz);
	OUT.Light0Dir.w = camera.x;
	OUT.Light1Dir.w = camera.y;
	OUT.Light2Dir.w = camera.z;
    OUT.Att1UV.w = 0.5;
    OUT.Att1UV.xyz = compress(lit3.xyz / LightPosition[1].w);
    OUT.Att2UV.w = 0.5;
    OUT.Att2UV.xyz = compress(lit5.xyz / LightPosition[2].w);
    OUT.ShadowUV0 = mul(m157, TESR_ShadowCameraToLightTransform[0]);
	OUT.ShadowUV1 = mul(m157, TESR_ShadowCameraToLightTransform[1]);

    return OUT;
};

// approximately 136 instruction slots used
