Shader "HappyDDZ/PBR_Aniso"
{
	Properties
	{   
		_Basemap("BaseMap", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (1, 1, 1, 1)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Mask0("_Mask0( [ R : 金属]  [G : 光滑度]  [B : AO]  [A : 边缘光] )", 2D) = "white" {}
		_Mask1("_Mask1", 2D) = "white" {}
		_Emissionmap("_Emissionmap", 2D) = "black" {}
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
	}

		SubShader
		{


			Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
			Cull Back


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

			#include "../PBR/ColorCore.hlsl"
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
			float4 _NormalMap_ST;
			float4 _Mask0_ST;
			float4 _Mask1_ST;
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

			CBUFFER_END
			sampler2D _Basemap;
			sampler2D _NormalMap;
			sampler2D _Mask0;
			sampler2D _Mask1;
			sampler2D _Emissionmap;
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
                float3 u_xlat0;
                float4 u_xlat16_0;
                float4 u_xlat1;
                float3 u_xlat16_2;
                float3 u_xlat3;
                float4 u_xlat16_3;
                float3 u_xlat4;
                float3 u_xlat16_4;
                float4 u_xlat16_5;
                float3 u_xlat16_6;
                float3 u_xlat7;
                float3 u_xlat16_8;
                float3 u_xlat16_9;
                float3 u_xlat16_10;
                float3 u_xlat16_11;
                float4 u_xlat16_12;
                float3 u_xlat16_13;
                float3 u_xlat16_14;
                float3 u_xlat16_15;
                float2 u_xlat16;
                float3 u_xlat16_21;
                float u_xlat16_22;
                float3 u_xlat16_24;
                float3 u_xlat16_27;
                float3 u_xlat16_29;
                float u_xlat16_38;
                float2 u_xlat16_43;
                float u_xlat16_48;
                float u_xlat50;
                float u_xlat16_53;
                float u_xlat16_54;
                float u_xlat16_56;
                float u_xlat16_57;
                float u_xlat16_58;
                float u_xlat16_60;


                u_xlat16_0 = tex2D(_Basemap, IN.uv.xy);
                u_xlat1 = u_xlat16_0 * _BaseColor;
                u_xlat16_2.xyz = tex2D(_Emissionmap, IN.uv.xy).xyz;
                u_xlat16_3 = tex2D(_Mask0, IN.uv.xy);
                u_xlat16_48 = tex2D(_Mask1, IN.uv.xy).y;
                u_xlat16_4.xyz = tex2D(_NormalMap, IN.uv.xy).xyz;
                u_xlat16_5.xyz = u_xlat16_4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                u_xlat16_5.xy = u_xlat16_5.xy * _NormalScale;
                u_xlat16_6.xyz = u_xlat16_5.yyy * IN.tSpace1.xyz;
                u_xlat16_5.xyw = u_xlat16_5.xxx * IN.tSpace0.xyz + u_xlat16_6.xyz;
                u_xlat16_5.xyz = u_xlat16_5.zzz * IN.tSpace2.xyz + u_xlat16_5.xyw;
                u_xlat16_53 = dot(u_xlat16_5.xyz, u_xlat16_5.xyz);
                u_xlat16_53 = 1.0/sqrt(u_xlat16_53);
                u_xlat16_5.xyz = u_xlat16_53 * u_xlat16_5.xyz;
                u_xlat16_53 = ((facing ? 0xffffffffu : uint(0)) != uint(0)) ? 1.0 : -1.0;
                u_xlat16_5.xyz = u_xlat16_53 * u_xlat16_5.xyz;
                u_xlat16_6.x = IN.tSpace0.w;
                u_xlat16_6.y = IN.tSpace1.w;
                u_xlat16_6.z = IN.tSpace2.w;
                u_xlat4.xyz = (-u_xlat16_6.xyz) + _WorldSpaceCameraPos.xyz;
                u_xlat50 = dot(u_xlat4.xyz, u_xlat4.xyz);
                u_xlat50 = max(u_xlat50, 1.17549435e-38);
                u_xlat16_53 = 1.0 / sqrt(u_xlat50);
                u_xlat7.xyz = u_xlat4.xyz * u_xlat16_53;
                u_xlat16_6.x = (-_Occlusion) + 1.0;
                u_xlat16_22 = u_xlat16_3.x * _Metallic;
                u_xlat16_6.x = u_xlat16_3.z * _Occlusion + u_xlat16_6.x;
                u_xlat16_38 = (-u_xlat16_22) * 0.959999979 + 0.959999979;
                u_xlat16_54 = u_xlat16_3.y * _Smoothness + (-u_xlat16_38);
                u_xlat16_8.xyz = u_xlat1.xyz * u_xlat16_38;
                u_xlat16_9.xyz = u_xlat16_0.xyz * _BaseColor.xyz + float3(-0.0399999991, -0.0399999991, -0.0399999991);
                u_xlat16_9.xyz = u_xlat16_22 * u_xlat16_9.xyz + float3(0.0399999991, 0.0399999991, 0.0399999991);
                u_xlat16_22 = (-u_xlat16_3.y) * _Smoothness + 1.0;
                u_xlat16_56 = u_xlat16_22 * u_xlat16_22;
                u_xlat16_56 = max(u_xlat16_56, 0.0078125);
                u_xlat16_54 = u_xlat16_54 + 1.0;
            #ifdef UNITY_ADRENO_ES3
                u_xlat16_54 = min(max(u_xlat16_54, 0.0), 1.0);
            #else
                u_xlat16_54 = clamp(u_xlat16_54, 0.0, 1.0);
            #endif
                u_xlat0.x = u_xlat16_56 * 4.0 + 2.0;
                u_xlat16_57 = dot(u_xlat16_5.xyz, _MainLightPosition.xyz);
            #ifdef UNITY_ADRENO_ES3
                u_xlat16_57 = min(max(u_xlat16_57, 0.0), 1.0);
            #else
                u_xlat16_57 = clamp(u_xlat16_57, 0.0, 1.0);
            #endif
            u_xlat16_10.x = (-u_xlat16_57) + 1.0;
            u_xlat16_57 = _GlobalBackfaceBrightness * u_xlat16_10.x + u_xlat16_57;
            u_xlat16_57 = u_xlat16_57 * unity_LightData.z;
            u_xlat16_10.xyz = u_xlat16_57 * _MainLightColor.xyz;
            u_xlat16_57 = (-u_xlat16_22) + 1.0;
            u_xlat16_11.xyz = u_xlat4.xyz * u_xlat16_53 + _MainLightPosition.xyz;
            u_xlat16_53 = dot(u_xlat16_11.xyz, u_xlat16_11.xyz);
            u_xlat16_53 = 1.0 / sqrt(u_xlat16_53);
            u_xlat16_12.xyz = u_xlat16_53 * u_xlat16_11.xyz;
            u_xlat16_53 = dot(u_xlat16_5.xyz, u_xlat16_12.xyz);
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_53 = min(max(u_xlat16_53, 0.0), 1.0);
        #else
            u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
        #endif
            u_xlat16_57 = max(u_xlat16_57, 0.00999999978);
            u_xlat16_57 = u_xlat16_57 * 32.0;
            u_xlat16_53 = log2(u_xlat16_53);
            u_xlat16_53 = u_xlat16_53 * u_xlat16_57;
            u_xlat16_53 = exp2(u_xlat16_53);
            u_xlat16_53 = u_xlat16_53 + u_xlat16_53;
            u_xlat16_12.xyz = u_xlat16_9.xyz * u_xlat16_53;
            u_xlat16.x = dot(u_xlat16_11.xyz, u_xlat16_11.xyz);
            u_xlat16.x = max(u_xlat16.x, 1.17549435e-38);
            u_xlat16_57 = 1.0 / sqrt(u_xlat16.x);
            u_xlat3.xyz = u_xlat16_57 * u_xlat16_11.xyz;
            u_xlat16.xy = (-float2(_Anisotropy, _Anisotropy2)) * float2(0.99000001, 0.99000001) + float2(1.0, 1.0);
            u_xlat16_11.xy = float2(_Anisotropy, _Anisotropy2) + float2(0.300000012, 0.300000012);
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_11.xy = min(max(u_xlat16_11.xy, 0.0), 1.0);
        #else
            u_xlat16_11.xy = clamp(u_xlat16_11.xy, 0.0, 1.0);
        #endif
            u_xlat16_43.xy = u_xlat16_56 / u_xlat16.xy;
            u_xlat16_11.xy = u_xlat16_56 / u_xlat16_11.xy;
            u_xlat16.xy = max(u_xlat16_43.xy, float2(0.00999999978, 0.00999999978));
            u_xlat4.xy = max(u_xlat16_11.xy, float2(0.00999999978, 0.00999999978));
            u_xlat16_57 = dot(u_xlat16_5.xyz, u_xlat3.xyz);
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_57 = min(max(u_xlat16_57, 0.0), 1.0);
        #else
            u_xlat16_57 = clamp(u_xlat16_57, 0.0, 1.0);
        #endif
            u_xlat16_58 = dot(_MainLightPosition.xyz, u_xlat3.xyz);
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_58 = min(max(u_xlat16_58, 0.0), 1.0);
        #else
            u_xlat16_58 = clamp(u_xlat16_58, 0.0, 1.0);
        #endif
            u_xlat16_11.xy = float2(_AnisoDirection, _AnisoDirection2) * float2(3.1415925, 3.1415925);
            u_xlat16_43.xy = cos(u_xlat16_11.xy);
            u_xlat16_11.xy = sin((-u_xlat16_11.xy));
            u_xlat16_13.xyz = u_xlat16_11.xxx * IN.tSpace1.xyz;
            u_xlat16_13.xyz = (-u_xlat16_43.xxx) * IN.tSpace0.xyz + u_xlat16_13.xyz;
            u_xlat16_11.x = dot(u_xlat16_13.xyz, u_xlat16_5.xyz);
            u_xlat16_13.xyz = (-u_xlat16_5.xyz) * u_xlat16_11.xxx + u_xlat16_13.xyz;
            u_xlat16_11.x = dot(u_xlat16_13.xyz, u_xlat16_13.xyz);
            u_xlat16_11.x = 1.0 / sqrt(u_xlat16_11.x);
            u_xlat16_13.xyz = u_xlat16_11.xxx * u_xlat16_13.xyz;
            u_xlat16_14.xyz = u_xlat16_5.zxy * u_xlat16_13.yzx;
            u_xlat16_14.xyz = u_xlat16_5.yzx * u_xlat16_13.zxy + (-u_xlat16_14.xyz);
            u_xlat16_11.x = dot(u_xlat16_14.xyz, u_xlat16_14.xyz);
            u_xlat16_11.x = 1.0 / sqrt(u_xlat16_11.x);
            u_xlat16_14.xyz = u_xlat16_11.xxx * u_xlat16_14.xyz;
            u_xlat16_11.xz = u_xlat16.xy * u_xlat16.xy;
            u_xlat16_15.xy = u_xlat4.xy * u_xlat4.xy;
            u_xlat16_60 = dot(u_xlat16_13.xyz, u_xlat3.xyz);
            u_xlat16_13.x = dot(u_xlat16_14.xyz, u_xlat3.xyz);
            u_xlat16_60 = u_xlat16_60 * u_xlat16_60;
            u_xlat16_29.xy = u_xlat16_11.xz * u_xlat16_11.xz;
            u_xlat16_60 = u_xlat16_60 / u_xlat16_29.x;
            u_xlat16_13.x = u_xlat16_13.x * u_xlat16_13.x;
            u_xlat16_29.xz = u_xlat16_15.xy * u_xlat16_15.xy;
            u_xlat16_13.x = u_xlat16_13.x / u_xlat16_29.x;
            u_xlat16_60 = u_xlat16_60 + u_xlat16_13.x;
            u_xlat16_60 = u_xlat16_57 * u_xlat16_57 + u_xlat16_60;
            u_xlat16_60 = min(u_xlat16_60, 500.0);
            u_xlat16_11.xz = u_xlat16_11.xz * u_xlat16_15.xy;
            u_xlat16_60 = u_xlat16_60 * u_xlat16_60;
            u_xlat16_11.x = u_xlat16_11.x * u_xlat16_60;
            u_xlat16_11.x = u_xlat16_11.x * 3.14159274;
            u_xlat16_11.x = 1.0 / u_xlat16_11.x;
            u_xlat16_14.xyz = u_xlat16_11.yyy * IN.tSpace1.xyz;
            u_xlat16_14.xyz = (-u_xlat16_43.yyy) * IN.tSpace0.xyz + u_xlat16_14.xyz;
            u_xlat16_27.x = dot(u_xlat16_14.xyz, u_xlat16_5.xyz);
            u_xlat16_14.xyz = (-u_xlat16_5.xyz) * u_xlat16_27.xxx + u_xlat16_14.xyz;
            u_xlat16_27.x = dot(u_xlat16_14.xyz, u_xlat16_14.xyz);
            u_xlat16_27.x = 1.0 / sqrt(u_xlat16_27.x);
            u_xlat16_14.xyz = u_xlat16_27.xxx * u_xlat16_14.xyz;
            u_xlat16_15.xyz = u_xlat16_5.zxy * u_xlat16_14.yzx;
            u_xlat16_15.xyz = u_xlat16_5.yzx * u_xlat16_14.zxy + (-u_xlat16_15.xyz);
            u_xlat16_27.x = dot(u_xlat16_15.xyz, u_xlat16_15.xyz);
            u_xlat16_27.x = 1.0 / sqrt(u_xlat16_27.x);
            u_xlat16_15.xyz = u_xlat16_27.xxx * u_xlat16_15.xyz;
            u_xlat16_27.x = dot(u_xlat16_14.xyz, u_xlat3.xyz);
            u_xlat16_27.z = dot(u_xlat16_15.xyz, u_xlat3.xyz);
            u_xlat16_27.xz = u_xlat16_27.xz * u_xlat16_27.xz;
            u_xlat16_27.xz = u_xlat16_27.xz / u_xlat16_29.yz;
            u_xlat16_27.x = u_xlat16_27.z + u_xlat16_27.x;
            u_xlat16_57 = u_xlat16_57 * u_xlat16_57 + u_xlat16_27.x;
            u_xlat16_57 = min(u_xlat16_57, 500.0);
            u_xlat16_57 = u_xlat16_57 * u_xlat16_57;
            u_xlat16_57 = u_xlat16_11.z * u_xlat16_57;
            u_xlat16_57 = u_xlat16_57 * 3.14159274;
            u_xlat16_57 = 1.0 / u_xlat16_57;
            u_xlat16_27.xyz = u_xlat16_57 * _AnisoColor2.xyz;
            u_xlat16_11.xyz = u_xlat16_11.xxx * _AnisoColor.xyz + u_xlat16_27.xyz;
            u_xlat16_11.xyz = u_xlat16_11.xyz + u_xlat16_11.xyz;
            u_xlat16_57 = u_xlat16_58 * u_xlat16_58;
            u_xlat16.x = max(u_xlat16_57, 0.100000001);
            u_xlat0.x = u_xlat0.x * u_xlat16.x;
            u_xlat0.xyz = u_xlat16_11.xyz / u_xlat0.xxx;
            u_xlat16_11.xyz = u_xlat16_9.xyz * u_xlat0.xyz;
            u_xlat16_11.xyz = min(u_xlat16_11.xyz, float3(10.0, 10.0, 10.0));
            u_xlat16_11.xyz = (-u_xlat16_53) * u_xlat16_9.xyz + u_xlat16_11.xyz;
            u_xlat16_11.xyz = u_xlat16_48 * u_xlat16_11.xyz + u_xlat16_12.xyz;
            u_xlat16_11.xyz = u_xlat1.xyz * u_xlat16_38 + u_xlat16_11.xyz;
            u_xlat16_12.xy = u_xlat16_5.yy * float2(0.699999988, -0.699999988) + float2(0.300000012, 0.300000012);
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_12.xy = min(max(u_xlat16_12.xy, 0.0), 1.0);
        #else
            u_xlat16_12.xy = clamp(u_xlat16_12.xy, 0.0, 1.0);
        #endif
            u_xlat16_53 = -abs(u_xlat16_5.y) + 1.60000002;
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_53 = min(max(u_xlat16_53, 0.0), 1.0);
        #else
            u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
        #endif
            u_xlat16_38 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
            u_xlat16_38 = max(u_xlat16_38, _AmbientSkyColor.x);
            u_xlat16_57 = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
            u_xlat16_57 = max(u_xlat16_57, _AmbientGroundColor.x);
            u_xlat16_38 = (-u_xlat16_38) + 3.0;
            u_xlat16_38 = (-u_xlat16_57) + u_xlat16_38;
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_38 = min(max(u_xlat16_38, 0.0), 1.0);
        #else
            u_xlat16_38 = clamp(u_xlat16_38, 0.0, 1.0);
        #endif
            u_xlat16_53 = u_xlat16_53 * u_xlat16_38;
            u_xlat16_13.xyz = u_xlat16_53 * _AmbientEquatorColor.xyz;
            u_xlat16_12.xzw = _AmbientSkyColor.xyz * u_xlat16_12.xxx + u_xlat16_13.xyz;
            u_xlat16_12.xyz = _AmbientGroundColor.xyz * u_xlat16_12.yyy + u_xlat16_12.xzw;
            u_xlat16_12.xyz = u_xlat16_12.xyz * _AmbientIntensity;
            u_xlat16_12.xyz = u_xlat16_6.xxx * u_xlat16_12.xyz;
            u_xlat16_8.xyz = u_xlat16_8.xyz * u_xlat16_12.xyz;
            u_xlat16_53 = dot((-u_xlat7.xyz), u_xlat16_5.xyz);
            u_xlat16_53 = u_xlat16_53 + u_xlat16_53;
            u_xlat16_12.xyz = u_xlat16_5.xyz * (-u_xlat16_53) + (-u_xlat7.xyz);
            u_xlat16_53 = _GlobalCubemapRotation * 6.28000021;
            u_xlat16_13.x = sin(u_xlat16_53);
            u_xlat16_14.x = cos(u_xlat16_53);
            u_xlat16_15.x = (-u_xlat16_13.x);
            u_xlat16_15.y = u_xlat16_14.x;
            u_xlat16_14.x = dot(u_xlat16_15.yx, u_xlat16_12.xz);
            u_xlat16_15.z = u_xlat16_13.x;
            u_xlat16_14.z = dot(u_xlat16_15.zy, u_xlat16_12.xz);
            u_xlat16_53 = (-u_xlat16_22) * 0.699999988 + 1.70000005;
            u_xlat16_53 = u_xlat16_53 * u_xlat16_22;
            u_xlat16_53 = u_xlat16_53 * 6.0;
            u_xlat16_14.y = u_xlat16_12.y;
            //u_xlat16_0 = textureLod(_GlobalCubemap, u_xlat16_14.xyz, u_xlat16_53);
            u_xlat16_0 = SAMPLE_TEXTURECUBE_LOD(_GlobalCubemap, sampler_GlobalCubemap, u_xlat16_14.xyz, u_xlat16_53);
            u_xlat16_53 = u_xlat16_0.w + -1.0;
            u_xlat16_53 = _GlobalCubemap_HDR.w * u_xlat16_53 + 1.0;
            u_xlat16_53 = max(u_xlat16_53, 0.0);
            u_xlat16_53 = log2(u_xlat16_53);
            u_xlat16_53 = u_xlat16_53 * _GlobalCubemap_HDR.y;
            u_xlat16_53 = exp2(u_xlat16_53);
            u_xlat16_53 = u_xlat16_53 * _GlobalCubemap_HDR.x;
            u_xlat16_12.xyz = u_xlat16_0.xyz * u_xlat16_53;
            u_xlat16_6.xyz = u_xlat16_6.xxx * u_xlat16_12.xyz;
            u_xlat16_6.xyz = u_xlat16_6.xyz *  _GlobalCubemapIntensity;
            u_xlat16_53 = dot(u_xlat16_5.xyz, u_xlat7.xyz);
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_53 = min(max(u_xlat16_53, 0.0), 1.0);
        #else
            u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
        #endif
            u_xlat16_53 = (-u_xlat16_53) + 1.0;
            u_xlat16_57 = u_xlat16_53 * u_xlat16_53;
            u_xlat16_57 = u_xlat16_57 * u_xlat16_57;
            u_xlat16_56 = u_xlat16_56 * u_xlat16_56 + 1.0;
            u_xlat16_56 = 1.0 / u_xlat16_56;
            u_xlat16_12.xyz = (-u_xlat16_9.xyz) + u_xlat16_54;
            u_xlat16_9.xyz = u_xlat16_57 * u_xlat16_12.xyz + u_xlat16_9.xyz;
            u_xlat0.xyz = u_xlat16_56 * u_xlat16_9.xyz;
            u_xlat16_6.xyz = u_xlat0.xyz * u_xlat16_6.xyz;
            u_xlat16_6.xyz = u_xlat16_8.xyz * float3(0.300000012, 0.300000012, 0.300000012) + u_xlat16_6.xyz;
            u_xlat16_6.xyz = u_xlat16_11.xyz * u_xlat16_10.xyz + u_xlat16_6.xyz;
            u_xlat16_6.xyz = u_xlat16_2.xyz * _Emission.xyz + u_xlat16_6.xyz;
            //
            u_xlat16_54 = dot(_HalfRimLightDir.xyz, _HalfRimLightDir.xyz);
            u_xlat16_54 = 1.0 / sqrt(u_xlat16_54);
            u_xlat16_8.xyz = u_xlat16_54 * _HalfRimLightDir.xyz;
            u_xlat16_54 = log2(u_xlat16_53);
            u_xlat16_54 = u_xlat16_54 * _HalfRimLightPower;
            u_xlat16_54 = exp2(u_xlat16_54);
            u_xlat16_8.x = dot(u_xlat16_5.xyz, u_xlat16_8.xyz);
            u_xlat16_8.x = u_xlat16_8.x * 0.5;
#ifdef UNITY_ADRENO_ES3
            u_xlat16_8.x = min(max(u_xlat16_8.x, 0.0), 1.0);
#else
            u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0);
#endif
            u_xlat16_24.x = u_xlat16_8.x * -2.0 + 3.0;
            u_xlat16_8.x = u_xlat16_8.x * u_xlat16_8.x;
            u_xlat16_8.x = u_xlat16_8.x * u_xlat16_24.x;
            u_xlat16_24.xyz = u_xlat16_54 * _HalfRimLightColor.xyz;
            u_xlat16_8.xyz = u_xlat16_8.xxx * u_xlat16_24.xyz;
            u_xlat16_8.xyz = u_xlat16_8.xyz *  _HalfRimLightIntensity;
            //
            u_xlat16_8.xyz = u_xlat16_8.xyz;
        #ifdef UNITY_ADRENO_ES3
            u_xlat16_8.xyz = min(max(u_xlat16_8.xyz, 0.0), 1.0);
        #else
            u_xlat16_8.xyz = clamp(u_xlat16_8.xyz, 0.0, 1.0);
        #endif
            u_xlat16_5.xyz = u_xlat16_3.www * u_xlat16_8.xyz + u_xlat16_6.xyz;
            //
            float4 result;
            result.xyz = min(u_xlat16_5.xyz, float3(4.0, 4.0, 4.0));
            u_xlat16_5.x = min(u_xlat1.w, 1.0);
            result.w =  u_xlat16_5.x;
				return result;
			}
			ENDHLSL
		}
		}
}

