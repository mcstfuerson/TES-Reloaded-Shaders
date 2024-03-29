//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SKIN2006.vso /Fcshaderdump19/SKIN2006.vso.dis
//
//
// Parameters:
//
float4 EyePosition : register(c25);
float3 FogColor : register(c24);
float4 FogParam : register(c23);
float3 LightDirection[3] : register(c13);
float4 LightPosition[3] : register(c16);
row_major float4x4 ModelViewProj : register(c0);
row_major float4x4 ShadowProj : register(c28);
float4 ShadowProjData : register(c32);
float4 ShadowProjTransform : register(c33);

row_major float4x4 TESR_ShadowCameraToLightTransform[2] : register(c34);
row_major float4x4 TESR_InvViewProjectionTransform : register(c97);
row_major float4x4 TESR_ShadowCameraToLightTransformSkin : register(c101);
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
//   LightPosition[0]       const_16       1
//   LightPosition[1]       const_17       1
//   FogParam            const_23      1
//   FogColor            const_24      1
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
    float4 position : POSITION;
    float3 tangent : TANGENT;
    float3 binormal : BINORMAL;
    float3 normal : NORMAL;
    float4 texcoord_0 : TEXCOORD0;
    float4 color_0 : COLOR0;

#define	TanSpaceProj	float3x3(IN.tangent.xyz, IN.binormal.xyz, IN.normal.xyz)
};

struct VS_OUTPUT {
    float4 color_0 : COLOR0;
    float4 color_1 : COLOR1;
    float4 position : POSITION;
    float2 texcoord_0 : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1;
    float3 texcoord_2 : TEXCOORD2;
    float4 texcoord_4 : TEXCOORD4;
    float4 texcoord_5 : TEXCOORD5; //Shadow Near
    float3 texcoord_6 : TEXCOORD6;
    float4 texcoord_7 : TEXCOORD7; //Shadow Far
    float4 texcoord_8 : TEXCOORD8; //Inverse pos
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)

    float3 lit1;
    float2 m22;
    float3 mdl15;
    float1 q3;

    mdl15.xyz = mul(float3x4(ModelViewProj[0].xyzw, ModelViewProj[1].xyzw, ModelViewProj[2].xyzw), IN.position.xyzw);
    lit1.xyz = LightPosition[1].xyz - IN.position.xyz;
    OUT.color_0.rgba = IN.color_0.rgba;
    OUT.color_1.a = 1 - saturate((FogParam.x - length(mdl15.xyz)) / FogParam.y);
    OUT.color_1.rgb = FogColor.rgb;
    OUT.position.w = dot(ModelViewProj[3].xyzw, IN.position.xyzw);
    OUT.position.xyz = mdl15.xyz;
    OUT.texcoord_0.xy = IN.texcoord_0.xy;
    OUT.texcoord_1.xyz = normalize(mul(TanSpaceProj, LightDirection[0].xyz));
    OUT.texcoord_2.xyz = mul(TanSpaceProj, normalize(lit1.xyz));
    OUT.texcoord_4.w = 0.5;
    OUT.texcoord_4.xyz = compress(lit1.xyz / LightPosition[1].w);
    OUT.texcoord_6.xyz = normalize(mul(TanSpaceProj, normalize(EyePosition.xyz - IN.position.xyz)));
    OUT.texcoord_7 = mul(OUT.position, TESR_ShadowCameraToLightTransform[0]);
    OUT.texcoord_5 = mul(OUT.position, TESR_ShadowCameraToLightTransformSkin);
    OUT.texcoord_8 = mul(OUT.position, TESR_InvViewProjectionTransform);

    return OUT;
};

// approximately 56 instruction slots used
