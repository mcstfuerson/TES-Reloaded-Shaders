#define	INTERPOLATE_SIMPLIFIED
#define nolight

float4 TESR_ParallaxData : register(c8);
float4 TESR_TextureData : register(c9);

#define	g_fHeightMapScale	TESR_ParallaxData.x
#define	g_fShadowSoftening	TESR_ParallaxData.y
#define	g_nMinSamples		TESR_ParallaxData.z
#define	g_nMaxSamples		TESR_ParallaxData.w

#define	g_nLODThreshold 10
#define	bBlendThreshold	(g_nLODThreshold / 2)
#define	bBlendRange		(g_nLODThreshold - bBlendThreshold)
#define	bBlendMIPs		(fMipLevelFrac = fMipLevel - (float)bBlendThreshold) > 0
#define	bBlendFraction	(fMipLevelFrac / bBlendRange)

void psParallax(in float2 BaseUV, in float3 CameraDir, inout float2 uv, inout float ao) {

#ifndef	INTERPOLATE_SIMPLIFIED
	// Compute initial parallax displacement direction:
	float2 ParallaxDirection = normalize(CameraDir.xy);
	float2 iParallaxOffset;

	// The length of this vector determines the furthest amount of displacement:
	float Length	     = length(CameraDir.xyz);
	float ParallaxLength = (sqrt(Length * Length - CameraDir.z * CameraDir.z)) / CameraDir.z;

	// Compute the actual reverse parallax displacement vector:
	iParallaxOffset = ParallaxDirection * ParallaxLength;

	// Need to scale the amount of displacement to account for different height ranges
	// in height maps. This is controlled by an artist-editable parameter:
	iParallaxOffset *= g_fHeightMapScale;
#else
	float2 iParallaxOffset;

	// Compute the actual reverse parallax displacement vector:
	iParallaxOffset = CameraDir.xy / length(CameraDir.xyz);

	// Need to scale the amount of displacement to account for different height ranges
	// in height maps. This is controlled by an artist-editable parameter:
	iParallaxOffset *= g_fHeightMapScale;
#endif

	/* the view angle between the tangent-space normal and the camera */
	float viewAngle = saturate(dot(normalize(CameraDir), float3(0, 0, 1)));

	/* try to get rid of the swimming
	iParallaxOffset *= pow(saturate(viewAngle + 0.25), 0.25); */

	// Adaptive in-shader level-of-detail system implementation. Compute the
	// current mip level explicitly in the pixel shader and use this information
	// to transition between different levels of detail from the full effect to
	// simple bump mapping. See the above paper for more discussion of the approach
	// and its benefits.

	// Compute the current gradients:
	float2 fTexCoordsPerSize = BaseUV.xy * TESR_TextureData.xy;

	// Compute all 4 derivatives in x and y in a single instruction to optimize:
	float2 dxSize, dySize;
	float2 dx, dy;

	float4(dxSize, dx) = ddx(float4(fTexCoordsPerSize, BaseUV.xy));
	float4(dySize, dy) = ddy(float4(fTexCoordsPerSize, BaseUV.xy));

	float  fMipLevel;
	float  fMipLevelInt;    // mip level integer portion
	float  fMipLevelFrac;   // mip level fractional amount for blending in between levels

	float  fMinTexCoordDelta;
	float2 dTexCoords;

	// Find min of change in u and v across quad: compute du and dv magnitude across quad
	dTexCoords = dxSize * dxSize + dySize * dySize;

	// Standard mipmapping uses max here
	fMinTexCoordDelta = max(dTexCoords.x, dTexCoords.y);

	// Compute the current mip level  (* 0.5 is effectively computing a square root before )
	fMipLevel = max(0.5 * log2(fMinTexCoordDelta), 0);

//  OUT.Color.rgb = float3(1 / fMipLevel, 0, 0);

	float2 texSample = uv.xy;
	float fOcclusionShadow = 1.0;

	if (fMipLevel <= (float)g_nLODThreshold) {
	   //===============================================//
	   // Parallax occlusion mapping offset computation //
	   //===============================================//
	   float precAngle = viewAngle;//1.0 - exp(-20.0 * viewAngle);

	   // Utilize dynamic flow control to change the number of samples per ray
	   // depending on the viewing angle for the surface. Oblique angles require
	   // smaller step sizes to achieve more accurate precision for computing displacement.
	   // We express the sampling rate as a linear function of the angle between
	   // the geometric normal and the view direction ray:
	   int nNumSteps = (int)lerp(g_nMaxSamples, g_nMinSamples, precAngle);

//  OUT.Color.rgb = float3(g_nMinSamples / (float)nNumSteps, 0, 0);

	   // Intersect the view ray with the height field profile along the direction of
	   // the parallax offset ray (computed in the vertex shader. Note that the code is
	   // designed specifically to take advantage of the dynamic flow control constructs
	   // in HLSL and is very sensitive to specific syntax. When converting to other examples,
	   // if still want to use dynamic flow control in the resulting assembly shader,
	   // care must be applied.
	   //
	   // In the below steps we approximate the height field profile as piecewise linear
	   // curve. We find the pair of endpoints between which the intersection between the
	   // height field profile and the view ray is found and then compute line segment
	   // intersection for the view ray and the line segment formed by the two endpoints.
	   // This intersection is the displacement offset from the original texture coordinate.
	   // See the above paper for more details about the process and derivation.
	   //

	   float fCurrHeight = 0.0;
	   float fStepSize   = 1.0 / (float)nNumSteps;
	   float fPrevHeight = 1.0;
	   float fNextHeight = 0.0;

	   int    nStepIndex = 0;
	   bool   bCondition = true;

	   float2 vTexOffsetPerStep = fStepSize * iParallaxOffset;
	   float2 vTexCurrentOffset = BaseUV.xy;
	   float  fCurrentBound     = 1.0;
	   float  fParallaxAmount   = 0.0;

	   float2 pt1 = 0;
	   float2 pt2 = 0;
	   float2 texOffset2 = 0;

	   while (nStepIndex < nNumSteps) {
	      vTexCurrentOffset -= vTexOffsetPerStep;

	      // Sample height map which in this case is stored in the alpha channel of the normal map:
	      fCurrHeight = tex2Dgrad(TESR_samplerBaseMap, vTexCurrentOffset, dx, dy).a;

//	      clip(                     - vTexCurrentOffset);
//	      clip(g_fBaseTextureRepeat + vTexCurrentOffset);

	      fCurrentBound -= fStepSize;
	      if (fCurrHeight > fCurrentBound) {
	         pt1 = float2(fCurrentBound            , fCurrHeight);
	         pt2 = float2(fCurrentBound + fStepSize, fPrevHeight);

	         texOffset2 = vTexCurrentOffset - vTexOffsetPerStep;

	         nStepIndex = nNumSteps + 1;
	      }
	      else {
	         fPrevHeight = fCurrHeight;

	         nStepIndex++;
	      }
	   }   // End of while ( nStepIndex < nNumSteps )

//  OUT.Color.rgb = float3(fPrevHeight, normalize((IN.ParallaxOffset.xy - 0.5) / 0.5) * 0.5 + 0.5);

	   float fDelta2 = pt2.x - pt2.y;
	   float fDelta1 = pt1.x - pt1.y;

	   float fDenominator = fDelta2 - fDelta1;

	   // SM 3.0 requires a check for divide by zero, since that operation will generate
	   // an 'Inf' number instead of 0, as previous models (conveniently) did:
	   if (fDenominator == 0.0f)
	       fParallaxAmount = 0.0f;
	   else
	       fParallaxAmount = (pt1.x * fDelta2 - pt2.x * fDelta1) / fDenominator;

	   float2 vParallaxOffset = iParallaxOffset * (1 - fParallaxAmount);

	   // The computed texture offset for the displaced point on the pseudo-extruded surface:
	   float2 texSampleBase = BaseUV.xy - vParallaxOffset;
	   texSample = texSampleBase;

//  OUT.Color.rgb = float3(fParallaxAmount, iParallaxOffset);
//  OUT.Color.rgb = float3(tex2D(TESR_samplerBaseMap, iParallaxOffset).a, 0, 0);

#ifndef	nolight
	   if (/*g_bDisplayShadows == true*/ 1 /*dot(IN.Light0Dir, float3(0, 0, 1)) > 0*/) {
	     float2 vLightRayTS = IN.Light0Dir.xy * g_fHeightMapScale;

	     // Compute the soft blurry shadows taking into account self-occlusion for
	     // features of the height field:

	     float sh0 =   tex2Dgrad(TESR_samplerBaseMap, texSampleBase                     , dx, dy).a;
	     float sh  =  sh0;

	     sh = max(sh, (tex2Dgrad(TESR_samplerBaseMap, texSampleBase + vLightRayTS * 0.88, dx, dy).a - sh0 - 0.88) *  1 * g_fShadowSoftening);
	     sh = max(sh, (tex2Dgrad(TESR_samplerBaseMap, texSampleBase + vLightRayTS * 0.77, dx, dy).a - sh0 - 0.77) *  2 * g_fShadowSoftening);
	     sh = max(sh, (tex2Dgrad(TESR_samplerBaseMap, texSampleBase + vLightRayTS * 0.66, dx, dy).a - sh0 - 0.66) *  4 * g_fShadowSoftening);
	     sh = max(sh, (tex2Dgrad(TESR_samplerBaseMap, texSampleBase + vLightRayTS * 0.55, dx, dy).a - sh0 - 0.55) *  6 * g_fShadowSoftening);
	     sh = max(sh, (tex2Dgrad(TESR_samplerBaseMap, texSampleBase + vLightRayTS * 0.44, dx, dy).a - sh0 - 0.44) *  8 * g_fShadowSoftening);
	     sh = max(sh, (tex2Dgrad(TESR_samplerBaseMap, texSampleBase + vLightRayTS * 0.33, dx, dy).a - sh0 - 0.33) * 10 * g_fShadowSoftening);
	     sh = max(sh, (tex2Dgrad(TESR_samplerBaseMap, texSampleBase + vLightRayTS * 0.22, dx, dy).a - sh0 - 0.22) * 12 * g_fShadowSoftening);

	     // Compute the actual shadow strength:
//	     fOcclusionShadow =     sh;
//	     fOcclusionShadow =     saturate(sh);
	     fOcclusionShadow = (1 - saturate(sh - sh0));

	     // The previous computation overbrightens the image, let's adjust for that:
	/*   fOcclusionShadow =
	     	pow(saturate(fOcclusionShadow * 1.9), 4); */

	     fOcclusionShadow = fOcclusionShadow * 0.6 + 0.4;
	   }   // End of if ( bAddShadows )
#endif

	   if (bBlendMIPs) {
	      // Lerp based on the fractional part:
	   // fMipLevelFrac = modf(fMipLevel, fMipLevelInt);
	      fMipLevelFrac = pow(frac(bBlendFraction), 2);

	      // Lerp the texture coordinate from parallax occlusion mapped coordinate to bump mapping
	      // smoothly based on the current mip level:
	      texSample = lerp(texSampleBase, uv, fMipLevelFrac);

	      fOcclusionShadow = lerp(fOcclusionShadow, 1, fMipLevelFrac);
	   }  // End of if ( fMipLevel > fThreshold - 1 )

//  OUT.Color.rgb = float3(-IN.Light0Dir.xy, 0);
//  OUT.Color.rgb = float3(normalize(-IN.Light0Dir.xy) * 0.5 + 0.5, 0);
//  OUT.Color.rgb = dot(-IN.Light0Dir, float3(0, 0, 1));

	}   // End of if ( fMipLevel <= (float) nLODThreshold )

//  OUT.Color.rgb = tex2D( TESR_samplerBaseMap, texSample ).rgb;

	uv = texSample;
	ao = fOcclusionShadow;
}