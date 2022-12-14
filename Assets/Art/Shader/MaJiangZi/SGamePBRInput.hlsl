#ifndef SGAME_PBRINPUT_INCLUDE
	#define SGAME_PBRINPUT_INCLUDE

	#include "../Common/CommonFunction.hlsl"
	#include "../Common/ShadingModel.hlsl"
	#include "../Common/GlobalIllumination.hlsl"

	CBUFFER_START(UnityPerMaterial)

		// transparent
		half _Cutoff;

		// PBR
		half4 _BaseColor;
		float4 _BaseMap_ST;

		half _Smoothness;
		half _Metallic;
		half _OcclusionStrength;
		half _SpecularOcclusionStrength;

		half _Reflectance;

		half4 _EmissionColor;

		// clear Cloat
		half _ClearCoatMask;
		half _ClearCoatSmoothness;
		half _ClearCoatDownSmoothness;
		float4 _ClearCoatCubeMap_HDR;
		half _ClearCoat_Detail_Factor;

		// detail
		float _DetailMap_Tilling_1;
		half _DetailAlbedoScale_1;
		half3 _DetailAlbedoColor_1;
		half _DetailNormalScale_1;
		half _DetailSmoothnessScale_1;

		float _DetailMap_Tilling_2;
		half _DetailAlbedoScale_2;
		half3 _DetailAlbedoColor_2;
		half _DetailNormalScale_2;
		half _DetailSmoothnessScale_2;

		float _DetailMap_Tilling_3;
		half _DetailAlbedoScale_3;
		half3 _DetailAlbedoColor_3;
		half _DetailNormalScale_3;
		half _DetailSmoothnessScale_3;

		float _DetailMap_Tilling_4;
		half _DetailAlbedoScale_4;
		half3 _DetailAlbedoColor_4;
		half _DetailNormalScale_4;
		half _DetailSmoothnessScale_4;

		// iridescence
		half _Iridescence;
		half _IridescenceThickness;

		// laser
		half  _LaserIOR;
		half  _LaserThickness;
		half  _LaserBrdfIntensity;
		half  _LaserAnisotropy;
		half3 _LaserColor;
		half  _LaserSmoothstepValue_1;
		half  _LaserSmoothstepValue_2;
		half  _LaserUniversal;
		half  _LaserAreaCubemapInt;

		// Subsurface
		half3 _SubsurfaceColor;

		// Anisotropy
		half _Anisotropy;
	CBUFFER_END

	TEXTURE2D(_BaseMap);	SAMPLER(sampler_BaseMap);

	TEXTURE2D(_NormalMap);
	TEXTURE2D(_BentNormalMap);

	TEXTURE2D(_MetallicGlossMap);

	TEXTURE2D_HALF(_EmissionMap);

	TEXTURE2D_HALF(_ClearCoatMap);
	TEXTURECUBE(_ClearCoatCubeMap);

	TEXTURE2D_HALF(_IridescenceMask);

	TEXTURE2D_HALF(_LaserMap);

	TEXTURE2D_HALF(_ThickMap);

	//detail
	TEXTURE2D_HALF(_Detail_ID);
	TEXTURE2D(_DetailMap_1);
	TEXTURE2D(_DetailMap_2);
	TEXTURE2D(_DetailMap_3);
	TEXTURE2D(_DetailMap_4);

#endif	//SGAME_PBRINPUT_NEW_INCLUDE
