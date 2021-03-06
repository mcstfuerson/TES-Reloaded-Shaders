//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SKIN2019.vso /Fcshaderdump19/SKIN2019.vso.dis
//
//
// Parameters:
//
float4 Bones[54] : register(c42);
float4 EyePosition : register(c25);
float4 LightPosition[3] : register(c16);
row_major float4x4 SkinModelViewProj : register(c1);
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
//   LightPosition[0]     const_16       1
//   LightPosition[1]     const_17       1
//   LightPosition[2]     const_18       1
//   EyePosition       const_25      1
//   Bones[0]             const_42      18
//   Bones[1]             const_43      18
//   Bones[2]             const_44      18
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
    float3 Light0Dir : TEXCOORD1;
    float3 Light1Dir : TEXCOORD2;
    float3 Light2Dir : TEXCOORD3;
    float4 Att0UV : TEXCOORD4;
    float4 Att1UV : TEXCOORD5;
    float4 Att2UV : TEXCOORD6;
    float3 CameraDir : TEXCOORD7;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	weight(v)		dot(v, 1)
#define	sqr(v)			((v) * (v))

    const float4 const_0 = {1, 765.01001, 0, 0.5};

    float3 eye58;
    float3 lit14;
    float3 lit4;
    float3 lit6;
    float4 offset;
    float1 q0;
    float4 q1;
    float3 q12;
    float3 q3;
    float3 q31;
    float3 q32;
    float3 q33;
    float3 q34;
    float3 q35;
    float3 q38;
    float3 q39;
    float3 q40;
    float3 q41;
    float3 q42;
    float3 q43;
    float3 q44;
    float3 q45;
    float3 q46;
    float3 q47;
    float3 q48;
    float3 q50;
    float3 q51;
    float3 q52;
    float3 q53;
    float3 q54;
    float4 r0;

    offset.xyzw = IN.blendindices.zyxw * 765.01001;
    q42.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.tangent.xyz);
    q40.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.tangent.xyz);
    q39.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.tangent.xyz);
    q38.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.tangent.xyz);
    q54.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.normal.xyz);
    q52.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.normal.xyz);
    q51.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.normal.xyz);
    q50.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.normal.xyz);
    q48.xyz = mul(float3x3(Bones[0 + offset.w].xyz, Bones[1 + offset.w].xyz, Bones[2 + offset.w].xyz), IN.binormal.xyz);
    q46.xyz = mul(float3x3(Bones[0 + offset.z].xyz, Bones[1 + offset.z].xyz, Bones[2 + offset.z].xyz), IN.binormal.xyz);
    q45.xyz = mul(float3x3(Bones[0 + offset.x].xyz, Bones[1 + offset.x].xyz, Bones[2 + offset.x].xyz), IN.binormal.xyz);
    q44.xyz = mul(float3x3(Bones[0 + offset.y].xyz, Bones[1 + offset.y].xyz, Bones[2 + offset.y].xyz), IN.binormal.xyz);
    q0.x = 1 - weight(IN.blendweight.xyz);
    r0.w = 1;
    q1.xyzw = (IN.Position.xyzx * const_0.xxxz) + const_0.zzzx;
    q35.xyz = mul(float3x4(Bones[0 + offset.w].xyzw, Bones[1 + offset.w].xyzw, Bones[2 + offset.w].xyzw), q1.xyzw);
    q33.xyz = mul(float3x4(Bones[0 + offset.z].xyzw, Bones[1 + offset.z].xyzw, Bones[2 + offset.z].xyzw), q1.xyzw);
    q32.xyz = mul(float3x4(Bones[0 + offset.x].xyzw, Bones[1 + offset.x].xyzw, Bones[2 + offset.x].xyzw), q1.xyzw);
    q31.xyz = mul(float3x4(Bones[0 + offset.y].xyzw, Bones[1 + offset.y].xyzw, Bones[2 + offset.y].xyzw), q1.xyzw);
    q53.xyz = (IN.blendweight.z * q52.xyz) + ((IN.blendweight.x * q51.xyz) + (q50.xyz * IN.blendweight.y));
    q47.xyz = (IN.blendweight.z * q46.xyz) + ((IN.blendweight.x * q45.xyz) + (q44.xyz * IN.blendweight.y));
    q12.xyz = normalize((q0.x * q48.xyz) + q47.xyz);
    q41.xyz = (IN.blendweight.z * q40.xyz) + ((IN.blendweight.x * q39.xyz) + (q38.xyz * IN.blendweight.y));
    q43.xyz = normalize((q0.x * q42.xyz) + q41.xyz);
    q34.xyz = (IN.blendweight.z * q33.xyz) + ((IN.blendweight.x * q32.xyz) + (q31.xyz * IN.blendweight.y));
    r0.xyz = (q0.x * q35.xyz) + q34.xyz;
    q3.xyz = normalize((q0.x * q54.xyz) + q53.xyz);
    eye58.xyz = mul(float3x3(q43.xyz, q12.xyz, q3.xyz), normalize(EyePosition.xyz - r0.xyz));
    OUT.Position.xyzw = mul(SkinModelViewProj, r0.xyzw);
    lit6.xyz = LightPosition[2].xyz - r0.xyz;
    lit14.xyz = LightPosition[1].xyz - r0.xyz;
    lit4.xyz = LightPosition[0].xyz - r0.xyz;
    OUT.BaseUV.xy = IN.BaseUV.xy;
    OUT.Light0Dir.xyz = mul(float3x3(q43.xyz, q12.xyz, q3.xyz), normalize(lit4.xyz));
    OUT.Light1Dir.xyz = mul(float3x3(q43.xyz, q12.xyz, q3.xyz), normalize(lit14.xyz));
    OUT.Light2Dir.xyz = mul(float3x3(q43.xyz, q12.xyz, q3.xyz), normalize(lit6.xyz));
    OUT.Att0UV.w = 0.5;
    OUT.Att0UV.xyz = compress(lit4.xyz / LightPosition[0].w);	// [-1,+1] to [0,1]
    OUT.Att1UV.w = 0.5;
    OUT.Att1UV.xyz = compress(lit14.xyz / LightPosition[1].w);	// [-1,+1] to [0,1]
    OUT.Att2UV.w = 0.5;
    OUT.Att2UV.xyz = compress(lit6.xyz / LightPosition[2].w);	// [-1,+1] to [0,1]
    OUT.CameraDir.xyz = normalize(eye58.xyz);

    return OUT;
};

// approximately 129 instruction slots used
