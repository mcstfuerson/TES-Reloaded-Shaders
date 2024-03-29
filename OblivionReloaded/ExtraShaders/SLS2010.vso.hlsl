//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SLS2010.vso /Fcshaderdump19/SLS2010.vso.dis
//
//
// Parameters:

float4 Bones[54] : register(c42);
float3 FogColor : register(c24);
float4 FogParam : register(c23);
float3 LightDirection[3] : register(c13);
float4 LightPosition[3] : register(c16);
row_major float4x4 ShadowProj : register(c28);
float4 ShadowProjData : register(c32);
float4 ShadowProjTransform : register(c33);
row_major float4x4 SkinModelViewProj : register(c1);
row_major float4x4 TESR_ShadowCameraToLightTransform[2] : register(c34);
row_major float4x4 TESR_InvViewProjectionTransform : register(c97);

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
//   FogParam            const_23      1
//   FogColor            const_24      1
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
    float4 LPOSITION : POSITION;
    float3 LTANGENT : TANGENT;
    float3 LBINORMAL : BINORMAL;
    float3 LNORMAL : NORMAL;
    float4 LTEXCOORD_0 : TEXCOORD0;
    float4 LCOLOR_0 : COLOR0;
    float3 LBLENDWEIGHT : BLENDWEIGHT;
    float4 LBLENDINDICES : BLENDINDICES;
};

struct VS_OUTPUT {
    float4 color_0 : COLOR0;
    float4 color_1 : COLOR1;
    float4 position : POSITION;
    float2 texcoord_0 : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1;
    float3 texcoord_2 : TEXCOORD2;
    float4 texcoord_4 : TEXCOORD4;
	float4 texcoord_6 : TEXCOORD6;
    float4 texcoord_7 : TEXCOORD7;
    float4 texcoord_8 : TEXCOORD8;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	weight(v)		dot(v, 1)
#define	sqr(v)			((v) * (v))

    const float4 const_0 = {1, 765.01001, 0, 0.5};

    float3 lit1;
    float3 m26;
    float4 mdl20;
    float4 offset;
    float4 q0;
    float3 q15;
    float3 q16;
    float3 q17;
    float3 q18;
    float3 q19;
    float3 q25;
    float3 q36;
    float4 r0;
    float3 r1;
    float3 r2;
    float3 r4;
    float3 r5;
    float3 r6;

