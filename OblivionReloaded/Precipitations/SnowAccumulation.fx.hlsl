// Snow accumulation fullscreen shader for Oblivion Reloaded

float4x4 TESR_WorldTransform;
float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4 TESR_SunDirection;
float4 TESR_SunColor;
float4 TESR_ReciprocalResolution;
float4 TESR_SnowAccumulationParams;
float4 TESR_WaterSettings;
float4 TESR_FogData;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_SourceBuffer : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_SnowSampler : register(s3) < string ResourceName = "Precipitations\snow.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_SnowNormSampler : register(s4) < string ResourceName = "Precipitations\snow_NRM.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float3 AmbientLight = float3(0.7f, 0.7f, 0.7f);
static const float2 OffsetMaskH = float2(1.0f, 0.0f);
static const float2 OffsetMaskV = float2(0.0f, 1.0f);
static const float3 eyepos = float3( -TESR_WorldTransform[3][0], -TESR_WorldTransform[3][1], -TESR_WorldTransform[3][2] );
static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;
static const float depthRange = nearZ - farZ;
static const int cKernelSize = 24;

static const float BlurWeights[cKernelSize] = 
{
	0.019956226f,
	0.031463016f,
	0.042969806f,
	0.054476596f,
	0.065983386f,
	0.077490176f,
	0.088996966f,
	0.100503756f,
	0.112010546f,
	0.135024126f,
	0.146530916f,
	0.158037706f,
	0.158037706f,
	0.146530916f,
	0.135024126f,
	0.112010546f,
	0.100503756f,
	0.088996966f,
	0.077490176f,
	0.065983386f,
	0.054476596f,
	0.042969806f,
	0.031463016f,
	0.019956226f
};

static const float2 BlurOffsets[cKernelSize] = 
{
	float2(-12.0f * TESR_ReciprocalResolution.x, -12.0f * TESR_ReciprocalResolution.y),
	float2(-11.0f * TESR_ReciprocalResolution.x, -11.0f * TESR_ReciprocalResolution.y),
	float2(-10.0f * TESR_ReciprocalResolution.x, -10.0f * TESR_ReciprocalResolution.y),
	float2( -9.0f * TESR_ReciprocalResolution.x,  -9.0f * TESR_ReciprocalResolution.y),
	float2( -8.0f * TESR_ReciprocalResolution.x,  -8.0f * TESR_ReciprocalResolution.y),
	float2( -7.0f * TESR_ReciprocalResolution.x,  -7.0f * TESR_ReciprocalResolution.y),
	float2( -6.0f * TESR_ReciprocalResolution.x,  -6.0f * TESR_ReciprocalResolution.y),
	float2( -5.0f * TESR_ReciprocalResolution.x,  -5.0f * TESR_ReciprocalResolution.y),
	float2( -4.0f * TESR_ReciprocalResolution.x,  -4.0f * TESR_ReciprocalResolution.y),
	float2( -3.0f * TESR_ReciprocalResolution.x,  -3.0f * TESR_ReciprocalResolution.y),
	float2( -2.0f * TESR_ReciprocalResolution.x,  -2.0f * TESR_ReciprocalResolution.y),
	float2( -1.0f * TESR_ReciprocalResolution.x,  -1.0f * TESR_ReciprocalResolution.y),
	float2(  1.0f * TESR_ReciprocalResolution.x,   1.0f * TESR_ReciprocalResolution.y),
	float2(  2.0f * TESR_ReciprocalResolution.x,   2.0f * TESR_ReciprocalResolution.y),
	float2(  3.0f * TESR_ReciprocalResolution.x,   3.0f * TESR_ReciprocalResolution.y),
	float2(  4.0f * TESR_ReciprocalResolution.x,   4.0f * TESR_ReciprocalResolution.y),
	float2(  5.0f * TESR_ReciprocalResolution.x,   5.0f * TESR_ReciprocalResolution.y),
	float2(  6.0f * TESR_ReciprocalResolution.x,   6.0f * TESR_ReciprocalResolution.y),
	float2(  7.0f * TESR_ReciprocalResolution.x,   7.0f * TESR_ReciprocalResolution.y),
	float2(  8.0f * TESR_ReciprocalResolution.x,   8.0f * TESR_ReciprocalResolution.y),
	float2(  9.0f * TESR_ReciprocalResolution.x,   9.0f * TESR_ReciprocalResolution.y),
	float2( 10.0f * TESR_ReciprocalResolution.x,  10.0f * TESR_ReciprocalResolution.y),
	float2( 11.0f * TESR_ReciprocalResolution.x,  11.0f * TESR_ReciprocalResolution.y),
	float2( 12.0f * TESR_ReciprocalResolution.x,  12.0f * TESR_ReciprocalResolution.y)
};

struct VSOUT
{
	float4 vertPos : POSITION;
	float2 UVCoord : TEXCOORD0;
};

struct VSIN
{
	float4 vertPos : POSITION0;
	float2 UVCoord : TEXCOORD0;
};

VSOUT FrameVS(VSIN IN)
{
	VSOUT OUT = (VSOUT)0.0f;
	OUT.vertPos = IN.vertPos;
	OUT.UVCoord = IN.UVCoord;
	return OUT;
}

float readDepth(in float2 coord : TEXCOORD0)
{
	float posZ = tex2D(TESR_DepthBuffer, coord).x;
	posZ = Zmul / ((posZ * Zdiff) - farZ);
	return posZ;
}

