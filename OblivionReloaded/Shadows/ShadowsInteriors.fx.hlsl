// Image space shadows shader for Oblivion Reloaded

float4x4 TESR_WorldTransform;
float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4 TESR_CameraPosition;
float4 TESR_WaterSettings;
float4 TESR_ShadowData;
float4 TESR_ShadowLightPosition0;
float4 TESR_ShadowLightPosition1;
float4 TESR_ShadowLightPosition2;
float4 TESR_ShadowLightPosition3;
float4 TESR_ShadowLightPosition4;
float4 TESR_ShadowLightPosition5;
float4 TESR_ShadowLightPosition6;
float4 TESR_ShadowLightPosition7;
float4 TESR_ShadowLightPosition8;
float4 TESR_ShadowLightPosition9;
float4 TESR_ShadowLightPosition10;
float4 TESR_ShadowLightPosition11;
float4 TESR_ShadowCubeMapFarPlanes;
float4 TESR_ShadowCubeMapBlend;
float4 TESR_ShadowCubeMapBlend2;
float4 TESR_ShadowCubeMapBlend3;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer1 : register(s3) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer2 : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer3 : register(s5) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer4 : register(s6) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer5 : register(s7) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer6 : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer7 : register(s9) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer8 : register(s10) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer9 : register(s11) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer10 : register(s12) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
samplerCUBE TESR_ShadowCubeMapBuffer11 : register(s13) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float nearZ = TESR_ProjectionTransform._43 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;
static const float BIAS = 0.001f;

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

float Lookup(int bufferIndex, float3 LightDir, float Distance, float Blend, float2 OffSet) {
	float Shadow = 1.0f;
	float3 coord = float3(OffSet.x * TESR_ShadowData.z, OffSet.y * TESR_ShadowData.z, 0.0f);

	if (bufferIndex == 0) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer0, LightDir + coord).r;
	}
	else if (bufferIndex == 1) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer1, LightDir + coord).r;
	}
	else if (bufferIndex == 2) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer2, LightDir + coord).r;
	}
	else if (bufferIndex == 3) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer3, LightDir + coord).r;
	}
	else if (bufferIndex == 4) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer4, LightDir + coord).r;
	}
	else if (bufferIndex == 5) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer5, LightDir + coord).r;
	}
	else if (bufferIndex == 6) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer6, LightDir + coord).r;
	}
	else if (bufferIndex == 7) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer7, LightDir + coord).r;
	}
	else if (bufferIndex == 8) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer8, LightDir + coord).r;
	}
	else if (bufferIndex == 9) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer9, LightDir + coord).r;
	}
	else if (bufferIndex == 10) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer10, LightDir + coord).r;
	}
	else if (bufferIndex == 11) {
		Shadow = texCUBE(TESR_ShadowCubeMapBuffer11, LightDir + coord).r;
	}

	if (Shadow > 0.0f && Shadow < 1.0f && Shadow < Distance - BIAS) return Blend;
	return 1.0f;

}

float LookupLightAmount(int bufferIndex, float4 WorldPos, float4 LightPos, float Blend) {

	float Shadow = 0.0f;
	float3 LightDir;
	float Distance;
	float x;
	float y;

	LightDir = WorldPos.xyz - LightPos.xyz;
	LightDir.z *= -1;
	Distance = length(LightDir);
	LightDir = LightDir / Distance;
	Distance = Distance / LightPos.w;

	Blend = max(1.0f - Blend, saturate(Distance) * TESR_ShadowData.y);

	for (y = -2.5f; y <= 2.5f; y += 1.0f) {
		for (x = -2.5f; x <= 2.5f; x += 1.0f) {
			Shadow += Lookup(bufferIndex, LightDir, Distance, Blend, float2(x, y));
		}
	}
	Shadow /= 36.0f;
	return Shadow;

}

float IsSameLight(float4 light1, float4 light2) {

	if (light1.x == light2.x) {
		if (light1.y == light2.y) {
			return true;
		}
	}
	return false;
}

