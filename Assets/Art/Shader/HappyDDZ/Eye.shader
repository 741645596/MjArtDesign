Shader "HappyDDZ/Eye"
{
	Properties
	{ 
		_Basemap("BaseMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Mask("_Mask([G : 光滑]  [B : 反射高光]  [A : AO] )", 2D) = "white" {}
		_ReflectionTex1("_ReflectionTex1", 2D) = "white" {}
		_ReflectionTex2("_ReflectionTex2", 2D) = "white" {}
		_LensesMap("_LensesMap", 2D) = "white" {}

		_Metallic("_Metallic", Range(0, 1)) = 0
		_Smoothness("_Smoothness", Range(0, 1)) = 0
		_OcclusionStrength("_OcclusionStrength", Range(0, 1)) = 1
		_NormalScale("_NormalScale", Range(0, 10)) = 1

		//
		_AmbientColor("_AmbientColor", Color) = (0, 0, 0, 0)
		_IrisSize("_IrisSize[虹膜大小]", Float) = 1
		_IrisColor("_IrisColor[虹膜颜色]", Color) = (0, 0, 0, 0)
		_IrisColorAlpha("_IrisColorAlpha[虹膜颜色Alpha]", Float) = 1
		_IrisBrightness("_IrisBrightness[虹膜颜色亮度]", Float) = 1
		_PupilSize("_PupilSize[瞳孔大小]", Float) = 1
        _ScleraColor("_ScleraColor[巩膜颜色]", Color) = (0, 0, 0, 0)
		_ParallaxHeight("_ParallaxHeight", Float) = 1
		//
		_ReflectionAlpha1("_ReflectionAlpha1", Float) = 1
		_ReflColor1("_ReflColor1", Color) = (0, 0, 0, 0)
		_ReflOffset1("_ReflOffset1", Vector) = (0, 0, 0, 0)
		_ReflectionAlpha2("_ReflectionAlpha2", Float) = 1
		_ReflColor2("_ReflColor2", Color) = (0, 0, 0, 0)
		_ReflOffset2("_ReflOffset2", Vector) = (0, 0, 0, 0)
		// 眼睛
		_LensesColor("_LensesColor[透镜颜色]", Color) = (0, 0, 0, 0)
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
			float4 _Mask_ST;
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
			sampler2D _Mask;
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


			/*half4 frag(VertexOutput IN) : SV_Target
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
				float4 maskColor = tex2D(_Mask, u_xlat16_35);
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
				// 调整后的法线。去处理
				float3 normalWS1;
				normalWS1.xy = Normal.xy + normalWS.xy;
				normalWS1.z = Normal.z * normalWS.z;
				normalWS1 = normalize(normalWS1);


				// 采样主纹理
				float4 baseMapCol = tex2D(_Basemap, baseMapUV);
				float MaxbaseMapCol = max(baseMapCol.r, max(baseMapCol.g, baseMapCol.b));
				float3 u_xlat16_12 = lerp(baseMapCol.rgb, MaxbaseMapCol * _ScleraColor.rgb, _ScleraColor.a);
				float3 u_xlat16_11 = lerp(baseMapCol.rgb, MaxbaseMapCol * _IrisColor.rgb, _IrisColorAlpha);
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

			   //WorldViewDirection = SafeNormalize(WorldViewDirection);

                // 
				float3 u_xlat6 = float3(unity_MatrixV[0].z, unity_MatrixV[1].z, unity_MatrixV[2].z) * 100.0f + _WorldSpaceCameraPos.xyz;
				float4 u_xlat3 = float4(-WorldPosition, 0);
				u_xlat6 = u_xlat3.wyw + u_xlat6.xyz;
				float3 u_xlat15 = u_xlat3.wyw + _WorldSpaceCameraPos.xyz;
				u_xlat3.y = float(50.0);
				u_xlat3.w = float(1.0);
				u_xlat6 = u_xlat3.xyz + u_xlat6;
				u_xlat3.xyz = u_xlat3.xwz + u_xlat15;
				u_xlat3.xyz = normalize(u_xlat3.xyz);
				// view 向量也发生调整
				WorldViewDirection = normalize(u_xlat6);


				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;
				//inputData.normalWS = normalWS;
				inputData.normalWS = normalWS1;


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
					_AmbientColor);

				// 加入一段自定义的执行。
				float3 normalOffset = Normal.xyz * float3(-2.0, -2.0, 1.0);
				normalOffset = TransformTangentToWorld(normalOffset, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
				normalOffset = normalize(normalOffset);

				float dd = saturate(dot(normalOffset, u_xlat3.xyz));
				float N_L = dot(_MainLightPosition.xyz, u_xlat3.xyz);
				N_L = saturate(N_L * 0.5 + 0.5);
				float xxxResult = _IrisBrightness *  (1- 0.9 *(1.0 - N_L));
				u_xlat16_53 = baseMapCol.a * pow(dd, 6);
				float u_xlat16_21 = xxxResult * u_xlat16_53;
				u_xlat16_53 = saturate(1 - u_xlat16_53 * xxxResult) * 0.5f + 0.01;
				float3 addColor = color.rgb * u_xlat16_21 / u_xlat16_53;


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

				float4 result = float4(color.rgb  + addColor + reflResult1 + reflResult2, 1.0f);
				
				return result;
			}*/
// 原版翻译
half4 frag(VertexOutput IN) : SV_Target
{
                float4 u_xlat16_0;
                u_xlat16_0.xy = max(_LensesOS.zw, float2(0.5, 0.5));
                float2 u_xlat16_34 = u_xlat16_0.xy + float2(-1.0, -1.0);
                u_xlat16_34 = u_xlat16_34 * float2(0.5, 0.5);
                float4 u_xlat16_1;
                u_xlat16_1.xy = _LensesOS.xy * float2(0.100000001, 0.100000001);
                u_xlat16_1.xy = max(u_xlat16_1.xy, float2(-1.0, -1.0));
                u_xlat16_1.xy = min(u_xlat16_1.xy, float2(1.0, 1.0));
                float2 u_xlat16_35;
                u_xlat16_35.x = _IrisSize + -1.0;
                u_xlat16_35.x = u_xlat16_35.x * 0.5;
                u_xlat16_35.xy = IN.uv.xy * _IrisSize + (-u_xlat16_35.xx);
                u_xlat16_1.xy = u_xlat16_1.xy + u_xlat16_35.xy;
                u_xlat16_0.xy = u_xlat16_1.xy * u_xlat16_0.xy + (-u_xlat16_34.xy);
                u_xlat16_0 = tex2D(_LensesMap, u_xlat16_0.xy);
                u_xlat16_1.x = max(u_xlat16_0.z, u_xlat16_0.y);
                u_xlat16_1.x = max(u_xlat16_0.x, u_xlat16_1.x);
                u_xlat16_1.x = u_xlat16_1.x * _LensesColorBrightness;
                float3 u_xlat16_2;
                u_xlat16_2.xyz = u_xlat16_1.xxx * _LensesColor.xyz + (-u_xlat16_0.xyz);
                u_xlat16_2.xyz = _LensesColorAlpha * u_xlat16_2.xyz + u_xlat16_0.xyz;
                u_xlat16_1.x = _PupilSize + -1.0;
                float u_xlatb3 = 1.0 < _PupilSize;
                float u_xlat16_18 = _PupilSize * _PupilSize;
                float4 u_xlat16_4;
                u_xlat16_4.xy = u_xlat16_35.xy + float2(-0.5, -0.5);
                float u_xlat16_53 = dot(u_xlat16_4.xy, u_xlat16_4.xy);
                u_xlat16_53 = sqrt(u_xlat16_53);
                u_xlat16_53 = min(u_xlat16_53, 1.0);
                u_xlat16_53 = (-u_xlat16_53) * 5.61999989 + 1.0;
                float4 u_xlat16_5 = tex2D(_Mask, u_xlat16_35.xy);
                u_xlat16_53 = u_xlat16_53 * u_xlat16_5.y;
                u_xlat16_18 = u_xlat16_18 * u_xlat16_53;
                u_xlat16_18 = min(u_xlat16_18, 1.0);
                u_xlat16_18 = (u_xlatb3) ? u_xlat16_18 : u_xlat16_53;
                u_xlat16_1.x = u_xlat16_18 * u_xlat16_1.x + 1.0;
                u_xlat16_4.xy = u_xlat16_4.xy / u_xlat16_1.xx;
                u_xlat16_4.xy = u_xlat16_4.xy + float2(0.5, 0.5);
                u_xlat16_4.xy = (-u_xlat16_35.xy) + u_xlat16_4.xy;
                u_xlat16_1.xy = u_xlat16_18 * u_xlat16_4.xy + u_xlat16_35.xy;
                u_xlat16_4.x = IN.tSpace0.w;
                u_xlat16_4.y = IN.tSpace1.w;
                u_xlat16_4.z = IN.tSpace2.w;
                float4 u_xlat3;
                u_xlat3.xyz = (-u_xlat16_4.xyz);
                float3 u_xlat6;
                u_xlat6.xyz = u_xlat3.xyz + _WorldSpaceCameraPos.xyz;
                float u_xlat57 = dot(u_xlat6.xyz, u_xlat6.xyz);
                u_xlat57 = max(u_xlat57, 1.17549435e-38);
                u_xlat16_53 = 1/sqrt(u_xlat57);
                u_xlat6.xyz = u_xlat16_53 * u_xlat6.xyz;
                u_xlat16_53 = dot(IN.tSpace0.xyz, IN.tSpace0.xyz);
                u_xlat16_53 = 1 / sqrt(u_xlat16_53);
                u_xlat16_4.xyz = u_xlat16_53 * IN.tSpace0.xyz;
                float3 u_xlat16_7;
                u_xlat16_7.z = u_xlat16_4.y;
                u_xlat16_7.x = IN.tSpace1.y;
                u_xlat16_7.y = IN.tSpace2.y;
                float3 u_xlat16_8;
                u_xlat16_8.xyz = u_xlat6.yyy * u_xlat16_7.xyz;
                float3 u_xlat16_9;
                u_xlat16_9.z = u_xlat16_4.x;
                u_xlat16_9.x = IN.tSpace1.x;
                u_xlat16_9.y = IN.tSpace2.x;
                u_xlat16_8.xyz = u_xlat16_9.xyz * u_xlat6.xxx + u_xlat16_8.xyz;
                u_xlat16_4.x = IN.tSpace1.z;
                u_xlat16_4.y = IN.tSpace2.z;
                u_xlat16_8.xyz = u_xlat16_4.xyz * u_xlat6.zzz + u_xlat16_8.xyz;
                float3 u_xlat16_10;
                u_xlat16_10.xy = (-u_xlat6.zx);
                u_xlat6.x = dot(u_xlat16_8.xyz, u_xlat16_8.xyz);
                u_xlat6.x = max(u_xlat6.x, 1.17549435e-38);
                float u_xlat16_55 = 1 / sqrt(u_xlat6.x);
                u_xlat6.xyz = u_xlat16_55 * u_xlat16_8.xyz;
                u_xlat16_55 = dot(u_xlat6.xyz, u_xlat6.xyz);
                u_xlat16_55 = 1 / sqrt(u_xlat16_55);
                u_xlat16_8.xy = u_xlat16_55 * u_xlat6.xy;
                u_xlat16_55 = u_xlat6.z * u_xlat16_55 + 0.419999987;
                u_xlat16_8.xy = u_xlat16_8.xy / u_xlat16_55;
                u_xlat16_55 = _ParallaxHeight * 0.5;
                u_xlat16_55 = u_xlat16_5.x * _ParallaxHeight + (-u_xlat16_55);
                u_xlat16_8.xy = u_xlat16_8.xy * u_xlat16_55;
                u_xlat16_1.xy = u_xlat16_8.xy * u_xlat16_5.yy + u_xlat16_1.xy;
                u_xlat16_35.xy = u_xlat16_8.xy * u_xlat16_5.yy + u_xlat16_35.xy;
                float4 u_xlat16_6;
                u_xlat16_6.xy = tex2D(_NormalMap, u_xlat16_35.xy).xy;
                u_xlat16_35.xy = u_xlat16_6.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                u_xlat16_8.xy = u_xlat16_35.xy * _NormalScale;
                u_xlat16_1 = tex2D(_Basemap, u_xlat16_1.xy);
                u_xlat16_55 = max(u_xlat16_1.z, u_xlat16_1.y);
                u_xlat16_55 = max(u_xlat16_1.x, u_xlat16_55);
                float4 u_xlat16_11;
                u_xlat16_11.xyz = u_xlat16_55 * _IrisColor.xyz + (-u_xlat16_1.xyz);
                float4 u_xlat16_12;
                u_xlat16_12.xyz = u_xlat16_55 * _ScleraColor.xyz + (-u_xlat16_1.xyz);
                u_xlat16_12.xyz = _ScleraColor.www * u_xlat16_12.xyz + u_xlat16_1.xyz;
                u_xlat16_11.xyz = _IrisColorAlpha * u_xlat16_11.xyz + u_xlat16_1.xyz;
                u_xlat16_11.xyz = (-u_xlat16_12.xyz) + u_xlat16_11.xyz;
                u_xlat16_11.xyz = u_xlat16_5.yyy * u_xlat16_11.xyz + u_xlat16_12.xyz;
                u_xlat16_2.xyz = u_xlat16_2.xyz + (-u_xlat16_11.xyz);
                u_xlat16_55 = u_xlat16_0.w * u_xlat16_5.y;
                u_xlat16_55 = u_xlat16_55 * _LensesAlpha;
                u_xlat16_2.xyz = u_xlat16_55 * u_xlat16_2.xyz + u_xlat16_11.xyz;
                u_xlat16_11.xyz = u_xlat16_2.xyz + float3(-0.0399999991, -0.0399999991, -0.0399999991);
                u_xlat16_11.xyz = _Metallic * u_xlat16_11.xyz + float3(0.0399999991, 0.0399999991, 0.0399999991);
                u_xlat16_55 = (-_Metallic) * 0.959999979 + 0.959999979;
                float u_xlat16_58;
                u_xlat16_58 = _Smoothness * u_xlat16_5.z + (-u_xlat16_55);
                u_xlat16_2.xyz = u_xlat16_2.xyz * u_xlat16_55;
                u_xlat16_55 = u_xlat16_58 + 1.0;
                u_xlat16_55 = clamp(u_xlat16_55, 0.0, 1.0);
                u_xlat16_12.xyz = (-u_xlat16_11.xyz) + u_xlat16_55;
                u_xlat16_8.z = 1.0;
                float4 u_xlat16_13;
                u_xlat16_13.x = dot(u_xlat16_9.xyz, u_xlat16_8.xyz);
                u_xlat16_13.y = dot(u_xlat16_7.xyz, u_xlat16_8.xyz);
                u_xlat16_13.z = dot(u_xlat16_4.xyz, u_xlat16_8.xyz);
                u_xlat16_8.xyz = u_xlat16_8.xyz * float3(-2.0, -2.0, 1.0);
                u_xlat16_55 = dot(u_xlat16_13.xyz, u_xlat16_13.xyz);
                u_xlat16_55 = 1 / sqrt(u_xlat16_55);
                u_xlat16_13.xyz = u_xlat16_55 * u_xlat16_13.xyz;
                float4 u_xlat16_14;
                u_xlat16_14.xy = IN.tSpace0.xy * u_xlat16_53 + u_xlat16_13.xy;
                u_xlat16_14.z = u_xlat16_4.z * u_xlat16_13.z;
                u_xlat16_53 = dot(u_xlat16_14.xyz, u_xlat16_14.xyz);
                u_xlat16_53 = 1 / sqrt(u_xlat16_53);
                u_xlat16_13.xyz = u_xlat16_53 * u_xlat16_14.xyz;
                u_xlat6.x = unity_MatrixV[0].z * 100.0;
                u_xlat6.y = unity_MatrixV[1].z * 100.0;
                u_xlat6.z = unity_MatrixV[2].z * 100.0;
                u_xlat6.xyz = u_xlat6.xyz + _WorldSpaceCameraPos.xyz;
                u_xlat3.w = 0.0;
                u_xlat6.xyz = u_xlat3.wyw + u_xlat6.xyz;
                float4 u_xlat15;
                u_xlat15.xyz = u_xlat3.wyw + _WorldSpaceCameraPos.xyz;
                u_xlat3.y = float(50.0);
                u_xlat3.w = float(1.0);
                u_xlat6.xyz = u_xlat3.xyz + u_xlat6.xyz;
                u_xlat3.xyz = u_xlat3.xwz + u_xlat15.xyz;
                float u_xlat54 = dot(u_xlat6.xyz, u_xlat6.xyz);
                u_xlat54 = max(u_xlat54, 1.17549435e-38);
                u_xlat16_53 = 1 / sqrt(u_xlat54);
                u_xlat15.xyz = u_xlat16_53 * u_xlat6.xyz;
                u_xlat16_14.xyz = u_xlat6.xyz * u_xlat16_53 + _MainLightPosition.xyz;
                u_xlat16_53 = dot(u_xlat16_13.xyz, u_xlat15.xyz);
                u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
                u_xlat16_53 = (-u_xlat16_53) + 1.0;
                u_xlat16_53 = u_xlat16_53 * u_xlat16_53;
                u_xlat16_53 = u_xlat16_53 * u_xlat16_53;
                u_xlat16_12.xyz = u_xlat16_53 * u_xlat16_12.xyz + u_xlat16_11.xyz;
                u_xlat16_53 = (-_Smoothness) * u_xlat16_5.z + 1.0;
                u_xlat16_55 = u_xlat16_53 * u_xlat16_53;
                u_xlat16_55 = max(u_xlat16_55, 0.0078125);
                u_xlat16_58 = u_xlat16_55 * u_xlat16_55 + 1.0;
                u_xlat16_58 = float(1.0) / u_xlat16_58;
                u_xlat6.xyz = u_xlat16_12.xyz * u_xlat16_58;
                u_xlat16_58 = (-u_xlat16_53) * 0.699999988 + 1.70000005;
                u_xlat16_53 = u_xlat16_53 * u_xlat16_58;
                u_xlat16_53 = u_xlat16_53 * 6.0;
                u_xlat16_58 = dot((-u_xlat15.xyz), u_xlat16_13.xyz);
                u_xlat16_58 = u_xlat16_58 + u_xlat16_58;
                u_xlat16_12.xyz = u_xlat16_13.xyz * (-u_xlat16_58) + (-u_xlat15.xyz);
                //u_xlat16_0 = textureLod(unity_SpecCube0, u_xlat16_12.xyz, u_xlat16_53);
                //u_xlat16_0 = texCUBE(unity_SpecCube0, u_xlat16_12.xyz, u_xlat16_53);
                u_xlat16_0 = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, u_xlat16_12.xyz, u_xlat16_53);
                u_xlat16_53 = u_xlat16_0.w + -1.0;
                u_xlat16_53 = unity_SpecCube0_HDR.w * u_xlat16_53 + 1.0;
                u_xlat16_53 = max(u_xlat16_53, 0.0);
                u_xlat16_53 = log2(u_xlat16_53);
                u_xlat16_53 = u_xlat16_53 * unity_SpecCube0_HDR.y;
                u_xlat16_53 = exp2(u_xlat16_53);
                u_xlat16_53 = u_xlat16_53 * unity_SpecCube0_HDR.x;
                u_xlat16_12.xyz = u_xlat16_0.xyz * u_xlat16_53;
                u_xlat16_53 = u_xlat16_5.w + -1.0;
                u_xlat16_53 = _OcclusionStrength * u_xlat16_53 + 1.0;
                u_xlat16_12.xyz = u_xlat16_53 * u_xlat16_12.xyz;
                float4 u_xlat16_16;
                u_xlat16_16.xyz = u_xlat16_53 * _AmbientColor.xyz;
                u_xlat16_12.xyz = u_xlat6.xyz * u_xlat16_12.xyz;
                u_xlat16_12.xyz = u_xlat16_16.xyz * u_xlat16_2.xyz + u_xlat16_12.xyz;
                u_xlat54 = dot(u_xlat16_14.xyz, u_xlat16_14.xyz);
                u_xlat54 = max(u_xlat54, 1.17549435e-38);
                u_xlat16_53 = 1 / sqrt(u_xlat54);
                float4 u_xlat5;
                u_xlat5.xyw = u_xlat16_53 * u_xlat16_14.xyz;
                u_xlat16_53 = dot(_MainLightPosition.xyz, u_xlat5.xyw);
                u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
                u_xlat16_58 = dot(u_xlat16_13.xyz, u_xlat5.xyw);
                u_xlat16_58 = clamp(u_xlat16_58, 0.0, 1.0);
                u_xlat16_58 = u_xlat16_58 * u_xlat16_58;
                u_xlat16_53 = u_xlat16_53 * u_xlat16_53;
                u_xlat54 = max(u_xlat16_53, 0.100000001);
                u_xlat5.x = u_xlat16_55 * u_xlat16_55 + -1.0;
                u_xlat5.x = u_xlat16_58 * u_xlat5.x + 1.00001001;
                u_xlat16_53 = u_xlat5.x * u_xlat5.x;
                u_xlat54 = u_xlat54 * u_xlat16_53;
                u_xlat5.x = u_xlat16_55 * 4.0 + 2.0;
                u_xlat16_53 = u_xlat16_55 * u_xlat16_55;
                u_xlat54 = u_xlat54 * u_xlat5.x;
                u_xlat54 = u_xlat16_53 / u_xlat54;
                u_xlat16_53 = u_xlat54 + -6.10351562e-05;
                u_xlat16_53 = max(u_xlat16_53, 0.0);
                u_xlat16_53 = min(u_xlat16_53, 100.0);
                u_xlat16_2.xyz = u_xlat16_11.xyz * u_xlat16_53 + u_xlat16_2.xyz;
                u_xlat16_53 = dot(u_xlat16_13.xyz, _MainLightPosition.xyz);
                u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
                //u_xlat16_53 = u_xlat16_53 * unity_LightData.z;
                u_xlat16_11.xyz = u_xlat16_53 * _MainLightColor.xyz;
                u_xlat16_2.xyz = u_xlat16_2.xyz * u_xlat16_11.xyz + u_xlat16_12.xyz;
                u_xlat16_9.x = dot(u_xlat16_9.xyz, u_xlat16_8.xyz);
                u_xlat16_9.y = dot(u_xlat16_7.xyz, u_xlat16_8.xyz);
                u_xlat16_9.z = dot(u_xlat16_4.xyz, u_xlat16_8.xyz);
                u_xlat16_53 = dot(u_xlat16_9.xyz, u_xlat16_9.xyz);
                u_xlat16_53 = 1 / sqrt(u_xlat16_53);
                u_xlat16_4.xyz = u_xlat16_53 * u_xlat16_9.xyz;
                u_xlat54 = dot(u_xlat3.xyz, u_xlat3.xyz);
                u_xlat54 = max(u_xlat54, 1.17549435e-38);
                u_xlat16_53 = 1 / sqrt(u_xlat54);
                u_xlat3.xyz = u_xlat16_53 * u_xlat3.xyz;
                u_xlat16_53 = dot(u_xlat16_4.xyz, u_xlat3.xyz);
                u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
                u_xlat16_4.x = dot(_MainLightPosition.xyz, u_xlat3.xyz);
                u_xlat16_4.x = u_xlat16_4.x * 0.5 + 0.5;
                u_xlat16_4.x = clamp(u_xlat16_4.x, 0.0, 1.0);
                u_xlat16_4.x = (-u_xlat16_4.x) + 1.0;
                u_xlat16_4.x = u_xlat16_4.x * _IrisBrightness;
                u_xlat16_4.x = u_xlat16_4.x * -0.899999976 + _IrisBrightness;
                u_xlat16_53 = u_xlat16_53 * u_xlat16_53;
                float u_xlat16_21 = u_xlat16_53 * u_xlat16_53;
                u_xlat16_53 = u_xlat16_53 * u_xlat16_21;
                u_xlat16_53 = u_xlat16_1.w * u_xlat16_53;
                u_xlat16_21 = u_xlat16_4.x * u_xlat16_53;
                u_xlat16_53 = (-u_xlat16_53) * u_xlat16_4.x + 1.0;
                u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
                u_xlat16_53 = u_xlat16_53 * 0.5 + 0.00999999978;
                u_xlat16_4.xyz = u_xlat16_2.xyz * u_xlat16_21;
                u_xlat16_4.xyz = u_xlat16_4.xyz / u_xlat16_53;
                u_xlat16_53 = (-IN.uv.y) + 0.5;
                u_xlat16_10.z = (-u_xlat16_53);
                u_xlat16_7.xyz = u_xlat16_10.xyz * unity_MatrixInvV[1].xyz;
                u_xlat16_7.xyz = unity_MatrixInvV[1].zxy * u_xlat16_10.yzx + (-u_xlat16_7.xyz);
                u_xlat16_53 = dot(u_xlat16_7.xyz, u_xlat16_7.xyz);
                u_xlat16_53 = 1 / sqrt(u_xlat16_53);
                u_xlat16_7.xyz = u_xlat16_53 * u_xlat16_7.xyz;
                u_xlat16_8.xyz = u_xlat16_7.xyz * u_xlat16_10.xyz;
                u_xlat16_8.xyz = u_xlat16_10.zxy * u_xlat16_7.yzx + (-u_xlat16_8.xyz);
                u_xlat16_53 = dot(u_xlat16_8.xyz, u_xlat16_8.xyz);
                u_xlat16_53 = 1 / sqrt(u_xlat16_53);
                float3 u_xlat16_24;
                u_xlat16_24.xz = u_xlat16_53 * u_xlat16_8.xy;
                u_xlat16_24.xz = u_xlat16_24.xz * u_xlat16_13.yy;
                u_xlat16_7.xy = u_xlat16_13.xx * u_xlat16_7.zx + u_xlat16_24.xz;
                u_xlat16_7.xy = u_xlat16_13.zz * u_xlat16_10.yz + u_xlat16_7.xy;
                u_xlat16_8.xyz = max(_ReflOffset2.xyz, float3(-1.0, -1.0, -1.0));
                u_xlat16_8.xyz = min(u_xlat16_8.xyz, float3(1.0, 1.0, 1.0));
                u_xlat16_7.xy = u_xlat16_7.xy * u_xlat16_8.zz + float2(1.0, 1.0);
                u_xlat16_7.xy = u_xlat16_7.xy * float2(0.5, 0.5) + u_xlat16_8.xy;
                float4 u_xlat16_3;
                u_xlat16_3.xyz = tex2D(_ReflectionTex2, u_xlat16_7.xy).xyz;
                u_xlat16_53 = max(u_xlat16_3.z, u_xlat16_3.y);
                u_xlat16_53 = max(u_xlat16_53, u_xlat16_3.x);
                u_xlat16_7.xyz = u_xlat16_53 * _ReflColor2.xyz + (-u_xlat16_3.xyz);
                u_xlat16_7.xyz = _ReflColor2.www * u_xlat16_7.xyz + u_xlat16_3.xyz;
                u_xlat16_53 = _ReflectionAlpha2;
                u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
                u_xlat16_7.xyz = u_xlat16_53 * u_xlat16_7.xyz;
                u_xlat16_7.xyz = u_xlat16_5.zzz * u_xlat16_7.xyz;
                u_xlat3.x = unity_WorldToObject[0].x;
                u_xlat3.y = unity_WorldToObject[1].x;
                u_xlat3.z = unity_WorldToObject[2].x;
                u_xlat16_8.x = dot(u_xlat3.xyz, u_xlat16_13.xyz);
                u_xlat3.x = unity_WorldToObject[0].y;
                u_xlat3.y = unity_WorldToObject[1].y;
                u_xlat3.z = unity_WorldToObject[2].y;
                u_xlat16_8.y = dot(u_xlat3.xyz, u_xlat16_13.xyz);
                u_xlat3.x = unity_WorldToObject[0].z;
                u_xlat3.y = unity_WorldToObject[1].z;
                u_xlat3.z = unity_WorldToObject[2].z;
                u_xlat16_8.z = dot(u_xlat3.xyz, u_xlat16_13.xyz);
                u_xlat3.xyz = unity_MatrixInvV[0].yyy * unity_WorldToObject[1].xyz;
                u_xlat3.xyz = unity_WorldToObject[0].xyz * unity_MatrixInvV[0].xxx + u_xlat3.xyz;
                u_xlat3.xyz = unity_WorldToObject[2].xyz * unity_MatrixInvV[0].zzz + u_xlat3.xyz;
                u_xlat3.xyz = unity_WorldToObject[3].xyz * unity_MatrixInvV[0].www + u_xlat3.xyz;
                u_xlat16_9.x = dot(u_xlat3.xyz, u_xlat16_8.xyz);
                u_xlat3.xyz = unity_MatrixInvV[1].yyy * unity_WorldToObject[1].xyz;
                u_xlat3.xyz = unity_WorldToObject[0].xyz * unity_MatrixInvV[1].xxx + u_xlat3.xyz;
                u_xlat3.xyz = unity_WorldToObject[2].xyz * unity_MatrixInvV[1].zzz + u_xlat3.xyz;
                u_xlat3.xyz = unity_WorldToObject[3].xyz * unity_MatrixInvV[1].www + u_xlat3.xyz;
                u_xlat16_9.y = dot(u_xlat3.xyz, u_xlat16_8.xyz);
                u_xlat3.xyz = unity_MatrixInvV[2].yyy * unity_WorldToObject[1].xyz;
                u_xlat3.xyz = unity_WorldToObject[0].xyz * unity_MatrixInvV[2].xxx + u_xlat3.xyz;
                u_xlat3.xyz = unity_WorldToObject[2].xyz * unity_MatrixInvV[2].zzz + u_xlat3.xyz;
                u_xlat3.xyz = unity_WorldToObject[3].xyz * unity_MatrixInvV[2].www + u_xlat3.xyz;
                u_xlat16_9.z = dot(u_xlat3.xyz, u_xlat16_8.xyz);
                u_xlat16_53 = dot(u_xlat16_9.xyz, u_xlat16_9.xyz);
                u_xlat16_53 = 1/sqrt(u_xlat16_53);
                u_xlat16_8.xyz = max(_ReflOffset1.xyz, float3(-1.0, -1.0, -1.0));
                u_xlat16_8.xyz = min(u_xlat16_8.xyz, float3(1.0, 1.0, 1.0));
                u_xlat16_8.xyz = u_xlat16_9.xyz * u_xlat16_53 + u_xlat16_8.xyz;
                u_xlat16_53 = dot(u_xlat16_8.xy, u_xlat16_8.xy);
                u_xlat16_55 = u_xlat16_8.z + 1.0;
                u_xlat16_53 = u_xlat16_55 * u_xlat16_55 + u_xlat16_53;
                u_xlat16_53 = sqrt(u_xlat16_53);
                u_xlat16_53 = u_xlat16_53 * -2.0;
                u_xlat16_8.xy = u_xlat16_8.xy / u_xlat16_53;
                u_xlat16_8.xy = (-u_xlat16_8.xy) + float2(0.5, 0.5);
                u_xlat16_3.xyz = tex2D(_ReflectionTex1, u_xlat16_8.xy).xyz;
                u_xlat16_53 = max(u_xlat16_3.z, u_xlat16_3.y);
                u_xlat16_53 = max(u_xlat16_53, u_xlat16_3.x);
                u_xlat16_8.xyz = u_xlat16_53 * _ReflColor1.xyz + (-u_xlat16_3.xyz);
                u_xlat16_8.xyz = _ReflColor1.www * u_xlat16_8.xyz + u_xlat16_3.xyz;
                u_xlat16_53 = _ReflectionAlpha1;
                u_xlat16_53 = clamp(u_xlat16_53, 0.0, 1.0);
                u_xlat16_8.xyz = u_xlat16_53 * u_xlat16_8.xyz;
                u_xlat16_7.xyz = u_xlat16_8.xyz * u_xlat16_5.zzz + u_xlat16_7.xyz;
                u_xlat16_4.xyz = u_xlat16_4.xyz + u_xlat16_7.xyz;
                return float4(u_xlat16_2.xyz + u_xlat16_4.xyz, 1.0f);
			}
			ENDHLSL
		}
	}
}

