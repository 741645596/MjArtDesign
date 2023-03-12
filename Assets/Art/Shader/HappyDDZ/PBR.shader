Shader "HappyDDZ/PBR"
{
	Properties
	{ _Basemap("BaseMap", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (1, 1, 1, 1)

		_NormalMap("NormalMap", 2D) = "bump" {}
		_Mask0("_Mask0( [ R : 金属]  [G : AO]  [B : 自发光]  [A : 光滑] )", 2D) = "white" {}
		_Emissionmap("_Emissionmap", 2D) = "black" {}

		_Metallic("_Metallic", Range(0, 1)) = 0
		_Smoothness("_Smoothness", Range(0, 1)) = 0

		_Occlusion("_Occlusion", Range(0, 1)) = 1

		_NormalScale("_NormalScale", Range(0, 10)) = 1

		_GlobalBackfaceBrightness("_GlobalBackfaceBrightness", Range(0, 1)) = 0
		_GlobalCubemapRotation("_GlobalCubemapRotation", Float) = 0
		_GlobalCubemapIntensity("_GlobalCubemapIntensity", Float) = 1.0

		[HDR]_Emission("Emission Color", Color) = (0, 0, 0, 0)


		_AmbientSkyColor("_AmbientSkyColor", Color) = (0, 0, 0, 0)
		_AmbientEquatorColor("_AmbientEquatorColor", Color) = (0, 0, 0, 0)
		_AmbientGroundColor("_AmbientGroundColor", Color) = (0, 0, 0, 0)

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

			CBUFFER_END
			sampler2D _Basemap;
			sampler2D _NormalMap;
			sampler2D _Mask0;
			sampler2D _Emissionmap;



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

				float max_AmbientSkyColor = max(_AmbientSkyColor.r,max(_AmbientSkyColor.b, _AmbientSkyColor.g));
				float max_AmbientGroundColor = max(_AmbientGroundColor.r, max(_AmbientGroundColor.b, _AmbientGroundColor.g));

				float3 result = diffNormalY * saturate(3.0 - max_AmbientSkyColor - max_AmbientGroundColor) * _AmbientEquatorColor.rgb;
				result = result + control.r * _AmbientSkyColor.rgb + control.g * _AmbientGroundColor.rgb;

				return result;
			}



			half4 frag(VertexOutput IN) : SV_Target
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
					_GlobalBackfaceBrightness,_GlobalCubemapRotation, _GlobalCubemapIntensity, AmbientCol);


				float3 emission = emissionMapColor.rgb * _Emission.rgb + color.rgb;


				float3 RimLightDir = normalize(_HalfRimLightDir);
				float Nov = saturate(dot(WorldViewDirection, normalWS));
				float nov_Pow = pow(saturate(1 - Nov), _HalfRimLightPower);


				float NoRim = saturate(dot(normalWS, RimLightDir) * 0.5f);
				//float NoRim1 = 3 - NoRim * 2;
				//float Rimpow = NoRim * NoRim * NoRim1;
				float smoothValue = smoothstep(0, 1, NoRim);
				float3 rimColor = saturate(nov_Pow * smoothValue * _HalfRimLightIntensity) * _HalfRimLightColor.rgb;

				float4 result = float4(emission + rimColor, 1.0f);
				return result;
			}

			ENDHLSL
		}
		}


}

