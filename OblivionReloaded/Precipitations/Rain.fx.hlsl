// Rain fullscreen shader for Oblivion Reloaded

float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4 TESR_CameraForward;
float4 TESR_Tick;
float4 TESR_RainData;
float4 TESR_SunColor;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_RainSampler : register(s2) < string ResourceName = "Precipitations\rainlayers.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float PI = 3.14159265;
static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float rangeZ = farZ - nearZ;
static const float timetick = TESR_Tick.y / 3500;
static const float hscale = 0.15;

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

float3 toWorld(float2 tex)
{
    float3 v = float3(TESR_ViewTransform[0][2], TESR_ViewTransform[1][2], TESR_ViewTransform[2][2]);
    v += (1 / TESR_ProjectionTransform[0][0] * (2 * tex.x - 1)).xxx * float3(TESR_ViewTransform[0][0], TESR_ViewTransform[1][0], TESR_ViewTransform[2][0]);
    v += (-1 / TESR_ProjectionTransform[1][1] * (2 * tex.y - 1)).xxx * float3(TESR_ViewTransform[0][1], TESR_ViewTransform[1][1], TESR_ViewTransform[2][1]);
    return v;
}

float readDepth(in float2 coord : TEXCOORD0)
{
	float posZ = tex2D(TESR_DepthBuffer, coord).x;
	posZ = Zmul / ((posZ * rangeZ) - farZ);
	return posZ;
}

float2 cylindrical(float3 world)
{
	float u = -atan2(world.y, world.x) / PI;
	float v = -world.z / length(world.xy);
	return float2(0.5f * u + 0.5f, hscale * v);
}

float2 cylindricalwave(float3 world)
{
	world.xy += float2((0 + 0.1 * sin(timetick * 8 * 0.2)), (0 + 0.2 *sin(timetick * 0.01))) * world.z;
	float u = -atan2(world.y, world.x) / PI;
	float v = -world.z / length(world.xy);
	return float2(0.5f * u + 0.5f, hscale * v);
}

float4 Rain( VSOUT IN ) : COLOR0
{ 
	float3 world = toWorld(IN.UVCoord);
	float2 uv = cylindrical(world);
	float2 uv2 = cylindricalwave(world);
	uv2 = float2(uv2.x, uv2.y * 0.1f);

	float4 color = tex2D(TESR_RenderedBuffer, IN.UVCoord);
	float depth = readDepth(IN.UVCoord);
	float depthmask = smoothstep(10000, 12000, depth);
	float depthtile = smoothstep(300, 500, depth);
	float depth1 = smoothstep(15, 30, depth);
	float depth2 = smoothstep(1000, 2000, depth);
	float depth3 =  smoothstep(4000, 10000, depth);
	float rmasktop = 1 - smoothstep(0, -1, uv.y);

	float3 rain = 2.0f * (tex2Dlod(TESR_RainSampler, float4(uv * 10.0f + float2(0.0f, -timetick * 2.0f), 0.0f, 0.0f)).b) * depth3 * 0.5f * rmasktop;
	rain = 0.5f * max(rain, tex2Dlod(TESR_RainSampler, float4(uv * float2(16.0f, 20.0f) + float2(0.0f, -timetick * 6.0f), 0.0f, 0.0f)).g * depth2 * 1.5f * rmasktop);
	rain = max(rain, tex2Dlod(TESR_RainSampler, float4(uv * float2(8.0f, 6.0f) + float2(0.0f, -timetick * 8.0f), 0.0f, 0.0f)).g * depth1 * 1.0f * rmasktop);
	rain *= TESR_RainData.x;
	rain.rgb *= max(0.25f, TESR_SunColor.rgb * 2.0f);
	
	float uv2fr = 1 - smoothstep(0.0f, 0.08f, uv2.y);
	float2 bnorm = float2(rain.r * 1.1f, rain.r * 0.9f);
	bnorm = saturate(bnorm * 1.5f);
	float4 rainsrefr = tex2D(TESR_RenderedBuffer, IN.UVCoord * (1.0f + (0.6f - depthtile * 0.3f) * bnorm * 0.07f));
	float topdmask = 1.0f - smoothstep(0.6f, 1.0f, TESR_CameraForward.z);
	topdmask = max(depthmask, topdmask);
	rain = pow(abs(1 - rain), 2 + 0.2f * sin(timetick * 4));
	rain = 1 - rain;
	rain = rain * topdmask * uv2fr;
	float rainc = max(rain.x, max(rain.y, rain.z));
	rainsrefr.rgb = lerp(rainsrefr.rgb, saturate(rainc * 2.0f + 0.9f), rainc);
	color.rgb = lerp(color.rgb, rainsrefr.rgb, 0.55f);
	return float4(color.rgb, 1);

}


technique
{
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Rain();
	}
}