float4 Shadow(VSOUT IN) : COLOR0{

	float3 color = tex2D(TESR_RenderedBuffer, IN.UVCoord).rgb;
	float depth = readDepth(IN.UVCoord);
	float3 camera_vector = toWorld(IN.UVCoord) * depth;
	float4 world_pos = float4(TESR_CameraPosition.xyz + camera_vector, 1.0f);

	float4 pos = mul(world_pos, TESR_WorldTransform);

	float4 light = 0.0f;
	float4 proxLight = 0.0f;
	float blend = 0;
	float fShadow = 1;
	float shadow = 1;
	float tShadow = 1;
	float tShadowMax = 1;

	float distToProximityLight;
	float farCutOffDist;
	float farMaxInc;
	float farClamp;
	float farScaler;
	float nearMaxInc;
	float nearClamp;
	float nearScaler;

	for (int i = 0; i < 12; i++) {
		if (i == 0) {
			light = TESR_ShadowLightPosition0;
			blend = TESR_ShadowCubeMapBlend.x;
		}
		else if (i == 1) {
			light = TESR_ShadowLightPosition1;
			blend = TESR_ShadowCubeMapBlend.y;
		}
		else if (i == 2) {
			light = TESR_ShadowLightPosition2;
			blend = TESR_ShadowCubeMapBlend.z;
		}
		else if (i == 3) {
			light = TESR_ShadowLightPosition3;
			blend = TESR_ShadowCubeMapBlend.w;
		}
		else if (i == 4) {
			light = TESR_ShadowLightPosition4;
			blend = TESR_ShadowCubeMapBlend2.x;
		}
		else if (i == 5) {
			light = TESR_ShadowLightPosition5;
			blend = TESR_ShadowCubeMapBlend2.y;
		}
		else if (i == 6) {
			light = TESR_ShadowLightPosition6;
			blend = TESR_ShadowCubeMapBlend2.z;
		}
		else if (i == 7) {
			light = TESR_ShadowLightPosition7;
			blend = TESR_ShadowCubeMapBlend2.w;
		}
		else if (i == 8) {
			light = TESR_ShadowLightPosition8;
			blend = TESR_ShadowCubeMapBlend3.x;
		}
		else if (i == 9) {
			light = TESR_ShadowLightPosition9;
			blend = TESR_ShadowCubeMapBlend3.y;
		}
		else if (i == 10) {
			light = TESR_ShadowLightPosition10;
			blend = TESR_ShadowCubeMapBlend3.z;
		}
		else if (i == 11) {
			light = TESR_ShadowLightPosition11;
			blend = TESR_ShadowCubeMapBlend3.w;
		}
		else {
			break;
		}

		if (light.w) {
			shadow = LookupLightAmount(i, pos, light, blend);
			tShadowMax = shadow;
			for (int l = 0; l < 12; l++) {
				if (l == 0) {
					proxLight = TESR_ShadowLightPosition0;
				}
				else if (l == 1) {
					proxLight = TESR_ShadowLightPosition1;
				}
				else if (l == 2) {
					proxLight = TESR_ShadowLightPosition2;
				}
				else if (l == 3) {
					proxLight = TESR_ShadowLightPosition3;
				}
				else if (l == 4) {
					proxLight = TESR_ShadowLightPosition4;
				}
				else if (l == 5) {
					proxLight = TESR_ShadowLightPosition5;
				}
				else if (l == 6) {
					proxLight = TESR_ShadowLightPosition6;
				}
				else if (l == 7) {
					proxLight = TESR_ShadowLightPosition7;
				}
				else if (l == 8) {
					proxLight = TESR_ShadowLightPosition8;
				}
				else if (l == 9) {
					proxLight = TESR_ShadowLightPosition9;
				}
				else if (l == 10) {
					proxLight = TESR_ShadowLightPosition10;
				}
				else if (l == 11) {
					proxLight = TESR_ShadowLightPosition11;
				}
				else {
					break;
				}

				tShadow = shadow;
				if (proxLight.w && !IsSameLight(proxLight, light)) {
					distToProximityLight = distance(pos.xyz, proxLight.xyz);
					if (distToProximityLight < proxLight.w) {
						farCutOffDist = proxLight.w * 0.5f;
						farMaxInc = 0.2f;
						farClamp = tShadow + farMaxInc;
						farScaler = (farMaxInc * 2) / (proxLight.w - farCutOffDist);
						if (distToProximityLight > farCutOffDist) {
							tShadow += (farCutOffDist - (distToProximityLight - farCutOffDist)) * farScaler;
							tShadow = clamp(tShadow, 0.0f, farClamp);
						}
						else {
							nearMaxInc = 1.0f;
							nearClamp = farClamp + nearMaxInc;
							nearScaler = (nearMaxInc * 2.0) / farCutOffDist;
							tShadow = farClamp;
							tShadow += (farCutOffDist - distToProximityLight) * nearScaler;
							tShadow = clamp(tShadow, 0.0f, nearClamp);
						}
					}
				}

				if (tShadow > tShadowMax) {
					tShadowMax = tShadow;
				}
			}
			tShadowMax = saturate(tShadowMax);
			fShadow *= tShadowMax;
		}
	}

	color.rgb *= fShadow * float3(0.96f, 0.98f, 1.0f);
	return float4(color, 1.0f);

}

technique {

	pass {
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Shadow();
	}

}