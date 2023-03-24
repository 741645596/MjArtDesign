Shader "HappyDDZ/Skin"
{
	Properties
	{   
		_Basemap("BaseMap", 2D) = "white" {}
		_Normalmap("NormalMap", 2D) = "bump" {}
		_Configmap("_Configmap( [ R : 金属]  [G : 光滑度]  [B : SSS]  [A : AO] )", 2D) = "white" {}
		_Sparklemap("_Sparklemap", 2D) = "black" {}
		_SkinProfile("_SkinProfile", 2D) = "black" {}
		_ColorIntensity("_ColorIntensity", Range(0, 2)) = 1
		_Saturation("_Saturation", Range(0, 2)) = 1 //饱和度
		_Contrast("_Contrast", Range(0, 2)) = 1 //对比度
		
		_BaseColor("BaseColor", Color) = (1, 1, 1, 1)
		_DesaturateScale("_DesaturateScale", Float) = 1.0
		_LightColor("_LightColor", Color) = (1, 1, 1, 1)
		_LightRange("_LightRange", Float) = 1.0
		// sss
		_SSS("_SSS", Float) = 1.0
		_SSSIntensity("_SSSIntensity", Float) = 1.0
		_Wrap("_Wrap", Float) = 1.0
        // pbr
		_Metallic("_Metallic", Range(0, 1)) = 0
		_Smoothness("_Smoothness", Range(0, 1)) = 0
		_Occlusion("_Occlusion", Range(0, 1)) = 1
		_NormalScale("_NormalScale", Range(0, 10)) = 1
        // 闪点
		//_SparkleControl("_SparkleControl", Color) = (1, 1, 1, 1)
		//_SparkleEyeTransparency("_SparkleEyeTransparency", Float) = 1.0
		//_SparkleLipTransparency("_SparkleLipTransparency", Float) = 1.0
		//_SparkleTattooATransparency("_SparkleTattooATransparency", Float) = 1.0
		_LipSmoothness("_LipSmoothness[嘴唇]", Float) = 1.0
		_EyeSmoothness("_EyeSmoothness[眼睛]", Float) = 1.0
		_TattooASmoothness("_TattooASmoothness[纹身]", Float) = 1.0
		//_SparkleLipDye("_SparkleLipDye", Color) = (1, 1, 1, 1)
		//_SparkleEyeDye("_SparkleEyeDye", Color) = (1, 1, 1, 1)
		//_SparkleTattooADye("_SparkleTattooADye", Color) = (1, 1, 1, 1)
        //
		[HDR]_HalfRimLightColor("_HalfRimLightColor", Color) = (0, 0, 0, 0)
		_HalfRimLightPower("_HalfRimLightPower", Range(0 , 50)) = 1
		_HalfRimLightIntensity("_HalfRimLightIntensity", Range(0 , 50)) = 1
		_HalfRimLightDir("_HalfRimLightDir", Vector) = (0, 0, 0, 0)
        // 全局的一些系数
		_AmbientSkyColor("_AmbientSkyColor", Color) = (0, 0, 0, 0)
		_AmbientEquatorColor("_AmbientEquatorColor", Color) = (0, 0, 0, 0)
		_AmbientGroundColor("_AmbientGroundColor", Color) = (0, 0, 0, 0)

		_AmbientIntensity("_AmbientIntensity", Float) = 1.0
			
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
			#include "DZZ_SSSLighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
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
			float4 _Normalmap_ST;
			float4 _Configmap_ST;
			float4 _Sparklemap_ST;
			float4 _SkinProfile_ST;
			float _ColorIntensity;
			float _Saturation;
			float _Contrast;


			float4 _BaseColor;
			float _DesaturateScale;
			float4 _LightColor;
			float _LightRange;
			// SSS相关
			float _SSS;
			float _SSSIntensity;
			float _Wrap;
			// pbr 相关
			float _Metallic;
			float _Smoothness;
			float _Occlusion;
			float _NormalScale;
			// 闪点
			//float4 _SparkleControl;
			//float _SparkleEyeTransparency;
			//float _SparkleLipTransparency;
			//float _SparkleTattooATransparency;
			float _LipSmoothness;
			float _EyeSmoothness;
			float _TattooASmoothness;
			//float4 _SparkleLipDye;
			//float4 _SparkleEyeDye;
			//float4 _SparkleTattooADye;
			//
			float4 _HalfRimLightColor;
			float _HalfRimLightPower;
			float4 _HalfRimLightDir;
			float _HalfRimLightIntensity;
			//
			float4 _AmbientSkyColor;
			float4	_AmbientEquatorColor;
			float4	_AmbientGroundColor;

			float _AmbientIntensity;

			CBUFFER_END
			sampler2D _Basemap;
			sampler2D _Normalmap;
			sampler2D _Configmap;
			sampler2D _Sparklemap;
			sampler2D _SkinProfile;



			VertexOutput vert(VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				o.uv.xy = v.uv.xy * _Basemap_ST.xy + _Basemap_ST.zw;
				o.uv.zw = 0;

				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float3 positionVS = TransformWorldToView(positionWS);
				float4 positionCS = TransformWorldToHClip(positionWS);

				VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

				o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
				OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);

				o.clipPos = positionCS;
				return o;
			}

			// 计算一个混合色
			float3 CalcBlendColor(float normalY)
			{
				float2 control = normalY * float2(0.7f, -0.7f) + 0.3f;
				float diffNormalY = saturate(1.6f - abs(normalY));

				float max_AmbientSkyColor = max(_AmbientSkyColor.r,max(_AmbientSkyColor.b, _AmbientSkyColor.g));
				float max_AmbientGroundColor = max(_AmbientGroundColor.r, max(_AmbientGroundColor.b, _AmbientGroundColor.g));

				float3 result = diffNormalY * saturate(3.0 - max_AmbientSkyColor - max_AmbientGroundColor) * _AmbientEquatorColor.rgb;
				result = result + control.r * _AmbientSkyColor.rgb + control.g * _AmbientGroundColor.rgb;

				return result;
			}
			/*
			half4 frag(VertexOutput IN) : SV_Target
			{
				float4 AlbedoColor = tex2D(_Basemap, IN.uv.xy);
				float3 Albedo = AlbedoColor.rgb * _BaseColor.rgb;
				float gray = dot(Albedo, float3(0.299f, 0.587f, 0.114f));
				Albedo = lerp(Albedo, gray, _DesaturateScale);

				float4 controlData = tex2D(_Configmap, IN.uv.xy);
				float3 sparkColor = tex2D(_Sparklemap, IN.uv.xy).rgb;

				float3 Normal = UnpackNormalScale(tex2D(_Normalmap, IN.uv.xy), _NormalScale);


				float3 WorldNormal = normalize(IN.tSpace0.xyz);
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
				float4 ShadowCoords = float4(0, 0, 0, 0);

				//----------------------

				WorldViewDirection = SafeNormalize(WorldViewDirection);


				float meta = _Metallic * controlData.r;
				float smooth = _Smoothness * controlData.g;
				float ao = controlData.a;
				smooth = saturate(smooth + dot(sparkColor, float3(_LipSmoothness, _EyeSmoothness, _TattooASmoothness)));

				float3 Specular = 0.5;
				float Metallic = meta;
				float Smoothness = smooth;
				float Occlusion = lerp(_Occlusion, 1, ao);
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
				float3 normalWS = normalize(inputData.normalWS);
				float3 lightDir = normalize(_MainLightPosition.xyz);
				float3 NoL = dot(normalWS, _MainLightPosition.xyz);
				// 不知道是个啥来着。
				float halfLanbettXXX = NoL * 0.5f + 0.47f;
				//float v1 = saturate((halfLanbettXXX - _LightRange) / (1 - _LightRange));
				//float f = v1 * v1 * (3.0f - v1 * 2.0f);
				float f = smoothstep(_LightRange, 1, halfLanbettXXX);
				Albedo = lerp(Albedo, Albedo * _LightColor.rgb, f);
				//
				float skuvX = saturate((NoL + _Wrap) / (1 + _Wrap));
				float2 skinUV = float2(skuvX, _SSS * controlData.b);
				float3 sssColor = tex2D(_SkinProfile, skinUV).rgb;
				sssColor = lerp(skuvX, sssColor, _SSSIntensity);
				// 新加入的
				float3 AmbientCol = CalcBlendColor(normalWS.y);


				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);


				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				half4 color = UniversalFragmentPBR(
					inputData,
					Albedo,
					Metallic,
					Specular,
					Smoothness,
					Occlusion,
					0,
					Alpha,
					AmbientCol, sssColor);


				float3 RimLightDir = normalize(_HalfRimLightDir);
				float Nov = saturate(dot(WorldViewDirection, normalWS));
				float nov_Pow = pow(saturate(1 - Nov), _HalfRimLightPower);


				float NoRim = saturate(dot(normalWS, RimLightDir) * 0.5f);
				float smoothValue = smoothstep(0, 1, NoRim);
				float3 rimColor = saturate(nov_Pow * smoothValue * _HalfRimLightIntensity) * _HalfRimLightColor.rgb;

				float4 result = float4(color.rgb + rimColor, 1.0f);
				return result;
			}
			*/
            half4 frag(VertexOutput IN) : SV_Target
            {
	            float4 u_xlat16_0;
				u_xlat16_0.xyz = tex2D(_Basemap, IN.uv.xy).xyz;
				float4 u_xlat1;
				u_xlat1.xyz = u_xlat16_0.xyz * _BaseColor.xyz;
				float4 u_xlat16_2;
				u_xlat16_2.x = dot(u_xlat1.xyz, float3(0.298999995, 0.587000012, 0.114));
				u_xlat16_2.xyz = (-u_xlat16_0.xyz) * _BaseColor.xyz + u_xlat16_2.xxx;
				u_xlat16_2.xyz = _DesaturateScale * u_xlat16_2.xyz + u_xlat1.xyz;
	            u_xlat16_0 = tex2D(_Configmap, IN.uv.xy);
				float4 u_xlat10_1;
				u_xlat10_1.xyz = tex2D(_Sparklemap, IN.uv.xy).xyz;
				float4 u_xlat16_3;
				u_xlat16_3.xyz = tex2D(_Normalmap, IN.uv.xy).xyz;
				float4 u_xlat16_4;
				u_xlat16_4.xyz = u_xlat16_3.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
				u_xlat16_4.xy = u_xlat16_4.xy * float2(_NormalScale, _NormalScale);
				float4 u_xlat16_5;
				u_xlat16_5.xyz = u_xlat16_4.yyy * IN.tSpace1.xyz;
				u_xlat16_4.xyw = u_xlat16_4.xxx * IN.tSpace0.xyz + u_xlat16_5.xyz;
				u_xlat16_4.xyz = u_xlat16_4.zzz * IN.tSpace2.xyz + u_xlat16_4.xyw;
				u_xlat16_5.x = IN.tSpace0.w;
				u_xlat16_5.y = IN.tSpace1.w;
				u_xlat16_5.z = IN.tSpace2.w;
				float4 u_xlat3;
				u_xlat3.xyz = (-u_xlat16_5.xyz) + _WorldSpaceCameraPos.xyz;
				float u_xlat31 = dot(u_xlat3.xyz, u_xlat3.xyz);
				u_xlat31 = max(u_xlat31, 1.17549435e-38);
				float u_xlat16_32 = 1/sqrt(u_xlat31);
				u_xlat3.xyz = u_xlat16_32 * u_xlat3.xyz;
				u_xlat31 = dot(_MainLightPosition.xyz, u_xlat16_4.xyz);
				u_xlat31 = u_xlat31 * 0.5 + 0.469999999;
				u_xlat16_32 = (-_LightRange) + 1.0;
				float u_xlat16_34 = u_xlat31 + (-_LightRange);
				u_xlat16_32 = float(1.0) / u_xlat16_32;
				u_xlat16_32 = u_xlat16_32 * u_xlat16_34;

				u_xlat16_32 = clamp(u_xlat16_32, 0.0, 1.0);
				u_xlat16_34 = u_xlat16_32 * -2.0 + 3.0;
				u_xlat16_32 = u_xlat16_32 * u_xlat16_32;
				u_xlat16_32 = u_xlat16_32 * u_xlat16_34;
				u_xlat16_5.xyz = u_xlat16_2.xyz * _LightColor.xyz + (-u_xlat16_2.xyz);
				u_xlat16_2.xyz = u_xlat16_32 * u_xlat16_5.xyz + u_xlat16_2.xyz;
				u_xlat16_5.xy = u_xlat16_0.xy * float2(_Metallic, _Smoothness);
				u_xlat16_32 = u_xlat10_1.x * _LipSmoothness + u_xlat16_5.y;
				u_xlat16_32 = u_xlat10_1.y * _EyeSmoothness + u_xlat16_32;
				u_xlat16_32 = u_xlat10_1.z * _TattooASmoothness + u_xlat16_32;

				u_xlat16_32 = clamp(u_xlat16_32, 0.0, 1.0);
				u_xlat16_34 = (-_Occlusion) + 1.0;
				float4 u_xlat16_6;
				u_xlat16_6.z = u_xlat16_0.z * _SSS;
				u_xlat16_34 = u_xlat16_0.w * _Occlusion + u_xlat16_34;
				float4 u_xlat16_15;
				u_xlat16_15.xy = u_xlat16_4.yy * float2(0.699999988, -0.699999988) + float2(0.300000012, 0.300000012);
	            u_xlat16_15.xy = clamp(u_xlat16_15.xy, 0.0, 1.0);
	            float u_xlat16_35 = -abs(u_xlat16_4.y) + 1.60000002;
				u_xlat16_35 = clamp(u_xlat16_35, 0.0, 1.0);
				float u_xlat16_16 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
				u_xlat16_16 = max(u_xlat16_16, _AmbientSkyColor.x);
				float u_xlat16_36 = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
				u_xlat16_36 = max(u_xlat16_36, _AmbientGroundColor.x);
				u_xlat16_16 = (-u_xlat16_16) + 3.0;
				u_xlat16_16 = (-u_xlat16_36) + u_xlat16_16;
				u_xlat16_16 = clamp(u_xlat16_16, 0.0, 1.0);
				u_xlat16_35 = u_xlat16_35 * u_xlat16_16;
				float4 u_xlat16_7;
				u_xlat16_7.xyz = u_xlat16_35 * _AmbientEquatorColor.xyz;
				u_xlat16_7.xyz = _AmbientSkyColor.xyz * u_xlat16_15.xxx + u_xlat16_7.xyz;
				u_xlat16_15.xyz = _AmbientGroundColor.xyz * u_xlat16_15.yyy + u_xlat16_7.xyz;
				u_xlat16_15.xyz = u_xlat16_15.xyz * _AmbientIntensity;
				u_xlat16_15.xyz = u_xlat16_34 * u_xlat16_15.xyz;
				u_xlat16_16 = dot(u_xlat16_4.xyz, _MainLightPosition.xyz);
				u_xlat16_16 = u_xlat16_16 + _Wrap;
				u_xlat16_36 = _Wrap + 1.0;
				u_xlat16_6.x = u_xlat16_16 / u_xlat16_36;
				u_xlat16_6.x = clamp(u_xlat16_6.x, 0.0, 1.0);
				u_xlat16_0.xyz = tex2D(_SkinProfile, u_xlat16_6.xz).xyz;
				u_xlat16_16 = (-u_xlat16_5.x) * 0.959999979 + 0.959999979;
				float u_xlat16_26 = u_xlat16_32 + (-u_xlat16_16);
				u_xlat16_7.xyz = u_xlat16_2.xyz * u_xlat16_16;
				u_xlat16_2.xyz = u_xlat16_2.xyz + float3(-0.0399999991, -0.0399999991, -0.0399999991);
				u_xlat16_2.xyz = u_xlat16_5.xxx * u_xlat16_2.xyz + float3(0.0399999991, 0.0399999991, 0.0399999991);
				u_xlat16_32 = (-u_xlat16_32) + 1.0;
				u_xlat16_5.x = u_xlat16_32 * u_xlat16_32;
				u_xlat16_5.x = max(u_xlat16_5.x, 0.0078125);
				u_xlat16_16 = u_xlat16_26 + 1.0;
				u_xlat16_16 = clamp(u_xlat16_16, 0.0, 1.0);
				u_xlat16_26 = dot((-u_xlat3.xyz), u_xlat16_4.xyz);
				u_xlat16_26 = u_xlat16_26 + u_xlat16_26;
				float4 u_xlat16_8;
				u_xlat16_8.xyz = u_xlat16_4.xyz * (-u_xlat16_26) + (-u_xlat3.xyz);
				u_xlat16_26 = dot(u_xlat16_4.xyz, u_xlat3.xyz);
				u_xlat16_26 = clamp(u_xlat16_26, 0.0, 1.0);
				u_xlat16_26 = (-u_xlat16_26) + 1.0;
				u_xlat16_36 = u_xlat16_26 * u_xlat16_26;
				u_xlat16_36 = u_xlat16_36 * u_xlat16_36;
				u_xlat16_15.xyz = u_xlat16_15.xyz * u_xlat16_7.xyz;
				float u_xlat16_37 = (-u_xlat16_32) * 0.699999988 + 1.70000005;
				u_xlat16_32 = u_xlat16_32 * u_xlat16_37;
				u_xlat16_32 = u_xlat16_32 * 6.0;
				float4 u_xlat16_1 = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, u_xlat16_8.xyz, u_xlat16_32);
				u_xlat16_32 = u_xlat16_1.w + -1.0;
				u_xlat16_32 = unity_SpecCube0_HDR.w * u_xlat16_32 + 1.0;
				u_xlat16_32 = max(u_xlat16_32, 0.0);
				u_xlat16_32 = log2(u_xlat16_32);
				u_xlat16_32 = u_xlat16_32 * unity_SpecCube0_HDR.y;
				u_xlat16_32 = exp2(u_xlat16_32);
				u_xlat16_32 = u_xlat16_32 * unity_SpecCube0_HDR.x;
				u_xlat16_8.xyz = u_xlat16_1.xyz * u_xlat16_32;
				u_xlat16_8.xyz = u_xlat16_34 * u_xlat16_8.xyz;
				u_xlat16_32 = u_xlat16_5.x * u_xlat16_5.x + 1.0;
				u_xlat16_32 = float(1.0) / u_xlat16_32;
				float4 u_xlat16_9;
				u_xlat16_9.xyz = (-u_xlat16_2.xyz) + u_xlat16_16;
				u_xlat16_2.xyz = u_xlat16_36 * u_xlat16_9.xyz + u_xlat16_2.xyz;
				u_xlat1.xyz = u_xlat16_2.xyz * u_xlat16_32;
				u_xlat16_2.xyz = u_xlat1.xyz * u_xlat16_8.xyz;
				u_xlat16_2.xyz = u_xlat16_15.xyz * float3(0.300000012, 0.300000012, 0.300000012) + u_xlat16_2.xyz;
				u_xlat16_32 = _SSSIntensity;
				u_xlat16_32 = clamp(u_xlat16_32, 0.0, 1.0);
				u_xlat16_5.xyz = (-u_xlat16_6.xxx) + u_xlat16_0.xyz;
				u_xlat16_5.xyz = u_xlat16_32 * u_xlat16_5.xyz + u_xlat16_6.xxx;
				//u_xlat16_5.xyz = u_xlat16_5.xyz * unity_LightData.zzz;
				u_xlat16_5.xyz = u_xlat16_5.xyz * _MainLightColor.xyz;
				u_xlat16_2.xyz = u_xlat16_7.xyz * u_xlat16_5.xyz + u_xlat16_2.xyz;

				u_xlat16_32 = dot(_HalfRimLightDir.xyz, _HalfRimLightDir.xyz);
				u_xlat16_32 = 1/sqrt(u_xlat16_32);
				u_xlat16_5.xyz = u_xlat16_32 * _HalfRimLightDir.xyz;
				u_xlat16_32 = log2(u_xlat16_26);
				u_xlat16_32 = u_xlat16_32 * _HalfRimLightPower;
				u_xlat16_32 = exp2(u_xlat16_32);
				u_xlat16_34 = dot(u_xlat16_4.xyz, u_xlat16_5.xyz);
				u_xlat16_34 = u_xlat16_34 * 0.5;
				u_xlat16_34 = clamp(u_xlat16_34, 0.0, 1.0);
				u_xlat16_5.x = u_xlat16_34 * -2.0 + 3.0;
				u_xlat16_34 = u_xlat16_34 * u_xlat16_34;
				u_xlat16_34 = u_xlat16_34 * u_xlat16_5.x;
				u_xlat16_5.xyz = u_xlat16_32 * _HalfRimLightColor.xyz;
				u_xlat16_5.xyz = u_xlat16_34 * u_xlat16_5.xyz;
				u_xlat16_5.xyz = u_xlat16_5.xyz * _HalfRimLightIntensity;
				u_xlat16_5.xyz = u_xlat16_5.xyz;
				u_xlat16_5.xyz = clamp(u_xlat16_5.xyz, 0.0, 1.0);

				u_xlat16_2.rgb = colorAdjust(u_xlat16_2.rgb,_Saturation,_Contrast);


				u_xlat16_2.xyz = u_xlat16_2.xyz * _ColorIntensity;

				
				

				return float4(u_xlat16_2.xyz + u_xlat16_5.xyz,1);
			}
			ENDHLSL
		}
		}


}

