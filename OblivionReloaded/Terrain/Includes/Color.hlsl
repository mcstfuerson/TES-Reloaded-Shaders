static const float3x3 YUVs_RGB  = {{+ 0.29900, + 0.58700	 , + 0.11400	},
								   {- 0.14740, - 0.28950	 , + 0.43690	},
								   {+ 0.61500, - 0.51500	 , - 0.10000	}};
								   
static const float3x3 RGB_YUVs  = {{+ 1	     , + 0.000	     , + 1.13980	},
								   {+ 1	     , - 0.39380     , - 0.58050	},
								   {+ 1	     , + 2.02790     , + 0.000	    }};
			
float3 GetYUV( const float3 rgb )
{
    return mul( YUVs_RGB, rgb );
}

float3 GetRGB( const float3 yuv )
{
    return mul( RGB_YUVs, yuv );
}