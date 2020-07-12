//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/WATER012.pso /Fcshaderdump19/WATER012.pso.dis
//
//
// Parameters:
//
float4 Scroll : register(c0);
float4 EyePos : register(c1);
float4 SunDir : register(c2);
float4 SunColor : register(c3);
float4 NotUsed4 : register(c4);
float4 ShallowColor : register(c5);
float4 DeepColor : register(c6);
float4 ReflectionColor : register(c7);
float4 VarAmounts : register(c8);
float4 FogParam : register(c9);
float4 FogColor : register(c10);
float4 FresnelRI : register(c11);
float4 BlendRadius : register(c12);
float4 TESR_SunColor : register(c13);
float4 TESR_WaterCoefficients : register(c14);
float4 TESR_WaveParams : register(c15);
float4 TESR_WaterVolume : register(c16);
float4 TESR_WaterSettings : register(c17);
float4 TESR_ReciprocalResolution : register(c18);
float4 TESR_Tick : register(c19);
float4x4 TESR_ViewTransform : register(c20);
float4x4 TESR_ProjectionTransform : register(c24);

sampler2D ReflectionMap : register(s0);
sampler2D NormalMap : register(s1);
sampler2D DetailMap : register(s2);
sampler2D DepthMap : register(s3);
sampler2D DisplacementMap : register(s4);
sampler2D TESR_RenderedBuffer : register(s5) = sampler_state { };
sampler2D TESR_DepthBuffer : register(s6) = sampler_state { };
sampler2D TESR_samplerWater : register(s7) < string ResourceName = "Water\water_NRM_LOD.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float4x4 ditherMat = { 0.0588, 0.5294, 0.1765, 0.6471,
									0.7647, 0.2941, 0.8824, 0.4118,
									0.2353, 0.7059, 0.1176, 0.5882,
									0.9412, 0.4706, 0.8235, 0.3259 };

//
//
// Registers:
//
//   Name            Reg   Size
//   --------------- ----- ----
//   EyePos          const_1       1
//   SunDir          const_2       1
//   SunColor        const_3       1
//   ShallowColor    const_5       1
//   DeepColor       const_6       1
//   ReflectionColor const_7       1
//   VarAmounts      const_8       1
//   FogParam        const_9       1
//   FogColor        const_10      1
//   FresnelRI       const_11      1
//   ReflectionMap   texture_0       1
//


// Structures:

