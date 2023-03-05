Shader "HappyMJ/PBRShoe"
{
	Properties
	{
		[Foldout] _BaseName("基础控制面板",Range(0,1)) = 0
		[FoldoutItem][Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode", float) = 2
		[FoldoutItem][Enum(UnityEngine.Rendering.BlendMode)] _SourceBlend("Source Blend Mode", Float) = 5
		[FoldoutItem][Enum(UnityEngine.Rendering.BlendMode)] _DestBlend("Dest Blend Mode", Float) = 10
		[FoldoutItem][Enum(Off, 0, On, 1)]_ZWriteMode("ZWriteMode", float) = 1
		[FoldoutItem][Enum(UnityEngine.Rendering.CompareFunction)] _ZTestMode("ZTestMode", float) = 4

		[Foldout] _StencilName("模板缓冲控制面板",Range(0,1)) = 0
		[FoldoutItem] _Stencil("Stencil ID[ref]", Float) = 0
		[FoldoutItem] _StencilWriteMask("Stencil Write Mask", Float) = 255
		[FoldoutItem] _StencilReadMask("Stencil Read Mask", Float) = 255
		[FoldoutItem][Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 3
		[FoldoutItem][Enum(UnityEngine.Rendering.StencilOp)]_StencilOp("Stencil Operation", Float) = 3
		[FoldoutItem][Enum(UnityEngine.Rendering.StencilOp)]_StencilFailOp("Stencil Fail Operation", Float) = 0
		[FoldoutItem][Enum(UnityEngine.Rendering.StencilOp)]_ZFailOp("Z Fail Operation", Float) = 0
		[FoldoutItem]_OffsetFactor("_OffsetFactor", Float) = 0
		[FoldoutItem]_OffsetUnits("_OffsetUnits", Float) = 0


		[Foldout] _PBRName("PBR控制面板",Range(0,1)) = 0
		[FoldoutItem] _u_AOColor("_u_AOColor", Color) = (1.00, 1.00, 1.00, 1.00)
		[FoldoutItem] _u_Color("_u_Color", Color) = (0.82353, 0.91237, 1.00, 1.00)
		[FoldoutItem] _u_DirectLightIntensity("_u_DirectLightIntensity", Float) = 1.0
		[FoldoutItem] _u_DirectSpecularScale("_u_DirectSpecularScale", Float) = 0.35
		[FoldoutItem] _u_EmissionScale("_u_EmissionScale", Float) = 0.35
		[FoldoutItem] _u_GiColor("_u_GiColor", Color) = (1.0, 1.0, 1.00, 1.00)
		[FoldoutItem] _u_GlossMapScale("_u_GlossMapScale", Float) = 0.448   // 光滑度
		[FoldoutItem] _u_InDirectLightIntensity("_u_InDirectLightIntensity", Float) = 3   // 直接光高光控制
		[FoldoutItem] _u_IndirectDiffuseIntensity("_u_IndirectDiffuseIntensity", Float) = 0.7
		[FoldoutItem] _u_MetalMapScale("_u_MetalMapScale", Float) = 1   // 金属度
		[FoldoutItem] _u_MetallicMapIndirectDiffuseIntensity("_u_MetallicMapIndirectDiffuseIntensity", Float) = 1.53

		[FoldoutItem] _u_Albedo("_u_Albedo", 2D) = "white" {}
		[FoldoutItem] _u_Bump("_u_Bump", 2D) = "bump" {}
		[FoldoutItem][NoScaleOffset] _u_CubeMap("_u_CubeMap   (HDR)", Cube) = "grey" {}
		[FoldoutItem][NoScaleOffset] _u_Emission("_u_Emission", 2D) = "grey" {}
		[FoldoutItem] _u_GM("_u_GM( [ R : 光滑]  [G : 金属]  [B : AO])", 2D) = "white" {}
		[FoldoutItem][NoScaleOffset] _ucustom_SpecCube("_ucustom_SpecCube   (HDR)", Cube) = "grey" {}


		[Foldout] _RimName("RIM边缘光控制面板",Range(0,1)) = 0
		[FoldoutItem] _u_RimVector("_u_RimVector", Vector) = (0.00, 0.30, -1.00, 1.00)
		[FoldoutItem] _u_RimColor("_u_RimColor", Color) = (1.00, 1.00, 1.00, 1.00)
		[FoldoutItem] _u_RimIntensity("_u_RimIntensity", Range(0 , 50)) = 1
		[FoldoutItem] _u_RimPower("_u_RimPower", Range(0 , 50)) = 0.40
	}

		SubShader
		{
			Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
			Pass
			{
				Name "Forward"
				Tags { "LightMode" = "UniversalForward" }

			//Blend One Zero, One Zero
			//ZWrite On
			//ZTest LEqual
			//Offset 0 , 0
			ColorMask RGBA

			ZTest[_ZTestMode]   //LEqual
			Cull[_CullMode]     //Cull off
			Blend[_SourceBlend][_DestBlend] //alpha 透贴
			ZWrite[_ZWriteMode] //ZWrite off
			Offset[_OffsetFactor],[_OffsetUnits]

			/*Stencil
			{
				Ref[_Stencil]                // 0
				ReadMask[_StencilReadMask]   // 255
				WriteMask[_StencilWriteMask] // 255
				Comp[_StencilComp]           // equal
				Pass[_StencilOp]             // incr sat
				Fail[_StencilFailOp]         // keep
				ZFail[_ZFailOp]              // keep

			}*/


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
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
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

				float _u_EmissionScale;

				float4 _u_Albedo_ST;
				float4 _u_Color;

				float4 _u_Bump_ST;
				float4 _u_GM_ST;
				float4 _u_Emission_ST;
				float4 _ucustom_SpecCube_HDR;
				float4 _u_CubeMap_HDR;

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
				samplerCUBE _u_CubeMap;
				samplerCUBE _ucustom_SpecCube;
				sampler2D _u_Emission;



				VertexOutput VertexFunction(VertexInput v)
				{
					VertexOutput o = (VertexOutput)0;
					o.uv.xy = v.texcoord.xy;

					float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
					float3 positionVS = TransformWorldToView(positionWS);
					float4 positionCS = TransformWorldToHClip(positionWS);
					o.positionWS = positionWS;
					o.worldView = normalize(_WorldSpaceCameraPos - positionWS);

					VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

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

					//----------------------

					float2 uv_BaseMap = IN.uv.xy * _u_Albedo_ST.xy + _u_Albedo_ST.zw;

					float2 uv_NormalMap = IN.uv.xy * _u_Bump_ST.xy + _u_Bump_ST.zw;

					float2 uv_MixMap = IN.uv.xy * _u_GM_ST.xy + _u_GM_ST.zw;

					float2 uv_Emission = IN.uv.xy * _u_Emission_ST.xy + _u_Emission_ST.zw;

					float4 tex2DNode11 = tex2D(_u_GM, uv_MixMap);

					float3 emission = tex2D(_u_Emission, uv_MixMap).rgb * _u_EmissionScale;

					float3 Albedo = tex2D(_u_Albedo, uv_BaseMap).rgb * _u_Color.rgb;

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
					float3 PPPPAlbedo = saturate(Albedo * xxxxxmeta);
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

					// 得到间接高光。流光直接硬加上去
					float3 result = DirectColor + inDirectSpecularColor;
					// AO 处理
					result = lerp(_u_AOColor.xyz, 1, occlusion) * result ;
					// 新的cubeMap
					float2 _uu_xlat16_15 = meta * float2(-0.3f, 0.1f) + float2(0.3f, 0.9f);
					float3 cubeColor = texCUBE(_u_CubeMap, reflectVector).rgb * _uu_xlat16_15.x;
					result = result + cubeColor + emission;
					result = result * _MainLightColor.xyz;

					half4 color = half4(result, 1.0f);
					return color;
				}
				ENDHLSL
			}
		}
	    CustomEditor "FoldoutShaderGUI"
}