    OUT.color_0.rgba = IN.LCOLOR_0.xyzw;
    offset.xyzw = IN.LBLENDINDICES.zyxw * 765.01001;
    r1.z = dot(Bones[2 + offset.y].xyz, IN.LTANGENT.xyz);
    r1.y = dot(Bones[1 + offset.y].xyz, IN.LTANGENT.xyz);
    r1.x = dot(Bones[0 + offset.y].xyz, IN.LTANGENT.xyz);
    r2.xyz = r1.xyz * IN.LBLENDWEIGHT.y;
    r1.z = dot(Bones[2 + offset.x].xyz, IN.LTANGENT.xyz);
    r1.y = dot(Bones[1 + offset.x].xyz, IN.LTANGENT.xyz);
    r1.x = dot(Bones[0 + offset.x].xyz, IN.LTANGENT.xyz);
    r0.w = 1;
    q0.xyzw = (IN.LPOSITION.xyzx * const_0.xxxz) + const_0.zzzx;
    q19.xyz = mul(float3x4(Bones[0 + offset.w].xyzw, Bones[1 + offset.w].xyzw, Bones[2 + offset.w].xyzw), q0.xyzw);
    q17.xyz = mul(float3x4(Bones[0 + offset.z].xyzw, Bones[1 + offset.z].xyzw, Bones[2 + offset.z].xyzw), q0.xyzw);
    q16.xyz = mul(float3x4(Bones[0 + offset.x].xyzw, Bones[1 + offset.x].xyzw, Bones[2 + offset.x].xyzw), q0.xyzw);
    q15.xyz = mul(float3x4(Bones[0 + offset.y].xyzw, Bones[1 + offset.y].xyzw, Bones[2 + offset.y].xyzw), q0.xyzw);
    q18.xyz = (IN.LBLENDWEIGHT.z * q17.xyz) + ((IN.LBLENDWEIGHT.x * q16.xyz) + (q15.xyz * IN.LBLENDWEIGHT.y));
    r2.xyz = (IN.LBLENDWEIGHT.x * r1.xyz) + r2.xyz;
    r1.z = dot(Bones[2 + offset.z].xyz, IN.LTANGENT.xyz);
    r1.y = dot(Bones[1 + offset.z].xyz, IN.LTANGENT.xyz);
    r1.x = dot(Bones[0 + offset.z].xyz, IN.LTANGENT.xyz);
    r2.xyz = (IN.LBLENDWEIGHT.z * r1.xyz) + r2.xyz;
    r1.z = dot(Bones[2 + offset.w].xyz, IN.LTANGENT.xyz);
    r1.y = dot(Bones[1 + offset.w].xyz, IN.LTANGENT.xyz);
    r1.x = dot(Bones[0 + offset.w].xyz, IN.LTANGENT.xyz);
    r1.xyz = ((1 - weight(IN.LBLENDWEIGHT.xyz)) * r1.xyz) + r2.xyz;
    r5.xyz = normalize(r1.xyz);
    r1.z = dot(Bones[2 + offset.y].xyz, IN.LBINORMAL.xyz);
    r1.y = dot(Bones[1 + offset.y].xyz, IN.LBINORMAL.xyz);
    r1.x = dot(Bones[0 + offset.y].xyz, IN.LBINORMAL.xyz);
    r2.xyz = r1.xyz * IN.LBLENDWEIGHT.y;
    r1.z = dot(Bones[2 + offset.x].xyz, IN.LBINORMAL.xyz);
    r1.y = dot(Bones[1 + offset.x].xyz, IN.LBINORMAL.xyz);
    r1.x = dot(Bones[0 + offset.x].xyz, IN.LBINORMAL.xyz);
    r2.xyz = (IN.LBLENDWEIGHT.x * r1.xyz) + r2.xyz;
    r1.z = dot(Bones[2 + offset.z].xyz, IN.LBINORMAL.xyz);
    r1.y = dot(Bones[1 + offset.z].xyz, IN.LBINORMAL.xyz);
    r1.x = dot(Bones[0 + offset.z].xyz, IN.LBINORMAL.xyz);
    r6.xyz = (IN.LBLENDWEIGHT.z * r1.xyz) + r2.xyz;
    r1.z = dot(Bones[2 + offset.y].xyz, IN.LNORMAL.xyz);
    r2.z = dot(Bones[2 + offset.w].xyz, IN.LBINORMAL.xyz);
    r1.y = dot(Bones[1 + offset.y].xyz, IN.LNORMAL.xyz);
    r2.y = dot(Bones[1 + offset.w].xyz, IN.LBINORMAL.xyz);
    r1.x = dot(Bones[0 + offset.y].xyz, IN.LNORMAL.xyz);
    r4.xyz = r1.xyz * IN.LBLENDWEIGHT.y;
    r1.z = dot(Bones[2 + offset.x].xyz, IN.LNORMAL.xyz);
    r1.y = dot(Bones[1 + offset.x].xyz, IN.LNORMAL.xyz);
    r1.x = dot(Bones[0 + offset.x].xyz, IN.LNORMAL.xyz);
    r2.x = dot(Bones[0 + offset.w].xyz, IN.LBINORMAL.xyz);
    q36.xyz = normalize(((1 - weight(IN.LBLENDWEIGHT.xyz)) * r2.xyz) + r6.xyz);
    r4.xyz = (IN.LBLENDWEIGHT.x * r1.xyz) + r4.xyz;
    r1.z = dot(Bones[2 + offset.z].xyz, IN.LNORMAL.xyz);
    r1.y = dot(Bones[1 + offset.z].xyz, IN.LNORMAL.xyz);
    r1.x = dot(Bones[0 + offset.z].xyz, IN.LNORMAL.xyz);
    r4.xyz = (IN.LBLENDWEIGHT.z * r1.xyz) + r4.xyz;
    r1.z = dot(Bones[2 + offset.w].xyz, IN.LNORMAL.xyz);
    r1.y = dot(Bones[1 + offset.w].xyz, IN.LNORMAL.xyz);
    r1.x = dot(Bones[0 + offset.w].xyz, IN.LNORMAL.xyz);
    q25.xyz = normalize(((1 - weight(IN.LBLENDWEIGHT.xyz)) * r1.xyz) + r4.xyz);
    m26.xyz = mul(float3x3(r5.xyz, q36.xyz, q25.xyz), LightDirection[0].xyz);
    r0.xyz = ((1 - weight(IN.LBLENDWEIGHT.xyz)) * q19.xyz) + q18.xyz;
    mdl20 = mul(SkinModelViewProj, r0.xyzw);
    lit1.xyz = LightPosition[1].xyz - r0.xyz;
    OUT.color_1.rgb = FogColor.rgb;
    OUT.color_1.a = 1 - saturate((FogParam.x - length(mdl20.xyz)) / FogParam.y);
    OUT.position = mdl20;
    OUT.texcoord_0.xy = IN.LTEXCOORD_0.xy;
    OUT.texcoord_1.xyz = normalize(m26.xyz);
    OUT.texcoord_2.xyz = mul(float3x3(r5.xyz, q36.xyz, q25.xyz), normalize(lit1.xyz));
    OUT.texcoord_4.w = 0.5;
    OUT.texcoord_4.xyz = compress(lit1.xyz / LightPosition[1].w);	// [-1,+1] to [0,1]
    OUT.texcoord_6 = mul(mdl20, TESR_ShadowCameraToLightTransform[0]);
	OUT.texcoord_7 = mul(mdl20, TESR_ShadowCameraToLightTransform[1]);
    OUT.texcoord_8 = mul(mdl20, TESR_InvViewProjectionTransform);
    return OUT;
};

// approximately 126 instruction slots used
