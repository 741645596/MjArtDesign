Shader "HappyDDZ/Eye"
{
	Properties
	{ 
		_Basemap("BaseMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Mask0("_Mask0([G : 光滑]  [B : 反射高光]  [A : AO] )", 2D) = "white" {}
		_ReflectionTex1("_ReflectionTex1", 2D) = "white" {}
		_ReflectionTex2("_ReflectionTex2", 2D) = "white" {}
		_LensesMap("_LensesMap", 2D) = "white" {}

		_Metallic("_Metallic", Range(0, 1)) = 0
		_Smoothness("_Smoothness", Range(0, 1)) = 0
		_OcclusionStrength("_OcclusionStrength", Range(0, 1)) = 1
		_NormalScale("_NormalScale", Range(0, 10)) = 1

		//
		_AmbientColor("_AmbientColor", Color) = (0, 0, 0, 0)
		_IrisSize("_IrisSize", Float) = 1
		_IrisColor("_IrisColor", Color) = (0, 0, 0, 0)
		_IrisColorAlpha("_IrisColorAlpha", Float) = 1
		_IrisBrightness("_IrisBrightness", Float) = 1
		_PupilSize("_PupilSize", Float) = 1
        _ScleraColor("_ScleraColor", Color) = (0, 0, 0, 0)
		_ParallaxHeight("_ParallaxHeight", Float) = 1
		_ReflectionAlpha1("_ReflectionAlpha1", Float) = 1
		_ReflColor1("_ReflColor1", Color) = (0, 0, 0, 0)
		_ReflOffset1("_ReflOffset1", Vector) = (0, 0, 0, 0)
		_ReflectionAlpha2("_ReflectionAlpha2", Float) = 1
		_ReflColor2("_ReflColor2", Color) = (0, 0, 0, 0)
		_ReflOffset2("_ReflOffset2", Vector) = (0, 0, 0, 0)
		// 眼睛
		_LensesColor("_LensesColor", Color) = (0, 0, 0, 0)
		_LensesColorBrightness("_LensesColorBrightness", Float) = 1
		_LensesColorAlpha("_LensesColorAlpha", Float) = 1
		_LensesAlpha("_LensesAlpha", Float) = 1
		_LensesAngle("_LensesAngle", Float) = 1
		_LensesOS("_LensesOS", Vector) = (0, 0, 0, 0)
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

			#include "DZZ_EyeLighting.hlsl"
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
			float4 _NormalMap_ST;
			float4 _Mask0_ST;
			float4 _ReflectionTex1_ST;
			float4 _ReflectionTex2_ST;
			float4 _LensesMap_ST;

			float _Metallic;
			float _Smoothness;
			float _OcclusionStrength;
			float _NormalScale;

			//
			float4 _AmbientColor;
			float _IrisSize;
			float4 _IrisColor;
			float _IrisColorAlpha;
			float _IrisBrightness;
			float _PupilSize;
			float4 _ScleraColor;
			float _ParallaxHeight;
			//
			float _ReflectionAlpha1;
			float4 _ReflColor1;
			float4 _ReflOffset1;
			float _ReflectionAlpha2;
			float4 _ReflColor2;
			float4 _ReflOffset2;
			// 眼睛
			float4 _LensesColor;
			float _LensesColorBrightness;
			float _LensesColorAlpha;
			float _LensesAlpha;
			float _LensesAngle;
			float4 _LensesOS;

			CBUFFER_END
			sampler2D _Basemap;
			sampler2D _NormalMap;
			sampler2D _Mask0;
			sampler2D _ReflectionTex1;
			sampler2D _ReflectionTex2;
			sampler2D _LensesMap;



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


			half4 frag(VertexOutput IN) : SV_Target
			{
				float2 u_xlat16_0 = max(_LensesOS.zw, float2(0.5, 0.5));
				float2 u_xlat16_34 = (u_xlat16_0 - 1.0f) * 0.5f;
				float2 u_xlat16_1 = clamp(_LensesOS.xy * 0.1f, -1, 1);
				float2 u_xlat16_35 = IN.uv.xy * _IrisSize;
				u_xlat16_35  = (1.0f - _IrisSize) * 0.5f + u_xlat16_35;
				u_xlat16_1 = u_xlat16_1 + u_xlat16_35;
			    float2  lensesMapUV = u_xlat16_1 * u_xlat16_0 - u_xlat16_34;
				//
				
				float4 LensesMapColor = tex2D(_LensesMap, lensesMapUV);
				float maxLensesMapColor = max(LensesMapColor.r, max(LensesMapColor.g, LensesMapColor.b));
				float3 LensesResult = lerp(LensesMapColor.rgb, maxLensesMapColor * _LensesColorBrightness * _LensesColor.rgb, _LensesColorAlpha);
                //
				float u_xlat16_53  = min(length(u_xlat16_35 + float2(-0.5, -0.5)), 1.0f);
				u_xlat16_53 = 1.0f - 5.62 * u_xlat16_53;
				float4 maskColor = tex2D(_Mask0, u_xlat16_35);
				u_xlat16_53 = u_xlat16_53 * maskColor.g;
				float u_xlat16_18 = min(_PupilSize * _PupilSize * u_xlat16_53, 1.0f);
				float flag = step(1, _PupilSize);
				u_xlat16_18 = flag * u_xlat16_18 + (1 - flag) * u_xlat16_53;
				float2 u_xlat16_4 = (u_xlat16_35 -0.5f)/ lerp(1.0f, _PupilSize, u_xlat16_18) + 0.5f;
				u_xlat16_1 = lerp(u_xlat16_35, u_xlat16_4, u_xlat16_18);
				//
				float3 WorldNormal = normalize(IN.tSpace0.xyz);
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				
				float3 WorldPosition = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
				float4 ShadowCoords = float4(0, 0, 0, 0);
				// 把视角方向当成法线去切线空间处理。
				float3 viewNormal = TransformTangentToWorld(WorldViewDirection, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
				viewNormal = normalize(viewNormal);

				float2 u_xlat16_8 = viewNormal.xy / (viewNormal.z + 0.42);
				u_xlat16_8 = u_xlat16_8 * _ParallaxHeight * (maskColor.r - 0.5f);
				float2 baseMapUV = u_xlat16_8 * maskColor.g + u_xlat16_1;
				float2 normalUV = u_xlat16_8 * maskColor.g + u_xlat16_35;
				//  采样法线。
				float3 Normal = UnpackNormalScale(tex2D(_NormalMap, normalUV), _NormalScale);
				Normal.z = 1.0;
				float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
				normalWS = normalize(normalWS);
				// 采样主纹理
				float3 baseMapCol = tex2D(_Basemap, baseMapUV).rgb;
				float MaxbaseMapCol = max(baseMapCol.r, max(baseMapCol.g, baseMapCol.b));
				float3 u_xlat16_12 = lerp(baseMapCol, MaxbaseMapCol * _ScleraColor.rgb, _ScleraColor.a);
				float3 u_xlat16_11 = lerp(baseMapCol, MaxbaseMapCol * _IrisColor.rgb, _IrisColorAlpha);
				u_xlat16_11 = lerp(u_xlat16_12, u_xlat16_11, maskColor.g);
				float3 Albedo = lerp(u_xlat16_11, LensesResult, LensesMapColor.a * maskColor.g * _LensesAlpha);
				//
				float smooth = _Smoothness * maskColor.b;
				float3 Specular = 0.5;
				float Metallic = _Metallic;
				float Smoothness = smooth;
				float Occlusion = lerp(1.0f, maskColor.a, _OcclusionStrength);
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

					WorldViewDirection = SafeNormalize(WorldViewDirection);

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;
				inputData.normalWS = normalWS;


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
					Alpha);
				// mat cap 采样
				float3 normalVS = normalize(mul(normalWS, UNITY_MATRIX_V).xyz);
				_ReflOffset2.xyz =clamp(_ReflOffset2.xyz, -1,1.0);
				float2 uv = (_ReflOffset2.xy * normalVS.zz + float2(1.0, 1.0)) * 0.5f + _ReflOffset2.xy;

				float3 reflResult2 = tex2D(_ReflectionTex2, uv).rgb;
				float maxReflResult2 = max(reflResult2.r, max(reflResult2.g, reflResult2.b));
				reflResult2 = lerp(reflResult2, reflResult2 * _ReflColor2.rgb, _ReflColor2.a) * saturate(_ReflectionAlpha2) * maskColor.b;
				//
				_ReflOffset1.xyz = clamp(_ReflOffset1.xyz, -1, 1.0) + normalVS;
				float3 temp = _ReflOffset1.xyz + float3(0, 0, 1);
				float tempLength = length(temp);
				uv = _ReflOffset1.xy / tempLength * 0.5f + 0.5f;

				float3 reflResult1 = tex2D(_ReflectionTex1, uv).rgb;
				float maxRef1Result = max(reflResult1.r, max(reflResult1.g, reflResult1.b));
				reflResult1 = lerp(reflResult1, maxRef1Result * _ReflColor1.xyz, _ReflColor1.a) * saturate(_ReflectionAlpha1) * maskColor.b;

				float4 result = float4(color.rgb + reflResult1 + reflResult2, 1.0f);
				return result;
			}
			ENDHLSL
		}
	}
}

