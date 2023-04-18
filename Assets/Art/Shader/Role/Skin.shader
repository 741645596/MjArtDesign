Shader "Weile/Skin"
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
        _SSSIntensity("_SSSIntensity", Range(0, 1)) = 1.0
        _Wrap("_Wrap", Float) = 1.0
        // pbr
        _Metallic("_Metallic", Range(0, 1)) = 0
        _Smoothness("_Smoothness", Range(0, 1)) = 0
        _Occlusion("_Occlusion", Range(0, 1)) = 1
        _NormalScale("_NormalScale", Range(0, 10)) = 1

        _LipSmoothness("_LipSmoothness[嘴唇]", Float) = 1.0
        _EyeSmoothness("_EyeSmoothness[眼睛]", Float) = 1.0
        _TattooASmoothness("_TattooASmoothness[纹身]", Float) = 1.0

		[FoldoutItem]  _SpecularStrength("高光强度", Range(0, 1)) = 1

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
        Tags { "RenderType"="Opaque" }
        LOD 100

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

				#pragma vertex vert
				#pragma fragment frag

				#define SHADERPASS_FORWARD
				#include "Assets/Art/shader/Core/ColorCore.hlsl"
				#include "Assets/Art/shader/Core/SSSLighting.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"


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
				//
				float _LipSmoothness;
				float _EyeSmoothness;
				float _TattooASmoothness;
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

				float _SpecularStrength;

				CBUFFER_END
				sampler2D _Basemap;
				sampler2D _Normalmap;
				sampler2D _Configmap;
				sampler2D _Sparklemap;
				sampler2D _SkinProfile;


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

				VertexOutput vert (VertexInput v)
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

				half4 frag(VertexOutput IN) : SV_Target
				{
					float3  Albedo = tex2D(_Basemap, IN.uv.xy).rgb * _BaseColor.rgb;
					float gray = dot(Albedo, float3(0.298999995, 0.587000012, 0.114));
					Albedo = lerp(Albedo, gray, _DesaturateScale);
					// pbr 混合贴图
					float4 configData = tex2D(_Configmap, IN.uv.xy);
					float3 sparkColor = tex2D(_Sparklemap, IN.uv.xy).rgb;
					// normal
					float3 Normal = UnpackNormalScale(tex2D(_Normalmap, IN.uv.xy), _NormalScale);
					float3 WorldNormal = normalize(IN.tSpace0.xyz);
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
					float3 NormalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
					float4 ShadowCoords = float4(0, 0, 0, 0);
					//
					float3 WorldPosition = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
					float3 viewWS = normalize(_WorldSpaceCameraPos.xyz - WorldPosition);


					float NoL = dot(_MainLightPosition.xyz, NormalWS);
					float halfLanbettXXX = NoL * 0.5 + 0.469999999;
					float f = smoothstep(_LightRange, 1, halfLanbettXXX);
					Albedo = lerp(Albedo, Albedo * _LightColor.xyz, f);
					// pbr 部分
					float metallic = configData.r * _Metallic;
					float Smoothness = configData.b * _Smoothness + dot(sparkColor, float3(_LipSmoothness, _EyeSmoothness, _TattooASmoothness));
					Smoothness = saturate(Smoothness);
					float Occlusion = lerp(_Occlusion, 1, configData.a);


					float3 addAmbientColor = CalcBlendColor(NormalWS.y) * 0.3f * Occlusion;
					// 3s 部分
					float skuvX = saturate((NoL + _Wrap) / (1 + _Wrap));
					float2 skinUV = float2(skuvX, _SSS * configData.b);
					float3 sssColor = tex2D(_SkinProfile, skinUV).rgb;
					//
					float3 baseDiffuseColor = Albedo * (0.96f - 0.96f * metallic);
					//
					float3 resultColor = float3(0, 0, 0);
					addAmbientColor = addAmbientColor * baseDiffuseColor;
					float3 s3Color = lerp(skuvX, sssColor, _SSSIntensity) * _MainLightColor.xyz * baseDiffuseColor;


					// PBR处理
					float3 Specular = 0.5;
					float Metallic = metallic;
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
					inputData.viewDirectionWS = viewWS;
					inputData.shadowCoord = ShadowCoords;

					inputData.normalWS = NormalWS;
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
						Alpha, _SpecularStrength);
						color = color * _SpecularStrength;
					resultColor = color + addAmbientColor + s3Color;
					// 边缘光
					float3 RimLightDir = normalize(_HalfRimLightDir);
					float Nov = saturate(dot(viewWS, NormalWS));
					float nov_Pow = pow(saturate(1 - Nov), _HalfRimLightPower);
					float NoRim = saturate(dot(NormalWS, RimLightDir) * 0.5f);
					float smoothValue = smoothstep(0, 1, NoRim);
					float3 rimColor = saturate(nov_Pow * smoothValue * _HalfRimLightIntensity) * _HalfRimLightColor.rgb;

					resultColor = colorAdjust(resultColor, _Saturation, _Contrast) * _ColorIntensity;
					return float4(resultColor + rimColor, 1);
				}
			    ENDHLSL
        }
    }
	CustomEditor "FoldoutShaderGUI"
}
