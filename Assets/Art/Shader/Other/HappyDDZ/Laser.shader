Shader "HappyDDZ/Laser"
{
	Properties
	{   
		_Basemap("BaseMap", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (1, 1, 1, 1)
        _Normalmap("Normalmap", 2D) = "bump" {}
        _Lasermap("Lasermap", 2D) = "white" {}

		_NormalScale("_NormalScale", Range(0, 10)) = 1

		_AmbientSkyColor("_AmbientSkyColor", Color) = (0, 0, 0, 0)
		_AmbientEquatorColor("_AmbientEquatorColor", Color) = (0, 0, 0, 0)
		_AmbientGroundColor("_AmbientGroundColor", Color) = (0, 0, 0, 0)
	    _AmbientIntensity("_AmbientIntensity", Float) = 1.0

		_LaserPower("_LaserPower", Float) = 1.0
		_LaserIntensity("_LaserIntensity", Float) = 1.0
		_SpecularColor1("_SpecularColor1", Color) = (0, 0, 0, 0)
		_SpecularGloss1("_SpecularGloss1", Float) = 1.0
		_ShiftValue1("_ShiftValue1", Float) = 1.0
		_SpecularColor2("_SpecularColor2", Color) = (0, 0, 0, 0)
		_SpecularGloss2("_SpecularGloss2", Float) = 1.0
		_ShiftValue2("_ShiftValue2", Float) = 1.0

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
			float4 _Normalmap_ST;
			float _NormalScale;
			float4 _Lasermap_ST;

            float4 _SpecularColor;
            float _SpecIntensity;
			//
			float4 _AmbientSkyColor;
			float4	_AmbientEquatorColor;
			float4	_AmbientGroundColor;
			float _AmbientIntensity;

			//

			float _LaserPower;
			float _LaserIntensity;
			float4 _SpecularColor1;
			float _SpecularGloss1;
			float _ShiftValue1;
			float4 _SpecularColor2;
			float _SpecularGloss2;
			float _ShiftValue2;

			CBUFFER_END
			sampler2D _Basemap;
			sampler2D _Normalmap;
            sampler2D _Lasermap;


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
				float3 u_xlat16_0;
			    float4 u_xlat1;
				float4 u_xlat16_1;
				float3 u_xlat16_2;
				float4 u_xlat16_3;
				float3 u_xlat16_4;
				float3 u_xlat16_5;
				float2 u_xlat16_6;
				float u_xlat16_21;
				float u_xlat22;
				float u_xlat16_24;
				float u_xlat16_25;
				//
				u_xlat16_0.x = IN.tSpace0.w;
				u_xlat16_0.y = IN.tSpace1.w;
				u_xlat16_0.z = IN.tSpace2.w;
				u_xlat1.xyz = (-u_xlat16_0.xyz) + _WorldSpaceCameraPos.xyz;
				u_xlat22 = dot(u_xlat1.xyz, u_xlat1.xyz);
				u_xlat22 = max(u_xlat22, 1.17549435e-38);
				u_xlat16_0.x = 1.0 / sqrt(u_xlat22);
				u_xlat16_0.xyz = u_xlat1.xyz * u_xlat16_0.xxx + _MainLightPosition.xyz;
				u_xlat1.x = dot(u_xlat16_0.xyz, u_xlat16_0.xyz);
				u_xlat1.x = max(u_xlat1.x, 1.17549435e-38);
				u_xlat16_21 = 1.0 / sqrt(u_xlat1.x);
				u_xlat1.xyz = u_xlat16_21 * u_xlat16_0.xyz;
				u_xlat16_2.xyz = tex2D(_Normalmap, IN.uv.xy).xyz;
				u_xlat16_3.xyz = u_xlat16_2.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
				u_xlat16_3.xy = u_xlat16_3.xy * _NormalScale;
				u_xlat16_4.xyz = u_xlat16_3.yyy * IN.tSpace1.xyz;
				u_xlat16_3.xyw = u_xlat16_3.xxx * IN.tSpace0.xyz + u_xlat16_4.xyz;
				u_xlat16_3.xyz = u_xlat16_3.zzz * IN.tSpace2.xyz + u_xlat16_3.xyw;
				u_xlat16_21 = ((facing ? 0xffffffffu : uint(0)) != uint(0)) ? 1.0 : -1.0;
				u_xlat16_3.xyz = u_xlat16_21 * u_xlat16_3.xyz;
				u_xlat16_4.xyz = u_xlat16_3.xyz * _ShiftValue2 + IN.tSpace1.xyz;
				u_xlat16_21 = dot(u_xlat16_4.xyz, u_xlat16_4.xyz);
				u_xlat16_21 = 1.0 / sqrt(u_xlat16_21);
				u_xlat16_4.xyz = u_xlat16_21 * u_xlat16_4.xyz;
				u_xlat16_21 = dot(u_xlat16_4.xyz, u_xlat1.xyz);
				u_xlat16_24 = (-u_xlat16_21) * u_xlat16_21 + 1.0;
				u_xlat16_21 = u_xlat16_21 + 1.0;
#ifdef UNITY_ADRENO_ES3
				u_xlat16_21 = min(max(u_xlat16_21, 0.0), 1.0);
#else
				u_xlat16_21 = clamp(u_xlat16_21, 0.0, 1.0);
#endif
				u_xlat16_24 = sqrt(u_xlat16_24);
				u_xlat16_24 = log2(u_xlat16_24);
				u_xlat16_24 = u_xlat16_24 * _SpecularGloss2;
				u_xlat16_24 = exp2(u_xlat16_24);
				u_xlat16_4.x = u_xlat16_21 * -2.0 + 3.0;
				u_xlat16_21 = u_xlat16_21 * u_xlat16_21;
				u_xlat16_21 = u_xlat16_21 * u_xlat16_4.x;
				u_xlat16_21 = u_xlat16_21 * u_xlat16_24;
				u_xlat16_21 = min(u_xlat16_21, 1.0);
				u_xlat16_4.xyz = u_xlat16_21 * _SpecularColor2.xyz;
				u_xlat16_5.xyz = u_xlat16_3.xyz * _ShiftValue1 + IN.tSpace1.xyz;
				u_xlat16_21 = dot(u_xlat16_5.xyz, u_xlat16_5.xyz);
				u_xlat16_21 = 1.0 / sqrt(u_xlat16_21);
				u_xlat16_5.xyz = u_xlat16_21 * u_xlat16_5.xyz;
				u_xlat16_21 = dot(u_xlat16_5.xyz, u_xlat1.xyz);
				u_xlat16_24 = (-u_xlat16_21) * u_xlat16_21 + 1.0;
				u_xlat16_21 = u_xlat16_21 + 1.0;
#ifdef UNITY_ADRENO_ES3
				u_xlat16_21 = min(max(u_xlat16_21, 0.0), 1.0);
#else
				u_xlat16_21 = clamp(u_xlat16_21, 0.0, 1.0);
#endif
				u_xlat16_24 = sqrt(u_xlat16_24);
				u_xlat16_24 = log2(u_xlat16_24);
				u_xlat16_24 = u_xlat16_24 * _SpecularGloss1;
				u_xlat16_24 = exp2(u_xlat16_24);
				u_xlat16_25 = u_xlat16_21 * -2.0 + 3.0;
				u_xlat16_21 = u_xlat16_21 * u_xlat16_21;
				u_xlat16_21 = u_xlat16_21 * u_xlat16_25;
				u_xlat16_21 = u_xlat16_21 * u_xlat16_24;
				u_xlat16_21 = min(u_xlat16_21, 1.0);
				u_xlat16_4.xyz = u_xlat16_21 * _SpecularColor1.xyz + u_xlat16_4.xyz;
				u_xlat16_21 = dot(u_xlat16_0.xyz, u_xlat16_0.xyz);
				u_xlat16_21 = 1.0 / sqrt(u_xlat16_21);
				u_xlat16_0.xyz = u_xlat16_21 * u_xlat16_0.xyz;
				u_xlat16_0.x = dot(u_xlat16_3.xyz, u_xlat16_0.xyz);
#ifdef UNITY_ADRENO_ES3
				u_xlat16_0.x = min(max(u_xlat16_0.x, 0.0), 1.0);
#else
				u_xlat16_0.x = clamp(u_xlat16_0.x, 0.0, 1.0);
#endif
				u_xlat16_0.x = log2(u_xlat16_0.x);
				u_xlat16_0.x = u_xlat16_0.x * _LaserPower;
				u_xlat16_0.x = exp2(u_xlat16_0.x);
				u_xlat16_0.y = 1.0;
				u_xlat16_1.xyz = tex2D(_Lasermap, u_xlat16_0.xy).xyz;
				u_xlat16_0.x = (-_LaserIntensity) + 1.0;
				u_xlat16_0.xyz = u_xlat16_1.xyz * _LaserIntensity + u_xlat16_0.xxx;
				u_xlat16_1 = tex2D(_Basemap, IN.uv.xy);
				u_xlat1 = u_xlat16_1 * _BaseColor;
				u_xlat16_4.xyz = u_xlat1.xyz * u_xlat16_0.xyz + u_xlat16_4.xyz;
				u_xlat16_0.xyz = u_xlat16_0.xyz * u_xlat1.xyz;

				float4 result;
				result.w = u_xlat1.w;
#ifdef UNITY_ADRENO_ES3
				result.w = min(max(result.w, 0.0), 1.0);
#else
				result.w = clamp(result.w, 0.0, 1.0);
#endif
				u_xlat16_21 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
				u_xlat16_21 = max(u_xlat16_21, _AmbientSkyColor.x);
				u_xlat16_21 = (-u_xlat16_21) + 3.0;
				u_xlat16_24 = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
				u_xlat16_24 = max(u_xlat16_24, _AmbientGroundColor.x);
				u_xlat16_21 = u_xlat16_21 + (-u_xlat16_24);
#ifdef UNITY_ADRENO_ES3
				u_xlat16_21 = min(max(u_xlat16_21, 0.0), 1.0);
#else
				u_xlat16_21 = clamp(u_xlat16_21, 0.0, 1.0);
#endif
				u_xlat16_24 = -abs(u_xlat16_3.y) + 1.60000002;
#ifdef UNITY_ADRENO_ES3
				u_xlat16_24 = min(max(u_xlat16_24, 0.0), 1.0);
#else
				u_xlat16_24 = clamp(u_xlat16_24, 0.0, 1.0);
#endif
				u_xlat16_21 = u_xlat16_21 * u_xlat16_24;
				u_xlat16_5.xyz = u_xlat16_21 * _AmbientEquatorColor.xyz;
				u_xlat16_6.xy = u_xlat16_3.yy * float2(0.699999988, -0.699999988) + float2(0.300000012, 0.300000012);
#ifdef UNITY_ADRENO_ES3
				u_xlat16_6.xy = min(max(u_xlat16_6.xy, 0.0), 1.0);
#else
				u_xlat16_6.xy = clamp(u_xlat16_6.xy, 0.0, 1.0);
#endif
				u_xlat16_21 = dot(u_xlat16_3.xyz, _MainLightPosition.xyz);
#ifdef UNITY_ADRENO_ES3
				u_xlat16_21 = min(max(u_xlat16_21, 0.0), 1.0);
#else
				u_xlat16_21 = clamp(u_xlat16_21, 0.0, 1.0);
#endif
				u_xlat16_21 = u_xlat16_21 * unity_LightData.z;
				u_xlat16_3.xyz = u_xlat16_21 * _MainLightColor.xyz;
				u_xlat16_5.xyz = _AmbientSkyColor.xyz * u_xlat16_6.xxx + u_xlat16_5.xyz;
				u_xlat16_5.xyz = _AmbientGroundColor.xyz * u_xlat16_6.yyy + u_xlat16_5.xyz;
				u_xlat16_5.xyz = u_xlat16_5.xyz * _AmbientIntensity;
				u_xlat16_5.xyz = u_xlat16_5.xyz * float3(0.300000012, 0.300000012, 0.300000012);
				u_xlat16_0.xyz = u_xlat16_0.xyz * u_xlat16_5.xyz;
				
				result.rgb = u_xlat16_4.xyz * u_xlat16_3.xyz + u_xlat16_0.xyz;
				return result;
			}
			ENDHLSL
		}
		}
}