struct VS_OUTPUT {
    float3 texcoord_0 : TEXCOORD0_centroid;
    float3 texcoord_1 : TEXCOORD1_centroid;
    float4 texcoord_2 : TEXCOORD2_centroid;
    float4 texcoord_3 : TEXCOORD3_centroid;
    float4 texcoord_4 : TEXCOORD4_centroid;
    float4 texcoord_5 : TEXCOORD5_centroid;
    float4 texcoord_6 : TEXCOORD6;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

// Code:
float3 toWorld(float2 tex)
{
    float3 v = float3(TESR_ViewTransform[2][0], TESR_ViewTransform[2][1], TESR_ViewTransform[2][2]);
    v += (1/TESR_ProjectionTransform[0][0] * (2*tex.x-1)).xxx * float3(TESR_ViewTransform[0][0], TESR_ViewTransform[0][1], TESR_ViewTransform[0][2]);
    v += (-1/TESR_ProjectionTransform[1][1] * (2*tex.y-1)).xxx * float3(TESR_ViewTransform[1][0], TESR_ViewTransform[1][1], TESR_ViewTransform[1][2]);
    return v;
}

#define animFrames 32
float2 get2DTex( float3 tex )
{
	float2 return_tex = float2(0, tex.y);
	return_tex.x = frac(tex.x)/animFrames + round( tex.z*(animFrames) )/animFrames;
	return return_tex;
}

float3 getWaterNorm( float2 tex, float dist, float camera_vector_z, inout float3 specNorm )
{
	float choppiness = TESR_WaveParams.x;
	float waveWidth = TESR_WaveParams.y;
	float LODdistance = TESR_WaterSettings.z;
	float MinLOD = TESR_WaterSettings.w;

	float lod = max( saturate( (camera_vector_z*camera_vector_z) * 50 * TESR_ProjectionTransform[0][0] /(TESR_ReciprocalResolution.x * dist) * LODdistance ), MinLOD);
	float2 Coord = tex / (1024 * waveWidth);

	float frame = TESR_Tick.y * TESR_WaveParams.z / 1500;
	float2 newCoord = get2DTex( float3(frac(Coord), frac(frame)) );
	float4 sampledResult = tex2D( TESR_samplerWater, newCoord );

	float2 temp_norm = sampledResult.rg * 2 - 1;
	float3 norm = normalize(float3(temp_norm * choppiness * lod,1));
	specNorm = normalize(float3(temp_norm * choppiness * max(0.5, lod), 1));
	return norm;
}

float getFresnelAboveWater( float3 ray, float3 norm )
{
	float temp_cos = dot( -ray, norm );
	float2 vec = float2(temp_cos, sqrt(1-temp_cos*temp_cos));

	float fresnel = vec.x - 1.33 * sqrt(1 - 0.565*vec.y*vec.y);
	fresnel /= vec.x + 1.33 * sqrt(1 - 0.565*vec.y*vec.y);
	fresnel = saturate(fresnel * fresnel);

	return fresnel;
}


PS_OUTPUT main(VS_OUTPUT IN, float2 PixelPos : VPOS) {
    PS_OUTPUT OUT;

	float2 UVCoord = (PixelPos+0.5)*TESR_ReciprocalResolution.xy;
	float3 eyepos = IN.texcoord_2.xyz;
	eyepos.z = -IN.texcoord_1.z;

    float3 camera_vector = toWorld(UVCoord);
	float3 norm_camera_vector = normalize( camera_vector );

	float4 sunColor = float4(TESR_SunColor.rgb, 1);
	float nightAmount = TESR_SunColor.a;
	float3 extCoeff = TESR_WaterCoefficients.xyz;
	float scattCoeff = TESR_WaterCoefficients.w;
	float reflectivity = TESR_WaveParams.w;
	float waveWidth = TESR_WaveParams.y;

	float dist = eyepos.z / -camera_vector.z;
	float2 surfPos = eyepos.xy + camera_vector.xy * dist;

	float3 normal = 0;
	float3 specNorm = float3(0,0,1);
	normal = getWaterNorm( surfPos, dist, -camera_vector.z, specNorm);

	//Calculate Refraction color
	float SinBoverSinA = -norm_camera_vector.z;
	float3 waterVolColor = scattCoeff * FogColor.xyz / ( extCoeff * (1 + SinBoverSinA) );

	float4 refract_color = float4( waterVolColor.rgb, 1 );

	//Calculate reflection color
	float4 reflection = FogColor;

	float2 refPos = UVCoord + 0.05*normal.yx;
	reflection = tex2D(ReflectionMap, float2(refPos.x,1-refPos.y) );

	float fresnel = saturate( getFresnelAboveWater( norm_camera_vector, normal ) * reflectivity );
	float4 water_result = lerp( refract_color, reflection, fresnel );

	float sunReflectionStrength = dot(reflection.rgb, float3(0.21,0.72,0.07) )/0.865;
	sunReflectionStrength = 5 * pow( sunReflectionStrength, 5);
	sunReflectionStrength *= lerp(1,15,saturate(nightAmount*nightAmount));

	float specular = saturate(dot( norm_camera_vector, reflect( SunDir.xyz, specNorm ) ));
	water_result.xyz += 4*saturate(sunReflectionStrength)*pow(specular, dist*0.3 + 750) * sunColor.xyz;

	float eyeFogDist = eyepos.z * (1.28 - 0.28 * (2*UVCoord.x-1)*(2*UVCoord.x-1));
	float eyeFog = saturate(eyeFogDist/30500 + 0.37);
	reflection = lerp(reflection, FogColor, eyeFog);

	//Add above water fog
    float fog = 1 - saturate((FogParam.x - length(IN.texcoord_1.xyz)) / FogParam.y);
	water_result.rgb = (fog * (reflection.rgb - water_result.rgb)) + water_result.rgb;

	water_result.rgb += ditherMat[ PixelPos.x%4 ][ PixelPos.y%4 ] / 255;

	OUT.color_0.rgb = water_result.rgb;
	OUT.color_0.a = 1;

    return OUT;
};

// approximately 84 instruction slots used (4 texture, 80 arithmetic)
