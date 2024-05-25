//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SM3003.pso /Fcshaderdump19/SM3003.pso.dis
//
//
// Parameters:
//
float4 AmbientColor : register(c0);
sampler2D AnisoMap : register(s4);
sampler2D BaseMap : register(s0);
float3 EyePosition : register(c1);
float3 HairTint : register(c2);
sampler2D LayerMap : register(s5);
float4 LightData[16] : register(c9);
float3 MatAlpha : register(c3);
sampler2D NormalMap : register(s1);
float4 ToggleADTS : register(c5);
float4 ToggleNumLights : register(c6);
//
//
// Registers:
//
//   Name            Reg   Size
//   --------------- ----- ----
//   AmbientColor    const_0       1
//   EyePosition     const_1       1
//   HairTint        const_2       1
//   MatAlpha        const_3       1
//   ToggleADTS      const_5       1
//   ToggleNumLights const_6       1
//   LightData[0]       const_9        1
//   LightData[1]       const_10        1
//   LightData[2]       const_11        1
//   LightData[3]       const_12        1
//   LightData[4]       const_13        1
//   LightData[5]       const_14        1
//   LightData[6]       const_15        1
//   LightData[7]       const_16        1
//   LightData[8]       const_17       1
//   LightData[9]       const_18       1
//   LightData[10]       const_19       1
//   LightData[11]       const_20       1
//   LightData[12]       const_21       1
//   LightData[13]       const_22       1
//   LightData[14]       const_23       1
//   LightData[15]       const_24       1
//   BaseMap         texture_0       1
//   NormalMap       texture_1       1
//   AnisoMap        texture_4       1
//   LayerMap        texture_5       1
//


// Structures:

struct VS_OUTPUT {
    float2 BaseUV : TEXCOORD0;			// partial precision
    float2 color_0 : COLOR0;			// partial precision
    float3 texcoord_3 : TEXCOORD3_centroid;			// partial precision
    float3 texcoord_4 : TEXCOORD4_centroid;			// partial precision
    float3 texcoord_5 : TEXCOORD5_centroid;			// partial precision
    float3 texcoord_6 : TEXCOORD6_centroid;			// partial precision
    float4 texcoord_7 : TEXCOORD7_centroid;			// partial precision
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

// Code:

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)		saturate(dot(n, l))
#define	weight(v)		dot(v, 1)
#define	sqr(v)			((v) * (v))

    const int4 const_25 = {-6, -7, -8, 7};
    const int4 const_26 = {-8, -9, -10, 0};
    const int4 const_27 = {2, -14, -15, 0};
    const int4 const_28 = {-12, -13, -14, 0};
    const int4 const_30 = {-1, -2, 0, 2};
    const int4 const_31 = {-4, -5, -6, 6};
    const int4 const_32 = {-10, -11, -12, 0};
    const float4 const_4 = {-0.05, 0, 0.7, 8};
    const int4 const_7 = {-2, -3, -4, 5};
    const float4 const_8 = {-0.5, 0, 1, 0.5};

    float3 eye179;
    float1 l10;
    float3 l13;
    float3 l14;
    float1 l16;
    float3 l19;
    float3 l20;
    float1 l22;
    float3 l240;
    float3 l25;
    float3 l26;
    float1 l28;
    float3 l31;
    float3 l32;
    float1 l34;
    float3 l37;
    float3 l38;
    float3 l4;
    float1 l40;
    float3 l43;
    float3 l44;
    float1 l46;
    float3 l51;
    float1 l656;
    float3 l8;
    float3 m186;
    float3 m194;
    float3 m202;
    float3 m210;
    float3 m218;
    float3 m226;
    float3 m234;
    float3 m241;
    float3 q1;
    float3 q102;
    float3 q108;
    float3 q112;
    float3 q114;
    float1 q12;
    float3 q15;
    float1 q18;
    float3 q2;
    float3 q21;
    float1 q24;
    float3 q27;
    float3 q3;
    float1 q30;
    float3 q33;
    float1 q36;
    float3 q39;
    float1 q42;
    float3 q45;
    float1 q48;
    float1 q5;
    float3 q67;
    float3 q7;
    float3 q74;
    float3 q81;
    float3 q88;
    float3 q9;
    float3 q95;
    float4 r0;
    float4 r1;
    float3 r10;
    float3 r11;
    float3 r12;
    float3 r13;
    float3 r14;
    float3 r15;
    float2 r16;
    float4 r2;
    float4 r3;
    float4 r4;
    float4 r5;
    float3 r6;
    float4 r7;
    float3 r8;
    float3 r9;

