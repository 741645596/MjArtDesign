Shader "HappyDDZ/PBR"
{
	Properties
	{   
		_Basemap("BaseMap", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (1, 1, 1, 1)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Mask0("_Mask0( [ R : 金属]  [G : 光滑度]  [B : AO]  [A : 边缘光] )", 2D) = "white" {}
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

		[HDR]_HalfRimLightColor("_HalfRimLightColor", Color) = (0, 0, 0, 0)
		_HalfRimLightPower("_HalfRimLightPower", Range(0 , 50)) = 1
		_HalfRimLightIntensity("_HalfRimLightIntensity", Range(0 , 50)) = 1
		// 正常的lightDir + view 方向，
		// 是一个自定义的h方向了
		_HalfRimLightDir("_HalfRimLightDir", Vector) = (0, 0, 0, 0)
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
			float4 _NormalMap_ST;
			float4 _Mask0_ST;
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

			CBUFFER_END
			sampler2D _Basemap;
			sampler2D _NormalMap;
			sampler2D _Mask0;
			sampler2D _Emissionmap;
			//samplerCUBE _GlobalCubemap;
			TEXTURECUBE(_GlobalCubemap);
			SAMPLER(sampler_GlobalCubemap);

			VertexOutput VertexFunction(VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;


				o.uv.xy = v.texcoord.xy;

				//setting value to unused interpolator channels and avoid initialization warnings
				o.uv.zw = 0;

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
			
			// 计算一个混合色
			float3 CalcBlendColor(float normalY)
			{
				float2 control = normalY * float2(0.7f, -0.7f) + 0.3f;
				float diffNormalY = saturate(1.6f - abs(normalY));

				float max_AmbientSkyColor = max(_AmbientSkyColor.r, max(_AmbientSkyColor.b, _AmbientSkyColor.g));
				float max_AmbientGroundColor = max(_AmbientGroundColor.r, max(_AmbientGroundColor.b, _AmbientGroundColor.g));

				float3 result = diffNormalY * saturate(3.0 - max_AmbientSkyColor - max_AmbientGroundColor) * _AmbientEquatorColor.rgb;
				result = result + control.r * _AmbientSkyColor.rgb + control.g * _AmbientGroundColor.rgb;
				result = result * _AmbientIntensity;
				return result;
			}



			/*half4 frag(VertexOutput IN) : SV_Target
			{
				float4 AlbedoColor = tex2D(_Basemap, IN.uv.xy);
				float3 Albedo = AlbedoColor.rgb * _BaseColor.rgb;
				float4 emissionMapColor = tex2D(_Emissionmap, IN.uv.xy);
				float4 tex2DNode11 = tex2D(_Mask0, IN.uv.xy);
				float3 Normal = UnpackNormalScale(tex2D(_NormalMap, IN.uv.xy), _NormalScale);


				float3 WorldNormal = normalize(IN.tSpace0.xyz);
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
				float4 ShadowCoords = float4(0, 0, 0, 0);

				//----------------------

				WorldViewDirection = SafeNormalize(WorldViewDirection);


				float meta = _Metallic * tex2DNode11.r;
				float smooth = _Smoothness * tex2DNode11.g;

				float3 Specular = 0.5;
				float Metallic = meta;
				float Smoothness = smooth;
				float Occlusion = lerp(_Occlusion, 1, tex2DNode11.b);
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
					_GlobalCubemap, _GlobalCubemap_HDR, _GlobalBackfaceBrightness,_GlobalCubemapRotation, _GlobalCubemapIntensity, AmbientCol);


				float3 emission = emissionMapColor.rgb * _Emission.rgb + color.rgb;


				float3 RimLightDir = normalize(_HalfRimLightDir);
				float Nov = saturate(dot(WorldViewDirection, normalWS));
				float nov_Pow = pow(saturate(1 - Nov), _HalfRimLightPower);


				float NoRim = saturate(dot(normalWS, RimLightDir) * 0.5f);
				float smoothValue = smoothstep(0, 1, NoRim);
				float3 rimColor = saturate(nov_Pow * smoothValue * _HalfRimLightIntensity) * _HalfRimLightColor.rgb;

				float gray = 0.2125 * emission.r + 0.7154 * emission.g + 0.0721 * emission.b;

				float3 grayColor = float3(gray, gray, gray);

				emission = lerp(grayColor, emission, _Saturation);

				float3 avgColor = float3(0.5, 0.5, 0.5);
				emission = lerp(avgColor, emission, _Contrast);


				result.rgb = colorAdjust(result.rgb,_Saturation,_Contrast);

				result.rgb = result.rgb * _ColorIntensity;


				float4 result = float4(emission + rimColor, 1.0f);
				
				return result;
			}*/

			half4 frag(VertexOutput IN, float facing : VFACE) : SV_Target
			{
				float4 u_xlat16_0;
				u_xlat16_0 = tex2D(_Basemap, IN.uv.xy);
				float4 u_xlat1 = u_xlat16_0 * _BaseColor;
				float4 u_xlat16_2;
				u_xlat16_2.xyz = tex2D(_Emissionmap, IN.uv.xy).xyz;
				float4 u_xlat16_3 = tex2D(_Mask0, IN.uv.xy);
				float4 u_xlat16_4;
				u_xlat16_4.xyz = tex2D(_NormalMap, IN.uv.xy).xyz;
				float4 u_xlat16_5;
				u_xlat16_5.xyz = u_xlat16_4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
				u_xlat16_5.xy = u_xlat16_5.xy * _NormalScale;
				float4 u_xlat16_6;
				u_xlat16_6.xyz = u_xlat16_5.yyy * IN.tSpace1.xyz;
				u_xlat16_5.xyw = u_xlat16_5.xxx * IN.tSpace0.xyz + u_xlat16_6.xyz;
				u_xlat16_5.xyz = u_xlat16_5.zzz * IN.tSpace2.xyz + u_xlat16_5.xyw;
				float u_xlat16_53 = dot(u_xlat16_5.xyz, u_xlat16_5.xyz);
				u_xlat16_53 = 1/ sqrt(u_xlat16_53);
				u_xlat16_5.xyz = u_xlat16_53 * u_xlat16_5.xyz;
				u_xlat16_53 = ((facing ? 0xffffffffu : uint(0)) != uint(0)) ? 1.0 : -1.0;
				u_xlat16_5.xyz = u_xlat16_53 * u_xlat16_5.xyz;
				u_xlat16_6.x = IN.tSpace0.w;
				u_xlat16_6.y = IN.tSpace1.w;
				u_xlat16_6.z = IN.tSpace2.w;
				float4 u_xlat4;
				u_xlat4.xyz = (-u_xlat16_6.xyz) + _WorldSpaceCameraPos.xyz;
				float u_xlat48 = dot(u_xlat4.xyz, u_xlat4.xyz);
				u_xlat48 = max(u_xlat48, 1.17549435e-38);
				u_xlat16_53 = 1/sqrt(u_xlat48);
				float4 u_xlat7;
				u_xlat7.xyz = u_xlat4.xyz * u_xlat16_53;
				u_xlat16_6.x = (-_Occlusion) + 1.0;
				float u_xlat16_22 = u_xlat16_3.x * _Metallic;
				u_xlat16_6.x = u_xlat16_3.z * _Occlusion + u_xlat16_6.x;
				float u_xlat16_38 = (-u_xlat16_22) * 0.959999979 + 0.959999979;
				float u_xlat16_54 = u_xlat16_3.y * _Smoothness + (-u_xlat16_38);
				float4 u_xlat16_8;
				u_xlat16_8.xyz = u_xlat1.xyz * u_xlat16_38;
				float4 u_xlat16_9;
				u_xlat16_9.xyz = u_xlat16_0.xyz * _BaseColor.xyz + float3(-0.0399999991, -0.0399999991, -0.0399999991);
				u_xlat16_9.xyz = u_xlat16_22 * u_xlat16_9.xyz + float3(0.0399999991, 0.0399999991, 0.0399999991);
				u_xlat16_22 = (-u_xlat16_3.y) * _Smoothness + 1.0;
				u_xlat16_38 = u_xlat16_22 * u_xlat16_22;
				u_xlat16_38 = max(u_xlat16_38, 0.0078125);
				u_xlat16_54 = u_xlat16_54 + 1.0;

				u_xlat16_54 = clamp(u_xlat16_54, 0.0, 1.0);
				float u_xlat16_56 = dot(u_xlat16_5.xyz, _MainLightPosition.xyz);
				u_xlat16_56 = clamp(u_xlat16_56, 0.0, 1.0);
				float u_xlat16_57 = (-u_xlat16_56) + 1.0;
				u_xlat16_56 = _GlobalBackfaceBrightness * u_xlat16_57 + u_xlat16_56;
				//u_xlat16_56 = u_xlat16_56 * unity_LightData.z;
				float4 u_xlat16_10;
				u_xlat16_10.xyz = u_xlat16_56 * _MainLightColor.xyz;
				u_xlat16_56 = (-u_xlat16_22) + 1.0;
				float4 u_xlat16_11;
				u_xlat16_11.xyz = u_xlat4.xyz * u_xlat16_53 + _MainLightPosition.xyz;
				u_xlat16_53 = dot(u_xlat16_11.xyz, u_xlat16_11.xyz);
				u_xlat16_53 = 1/sqrt(u_xlat16_53);
				u_xlat16_11.xyz = u_xlat16_53 * u_xlat16_11.xyz;
				u_xlat16_53 = dot(u_xlat16_5.xyz, u_xlat16_11.xyz);
				u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
				u_xlat16_56 = max(u_xlat16_56, 0.00999999978);
				u_xlat16_56 = u_xlat16_56 * 32.0;
				u_xlat16_53 = log2(u_xlat16_53);
				u_xlat16_53 = u_xlat16_53 * u_xlat16_56;
				u_xlat16_53 = exp2(u_xlat16_53);
				u_xlat16_53 = u_xlat16_53 + u_xlat16_53;
				u_xlat16_11.xyz = u_xlat16_53 * u_xlat16_9.xyz + u_xlat16_8.xyz;
				float4 u_xlat16_12;
				u_xlat16_12.xy = u_xlat16_5.yy * float2(0.699999988, -0.699999988) + float2(0.300000012, 0.300000012);

				u_xlat16_12.xy = clamp(u_xlat16_12.xy, 0.0, 1.0);
				u_xlat16_53 = -abs(u_xlat16_5.y) + 1.60000002;
				u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
				u_xlat16_56 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
				u_xlat16_56 = max(u_xlat16_56, _AmbientSkyColor.x);
				u_xlat16_57 = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
				u_xlat16_57 = max(u_xlat16_57, _AmbientGroundColor.x);
				u_xlat16_56 = (-u_xlat16_56) + 3.0;
				u_xlat16_56 = (-u_xlat16_57) + u_xlat16_56;
				u_xlat16_56 = clamp(u_xlat16_56, 0.0, 1.0);
				u_xlat16_53 = u_xlat16_53 * u_xlat16_56;
				float4 u_xlat16_13;
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
				float4 u_xlat16_14;
				u_xlat16_14.x = cos(u_xlat16_53);
				float4 u_xlat16_15;
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
				u_xlat16_12.xyz = u_xlat16_6.xxx * u_xlat16_12.xyz;
				u_xlat16_12.xyz = u_xlat16_12.xyz * _GlobalCubemapIntensity;
				u_xlat16_53 = dot(u_xlat16_5.xyz, u_xlat7.xyz);
				u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
				u_xlat16_53 = (-u_xlat16_53) + 1.0;
				u_xlat16_6.x = u_xlat16_53 * u_xlat16_53;
				u_xlat16_6.x = u_xlat16_6.x * u_xlat16_6.x;
				u_xlat16_22 = u_xlat16_38 * u_xlat16_38 + 1.0;
				u_xlat16_22 = float(1.0) / u_xlat16_22;
				u_xlat16_13.xyz = (-u_xlat16_9.xyz) + u_xlat16_54;
				u_xlat16_6.xzw = u_xlat16_6.xxx * u_xlat16_13.xyz + u_xlat16_9.xyz;
				float4 u_xlat0;
				u_xlat0.xyz = u_xlat16_6.xzw * u_xlat16_22;
				u_xlat16_6.xyz = u_xlat0.xyz * u_xlat16_12.xyz;
				u_xlat16_6.xyz = u_xlat16_8.xyz * float3(0.300000012, 0.300000012, 0.300000012) + u_xlat16_6.xyz;
				u_xlat16_6.xyz = u_xlat16_11.xyz * u_xlat16_10.xyz + u_xlat16_6.xyz;
				u_xlat16_6.xyz = u_xlat16_2.xyz * _Emission.xyz + u_xlat16_6.xyz;
				//
				u_xlat16_54 = dot(_HalfRimLightDir.xyz, _HalfRimLightDir.xyz);
				u_xlat16_54 = 1/sqrt(u_xlat16_54);
				u_xlat16_8.xyz = u_xlat16_54 * _HalfRimLightDir.xyz;
				u_xlat16_54 = log2(u_xlat16_53);
				u_xlat16_54 = u_xlat16_54 * _HalfRimLightPower;
				u_xlat16_54 = exp2(u_xlat16_54);
				u_xlat16_8.x = dot(u_xlat16_5.xyz, u_xlat16_8.xyz);
				u_xlat16_8.x = u_xlat16_8.x * 0.5;
				u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0);
				float4 u_xlat16_24;
				u_xlat16_24.x = u_xlat16_8.x * -2.0 + 3.0;
				u_xlat16_8.x = u_xlat16_8.x * u_xlat16_8.x;
				u_xlat16_8.x = u_xlat16_8.x * u_xlat16_24.x;
				u_xlat16_24.xyz = u_xlat16_54 * _HalfRimLightColor.xyz;
				u_xlat16_8.xyz = u_xlat16_8.xxx * u_xlat16_24.xyz;
				u_xlat16_8.xyz = u_xlat16_8.xyz * _HalfRimLightIntensity;
				u_xlat16_8.xyz = u_xlat16_8.xyz;
				u_xlat16_8.xyz = clamp(u_xlat16_8.xyz, 0.0, 1.0);
				u_xlat16_5.xyz = u_xlat16_3.www * u_xlat16_8.xyz + u_xlat16_6.xyz;

				float4 result;
				result.xyz = min(u_xlat16_5.xyz, float3(4.0, 4.0, 4.0));
				u_xlat16_5.x = min(u_xlat1.w, 1.0);
				result.w = u_xlat16_5.x;

				result.rgb = colorAdjust(result.rgb,_Saturation,_Contrast);

				result.rgb = result.rgb * _ColorIntensity;


				return result;
			}
			ENDHLSL
		}
		}
}

