Shader "HappyDDZ/PBR_Aniso_Twinkle"
{
	Properties
	{   
		_Basemap("BaseMap", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (1, 1, 1, 1)
		_Normalmap("NormalMap", 2D) = "bump" {}
		_Mask0("_Mask0( [ R : 金属]  [G : 光滑度]  [B : AO]  [A : 边缘光] )", 2D) = "white" {}
		_Mask1("_Mask1", 2D) = "white" {}
		_Emissionmap("_Emissionmap", 2D) = "black" {}
        _Detailmap("_Detailmap", 2D) = "black" {}
        _Twinklemap("_Twinklemap", 2D) = "black" {}

		_ColorIntensity("_ColorIntensity", Range(0, 3)) = 1
		_Saturation("_Saturation", Range(0, 2)) = 1 //饱和度
		_Contrast("_Contrast", Range(0, 2)) = 1 //对比度

		_Metallic("_Metallic", Range(0, 1)) = 0
		_Smoothness("_Smoothness", Range(0, 1)) = 0
		_Occlusion("_Occlusion", Range(0, 1)) = 1

		_NormalScale("_NormalScale", Range(0, 10)) = 1

		_GlobalCubemap("_GlobalCubemap   (HDR)", Cube) = "grey" {}
		_GlobalBackfaceBrightness("_GlobalBackfaceBrightness", Range(0, 1)) = 0
		_GlobalCubemapRotation("_GlobalCubemapRotation", Float) = 0
		_GlobalCubemapIntensity("_GlobalCubemapIntensity", Float) = 1.0

		[HDR]_Emission("Emission Color", Color) = (0, 0, 0, 0)
        _DetailScale("_DetailScale", Float) = 1.0


		_AmbientSkyColor("_AmbientSkyColor", Color) = (0, 0, 0, 0)
		_AmbientEquatorColor("_AmbientEquatorColor", Color) = (0, 0, 0, 0)
		_AmbientGroundColor("_AmbientGroundColor", Color) = (0, 0, 0, 0)
	    _AmbientIntensity("_AmbientIntensity", Float) = 1.0

		_HalfRimLightColor("_HalfRimLightColor", Color) = (0, 0, 0, 0)
		_HalfRimLightPower("_HalfRimLightPower", Range(0 , 50)) = 1
		_HalfRimLightIntensity("_HalfRimLightIntensity", Range(0 , 50)) = 1
		// 正常的lightDir + view 方向，
		// 是一个自定义的h方向了
		_HalfRimLightDir("_HalfRimLightDir", Vector) = (0, 0, 0, 0)

        _Anisotropy("_Anisotropy", Float) = 1.0
        _AnisoDirection("_AnisoDirection", Float) = 1.0
        _AnisoColor("_AnisoColor", Color) = (0, 0, 0, 0)

        _Anisotropy2("_Anisotropy2", Float) = 1.0
        _AnisoDirection2("_AnisoDirection2", Float) = 1.0
        _AnisoColor2("_AnisoColor2", Color) = (0, 0, 0, 0)
        //
        _TwinkleType("_TwinkleType", Float) = 2.00
        _TwinkleColor("_TwinkleColor", Color)= (0.67685, 0.39151, 1.00) 
        _TwinkleSize("_TwinkleSize", Float) = 8.10
        _TwinklePower("_TwinklePower", Float) = 20.00
        _TwinkleIntensity("_TwinkleIntensity", Float) = 0.473
        _ShiningSpeed("_ShiningSpeed", Float) = 0.073
        _ShineMask("_ShineMask", Float) = 0.438
        _ShineSpeed("_ShineSpeed", Float) = 0.00
        _UVFrequency("_UVFrequency", Float) = 0.00
        _ShineIntensity("_ShineIntensity", Float) = 52.00
        _ShineIntensity2("_ShineIntensity2", Float) = 27.00

        _DiamondCol("_DiamondCol", Color) = (0.93869, 0.10768, 0.02416, 1.00)
        _DiamondCol2("_DiamondCol2", Color) = (0.98225, 0.61099, 0.36625, 1.00)
        _DiamondCol3("_DiamondCol3", Color) = (0.91629, 0.00391, 0.00035, 1.00)


        _EnvReflIntensity("_EnvReflIntensity", Float) = 0.0
        _EnvReflAmbientColor("_EnvReflAmbientColor", Color) = (0.21404, 0.21404, 0.21404, 1.00)

        _RotateRate("_RotateRate", Float) = 8.09
        _Power1("_Power1", Float) = 76.20
        _Power2("_Power2", Float) = 12.50
	}

		SubShader
		{
			Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
			// Cull Back
            Cull off

			Pass
			{

				Name "Forward"
				Tags { "LightMode" = "UniversalForward" }

				Blend One Zero, One Zero
				ZWrite On
				ZTest LEqual
				Offset 0 , 0
				ColorMask RGBA


				HLSLPROGRAM

				#define _RECEIVE_SHADOWS_OFF 1


				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
				#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS


				#pragma vertex vert
				#pragma fragment frag

				#define SHADERPASS_FORWARD

            #include "Assets/Art/shader/Core/ColorCore.hlsl"
			#include "DZZLighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 vertexLight : TEXCOORD1;

				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;

				float4 uv : TEXCOORD6;


			};

			CBUFFER_START(UnityPerMaterial)

			float4 _Basemap_ST;
			float4 _BaseColor;
			float4 _Normalmap_ST;
			float4 _Mask0_ST;
			float4 _Mask1_ST;
            float4 _Detailmap_ST;
            float4 _Twinklemap_ST;


			float4 _GlobalCubemap_HDR;
			float _ColorIntensity;
			float _Saturation;
			float _Contrast;

			float4 _HalfRimLightColor;
			float _HalfRimLightPower;
			float4 _HalfRimLightDir;
			float _HalfRimLightIntensity;

			float _Metallic;
			float _Smoothness;
			float _Occlusion;
			float _NormalScale;
            float _DetailScale;

			float4 _Emission;
			//
			float _GlobalBackfaceBrightness;
			float _GlobalCubemapRotation;
			float _GlobalCubemapIntensity;
			//
			float4 _AmbientSkyColor;
			float4	_AmbientEquatorColor;
			float4	_AmbientGroundColor;
			float _AmbientIntensity;

            float _Anisotropy;
            float _Anisotropy2;
            float _AnisoDirection;
            float _AnisoDirection2;
            float4 _AnisoColor;
            float4 _AnisoColor2;
            // twinkle
            float _TwinkleType;
            float4 _TwinkleColor;
            float  _TwinkleSize;
            float  _TwinklePower;
            float  _TwinkleIntensity;
            float  _ShiningSpeed;
            float  _ShineMask;
            float  _ShineSpeed;
            float  _UVFrequency;
            float  _ShineIntensity;
            float  _ShineIntensity2;
            float4 _DiamondCol;
            float4 _DiamondCol2;
            float4 _DiamondCol3;

            float _EnvReflIntensity;
            float _RotateRate;
            float _Power1;
            float _Power2;

            float4 _EnvReflAmbientColor;


			CBUFFER_END
			sampler2D _Basemap;
			sampler2D _Normalmap;
			sampler2D _Mask0;
			sampler2D _Mask1;
			sampler2D _Emissionmap;
            sampler2D _Detailmap;
            sampler2D _Twinklemap;
			//samplerCUBE _GlobalCubemap;
            TEXTURECUBE(_GlobalCubemap);
			SAMPLER(sampler_GlobalCubemap);

			VertexOutput VertexFunction(VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				o.uv.xy = v.texcoord.xy * _Basemap_ST.xy + _Basemap_ST.zw;
				o.uv.zw = v.texcoord.xy;

				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float3 positionVS = TransformWorldToView(positionWS);
				float4 positionCS = TransformWorldToHClip(positionWS);

				VertexNormalInputs normalInput = GetVertexNormalInputs(v.ase_normal, v.ase_tangent);

				o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
				OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);



				o.clipPos = positionCS;

				return o;
			}



			VertexOutput vert(VertexInput v)
			{
				return VertexFunction(v);
			}
            half4 frag(VertexOutput IN, float facing : VFACE) : SV_Target
            {
                float u_xlat0;
				float4 u_xlat16_0;
				float2 u_xlatb0; // bool2
				float4 u_xlat1;
				float3 u_xlat16_2;
				float4 u_xlat16_3;
				float4 u_xlat4;
				float2 u_xlat16_4;
				float3 u_xlat5;
				float3 u_xlat16_5;
				float4 u_xlat16_6;
				float4 u_xlat16_7;
				float3 u_xlat16_8;
				float3 u_xlat16_9;
				float3 u_xlat16_10;
				float3 u_xlat16_11;
				float4 u_xlat16_12;
				float3 u_xlat16_13;
				float3 u_xlat16_14;
				float u_xlat15;
				float u_xlat16_15;
				float u_xlat16_21;
				float u_xlat16_22;
				float3 u_xlat16_23;
				float u_xlat16_24;
				float3 u_xlat16_26;
				float u_xlat30;
				float u_xlat16_36;
				float2 u_xlat16_37;
				float u_xlat16_38;
				float2 u_xlat16_39;
				float u_xlat16_41;
				float u_xlat45;
				float u_xlat16_51;
				float u_xlat16_52;
				float u_xlat16_53;
				float u_xlat16_54;
				float u_xlat16_55;
				float u_xlat16_56;
				//
                u_xlat16_0 = tex2D(_Basemap, IN.uv.xy);
                u_xlat1 = u_xlat16_0 * _BaseColor;
                u_xlat16_2.xyz = tex2D(_Emissionmap, IN.uv.xy).xyz;
                u_xlat16_3 = tex2D(_Mask0, IN.uv.xy);
                u_xlat16_4.xy = tex2D(_Mask1, IN.uv.xy).xz;
                u_xlat16_5.xyz = tex2D(_Normalmap, IN.uv.xy).xyz;
                u_xlat16_6.z = u_xlat16_5.z + u_xlat16_5.z;
                u_xlat16_6.xyw = u_xlat16_5.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                u_xlat16_6.xy = u_xlat16_6.xy * _NormalScale;
                u_xlat16_7.xy = IN.uv.zw * _Detailmap_ST.xy + _Detailmap_ST.zw;
                u_xlat16_5.xyz = tex2D(_Detailmap, u_xlat16_7.xy).xyz;
                u_xlat16_7.xyz = u_xlat16_5.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                u_xlat16_7.xy = u_xlat16_7.xy * _DetailScale;
                u_xlat16_52 = dot(u_xlat16_7.xyz, u_xlat16_7.xyz);
                u_xlat16_52 = 1.0/sqrt(u_xlat16_52);
                u_xlat16_7.xyz = u_xlat16_52 * u_xlat16_7.xyz;
                u_xlat16_7.xyz = u_xlat16_7.xyz * float3(-1.0, -1.0, 1.0);
                u_xlat16_8.xyz = u_xlat16_6.xyz / u_xlat16_6.zzz;
                u_xlat16_36 = dot(u_xlat16_6.xyz, u_xlat16_7.xyz);
                u_xlat16_7.xyz = u_xlat16_8.xyz * u_xlat16_36 + (-u_xlat16_7.xyz);
                u_xlat16_7.xyz = (-u_xlat16_6.xyw) + u_xlat16_7.xyz;
                u_xlat16_6.xyz = u_xlat16_4.xxx * u_xlat16_7.xyz + u_xlat16_6.xyw;
                u_xlat16_7.xyz = u_xlat16_6.yyy * IN.tSpace1.xyz;
                u_xlat16_6.xyw = u_xlat16_6.xxx * IN.tSpace0.xyz + u_xlat16_7.xyz;
                u_xlat16_6.xyz = u_xlat16_6.zzz * IN.tSpace2.xyz + u_xlat16_6.xyw;
                u_xlat16_51 = dot(u_xlat16_6.xyz, u_xlat16_6.xyz);
                u_xlat16_51 = 1.0/sqrt(u_xlat16_51);
                u_xlat16_6.xyz = u_xlat16_51 * u_xlat16_6.xyz;
                u_xlat16_51 = ((facing ? 0xffffffffu : uint(0)) != uint(0)) ? 1.0 : -1.0;
                u_xlat16_6.xyz = u_xlat16_51 * u_xlat16_6.xyz;
                u_xlat16_7.x = IN.tSpace0.w;
                u_xlat16_7.y = IN.tSpace1.w;
                u_xlat16_7.z = IN.tSpace2.w;
                u_xlat4.xzw = (-u_xlat16_7.xyz) + _WorldSpaceCameraPos.xyz;
                u_xlat45 = dot(u_xlat4.xzw, u_xlat4.xzw);
                u_xlat45 = max(u_xlat45, 1.17549435e-38);
                u_xlat16_51 = 1.0/sqrt(u_xlat45);
                u_xlat5.xyz = u_xlat4.xzw * u_xlat16_51;
                u_xlat16_7.x = (-_Occlusion) + 1.0;
                u_xlat16_22 = u_xlat16_3.x * _Metallic;
                u_xlat16_7.x = u_xlat16_3.z * _Occlusion + u_xlat16_7.x;
                u_xlat16_37.xy = u_xlat16_6.yy * float2(0.699999988, -0.699999988) + float2(0.300000012, 0.300000012);
#ifdef UNITY_ADRENO_ES3
                u_xlat16_37.xy = min(max(u_xlat16_37.xy, 0.0), 1.0);
#else
                u_xlat16_37.xy = clamp(u_xlat16_37.xy, 0.0, 1.0);
#endif
                u_xlat16_8.x = -abs(u_xlat16_6.y) + 1.60000002;
#ifdef UNITY_ADRENO_ES3
                u_xlat16_8.x = min(max(u_xlat16_8.x, 0.0), 1.0);
#else
                u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0);
#endif
                u_xlat16_23.x = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
                u_xlat16_23.x = max(u_xlat16_23.x, _AmbientSkyColor.x);
                u_xlat16_38 = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
                u_xlat16_38 = max(u_xlat16_38, _AmbientGroundColor.x);
                u_xlat16_23.x = (-u_xlat16_23.x) + 3.0;
                u_xlat16_23.x = (-u_xlat16_38) + u_xlat16_23.x;
#ifdef UNITY_ADRENO_ES3
                u_xlat16_23.x = min(max(u_xlat16_23.x, 0.0), 1.0);
#else
                u_xlat16_23.x = clamp(u_xlat16_23.x, 0.0, 1.0);
#endif
                u_xlat16_8.x = u_xlat16_23.x * u_xlat16_8.x;
                u_xlat16_8.xyz = u_xlat16_8.xxx * _AmbientEquatorColor.xyz;
                u_xlat16_8.xyz = _AmbientSkyColor.xyz * u_xlat16_37.xxx + u_xlat16_8.xyz;
                u_xlat16_8.xyz = _AmbientGroundColor.xyz * u_xlat16_37.yyy + u_xlat16_8.xyz;
                u_xlat16_8.xyz = u_xlat16_8.xyz * _AmbientIntensity;
                u_xlat16_8.xyz = u_xlat16_8.xyz * float3(0.300000012, 0.300000012, 0.300000012);
                u_xlat16_37.x = max(_EnvReflIntensity, 0.0);
                u_xlat16_37.x = min(u_xlat16_37.x, 0.300000012);
                u_xlat16_52 = (-u_xlat16_37.x) * 2.20000005 + 1.0;
                u_xlat16_52 = max(u_xlat16_52, 0.5);
                u_xlat16_8.xyz = u_xlat16_52 * u_xlat16_8.xyz;
                u_xlat16_52 = (-u_xlat16_22) * 0.959999979 + 0.959999979;
                u_xlat16_53 = u_xlat16_3.y * _Smoothness + (-u_xlat16_52);
                u_xlat16_9.xyz = u_xlat1.xyz * u_xlat16_52;
                u_xlat16_10.xyz = u_xlat16_0.xyz * _BaseColor.xyz + float3(-0.0399999991, -0.0399999991, -0.0399999991);
                u_xlat16_10.xyz = u_xlat16_22 * u_xlat16_10.xyz + float3(0.0399999991, 0.0399999991, 0.0399999991);
                u_xlat16_22 = (-u_xlat16_3.y) * _Smoothness + 1.0;
                u_xlat16_52 = u_xlat16_22 * u_xlat16_22;
                u_xlat16_52 = max(u_xlat16_52, 0.0078125);
                u_xlat16_54 = u_xlat16_52 * u_xlat16_52;
                u_xlat16_53 = u_xlat16_53 + 1.0;
#ifdef UNITY_ADRENO_ES3
                u_xlat16_53 = min(max(u_xlat16_53, 0.0), 1.0);
#else
                u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
#endif
                u_xlat0 = u_xlat16_52 * 4.0 + 2.0;
                u_xlat15 = u_xlat16_52 * u_xlat16_52 + -1.0;
                u_xlat16_55 = dot((-u_xlat5.xyz), u_xlat16_6.xyz);
                u_xlat16_55 = u_xlat16_55 + u_xlat16_55;
                u_xlat16_11.xyz = u_xlat16_6.xyz * (-u_xlat16_55) + (-u_xlat5.xyz);
                u_xlat16_55 = _GlobalCubemapRotation * 6.28000021;
                u_xlat16_12.x = sin(u_xlat16_55);
                u_xlat16_13.x = cos(u_xlat16_55);
                u_xlat16_14.x = (-u_xlat16_12.x);
                u_xlat16_14.y = u_xlat16_13.x;
                u_xlat16_13.x = dot(u_xlat16_14.yx, u_xlat16_11.xz);
                u_xlat16_14.z = u_xlat16_12.x;
                u_xlat16_13.z = dot(u_xlat16_14.zy, u_xlat16_11.xz);
                u_xlat16_55 = dot(u_xlat16_6.xyz, u_xlat5.xyz);
#ifdef UNITY_ADRENO_ES3
                u_xlat16_55 = min(max(u_xlat16_55, 0.0), 1.0);
#else
                u_xlat16_55 = clamp(u_xlat16_55, 0.0, 1.0);
#endif
                u_xlat16_55 = (-u_xlat16_55) + 1.0;
                u_xlat16_11.x = u_xlat16_55 * u_xlat16_55;
                u_xlat16_11.x = u_xlat16_11.x * u_xlat16_11.x;
                u_xlat16_8.xyz = u_xlat16_7.xxx * u_xlat16_8.xyz;
                u_xlat16_41 = (-u_xlat16_22) * 0.699999988 + 1.70000005;
                u_xlat16_22 = u_xlat16_22 * u_xlat16_41;
                u_xlat16_22 = u_xlat16_22 * 6.0;
                u_xlat16_13.y = u_xlat16_11.y;
                //u_xlat16_12 = tex2DLod(_GlobalCubemap, u_xlat16_13.xyz, u_xlat16_22);
                u_xlat16_12 = SAMPLE_TEXTURECUBE_LOD(_GlobalCubemap, sampler_GlobalCubemap, u_xlat16_13.xyz, u_xlat16_22);
                u_xlat16_22 = u_xlat16_12.w + -1.0;
                u_xlat16_22 = _GlobalCubemap_HDR.w * u_xlat16_22 + 1.0;
                u_xlat16_22 = max(u_xlat16_22, 0.0);
                u_xlat16_22 = log2(u_xlat16_22);
                u_xlat16_22 = u_xlat16_22 * _GlobalCubemap_HDR.y;
                u_xlat16_22 = exp2(u_xlat16_22);
                u_xlat16_22 = u_xlat16_22 * _GlobalCubemap_HDR.x;
                u_xlat16_26.xyz = u_xlat16_12.xyz * u_xlat16_22;
                u_xlat16_26.xyz = u_xlat16_7.xxx * u_xlat16_26.xyz;
                u_xlat16_26.xyz = u_xlat16_26.xyz * float3(_GlobalCubemapIntensity, _GlobalCubemapIntensity, _GlobalCubemapIntensity);
                u_xlat16_7.x = u_xlat16_52 * u_xlat16_52 + 1.0;
                u_xlat16_7.x = float(1.0) / u_xlat16_7.x;
                u_xlat16_13.xyz = (-u_xlat16_10.xyz) + u_xlat16_53;
                u_xlat16_13.xyz = u_xlat16_11.xxx * u_xlat16_13.xyz + u_xlat16_10.xyz;
                u_xlat1.xyz = u_xlat16_7.xxx * u_xlat16_13.xyz;
                u_xlat16_7.xyw = u_xlat1.xyz * u_xlat16_26.xyz;
                u_xlat16_7.xyw = u_xlat16_8.xyz * u_xlat16_9.xyz + u_xlat16_7.xyw;
                u_xlat16_8.x = dot(u_xlat16_6.xyz, _MainLightPosition.xyz);
                u_xlat16_23.x = u_xlat16_8.x;
#ifdef UNITY_ADRENO_ES3
                u_xlat16_23.x = min(max(u_xlat16_23.x, 0.0), 1.0);
#else
                u_xlat16_23.x = clamp(u_xlat16_23.x, 0.0, 1.0);
#endif
                u_xlat16_38 = (-u_xlat16_23.x) + 1.0;
                u_xlat16_23.x = _GlobalBackfaceBrightness * u_xlat16_38 + u_xlat16_23.x;
                u_xlat16_23.x = u_xlat16_23.x * unity_LightData.z;
                u_xlat16_23.xyz = u_xlat16_23.xxx * _MainLightColor.xyz;
                u_xlat16_11.xyz = u_xlat4.xzw * u_xlat16_51 + _MainLightPosition.xyz;
                u_xlat30 = dot(u_xlat16_11.xyz, u_xlat16_11.xyz);
                u_xlat30 = max(u_xlat30, 1.17549435e-38);
                u_xlat16_56 = 1.0/sqrt(u_xlat30);
                u_xlat1.xyz = u_xlat16_56 * u_xlat16_11.xyz;
                u_xlat16_56 = dot(u_xlat16_6.xyz, u_xlat1.xyz);
#ifdef UNITY_ADRENO_ES3
                u_xlat16_56 = min(max(u_xlat16_56, 0.0), 1.0);
#else
                u_xlat16_56 = clamp(u_xlat16_56, 0.0, 1.0);
#endif
                u_xlat16_13.x = dot(_MainLightPosition.xyz, u_xlat1.xyz);
#ifdef UNITY_ADRENO_ES3
                u_xlat16_13.x = min(max(u_xlat16_13.x, 0.0), 1.0);
#else
                u_xlat16_13.x = clamp(u_xlat16_13.x, 0.0, 1.0);
#endif
                u_xlat16_56 = u_xlat16_56 * u_xlat16_56;
                u_xlat15 = u_xlat16_56 * u_xlat15 + 1.00001001;
                u_xlat16_56 = u_xlat16_13.x * u_xlat16_13.x;
                u_xlat16_13.x = u_xlat15 * u_xlat15;
                u_xlat15 = max(u_xlat16_56, 0.100000001);
                u_xlat15 = u_xlat15 * u_xlat16_13.x;
                u_xlat0 = u_xlat0 * u_xlat15;
                u_xlat0 = u_xlat16_54 / u_xlat0;
                u_xlat16_54 = u_xlat0 + -6.10351562e-05;
                u_xlat16_54 = max(u_xlat16_54, 0.0);
                u_xlat16_54 = min(u_xlat16_54, 100.0);
                u_xlat16_9.xyz = u_xlat16_10.xyz * u_xlat16_54 + u_xlat16_9.xyz;
                u_xlat16_7.xyw = u_xlat16_9.xyz * u_xlat16_23.xyz + u_xlat16_7.xyw;
                u_xlat16_7.xyw = u_xlat16_2.xyz * _Emission.xyz + u_xlat16_7.xyw;
#ifdef UNITY_ADRENO_ES3
                u_xlatb0.x = !!(_TwinkleType == 0.0);
#else
                u_xlatb0.x = _TwinkleType == 0.0;
#endif
                if (u_xlatb0.x) {
                    u_xlat16_8.x = u_xlat16_8.x * 0.5 + 0.5;
#ifdef UNITY_ADRENO_ES3
                    u_xlat16_8.x = min(max(u_xlat16_8.x, 0.0), 1.0);
#else
                    u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0);
#endif
                    u_xlat16_23.xy = u_xlat5.xy * float2(_ShiningSpeed, _ShiningSpeed);
                    u_xlat16_9.xy = IN.uv.xy * _TwinkleSize;
                    u_xlat16_39.xy = IN.uv.xy * _TwinkleSize + u_xlat16_23.xy;
                    u_xlat16_0.x = tex2D(_Twinklemap, u_xlat16_39.xy).x;
                    u_xlat16_39.xy = u_xlat16_9.xy * float2(1.39999998, 1.39999998);
                    u_xlat16_15 = tex2D(_Twinklemap, u_xlat16_39.xy).x;
                    u_xlat16_53 = dot(u_xlat16_0.xx, u_xlat16_15);
                    u_xlat16_39.x = max(_TwinklePower, 1.0);
                    u_xlat16_53 = log2(abs(u_xlat16_53));
                    u_xlat16_53 = u_xlat16_53 * u_xlat16_39.x;
                    u_xlat16_53 = exp2(u_xlat16_53);
                    u_xlat16_23.xy = u_xlat16_23.xy + u_xlat16_23.xy;
                    u_xlat16_10.xy = IN.uv.xy * _TwinkleSize + u_xlat16_23.xy;
                    u_xlat16_0.x = tex2D(_Twinklemap, u_xlat16_10.xy).x;
                    u_xlat16_23.xy = u_xlat16_9.xy * float2(1.39999998, 1.39999998) + u_xlat16_23.xy;
                    u_xlat16_15 = tex2D(_Twinklemap, u_xlat16_23.xy).x;
                    u_xlat16_23.x = dot(u_xlat16_0.xx, u_xlat16_15);
                    u_xlat16_23.x = log2(abs(u_xlat16_23.x));
                    u_xlat16_23.x = u_xlat16_23.x * u_xlat16_39.x;
                    u_xlat16_23.x = exp2(u_xlat16_23.x);
                    u_xlat16_23.x = u_xlat16_23.x + u_xlat16_53;
                    u_xlat16_23.x = min(u_xlat16_23.x, 1.0);
                    u_xlat16_23.x = u_xlat16_23.x * _TwinkleIntensity;
                    u_xlat16_23.xyz = u_xlat16_23.xxx * _TwinkleColor.xyz;
                    u_xlat16_8.xyz = u_xlat16_8.xxx * u_xlat16_23.xyz;
                    u_xlat16_8.xyz = u_xlat16_4.yyy * u_xlat16_8.xyz;
                }
                else {
#ifdef UNITY_ADRENO_ES3
                    u_xlatb0.x = !!(_TwinkleType == 1.0);
#else
                    u_xlatb0.x = _TwinkleType == 1.0;
#endif
                    if (u_xlatb0.x) {
                        u_xlat16_9.xy = IN.uv.xy * _TwinkleSize;
                        u_xlat16_9.xy = u_xlat16_9.xy * float2(20.0, 20.0);
                        u_xlat16_0.x = tex2D(_Twinklemap, u_xlat16_9.xy).x;
                        u_xlat16_9.xy = floor(u_xlat16_9.xy);
                        u_xlat15 = _Time.y * _ShiningSpeed;
                        u_xlat16_53 = floor(u_xlat15);
                        u_xlat16_39.xy = u_xlat16_53 * u_xlat16_9.xy;
                        u_xlat16_53 = dot(u_xlat16_39.xy, float2(12.9898005, 78.2330017));
                        u_xlat16_53 = sin(u_xlat16_53);
                        u_xlat16_53 = u_xlat16_53 * 43758.5469;
                        u_xlat16_53 = frac(u_xlat16_53);
                        u_xlat16_39.x = ceil(u_xlat15);
                        u_xlat16_9.xy = u_xlat16_39.xx * u_xlat16_9.xy;
                        u_xlat16_9.x = dot(u_xlat16_9.xy, float2(12.9898005, 78.2330017));
                        u_xlat16_9.x = sin(u_xlat16_9.x);
                        u_xlat16_9.x = u_xlat16_9.x * 43758.5469;
                        u_xlat16_9.x = frac(u_xlat16_9.x);
                        u_xlat16_24 = frac(u_xlat15);
                        u_xlat16_9.x = (-u_xlat16_53) + u_xlat16_9.x;
                        u_xlat16_53 = u_xlat16_24 * u_xlat16_9.x + u_xlat16_53;
                        u_xlat16_9.x = floor(_TwinklePower);
                        u_xlat16_53 = log2(abs(u_xlat16_53));
                        u_xlat16_53 = u_xlat16_53 * u_xlat16_9.x;
                        u_xlat16_53 = exp2(u_xlat16_53);
                        u_xlat16_9.x = u_xlat16_53 + u_xlat16_53;
                        u_xlat16_9.x = sin(u_xlat16_9.x);
                        u_xlat16_9.x = u_xlat16_9.x * 2.0 + -1.20000005;
                        u_xlat16_9.x = max(u_xlat16_9.x, 0.0);
                        u_xlat16_53 = u_xlat16_53 * _TwinkleIntensity;
                        u_xlat16_24 = dot(_TwinkleColor.xyz, float3(0.212500006, 0.715399981, 0.0720999986));
                        u_xlat16_10.xyz = (-u_xlat16_24) + _TwinkleColor.xyz;
                        u_xlat16_9.xyz = u_xlat16_9.xxx * u_xlat16_10.xyz + u_xlat16_24;
                        u_xlat16_9.xyz = u_xlat16_0.xxx * u_xlat16_9.xyz;
                        u_xlat16_9.xyz = u_xlat16_53 * u_xlat16_9.xyz;
                        u_xlat16_8.xyz = u_xlat16_4.yyy * u_xlat16_9.xyz;
                    }
                    else {
#ifdef UNITY_ADRENO_ES3
                        u_xlatb0.x = !!(_TwinkleType == 2.0);
#else
                        u_xlatb0.x = _TwinkleType == 2.0;
#endif
                        if (u_xlatb0.x) {
                            u_xlat16_9.xy = IN.uv.xy * _TwinkleSize;
                            u_xlat16_0.xyz = tex2D(_Twinklemap, u_xlat16_9.xy).xyz;
                            u_xlat16_53 = u_xlat4.x * u_xlat16_51 + (-u_xlat5.y);
                            u_xlat16_51 = u_xlat4.w * u_xlat16_51 + u_xlat16_53;
                            u_xlat16_51 = u_xlat16_51 * _RotateRate + u_xlat16_0.x;
                            u_xlat45 = dot(_Time.yy, float2(float2(_ShiningSpeed, _ShiningSpeed)));
                            u_xlat45 = u_xlat45 + u_xlat16_51;
                            u_xlat16_51 = u_xlat16_0.x + u_xlat45;
                            u_xlat16_51 = frac(u_xlat16_51);
                            u_xlat16_51 = u_xlat16_51 * u_xlat16_0.z + (-_ShineMask);
                            u_xlat16_53 = u_xlat16_51 * u_xlat16_51;
                            u_xlat16_51 = u_xlat16_51 * u_xlat16_53;
                            u_xlat16_51 = u_xlat16_51 * _ShineIntensity;
#ifdef UNITY_ADRENO_ES3
                            u_xlat16_51 = min(max(u_xlat16_51, 0.0), 1.0);
#else
                            u_xlat16_51 = clamp(u_xlat16_51, 0.0, 1.0);
#endif
                            u_xlat16_51 = log2(u_xlat16_51);
                            u_xlat16_51 = u_xlat16_51 * 50.0;
                            u_xlat16_51 = exp2(u_xlat16_51);
                            u_xlat16_51 = u_xlat16_0.z * u_xlat16_51;
                            u_xlat16_53 = u_xlat16_0.y + u_xlat16_0.y;
                            u_xlat16_53 = u_xlat16_53;
#ifdef UNITY_ADRENO_ES3
                            u_xlat16_53 = min(max(u_xlat16_53, 0.0), 1.0);
#else
                            u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
#endif
                            u_xlat16_9.xyz = (-_DiamondCol.xyz) + _DiamondCol2.xyz;
                            u_xlat16_9.xyz = u_xlat16_53 * u_xlat16_9.xyz + _DiamondCol.xyz;
                            u_xlat16_53 = u_xlat16_0.y * 2.0 + -1.0;
#ifdef UNITY_ADRENO_ES3
                            u_xlat16_53 = min(max(u_xlat16_53, 0.0), 1.0);
#else
                            u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
#endif
                            u_xlat16_10.xyz = (-u_xlat16_9.xyz) + _DiamondCol3.xyz;
                            u_xlat16_9.xyz = u_xlat16_53 * u_xlat16_10.xyz + u_xlat16_9.xyz;
                            u_xlat16_51 = u_xlat16_51 * _ShineIntensity2;
                            u_xlat16_9.xyz = u_xlat16_51 * u_xlat16_9.xyz;
                            u_xlat16_51 = dot(u_xlat16_11.xyz, u_xlat16_11.xyz);
                            u_xlat16_51 = 1.0/sqrt(u_xlat16_51);
                            u_xlat16_10.xyz = u_xlat16_51 * u_xlat16_11.xyz;
                            u_xlat16_51 = dot(u_xlat16_6.xyz, u_xlat16_10.xyz);
#ifdef UNITY_ADRENO_ES3
                            u_xlat16_51 = min(max(u_xlat16_51, 0.0), 1.0);
#else
                            u_xlat16_51 = clamp(u_xlat16_51, 0.0, 1.0);
#endif
                            u_xlat16_53 = dot(_MainLightPosition.xyz, u_xlat5.xyz);
#ifdef UNITY_ADRENO_ES3
                            u_xlat16_53 = min(max(u_xlat16_53, 0.0), 1.0);
#else
                            u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
#endif
                            u_xlat16_54 = (-_Power1) + _Power2;
                            u_xlat16_53 = u_xlat16_53 * u_xlat16_54 + _Power1;
                            u_xlat16_51 = log2(u_xlat16_51);
                            u_xlat16_51 = u_xlat16_51 * u_xlat16_53;
                            u_xlat16_51 = exp2(u_xlat16_51);
                            u_xlat16_9.xyz = u_xlat16_9.xyz * u_xlat16_51;
                            u_xlat16_8.xyz = u_xlat16_4.yyy * u_xlat16_9.xyz;
                        }
                        else {
                            u_xlat16_8.x = 0.0;
                            u_xlat16_8.y = 0.0;
                            u_xlat16_8.z = 0.0;
                        }
                    }
                }
                u_xlat16_7.xyw = u_xlat16_7.xyw + u_xlat16_8.xyz;
                u_xlat16_51 = u_xlat1.w;
#ifdef UNITY_ADRENO_ES3
                u_xlat16_51 = min(max(u_xlat16_51, 0.0), 1.0);
#else
                u_xlat16_51 = clamp(u_xlat16_51, 0.0, 1.0);
#endif
                u_xlat16_7.xyz = _EnvReflAmbientColor.xyz * u_xlat16_37.xxx + u_xlat16_7.xyw;

                //
                u_xlat16_52 = dot(_HalfRimLightDir.xyz, _HalfRimLightDir.xyz);
                u_xlat16_52 = 1.0 / sqrt(u_xlat16_52);
                u_xlat16_8.xyz = u_xlat16_52 * _HalfRimLightDir.xyz;
                u_xlat16_52 = log2(u_xlat16_55);
                u_xlat16_52 = u_xlat16_52 * _HalfRimLightPower;
                u_xlat16_52 = exp2(u_xlat16_52);
                u_xlat16_8.x = dot(u_xlat16_6.xyz, u_xlat16_8.xyz);
                u_xlat16_8.x = u_xlat16_8.x * 0.5;
#ifdef UNITY_ADRENO_ES3
                u_xlat16_8.x = min(max(u_xlat16_8.x, 0.0), 1.0);
#else
                u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0);
