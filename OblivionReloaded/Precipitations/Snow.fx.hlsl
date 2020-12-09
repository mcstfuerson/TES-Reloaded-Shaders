// Snow fullscreen shader for Oblivion Reloaded
#define SnowLayers 50

float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4 TESR_Tick;
float4 TESR_SnowData;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float PI = 3.14159265;
static const float timetick = TESR_Tick.y / 1500;
static const float hscale = 0.1;
static const float3x3 p = float3x3(30.323122,30.323122,30.323122,30.323122,30.323122,30.323122,30.323122,30.323122,30.323122);
//static const float3x3 p = float3x3(13.323122,23.5112,21.71123,21.1212,28.7312,11.9312,21.8112,14.7212,61.3934);

#define DEPTH 2.5
#define WIDTH 0.5
#define SPEED 1.8

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

float2 cylindrical(float3 world)
{
	float u = -atan2(world.y, world.x) / PI;
	float v = -world.z / length(world.xy);
	return float2(0.5f * u + 0.5f, hscale * v);
}

float4 Snow( VSOUT IN ) : COLOR0
{
	float2 q;
	float3 n;
	float3 m;
	float3 mp;
	float3 r;
	float2 s;
	float d;
	float edge;
	float4 color = tex2D(TESR_RenderedBuffer, IN.UVCoord);
	float3 world = toWorld(IN.UVCoord);
	float2 uv = cylindrical(world);
	float sn = 0.0f;
	float dof = 5.0f * sin(timetick * 0.1f);
	int l = TESR_SnowData.x * SnowLayers;
	
	uv.y = -uv.y;
	for (int i = 0; i < l; i++) {
		q = uv * (1.0f + i * DEPTH);
		q += float2(q.y * (WIDTH * fmod(i * 107.238917f, 1.0f) - WIDTH * 0.5f), SPEED * timetick);
		n = float3(floor(q), i);
		m = floor(n) + frac(n);
		mp = m / frac(mul(p, m));
		r = frac(mp);
		s = abs(fmod(q, 1.0f) + r.xy - 1.0f);
		s += 0.01f * abs(2.0f * frac(10.0f * q.yx) - 1.0f); 
		d = 0.6f * max(s.x - s.y, s.x + s.y) + max(s.x, s.y) - 0.01f;
		edge = 0.005f + 0.05f * min(0.5f * abs(i - 5.0f - dof), 1.0f);
		sn += smoothstep(edge, -edge, d) * (r.x / (1.0f + 0.02f * i * DEPTH));
	}
	color += sn;
	return float4(color.rgb, 1.0f);
}

technique
{
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Snow();
	}
}