#define	TanSpaceProj	float3x3(r12.xyz, r11.xyz, r10.xyz)
#define	TanSpaceProj	float3x3(r12.xyz, r11.xyz, r10.xyz)

    r1.xyzw = tex2D(NormalMap, IN.BaseUV.xy);			// partial precision
    r5.xyz = normalize(expand(r1.xyz));			// partial precision
    r0.xyz = r5.xyz * 0.5;			// partial precision
    q1.xyz = r0.xyz + const_8.yyz;			// partial precision
    r0.w = r0.z + 1;			// partial precision
    r0.xyz = q1.xyz / sqrt(dot(r0.xyw, q1.xyz));			// partial precision
    r0.w = r0.x - 0.05;			// partial precision
    q2.xyz = r0.xyz + const_4.xyy;			// partial precision
    r8.xyz = q2.xyz / sqrt(dot(r0.wyz, q2.xyz));			// partial precision
    r10.xyz = normalize(IN.texcoord_5.xyz);			// partial precision
    r11.xyz = normalize(IN.texcoord_4.xyz);			// partial precision
    r12.xyz = normalize(IN.texcoord_3.xyz);			// partial precision
    r4.xyz = mul(TanSpaceProj, LightData[1].xyz);
    eye179.xyz = mul(TanSpaceProj, EyePosition.xyz - IN.texcoord_6.xyz);
    r9.xyz = normalize(eye179.xyz);			// partial precision
    q3.xyz = normalize(r4.xyz + r9.xyz);			// partial precision
    r2.x = dot(r8.xyz, r4.xyz);			// partial precision
    r2.y = dot(r8.xyz, q3.xyz);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r2.xy);			// partial precision
    r3.x = dot(r0.xyz, r4.xyz);			// partial precision
    r3.y = dot(r0.xyz, q3.xyz);			// partial precision
    r3.xyzw = tex2D(AnisoMap, r3.xy);			// partial precision
    r6.xyz = const_8.xyz;
    r4.w = (ToggleNumLights.x <= 0.0 ? r6.y : r6.z);			// partial precision

    if (0 != r4.w) {
      r0.w = 1;			// partial precision
      l4.xyz = ((r2.w * (2 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5))) + (r3.w * 0.7)) * LightData[0].xyz;			// partial precision
      r1.xyz = max(r4.z, 0) * l4.xyz;			// partial precision
      r4.xyz = shade(r5.xyz, r4.xyz) * LightData[0].xyz;			// partial precision
    }
    else {
      r0.w = 0;
      r4.xyz = r0.w;			// partial precision
      r1.xyz = r0.w;			// partial precision
    }

    q5.x = min(ToggleNumLights.y, 8 - ToggleNumLights.x);			// partial precision
    r13.x = 2 * r0.w;
    r13.yz = r13.x + const_30.xy;
    q7.xyz = r13.x + const_30.zxy;
    r14.xyz = (q7.xyz >= 0.0 ? q7.xyz : -r13.xyz);
    l8.xyz = (r14.z <= 0.0 ? LightData[3].xyz : (r14.y <= 0.0 ? LightData[2].xyz : (r14.x <= 0.0 ? LightData[1].xyz : r6.y)));
    r15.xyz = l8.xyz - IN.texcoord_6.xyz;
    m186.xyz = mul(TanSpaceProj, r15.xyz);
    r7.xyz = normalize(m186.xyz);			// partial precision
    q9.xyz = normalize(r9.xyz + r7.xyz);			// partial precision
    r16.x = dot(r8.xyz, r7.xyz);			// partial precision
    r16.y = dot(r8.xyz, q9.xyz);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r16.xy);			// partial precision
    r3.x = dot(r0.xyz, r7.xyz);			// partial precision
    r3.y = dot(r0.xyz, q9.xyz);			// partial precision
    r3.xyzw = tex2D(AnisoMap, r3.xy);			// partial precision
    r4.w = ((q5.x >= 0.0 ? 0 : 1) * (frac(q5.x) <= 0.0 ? 0 : 1)) + (q5.x - frac(q5.x));
    r5.w = (r4.w <= 0.0 ? 0 : 1);			// partial precision

    if (0 != r5.w) {
      r2.xyz = r13.x + const_30.zxy;
      r5.w = r0.w + 1;
      l13.xyz = (r2.z == 0.0 ? LightData[2].xyz : (r2.y == 0.0 ? LightData[1].xyz : (r2.x == 0.0 ? LightData[0].xyz : r6.y)));			// partial precision
      q67.xyz = (r2.w * ((0.3 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) + 0.2)) + (r3.w * 0.7);			// partial precision
      l10.x = (r14.z <= 0.0 ? LightData[3].w : (r14.y <= 0.0 ? LightData[2].w : (r14.x <= 0.0 ? LightData[1].w : r6.y)));			// partial precision
      q12.x = 1.0 - sqr(saturate(length(r15.xyz) / l10.x));			// partial precision
      r1.xyz = (max(r7.z, 0) * ((q12.x * l13.xyz) * q67.xyz)) + r1.xyz;			// partial precision
      r4.xyz = (max(dot(r5.xyz, r7.xyz) * q12.x, 0) * l13.xyz) + r4.xyz;			// partial precision
    }
    else {
      r5.w = r0.w;
    }

    r7.w = 2 * r5.w;
    r13.xyz = r7.w + const_7.xyz;
    l14.xyz = (r13.z == 0.0 ? LightData[5].xyz : (r13.y == 0.0 ? LightData[4].xyz : (r13.x == 0.0 ? LightData[3].xyz : r6.y)));
    r14.xyz = l14.xyz - IN.texcoord_6.xyz;
    m194.xyz = mul(TanSpaceProj, r14.xyz);
    r7.xyz = normalize(m194.xyz);			// partial precision
    q15.xyz = normalize(r9.xyz + r7.xyz);			// partial precision
    r15.x = dot(r8.xyz, r7.xyz);			// partial precision
    r15.y = dot(r8.xyz, q15.xyz);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r15.xy);			// partial precision
    r3.x = dot(r0.xyz, r7.xyz);			// partial precision
    r3.y = dot(r0.xyz, q15.xyz);			// partial precision
    r3.xyzw = tex2D(AnisoMap, r3.xy);			// partial precision

    if (1 < r4.w) {
      r2.xyz = r7.w + const_7.xyz;
      r5.w = r5.w + 1;
      l19.xyz = (r2.z == 0.0 ? LightData[4].xyz : (r2.y == 0.0 ? LightData[3].xyz : (r2.x == 0.0 ? LightData[2].xyz : r6.y)));			// partial precision
      q74.xyz = (r2.w * ((0.3 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) + 0.2)) + (r3.w * 0.7);			// partial precision
      l16.x = (r13.z == 0.0 ? LightData[5].w : (r13.y == 0.0 ? LightData[4].w : (r13.x == 0.0 ? LightData[3].w : r6.y)));			// partial precision
      q18.x = 1.0 - sqr(saturate(length(r14.xyz) / l16.x));			// partial precision
      r1.xyz = (max(r7.z, 0) * ((q18.x * l19.xyz) * q74.xyz)) + r1.xyz;			// partial precision
      r4.xyz = (max(dot(r5.xyz, r7.xyz) * q18.x, 0) * l19.xyz) + r4.xyz;			// partial precision
    }

    r7.w = 2 * r5.w;
    r13.xyz = r7.w + const_31.xyz;
    l20.xyz = (r13.z == 0.0 ? LightData[7].xyz : (r13.y == 0.0 ? LightData[6].xyz : (r13.x == 0.0 ? LightData[5].xyz : r6.y)));
    r14.xyz = l20.xyz - IN.texcoord_6.xyz;
    m202.xyz = mul(TanSpaceProj, r14.xyz);
    r7.xyz = normalize(m202.xyz);			// partial precision
    q21.xyz = normalize(r9.xyz + r7.xyz);			// partial precision
    r15.x = dot(r8.xyz, r7.xyz);			// partial precision
    r15.y = dot(r8.xyz, q21.xyz);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r15.xy);			// partial precision
    r3.x = dot(r0.xyz, r7.xyz);			// partial precision
    r3.y = dot(r0.xyz, q21.xyz);			// partial precision
    r3.xyzw = tex2D(AnisoMap, r3.xy);			// partial precision

    if (2 < r4.w) {
      r2.xyz = r7.w + const_31.xyz;
      r5.w = r5.w + 1;
      l25.xyz = (r2.z == 0.0 ? LightData[6].xyz : (r2.y == 0.0 ? LightData[5].xyz : (r2.x == 0.0 ? LightData[4].xyz : r6.y)));			// partial precision
      q81.xyz = (r2.w * ((0.3 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) + 0.2)) + (r3.w * 0.7);			// partial precision
      l22.x = (r13.z == 0.0 ? LightData[7].w : (r13.y == 0.0 ? LightData[6].w : (r13.x == 0.0 ? LightData[5].w : r6.y)));			// partial precision
      q24.x = 1.0 - sqr(saturate(length(r14.xyz) / l22.x));			// partial precision
      r1.xyz = (max(r7.z, 0) * ((q24.x * l25.xyz) * q81.xyz)) + r1.xyz;			// partial precision
      r4.xyz = (max(dot(r5.xyz, r7.xyz) * q24.x, 0) * l25.xyz) + r4.xyz;			// partial precision
    }

    r7.w = 2 * r5.w;
    r13.xyz = r7.w + const_25.xyz;
    l26.xyz = (r13.z == 0.0 ? LightData[9].xyz : (r13.y == 0.0 ? LightData[8].xyz : (r13.x == 0.0 ? LightData[7].xyz : r6.y)));
    r14.xyz = l26.xyz - IN.texcoord_6.xyz;
    m210.xyz = mul(TanSpaceProj, r14.xyz);
    r7.xyz = normalize(m210.xyz);			// partial precision
    q27.xyz = normalize(r9.xyz + r7.xyz);			// partial precision
    r15.x = dot(r8.xyz, r7.xyz);			// partial precision
    r15.y = dot(r8.xyz, q27.xyz);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r15.xy);			// partial precision
    r3.x = dot(r0.xyz, r7.xyz);			// partial precision
    r3.y = dot(r0.xyz, q27.xyz);			// partial precision
    r3.xyzw = tex2D(AnisoMap, r3.xy);			// partial precision

    if (3 < r4.w) {
      r2.xyz = r7.w + const_25.xyz;
      r5.w = r5.w + 1;
      l31.xyz = (r2.z == 0.0 ? LightData[8].xyz : (r2.y == 0.0 ? LightData[7].xyz : (r2.x == 0.0 ? LightData[6].xyz : r6.y)));			// partial precision
      q88.xyz = (r2.w * ((0.3 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) + 0.2)) + (r3.w * 0.7);			// partial precision
      l28.x = (r13.z == 0.0 ? LightData[9].w : (r13.y == 0.0 ? LightData[8].w : (r13.x == 0.0 ? LightData[7].w : r6.y)));			// partial precision
      q30.x = 1.0 - sqr(saturate(length(r14.xyz) / l28.x));			// partial precision
      r1.xyz = (max(r7.z, 0) * ((q30.x * l31.xyz) * q88.xyz)) + r1.xyz;			// partial precision
      r4.xyz = (max(dot(r5.xyz, r7.xyz) * q30.x, 0) * l31.xyz) + r4.xyz;			// partial precision
    }

    r7.w = 2 * r5.w;
    r13.xyz = r7.w + const_26.xyz;
    l32.xyz = (r13.z == 0.0 ? LightData[11].xyz : (r13.y == 0.0 ? LightData[10].xyz : (r13.x == 0.0 ? LightData[9].xyz : r6.y)));
    r14.xyz = l32.xyz - IN.texcoord_6.xyz;
    m218.xyz = mul(TanSpaceProj, r14.xyz);
    r7.xyz = normalize(m218.xyz);			// partial precision
    q33.xyz = normalize(r9.xyz + r7.xyz);			// partial precision
    r15.x = dot(r8.xyz, r7.xyz);			// partial precision
    r15.y = dot(r8.xyz, q33.xyz);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r15.xy);			// partial precision
    r3.x = dot(r0.xyz, r7.xyz);			// partial precision
    r3.y = dot(r0.xyz, q33.xyz);			// partial precision
    r3.xyzw = tex2D(AnisoMap, r3.xy);			// partial precision

    if (4 < r4.w) {
      r2.xyz = r7.w + const_26.xyz;
      r5.w = r5.w + 1;
      l37.xyz = (r2.z == 0.0 ? LightData[10].xyz : (r2.y == 0.0 ? LightData[9].xyz : (r2.x == 0.0 ? LightData[8].xyz : r6.y)));			// partial precision
      q95.xyz = (r2.w * ((0.3 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) + 0.2)) + (r3.w * 0.7);			// partial precision
      l34.x = (r13.z == 0.0 ? LightData[11].w : (r13.y == 0.0 ? LightData[10].w : (r13.x == 0.0 ? LightData[9].w : r6.y)));			// partial precision
      q36.x = 1.0 - sqr(saturate(length(r14.xyz) / l34.x));			// partial precision
      r1.xyz = (max(r7.z, 0) * ((q36.x * l37.xyz) * q95.xyz)) + r1.xyz;			// partial precision
      r4.xyz = (max(dot(r5.xyz, r7.xyz) * q36.x, 0) * l37.xyz) + r4.xyz;			// partial precision
    }

    r7.w = 2 * r5.w;
    r13.xyz = r7.w + const_32.xyz;
    l38.xyz = (r13.z == 0.0 ? LightData[13].xyz : (r13.y == 0.0 ? LightData[12].xyz : (r13.x == 0.0 ? LightData[11].xyz : r6.y)));
    r14.xyz = l38.xyz - IN.texcoord_6.xyz;
    m226.xyz = mul(TanSpaceProj, r14.xyz);
    r7.xyz = normalize(m226.xyz);			// partial precision
    q39.xyz = normalize(r9.xyz + r7.xyz);			// partial precision
    r15.x = dot(r8.xyz, r7.xyz);			// partial precision
    r15.y = dot(r8.xyz, q39.xyz);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r15.xy);			// partial precision
    r3.x = dot(r0.xyz, r7.xyz);			// partial precision
    r3.y = dot(r0.xyz, q39.xyz);			// partial precision
    r3.xyzw = tex2D(AnisoMap, r3.xy);			// partial precision

    if (5 < r4.w) {
      r2.xyz = r7.w + const_32.xyz;
      r5.w = r5.w + 1;
      l43.xyz = (r2.z == 0.0 ? LightData[12].xyz : (r2.y == 0.0 ? LightData[11].xyz : (r2.x == 0.0 ? LightData[10].xyz : r6.y)));			// partial precision
      q102.xyz = (r2.w * ((0.3 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) + 0.2)) + (r3.w * 0.7);			// partial precision
      l40.x = (r13.z == 0.0 ? LightData[13].w : (r13.y == 0.0 ? LightData[12].w : (r13.x == 0.0 ? LightData[11].w : r6.y)));			// partial precision
      q42.x = 1.0 - sqr(saturate(length(r14.xyz) / l40.x));			// partial precision
      r1.xyz = (max(r7.z, 0) * ((q42.x * l43.xyz) * q102.xyz)) + r1.xyz;			// partial precision
      r4.xyz = (max(dot(r5.xyz, r7.xyz) * q42.x, 0) * l43.xyz) + r4.xyz;			// partial precision
    }

    r7.w = 2 * r5.w;
    r13.xyz = r7.w + const_28.xyz;
    l44.xyz = (r13.z == 0.0 ? LightData[15].xyz : (r13.y == 0.0 ? LightData[14].xyz : (r13.x == 0.0 ? LightData[13].xyz : r6.y)));
    r14.xyz = l44.xyz - IN.texcoord_6.xyz;
    m234.xyz = mul(TanSpaceProj, r14.xyz);
    r7.xyz = normalize(m234.xyz);			// partial precision
    q45.xyz = normalize(r9.xyz + r7.xyz);			// partial precision
    r15.x = dot(r8.xyz, r7.xyz);			// partial precision
    r15.y = dot(r8.xyz, q45.xyz);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r15.xy);			// partial precision
    r3.x = dot(r0.xyz, r7.xyz);			// partial precision
    r3.y = dot(r0.xyz, q45.xyz);			// partial precision
    r3.xyzw = tex2D(AnisoMap, r3.xy);			// partial precision

    if (6 < r4.w) {
      r2.xyz = r7.w + const_28.xyz;
      r5.w = r5.w + 1;
      l240.xyz = (r2.z == 0.0 ? LightData[14].xyz : (r2.y == 0.0 ? LightData[13].xyz : (r2.x == 0.0 ? LightData[12].xyz : r6.y)));			// partial precision
      q108.xyz = (r2.w * ((0.3 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) + 0.2)) + (r3.w * 0.7);			// partial precision
      l46.x = (r13.z == 0.0 ? LightData[15].w : (r13.y == 0.0 ? LightData[14].w : (r13.x == 0.0 ? LightData[13].w : r6.y)));			// partial precision
      q48.x = 1.0 - sqr(saturate(length(r14.xyz) / l46.x));			// partial precision
      r1.xyz = (max(r7.z, 0) * ((q48.x * l240.xyz) * q108.xyz)) + r1.xyz;			// partial precision
      r4.xyz = (max(dot(r5.xyz, r7.xyz) * q48.x, 0) * l240.xyz) + r4.xyz;			// partial precision
    }

    r7.xyz = LightData[15].xyz - IN.texcoord_6.xyz;
    m241.xyz = mul(TanSpaceProj, r7.xyz);
    r3.xyz = normalize(m241.xyz);			// partial precision
    r9.xyz = r9.xyz + r3.xyz;			// partial precision
    r2.xyz = normalize(r9.xyz);			// partial precision
    r9.x = dot(r8.xyz, r3.xyz);			// partial precision
    r9.y = dot(r8.xyz, r2.xyz);			// partial precision
    r2.y = dot(r0.xyz, r2.xyz);			// partial precision
    r2.x = dot(r0.xyz, r3.xyz);			// partial precision
    r0.xyzw = tex2D(AnisoMap, r9.xy);			// partial precision
    r2.xyzw = tex2D(AnisoMap, r2.xy);			// partial precision

    if (7 < r4.w) {
      r3.w = dot(r5.xyz, r3.xyz);			// partial precision
      l656.x = 1.0 - sqr(saturate(length(r7.xyz) / LightData[15].w));			// partial precision
      q112.xyz = (r0.w * ((0.3 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) + 0.2)) + (r2.w * 0.7);			// partial precision
      r3.xy = (2 * r5.w) + const_27.yz;
      l51.xyz = (r3.y == 0.0 ? LightData[15].xyz : (r3.x == 0.0 ? LightData[14].xyz : r6.y));			// partial precision
      r1.xyz = (max(r3.z, 0) * ((l656.x * l51.xyz) * q112.xyz)) + r1.xyz;			// partial precision
      r4.xyz = (max(r3.w * l656.x, 0) * l51.xyz) + r4.xyz;			// partial precision
    }

    r2.xyzw = tex2D(LayerMap, IN.BaseUV.xy);			// partial precision
    r0.xyzw = tex2D(BaseMap, IN.BaseUV.xy);			// partial precision
    r3.xyz = r1.xyz * IN.color_0.g;			// partial precision
    r1.xyz = lerp(r0.xyz, r2.xyz, r2.w);			// partial precision
    r0.xyz = r4.xyz + ((ToggleADTS.x * AmbientColor.rgb) + (r6.z - ToggleADTS.x));			// partial precision
    q114.xyz = (((2 * ((IN.color_0.g * (r6.x + HairTint.rgb)) + 0.5)) * r1.xyz) * r0.xyz) + (r1.w * r3.xyz);			// partial precision
    OUT.color_0.a = r0.w * MatAlpha.x;			// partial precision
    OUT.color_0.rgb = (IN.texcoord_7.w * (IN.texcoord_7.xyz - q114.xyz)) + q114.xyz;			// partial precision

    return OUT;
};

// approximately 495 instruction slots used (21 texture, 474 arithmetic)
