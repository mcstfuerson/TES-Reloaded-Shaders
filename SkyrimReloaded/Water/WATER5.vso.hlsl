//
// Generated by Microsoft (R) HLSL Shader Compiler 9.27.952.3022
//
// Parameters:

row_major float4x4 ModelViewProj : register(c0);
row_major float3x4 WorldMat : register(c4);
float4 QPosAdjust : register(c7);
float ObjectUV : register(c8);
float4 NormalsScroll0 : register(c9);
float4 NormalsScroll1 : register(c10);
float4 NormalsScale : register(c11);
float4 VSFogParam : register(c12);
float4 VSFogNearColor : register(c13);
float4 VSFogFarColor : register(c14);


// Registers:
//
//   Name           Reg   Size
//   -------------- ----- ----
//   ModelViewProj[0]  const_0        1
//   ModelViewProj[1]  const_1        1
//   ModelViewProj[2]  const_2        1
//   ModelViewProj[3]  const_3        1
//   WorldMat[0]       const_4       1
//   WorldMat[1]       const_5       1
//   WorldMat[2]       const_6       1
//   QPosAdjust        const_7       1
//   ObjectUV          const_8       1
//   NormalsScroll0    const_9       1
//   NormalsScroll1    const_10      1
//   NormalsScale      const_11      1
//   VSFogParam        const_12      1
//   VSFogNearColor    const_13      1
//   VSFogFarColor     const_14      1
//


// Structures:

struct VS_INPUT {
    float4 LPOSITION : POSITION;
    float4 LTEXCOORD_0 : TEXCOORD0;
};

struct VS_OUTPUT {
    float4 LPOSITION : POSITION;
    float4 LTEXCOORD_0 : TEXCOORD0;
    float4 LTEXCOORD_1 : TEXCOORD1;
    float4 LTEXCOORD_2 : TEXCOORD2;
    float4 LTEXCOORD_4 : TEXCOORD4;
    float4 LCOLOR_1 : COLOR1;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

    const float4 const_15 = {0.001, 1, 0, 0};

    float2 q0;
    float1 q1;
    float1 q2;
    float2 q4;
    float4 r0;
    float3 r1;
    float3 r2;
    float4 r3;

    r0.z = dot(WorldMat[2].xyzw, IN.LPOSITION.xyzw);
    r0.y = dot(WorldMat[1].xyzw, IN.LPOSITION.xyzw);
    r0.x = dot(WorldMat[0].xyzw, IN.LPOSITION.xyzw);
    OUT.LTEXCOORD_0.w = length(r0.xyz);
    OUT.LTEXCOORD_0.xyz = r0.xyz;
    r0.xy = r0.xy + QPosAdjust.xy;
    r3.zw = r0.xy / NormalsScale.z;
    r3.xy = r0.xy / NormalsScale.y;
    q0.xy = r0.xy / NormalsScale.x;
    r2.xyz = VSFogNearColor.rgb;
    r1.xyz = NormalsScale.xyz * 0.001;
    r0.y = 1.0 / r1.z;
    r0.x = 1.0 / r1.y;
    r0.xyzw = lerp(r3.xyzw, r0.xxyy * IN.LTEXCOORD_0.xyxy, (-abs(ObjectUV.x) < abs(ObjectUV.x) ? 1.0 : 0.0));
    OUT.LTEXCOORD_1.zw = r0.xy + NormalsScroll0.zw;
    r0.y = dot(ModelViewProj[1].xyzw, IN.LPOSITION.xyzw);
    r0.x = dot(ModelViewProj[0].xyzw, IN.LPOSITION.xyzw);
    q4.xy = ((-abs(ObjectUV.x) < abs(ObjectUV.x) ? 1.0 : 0.0) * ((IN.LTEXCOORD_0.xy / r1.x) - q0.xy)) + q0.xy;
    OUT.LTEXCOORD_1.xy = q4.xy + NormalsScroll0.xy * -1;
    OUT.LTEXCOORD_2.xy = r0.zw + NormalsScroll1.xy;
    r0.w = dot(ModelViewProj[3].xyzw, IN.LPOSITION.xyzw);
    r0.z = dot(ModelViewProj[2].xyzw, IN.LPOSITION.xyzw);
    OUT.LPOSITION.xyzw = r0.xyzw;
    q1.x = pow(abs(saturate((length(r0.xyz) * VSFogParam.y) - VSFogParam.x)), NormalsScale.w);
    q2.x = min(q1.x, VSFogFarColor.a);
    OUT.LCOLOR_1.xyz = (q2.x * (VSFogFarColor.xxy - r2.xxy)) + VSFogNearColor.rgb;
    OUT.LCOLOR_1.w = q2.x;
    OUT.LTEXCOORD_2.zw = r0.w * const_15.yz;
    OUT.LTEXCOORD_4.xyzw = IN.LPOSITION.xyzw;

    return OUT;
};