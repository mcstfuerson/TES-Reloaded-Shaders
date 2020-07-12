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
row_major float4x4 TESR_ShadowCameraToLightTransform : register(c34);
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
    float4 Position : POSITION;
    float3 tangent : TANGENT;
    float3 binormal : BINORMAL;
    float3 normal : NORMAL;
    float4 BaseUV : TEXCOORD0;
    float4 Color : COLOR0;

#define	TanSpaceProj	float3x3(IN.tangent.xyz, IN.binormal.xyz, IN.normal.xyz)
};

struct VS_OUTPUT {
    float4 Color : COLOR0;
    float4 Fog : COLOR1;
    float4 Position : POSITION;
    float2 BaseUV : TEXCOORD0;
    float3 Light0Dir : TEXCOORD1;
    float3 Light1Dir : TEXCOORD2;
    float4 Att1UV : TEXCOORD4;
    float3 CameraDir : TEXCOORD6;
    float4 ShadowUV : TEXCOORD7;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)

    float3 lit1;
    float4 m22;
    float4 mdl15;

    mdl15 = mul(ModelViewProj, IN.Position.xyzw);
    m22 = mul(mdl15, TESR_ShadowCameraToLightTransform);
    lit1.xyz = LightPosition[1].xyz - IN.Position.xyz;
    OUT.Color.rgba = IN.Color.rgba;
    OUT.Fog.a = 1 - saturate((FogParam.x - length(mdl15.xyz)) / FogParam.y);
    OUT.Fog.rgb = FogColor.rgb;
    OUT.Position = mdl15;
    OUT.BaseUV.xy = IN.BaseUV.xy;
    OUT.Light0Dir.xyz = normalize(mul(TanSpaceProj, LightDirection[0].xyz));
    OUT.Light1Dir.xyz = mul(TanSpaceProj, normalize(lit1.xyz));
    OUT.Att1UV.w = 0.5;
    OUT.Att1UV.xyz = compress(lit1.xyz / LightPosition[1].w);	// [-1,+1] to [0,1]
    OUT.CameraDir.xyz = normalize(mul(TanSpaceProj, normalize(EyePosition.xyz - IN.Position.xyz)));
    OUT.ShadowUV = m22;

    return OUT;
};

// approximately 56 instruction slots used
