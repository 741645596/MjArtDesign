Shader "HappyMJ/PBRTransparentBase"
{
	Properties
	{
		[Foldout] _PBRName("PBR控制面板",Range(0,1)) = 0
		[FoldoutItem] _CutOff("_CutOff", Float) = 1.00
		[FoldoutItem] _u_AOColor("_u_AOColor", Color) = (1.00, 1.00, 1.00, 1.00)
		[FoldoutItem] _u_Color("_u_Color", Color) = (1.0, 1.0, 1.00, 1.00)
		// 直接光高光控制
		[FoldoutItem] _u_DirectLightIntensity("_u_DirectLightIntensity", Float) = 1.0
		[FoldoutItem] _u_DirectSpecularScale("_u_DirectSpecularScale", Float) = 0.24   
		[FoldoutItem] _u_GiColor("_u_GiColor", Color) = (1.0, 1.0, 1.00, 1.00)
		[FoldoutItem] _u_GlossMapScale("_u_GlossMapScale", Float) = 0.523   // 光滑度
		// 间接光
		[FoldoutItem] _u_InDirectLightIntensity("_u_InDirectLightIntensity", Float) = 3.0   
		[FoldoutItem] _u_IndirectDiffuseIntensity("_u_IndirectDiffuseIntensity", Float) = 0.7

		[FoldoutItem] _u_MetalMapScale("_u_MetalMapScale", Float) = 0.52   // 金属度
		[FoldoutItem] _u_MetallicMapIndirectDiffuseIntensity("_u_MetallicMapIndirectDiffuseIntensity", Float) = 1.47
		// PBR 纹理
		[FoldoutItem] _u_Albedo("_u_Albedo", 2D) = "white" {}
		[FoldoutItem] _u_Bump("_u_Bump", 2D) = "bump" {}
		[FoldoutItem] _u_GM("_u_GM( [ R : 光滑]  [G : 金属]  [B : AO])", 2D) = "white" {}
		[FoldoutItem][NoScaleOffset] _ucustom_SpecCube("_ucustom_SpecCube   (HDR)", Cube) = "grey" {}
		
		[Foldout] _RimName("RIM边缘光控制面板",Range(0,1)) = 0
		[FoldoutItem] _u_RimVector("_u_RimVector", Vector) = (0.00, 0.30, -1.00, 1.00)
		[FoldoutItem]_u_RimColor("_u_RimColor", Color) = (1.00, 1.00, 1.00, 1.00)
		[FoldoutItem] _u_RimIntensity("_u_RimIntensity", Range(0 , 50)) = 1
		[FoldoutItem] _u_RimPower("_u_RimPower", Range(0 , 50)) = 0.40
	}

		SubShader
		{
			Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }
			Pass
			{
				Name "FORWARD"
				Tags 
			    {
				   //"LightMode" = "UniversalForward" 
				   "LIGHTMODE" = "Fpass0"
				   "QUEUE" = "Transparent+1"
				   "RenderType" = "Transparent"
		        }

				Cull Off

				HLSLPROGRAM
				#define _RECEIVE_SHADOWS_OFF 1


				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
				#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS


				#pragma vertex vert
				#pragma fragment frag

				#define SHADERPASS_FORWARD

				#include "ColorCore.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"


				struct VertexInput
				{
					float4 vertex : POSITION;
					float3 ase_normal : NORMAL;
					float4 ase_tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
				};

				struct VertexOutput
				{
					float4 clipPos : SV_POSITION;
					float4 lightmapUVOrVertexSH : TEXCOORD0;
					half4 vertexLight : TEXCOORD1;
					float4 tSpace0 : TEXCOORD2;
					float4 tSpace1 : TEXCOORD3;
					float4 tSpace2 : TEXCOORD4;
					float2 uv : TEXCOORD5;
					//
					float3 positionWS :TEXCOORD6;
					float3 worldView :TEXCOORD7;
					float3 rimDirView :TEXCOORD8;
				};

				CBUFFER_START(UnityPerMaterial)
				float4 _u_GiColor;
				float  _u_DirectLightIntensity;
				float  _u_IndirectDiffuseIntensity;
				float  _u_MetallicMapIndirectDiffuseIntensity;
				float  _u_DirectSpecularScale;
				float  _u_InDirectLightIntensity;

				float4 _u_Albedo_ST;
				float4 _u_Color;

				float4 _u_Bump_ST;
				float4 _u_GM_ST;
				float4 _ucustom_SpecCube_HDR;

				float4 _u_AOColor;

				float _u_GlossMapScale;
				float _u_MetalMapScale;


				float3 _u_RimVector;
				float4 _u_RimColor;
				float _u_RimIntensity;
				float _u_RimPower;
                //
				float _CutOff;
				CBUFFER_END
				sampler2D _u_Albedo;
				sampler2D _u_Bump;
				sampler2D _u_GM;
				samplerCUBE _ucustom_SpecCube;



				VertexOutput VertexFunction(VertexInput v)
				{
					VertexOutput o = (VertexOutput)0;
					o.uv.xy = v.texcoord.xy;

					float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
					float3 positionVS = TransformWorldToView(positionWS);
					float4 positionCS = TransformWorldToHClip(positionWS);
					o.positionWS = positionWS;
					o.worldView = normalize(_WorldSpaceCameraPos - positionWS);

					VertexNormalInputs normalInput = GetVertexNormalInputs(v.ase_normal, v.ase_tangent);

					o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
					o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
					o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

					OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
					OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);


					half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);

					o.vertexLight = half4(vertexLight, 0);


					float3 rimVector = normalize(_u_RimVector);
					o.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

					o.clipPos = positionCS;

					return o;
				}



				VertexOutput vert(VertexInput v)
				{
					return VertexFunction(v);
				}

				half4 frag(VertexOutput IN, float facing : VFACE) : SV_Target
				{
					float3 WorldNormal = normalize(IN.tSpace0.xyz);
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;

					//float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
					//float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
					//WorldViewDirection = SafeNormalize(WorldViewDirection);
					float4 ShadowCoords = float4(0, 0, 0, 0);




					float2 uv_BaseMap = IN.uv.xy * _u_Albedo_ST.xy + _u_Albedo_ST.zw;

					float2 uv_NormalMap = IN.uv.xy * _u_Bump_ST.xy + _u_Bump_ST.zw;

					float2 uv_MixMap = IN.uv.xy * _u_GM_ST.xy + _u_GM_ST.zw;

					float4 tex2DNode11 = tex2D(_u_GM, uv_MixMap);

					float4 emission = float4(0,0,0,0);

					float4 albedoColor = tex2D(_u_Albedo, uv_BaseMap);
					float Alpha = albedoColor.a;
				    clip(Alpha - _CutOff);

					float3 Albedo = albedoColor.rgb * _u_Color.rgb;

					float3 Normal = UnpackNormalScale(tex2D(_u_Bump, uv_NormalMap), 1.0f);
					bool backface = facing < 0.0f;
					if (backface)
					{
						Normal = -Normal;
					}

					float meta = tex2DNode11.g * _u_MetalMapScale;

					float smooth = tex2DNode11.r;
					float occlusion = tex2DNode11.b;


					float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
					
					// 半lanbert 
					float3 lightDir = _MainLightPosition; // 平行光就是方向了
					float3 WorldviewDir = IN.worldView;
					float3 shadowColor = float3(1, 1, 1); // 考虑投影
					float NoL = clamp(dot(normalWS, lightDir), 0, 1);
					float halfLanbett  = NoL * 0.5f + 0.5f;
					float3 diffuse = shadowColor* halfLanbett * _u_DirectLightIntensity;
					float3 gi = _u_GiColor.rgb * _u_IndirectDiffuseIntensity * _u_MetallicMapIndirectDiffuseIntensity;
					diffuse = diffuse + gi;
					// 直接光的高光。
					float NoV = dot(normalWS, WorldviewDir);
					smooth = (1.0f - smooth)* _u_GlossMapScale;
					smooth = clamp(smooth, 0.0f, 1.5f);
					// 粗糙度
					float perceptualRoughness = 1.0f - smooth;
					float roughness = perceptualRoughness * perceptualRoughness;
					float roughness2 = roughness * roughness;
					//  V函数的计算。
					float V = Vis_SmithJointApprox_Plus(roughness, NoV, NoL);
					// 
					float3 H = normalize(WorldviewDir + lightDir);
					float NoH = saturate(dot(normalWS, H));
					float LoH = saturate(dot(lightDir, H));
					
					float _uu_xlat16_18 =  1.0f - roughness * 0.28f * perceptualRoughness;
					// D函数
					float D = D_GGX_UE4(roughness2, NoH);

					// 计算F项,变种的F项
					float F = Pow5(1 - LoH);
					//
					float xxxxxmeta = (1.0f - meta) * 0.77908373f;
					float3 PPPPAlbedo = Albedo * xxxxxmeta;
					PPPPAlbedo = clamp(PPPPAlbedo, 0.0f, 1.0f);
		            //
					float xxx = saturate(smooth + 1.0f - xxxxxmeta);

					float3  frenel = lerp(PPPPAlbedo, 1.0f, F);
					float3  DirectSpecularColor = max(0, frenel * NoL * D * V * PI * _u_DirectSpecularScale);
					//直接光的边缘光
					float rim = pow(saturate(dot(normalWS, IN.rimDirView)) * (1 - NoL), _u_RimPower);
					float3 rimColor = min(rim, 1.0f) * _u_RimColor.xyz * _u_RimIntensity;
					rimColor = clamp(rimColor, 0.0f, 1.0f);
					// 得到直接光的渲染。
					float3 DirectColor = PPPPAlbedo * diffuse + DirectSpecularColor + rimColor;
					// 间接高光
					// 采样天空盒数据
					float3 reflectVector = reflect(-WorldviewDir, normalWS);
					float4 encodedIrradiance = texCUBE(_ucustom_SpecCube, reflectVector);
					float3 irradiance = DecodeHDREnvironment(encodedIrradiance, _ucustom_SpecCube_HDR);
					float3 yyy = irradiance * meta * _uu_xlat16_18;
					// F项
					float  NF = Pow5(1.0f - abs(NoV));
					NF = clamp(NF, 0.0, 1.0);

					float3 xxxzzz = lerp(0.2209163f, Albedo, meta);
					xxxzzz = lerp(xxxzzz, xxx, NF);
					float3 inDirectSpecularColor = yyy * xxxzzz * _u_InDirectLightIntensity;
					// 得到间接高光。
					float3 result = DirectColor + inDirectSpecularColor;
                    // AO 处理
					result = lerp(_u_AOColor.xyz, 1, occlusion) * result * _MainLightColor.xyz;

					half4 color = half4(result, Alpha);
					return color;
				}
				ENDHLSL
			}

			Pass
			{
				Name "ALPHA BLENDING"
				Tags
				{
					//"LightMode" = "UniversalForward" 
					"LIGHTMODE" = "Fpass1"
					"QUEUE" = "Transparent+2"
					"RenderType" = "Transparent"
				 }
				ZTest Less
				ZWrite Off
				Cull Front
				Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One

				 HLSLPROGRAM
				 #define _RECEIVE_SHADOWS_OFF 1


				 #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
				 #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
				 #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS


				 #pragma vertex vert
				 #pragma fragment frag

				 #define SHADERPASS_FORWARD

				 #include "ColorCore.hlsl"
				 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
				 #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
				 #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
				 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"


				 struct VertexInput
				 {
					 float4 vertex : POSITION;
					 float3 ase_normal : NORMAL;
					 float4 ase_tangent : TANGENT;
					 float4 texcoord : TEXCOORD0;
					 float4 texcoord1 : TEXCOORD1;
				 };

				 struct VertexOutput
				 {
					 float4 clipPos : SV_POSITION;
					 float4 lightmapUVOrVertexSH : TEXCOORD0;
					 half4 vertexLight : TEXCOORD1;
					 float4 tSpace0 : TEXCOORD2;
					 float4 tSpace1 : TEXCOORD3;
					 float4 tSpace2 : TEXCOORD4;
					 float2 uv : TEXCOORD5;
					 //
					 float3 positionWS :TEXCOORD6;
					 float3 worldView :TEXCOORD7;
					 float3 rimDirView :TEXCOORD8;
				 };

				 CBUFFER_START(UnityPerMaterial)
				 float4 _u_GiColor;
				 float  _u_DirectLightIntensity;
				 float  _u_IndirectDiffuseIntensity;
				 float  _u_MetallicMapIndirectDiffuseIntensity;
				 float  _u_DirectSpecularScale;
				 float  _u_InDirectLightIntensity;

				 float4 _u_Albedo_ST;
				 float4 _u_Color;

				 float4 _u_Bump_ST;
				 float4 _u_GM_ST;
				 float4 _ucustom_SpecCube_HDR;

				 float4 _u_AOColor;

				 float _u_GlossMapScale;
				 float _u_MetalMapScale;


				 float3 _u_RimVector;
				 float4 _u_RimColor;
				 float _u_RimIntensity;
				 float _u_RimPower;
				 //
				 CBUFFER_END
				 sampler2D _u_Albedo;
				 sampler2D _u_Bump;
				 sampler2D _u_GM;
				 samplerCUBE _ucustom_SpecCube;



				 VertexOutput VertexFunction(VertexInput v)
				 {
					 VertexOutput o = (VertexOutput)0;
					 o.uv.xy = v.texcoord.xy;

					 float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
					 float3 positionVS = TransformWorldToView(positionWS);
					 float4 positionCS = TransformWorldToHClip(positionWS);
					 o.positionWS = positionWS;
					 o.worldView = normalize(_WorldSpaceCameraPos - positionWS);

					 VertexNormalInputs normalInput = GetVertexNormalInputs(v.ase_normal, v.ase_tangent);

					 o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
					 o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
					 o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

					 OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
					 OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);


					 half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);

					 o.vertexLight = half4(vertexLight, 0);


					 float3 rimVector = normalize(_u_RimVector);
					 o.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

					 o.clipPos = positionCS;

					 return o;
				 }



				 VertexOutput vert(VertexInput v)
				 {
					 return VertexFunction(v);
				 }

				 half4 frag(VertexOutput IN) : SV_Target
				 {
					 float3 WorldNormal = normalize(IN.tSpace0.xyz);
					 float3 WorldTangent = IN.tSpace1.xyz;
					 float3 WorldBiTangent = IN.tSpace2.xyz;

					 //float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
					 //float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
					 //WorldViewDirection = SafeNormalize(WorldViewDirection);
					 float4 ShadowCoords = float4(0, 0, 0, 0);
					 


					 float2 uv_BaseMap = IN.uv.xy * _u_Albedo_ST.xy + _u_Albedo_ST.zw;

					 float2 uv_NormalMap = IN.uv.xy * _u_Bump_ST.xy + _u_Bump_ST.zw;

					 float2 uv_MixMap = IN.uv.xy * _u_GM_ST.xy + _u_GM_ST.zw;

					 float4 tex2DNode11 = tex2D(_u_GM, uv_MixMap);

					 float4 emission = float4(0,0,0,0);

					 float4 albedoColor = tex2D(_u_Albedo, uv_BaseMap);
					 float Alpha = albedoColor.a;

					 float3 Albedo = albedoColor.rgb * _u_Color.rgb;

					 float3 Normal = UnpackNormalScale(tex2D(_u_Bump, uv_NormalMap), 1.0f);

					 float meta = tex2DNode11.g * _u_MetalMapScale;

					 float smooth = tex2DNode11.r;
					 float occlusion = tex2DNode11.b;


					 float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));

					 // 半lanbert 
					 float3 lightDir = _MainLightPosition; // 平行光就是方向了
					 float3 worldView = IN.worldView;
					 float3 shadowColor = float3(1, 1, 1); // 考虑投影
					 float NoL = clamp(dot(normalWS, lightDir), 0, 1);
					 float halfLanbett = NoL * 0.5f + 0.5f;
					 float3 diffuse = shadowColor * halfLanbett * _u_DirectLightIntensity;
					 float3 gi = _u_GiColor.rgb * _u_IndirectDiffuseIntensity * _u_MetallicMapIndirectDiffuseIntensity;
					 diffuse = diffuse + gi;
					 // 直接光的高光。
					 float NoV = dot(normalWS, worldView);
					 smooth = (1.0f - smooth) * _u_GlossMapScale;
					 smooth = clamp(smooth, 0.0f, 1.5f);
					 // 粗糙度
					 float perceptualRoughness = 1.0f - smooth;
					 float roughness = perceptualRoughness * perceptualRoughness;
					 float roughness2 = roughness * roughness;
					 //  G函数的计算。
					 float V = Vis_SmithJointApprox_Plus(roughness, NoV, NoL);
					 // 
					 float3 H = normalize(worldView + lightDir);
					 float NoH = saturate(dot(normalWS, H));
					 float LoH = saturate(dot(lightDir, H));

					 float _uu_xlat16_18 = 1.0f - roughness * 0.28f * perceptualRoughness;
					 // D函数
					 float D = D_GGX_UE4(roughness2, NoH);

					 // 计算F项,变种的F项
					 float F = Pow5(1 - LoH);
					 //
					 float xxxxxmeta = (1.0f - meta) * 0.77908373f;
					 float3 PPPPAlbedo = Albedo * xxxxxmeta;
					 PPPPAlbedo = saturate(PPPPAlbedo);
					 //
					 float xxx = saturate(smooth + 1.0f - xxxxxmeta);

					 float3  frenel = lerp(PPPPAlbedo, 1.0f, F);
					 float3  DirectSpecularColor = max(0, frenel * NoL * D * V * PI * _u_DirectSpecularScale);
					 //直接光的边缘光
					 float rim = pow(saturate(dot(normalWS, IN.rimDirView)) * (1 - NoL), _u_RimPower);
					 float3 rimColor = min(rim, 1.0f) * _u_RimColor.xyz * _u_RimIntensity;
					 rimColor = clamp(rimColor, 0.0f, 1.0f);
					 // 得到直接光的渲染。
					 float3 DirectColor = PPPPAlbedo * diffuse + DirectSpecularColor + rimColor;
					 // 间接高光
					 // 采样天空盒数据
					 float3 reflectVector = reflect(-worldView, normalWS);
					 float4 encodedIrradiance = texCUBE(_ucustom_SpecCube, reflectVector);
					 float3 irradiance = DecodeHDREnvironment(encodedIrradiance, _ucustom_SpecCube_HDR);
					 float3 yyy = irradiance * meta * _uu_xlat16_18;
					 // F项
					 float  NF = Pow5(1.0f - abs(NoV));
					 NF = clamp(NF, 0.0, 1.0);

					 float3 xxxzzz = lerp(0.2209163f, Albedo, meta);
					 xxxzzz = lerp(xxxzzz, xxx, NF);
					 float3 inDirectSpecularColor = yyy * xxxzzz * _u_InDirectLightIntensity;
					 // 得到间接高光。
					 float3 result = DirectColor + inDirectSpecularColor;
					 // AO 处理
					 result = lerp(_u_AOColor.xyz, 1, occlusion) * result * _MainLightColor.xyz * Alpha;

					 half4 color = half4(result, Alpha);
					 return color;
				 }
				 ENDHLSL
			}

			Pass
			{
				Name "ALPHA BLENDING"
				Tags
				{
					//"LIGHTMODE" = "UniversalForward"
					"LIGHTMODE" = "Fpass2"
					"QUEUE" = "Transparent+3"
					"RenderType" = "Transparent"
				 }
				ZTest Less
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One

				 HLSLPROGRAM
				 #define _RECEIVE_SHADOWS_OFF 1


				 #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
				 #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
				 #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS


				 #pragma vertex vert
				 #pragma fragment frag

				 #define SHADERPASS_FORWARD

				 #include "ColorCore.hlsl"
				 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
				 #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
				 #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
				 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"


				 struct VertexInput
				 {
					 float4 vertex : POSITION;
					 float3 ase_normal : NORMAL;
					 float4 ase_tangent : TANGENT;
					 float4 texcoord : TEXCOORD0;
					 float4 texcoord1 : TEXCOORD1;
				 };

				 struct VertexOutput
				 {
					 float4 clipPos : SV_POSITION;
					 float4 lightmapUVOrVertexSH : TEXCOORD0;
					 half4 vertexLight : TEXCOORD1;
					 float4 tSpace0 : TEXCOORD2;
					 float4 tSpace1 : TEXCOORD3;
					 float4 tSpace2 : TEXCOORD4;
					 float2 uv : TEXCOORD5;
					 //
					 float3 positionWS :TEXCOORD6;
					 float3 worldView :TEXCOORD7;
					 float3 rimDirView :TEXCOORD8;
				 };

				 CBUFFER_START(UnityPerMaterial)
				 float4 _u_GiColor;
				 float  _u_DirectLightIntensity;
				 float  _u_IndirectDiffuseIntensity;
				 float  _u_MetallicMapIndirectDiffuseIntensity;
				 float  _u_DirectSpecularScale;
				 float  _u_InDirectLightIntensity;

				 float4 _u_Albedo_ST;
				 float4 _u_Color;

				 float4 _u_Bump_ST;
				 float4 _u_GM_ST;
				 float4 _ucustom_SpecCube_HDR;

				 float4 _u_AOColor;

				 float _u_GlossMapScale;
				 float _u_MetalMapScale;


				 float3 _u_RimVector;
				 float4 _u_RimColor;
				 float _u_RimIntensity;
				 float _u_RimPower;
				 CBUFFER_END
				 sampler2D _u_Albedo;
				 sampler2D _u_Bump;
				 sampler2D _u_GM;
				 samplerCUBE _ucustom_SpecCube;



				 VertexOutput VertexFunction(VertexInput v)
				 {
					 VertexOutput o = (VertexOutput)0;
					 o.uv.xy = v.texcoord.xy;

					 float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
					 float3 positionVS = TransformWorldToView(positionWS);
					 float4 positionCS = TransformWorldToHClip(positionWS);
					 o.positionWS = positionWS;
					 o.worldView = normalize(_WorldSpaceCameraPos- positionWS);

					 VertexNormalInputs normalInput = GetVertexNormalInputs(v.ase_normal, v.ase_tangent);

					 o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
					 o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
					 o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

					 OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
					 OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);


					 half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);

					 o.vertexLight = half4(vertexLight, 0);


					 float3 rimVector = normalize(_u_RimVector);
					 o.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

					 o.clipPos = positionCS;

					 return o;
				 }



				 VertexOutput vert(VertexInput v)
				 {
					 return VertexFunction(v);
				 }

				 half4 frag(VertexOutput IN) : SV_Target
				 {
					 float3 WorldNormal = normalize(IN.tSpace0.xyz);
					 float3 WorldTangent = IN.tSpace1.xyz;
					 float3 WorldBiTangent = IN.tSpace2.xyz;

					 //float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
					 //float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
					 //WorldViewDirection = SafeNormalize(WorldViewDirection);
					 float4 ShadowCoords = float4(0, 0, 0, 0);

					 //----------------------

					 


					 float2 uv_BaseMap = IN.uv.xy * _u_Albedo_ST.xy + _u_Albedo_ST.zw;

					 float2 uv_NormalMap = IN.uv.xy * _u_Bump_ST.xy + _u_Bump_ST.zw;

					 float2 uv_MixMap = IN.uv.xy * _u_GM_ST.xy + _u_GM_ST.zw;

					 float4 tex2DNode11 = tex2D(_u_GM, uv_MixMap);

					 float4 emission = float4(0,0,0,0);

					 float4 albedoColor = tex2D(_u_Albedo, uv_BaseMap);
					 float Alpha = albedoColor.a;

					 float3 Albedo = albedoColor.rgb * _u_Color.rgb;

					 float3 Normal = UnpackNormalScale(tex2D(_u_Bump, uv_NormalMap), 1.0f);

					 float meta = tex2DNode11.g * _u_MetalMapScale;

					 float smooth = tex2DNode11.r;
					 float occlusion = tex2DNode11.b;


					 float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));

					 // 半lanbert 
					 float3 lightDir = _MainLightPosition; // 平行光就是方向了
					 float3 worldView = IN.worldView;
					 float3 shadowColor = float3(1, 1, 1); // 考虑投影
					 float NoL = clamp(dot(normalWS, lightDir), 0, 1);
					 float halfLanbett = NoL * 0.5f + 0.5f;
					 float3 diffuse = shadowColor * halfLanbett * _u_DirectLightIntensity;
					 float3 gi = _u_GiColor.rgb * _u_IndirectDiffuseIntensity * _u_MetallicMapIndirectDiffuseIntensity;
					 diffuse = diffuse + gi;
					 // 直接光的高光。
					 float NoV = dot(normalWS, worldView);
					 smooth = (1.0f - smooth) * _u_GlossMapScale;
					 smooth = clamp(smooth, 0.0f, 1.5f);
					 // 粗糙度
					 float perceptualRoughness = 1.0f - smooth;
					 float roughness = perceptualRoughness * perceptualRoughness;
					 float roughness2 = roughness * roughness;
					 //  V函数的计算。
					 float V = Vis_SmithJointApprox_Plus(roughness, NoV, NoL);
					 // 
					 float3 H = normalize(worldView + lightDir);
					 float NoH = saturate(dot(normalWS, H));
					 float LoH = saturate(dot(lightDir, H));

					 float _uu_xlat16_18 = 1.0f - roughness * 0.28f * perceptualRoughness;
					 // D函数
					 float D = D_GGX_UE4(roughness2, NoH);

					 // 计算F项,变种的F项
					 float F = Pow5(1 - LoH);
					 //
					 float xxxxxmeta = (1.0f - meta) * 0.77908373f;
					 float3 PPPPAlbedo = Albedo * xxxxxmeta;
					 PPPPAlbedo = saturate(PPPPAlbedo);
					 //
					 float xxx = saturate(smooth + 1.0f - xxxxxmeta);
					 float3  frenel = lerp(PPPPAlbedo, 1.0f, F);
					 float3  DirectSpecularColor = max(0, frenel * NoL * D * V * PI * _u_DirectSpecularScale);
					 //直接光的边缘光
					 float rim = pow(saturate(dot(normalWS, IN.rimDirView)) * (1 - NoL), _u_RimPower);
					 float3 rimColor = min(rim, 1.0f) * _u_RimColor.xyz * _u_RimIntensity;
					 rimColor = clamp(rimColor, 0.0f, 1.0f);
					 // 得到直接光的渲染。
					 float3 DirectColor = PPPPAlbedo * diffuse + DirectSpecularColor + rimColor;
					 // 间接高光
					 // 采样天空盒数据
					 float3 reflectVector = reflect(-worldView, normalWS);
					 float4 encodedIrradiance = texCUBE(_ucustom_SpecCube, reflectVector);
					 float3 irradiance = DecodeHDREnvironment(encodedIrradiance, _ucustom_SpecCube_HDR);
					 float3 yyy = irradiance * meta * _uu_xlat16_18;
					 // F项
					 float  NF = Pow5(1.0f - abs(NoV));
					 NF = clamp(NF, 0.0, 1.0);

					 float3 xxxzzz = lerp(0.2209163f, Albedo, meta);
					 xxxzzz = lerp(xxxzzz, xxx, NF);
					 float3 inDirectSpecularColor = yyy * xxxzzz * _u_InDirectLightIntensity;
					 // 得到间接高光。
					 float3 result = DirectColor + inDirectSpecularColor;
					 // AO 处理
					 result = lerp(_u_AOColor.xyz, 1, occlusion) * result * _MainLightColor.xyz * Alpha;

					 half4 color = half4(result, Alpha);
					 return color;
				 }
				 ENDHLSL
			}
		}
		CustomEditor "FoldoutShaderGUI"
}