float3 toWorld(float2 tex)
{
    float3 v = float3(TESR_ViewTransform[0][2], TESR_ViewTransform[1][2], TESR_ViewTransform[2][2]);
    v += (1 / TESR_ProjectionTransform[0][0] * (2 * tex.x - 1)).xxx * float3(TESR_ViewTransform[0][0], TESR_ViewTransform[1][0], TESR_ViewTransform[2][0]);
    v += (-1 / TESR_ProjectionTransform[1][1] * (2 * tex.y - 1)).xxx * float3(TESR_ViewTransform[0][1], TESR_ViewTransform[1][1], TESR_ViewTransform[2][1]);
    return v;
}

float3 getPosition(in float2 tex, in float depth)
{
	return (eyepos + toWorld(tex) * depth);
}

float4 GetNormals( VSOUT IN ) : COLOR0
{
	float depth = readDepth(IN.UVCoord);
	float3 pos = getPosition(IN.UVCoord, depth);

    float3 left = pos - getPosition(IN.UVCoord + TESR_ReciprocalResolution.xy * float2(-1, 0), readDepth(IN.UVCoord + TESR_ReciprocalResolution.xy * float2(-1, 0)));
    float3 right = getPosition(IN.UVCoord + TESR_ReciprocalResolution.xy * float2(1, 0), readDepth(IN.UVCoord + TESR_ReciprocalResolution.xy * float2(1, 0))) - pos;
    float3 up = pos - getPosition(IN.UVCoord + TESR_ReciprocalResolution.xy * float2(0, -1), readDepth(IN.UVCoord + TESR_ReciprocalResolution.xy * float2(0, -1)));
    float3 down = getPosition(IN.UVCoord + TESR_ReciprocalResolution.xy * float2(0, 1), readDepth(IN.UVCoord + TESR_ReciprocalResolution.xy * float2(0, 1))) - pos;

    float3 dx = length(left) < length(right) ? left : right;
    float3 dy = length(up) < length(down) ? up : down;

	float3 norm = normalize(cross(dx,dy));
	norm.z *= -1;

	return float4((norm + 1) / 2, 1);
}

float4 BlurNormals(VSOUT IN, uniform float2 OffsetMask) : COLOR0
{
	float WeightSum = 0.12 * saturate(1 - TESR_SnowAccumulationParams.x);
	float3 oColor = tex2D(TESR_RenderedBuffer,IN.UVCoord).rgb;
	float3 finalColor = oColor * WeightSum;
	float depth = readDepth(IN.UVCoord);
	
	for (int i = 0; i < cKernelSize; i++)
	{
		float2 uvOff = (BlurOffsets[i] * OffsetMask) * TESR_SnowAccumulationParams.y;
		float3 Color = tex2D(TESR_RenderedBuffer, IN.UVCoord + uvOff).rgb;
		float weight = saturate(dot(Color.xyz * 2 - 1, oColor.xyz * 2 - 1) - TESR_SnowAccumulationParams.x);
		finalColor += BlurWeights[i] * weight * Color;
		WeightSum += BlurWeights[i] * weight;
	}
	
	finalColor /= WeightSum;
    return float4(finalColor, 1.0f);
}

float4 Snow( VSOUT IN ) : COLOR0
{
	float3 color = tex2D(TESR_SourceBuffer, IN.UVCoord).rgb;
	float depth = readDepth(IN.UVCoord);
    float3 screen_color = color;
    float3 camera_vector = toWorld(IN.UVCoord) * depth;
    float3 pos = eyepos + camera_vector;
	
    if (pos.z >= TESR_WaterSettings.x + 1)
    {
		float2 uv = pos.xy/200;
		float3 norm = tex2D(TESR_RenderedBuffer, IN.UVCoord).rgb * 2 - 1;
		float3 detail_norm = reflect(tex2D(TESR_SnowNormSampler, uv).rgb * 2 - 1, norm);
		detail_norm.z *= -1;
		
		float3 snow_light = AmbientLight.rgb + (min(TESR_FogData.z, 0.4) * TESR_SnowAccumulationParams.z) + (TESR_SunColor.rgb * TESR_SnowAccumulationParams.z) * dot(TESR_SunDirection.xyz, detail_norm);
		float3 snow_tex = tex2D(TESR_SnowSampler, uv).rgb;
		float3 snow_diffuse = snow_light * snow_tex;
		
		screen_color *= 1 - (saturate(saturate(norm.z * TESR_SnowAccumulationParams.w) * 2 - 1) * saturate(lerp(1, 0, (depth * 0.5 - TESR_FogData.x) / (TESR_FogData.y - TESR_FogData.x))));
		snow_diffuse *= saturate(saturate(norm.z * TESR_SnowAccumulationParams.w) * 2 - 1) * saturate(lerp(1, 0, (depth * 0.5 - TESR_FogData.x) / (TESR_FogData.y - TESR_FogData.x)));
		
		color.rgb = screen_color + snow_diffuse;
    }

    return float4(color, 1.0f);
}

technique
{
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 GetNormals();
	}
	pass
	{ 
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 BlurNormals(OffsetMaskH);
	}
	pass
	{ 
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 BlurNormals(OffsetMaskV);
	}
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Snow();
	}
}