#endif
                u_xlat16_23.x = u_xlat16_8.x * -2.0 + 3.0;
                u_xlat16_8.x = u_xlat16_8.x * u_xlat16_8.x;
                u_xlat16_8.x = u_xlat16_8.x * u_xlat16_23.x;
                u_xlat16_23.xyz = u_xlat16_52 * _HalfRimLightColor.xyz;
                u_xlat16_8.xyz = u_xlat16_8.xxx * u_xlat16_23.xyz;
                u_xlat16_8.xyz = u_xlat16_8.xyz * float3(_HalfRimLightIntensity, _HalfRimLightIntensity, _HalfRimLightIntensity);
                //
                u_xlat16_8.xyz = u_xlat16_8.xyz;
#ifdef UNITY_ADRENO_ES3
                u_xlat16_8.xyz = min(max(u_xlat16_8.xyz, 0.0), 1.0);
#else
                u_xlat16_8.xyz = clamp(u_xlat16_8.xyz, 0.0, 1.0);
#endif
                u_xlat16_6.xyz = u_xlat16_3.www * u_xlat16_8.xyz + u_xlat16_7.xyz;


                //
                float4 result;
                result.xyz = min(u_xlat16_6.xyz, float3(4.0, 4.0, 4.0));
                result.w = min(u_xlat16_51, 1.0);
				return result;
			}
			ENDHLSL
		}
		}
}

