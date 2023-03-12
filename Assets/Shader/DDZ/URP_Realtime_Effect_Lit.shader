// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Realtime/Effect/Lit"
{
  Properties
  {
    [Toggle(ALPHATEST_ON)] _AlphaTest ("AlphaTest", float) = 0
    [Space] _Basemap ("Base map", 2D) = "white" {}
    _BaseColor ("Base Color", Color) = (1,1,1,1)
    _AmbientColor ("Ambient Color", Color) = (0.5,0.5,0.5,1)
    [Space(20)] [NoScaleOffset] _Normalmap ("Normal map", 2D) = "bump" {}
    _NormalScale ("Normal Scale", Range(0, 2)) = 1
    [Space(20)] [NoScaleOffset] _Mask0 ("Mask", 2D) = "white" {}
    _Metallic ("Metallic", Range(0, 1)) = 0
    _Smoothness ("Smoothness", Range(0, 1)) = 1
    _Occlusion ("Occlusion", Range(0, 1)) = 1
    [Space] [Header(Cube map)] [Space] [Toggle(ENABLE_CUSTOMCUBEMAP_ON)] _CustomCubemap_On ("Custom Cubemap On", float) = 0
    _CustomCubemap ("Custom Cubemap", Cube) = "" {}
    _CubemapRotation ("Cubemap Rotation", Range(0, 1)) = 0
    _CubemapIntensity ("Cubemap Intensity", Range(0, 5)) = 1
    [Space] [Header(Emission)] [Space] [Toggle(EMISSION_ON)] _Emission_On ("Emission On", float) = 0
    [NoScaleOffset] _EmissionMap ("Emission Map", 2D) = "white" {}
    [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0,0)
    [Space] [Header(Half Rim Light)] [Space] [MaterialEnum(Off, 0, CustomDir, 1, CommonDir, 2)] _HalfRimLightState ("Half Rim Light State", float) = 0
    _HalfRimLightColor ("Half Rim Light Color", Color) = (1,1,1,1)
    _HalfRimLightDir ("Half Rim Light Direction", Vector) = (-1,0.5,0,0)
    _HalfRimLightPower ("Half Rim Light Power", Range(1, 10)) = 2
    _HalfRimLightIntensity ("Half Rim Light Intensity", Range(0, 5)) = 2
  }
  SubShader
  {
    Tags
    { 
      "CanUseSpriteAtlas" = "true"
      "IGNOREPROJECTOR" = "true"
      "QUEUE" = "Geometry"
      "RenderType" = "Opaque"
    }
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "CanUseSpriteAtlas" = "true"
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "BeforePostProcessingUI"
        "QUEUE" = "Geometry"
        "RenderType" = "Opaque"
      }
      // m_ProgramMask = 6
      CGPROGRAM
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_MatrixVP;
      uniform float4x4 ShadowVP;
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightColor;
      //uniform float3 _WorldSpaceCameraPos;
      uniform float3 _CommonHalfRimLightDir;
      uniform float _GlobalCubemapRotation;
      uniform float _GlobalCubemapIntensity;
      uniform float4 _GlobalCubemap_HDR;
      uniform float _GlobalBackfaceBrightness;
      uniform float4 _AmbientColor;
      uniform sampler2D _Basemap;
      uniform sampler2D _Normalmap;
      uniform sampler2D _Mask0;
      uniform samplerCUBE _GlobalCubemap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 tangent :TANGENT0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 texcoord :TEXCOORD0;
          float4 texcoord2 :TEXCOORD2;
          float4 texcoord3 :TEXCOORD3;
          float4 texcoord4 :TEXCOORD4;
          float4 texcoord5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 texcoord :TEXCOORD0;
          float4 texcoord3 :TEXCOORD3;
          float4 texcoord4 :TEXCOORD4;
          float4 texcoord5 :TEXCOORD5;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      uniform UnityPerDraw;
      #endif
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_LODFade;
      //uniform float4 unity_WorldTransformParams;
      uniform float4 unity_LightData;
      uniform float4 unity_LightIndices[2];
      uniform float4 unity_ProbesOcclusion;
      //uniform float4 unity_SpecCube0_HDR;
      // uniform float4 unity_LightmapST;
      // uniform float4 unity_DynamicLightmapST;
      //uniform float4 unity_SHAr;
      //uniform float4 unity_SHAg;
      //uniform float4 unity_SHAb;
      //uniform float4 unity_SHBr;
      //uniform float4 unity_SHBg;
      //uniform float4 unity_SHBb;
      //uniform float4 unity_SHC;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      uniform UnityPerMaterial;
      #endif
      uniform float4 _Basemap_ST;
      uniform float4 _BaseColor;
      uniform float4 _ShadowColor;
      uniform float _NormalScale;
      uniform float _Metallic;
      uniform float _Smoothness;
      uniform float _Occlusion;
      uniform float4 _Emission;
      uniform float4 _SpecularColor;
      uniform float _SpecIntensity;
      uniform float _SurfaceType;
      uniform float4 _ScatterColor;
      uniform float _ScatterScale;
      uniform float4 _Detailmap_ST;
      uniform float _DetailScale;
      uniform float4 _DetailNormal_ST;
      uniform float _DetailNorScale;
      uniform float4 _DetailNorTilingAB;
      uniform float4 _DetailNorTilingCD;
      uniform int4 _DetailNorIndexABCD;
      uniform float4 _DetailNorScaleABCD;
      uniform int4 _DetailTexIndexABCD;
      uniform float4 _DetailTexTilingAB;
      uniform float4 _DetailTexTilingCD;
      uniform float4 _DetailTexAlphaABCD;
      uniform float4 _DetailTexBlendModeABCD;
      uniform float4 _DetailTexMetallicABCD;
      uniform float4 _DetailTexSmoothnessABCD;
      uniform float _Anisotropy;
      uniform float _Anisotropy2;
      uniform float4 _AnisoColor;
      uniform float4 _AnisoColor2;
      uniform float _AnisoDirection;
      uniform float _AnisoDirection2;
      uniform float _TwinkleType;
      uniform float4 _TwinkleColor;
      uniform float _TwinkleSize;
      uniform float _TwinklePower;
      uniform float _TwinkleIntensity;
      uniform float _ShiningSpeed;
      uniform float _ShineMask;
      uniform float _ShineSpeed;
      uniform float _UVFrequency;
      uniform float _ShineIntensity;
      uniform float _ShineIntensity2;
      uniform float4 _DiamondCol;
      uniform float4 _DiamondCol2;
      uniform float4 _DiamondCol3;
      uniform float _Power1;
      uniform float _Power2;
      uniform float _RotateRate;
      uniform float _HalfRimLightState;
      uniform float4 _HalfRimLightColor;
      uniform float4 _HalfRimLightDir;
      uniform float _HalfRimLightPower;
      uniform float _HalfRimLightIntensity;
      uniform float _EnvReflIntensity;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float3 u_xlat0;
      int u_xlatb0;
      float4 u_xlat1;
      float4 u_xlat2;
      float u_xlat16_3;
      float3 u_xlat4;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat1 = mul(unity_MatrixVP, float4(u_xlat0.xyz,1.0));
          out_v.vertex = u_xlat1;
          out_v.texcoord.xy = TRANSFORM_TEX(in_v.texcoord.xy, _Basemap);
          u_xlat1 = mul(ShadowVP, float4(u_xlat0.xyz,1.0));
          out_v.texcoord2 = u_xlat1;
          u_xlat1.w = u_xlat0.x;
          u_xlat2.xyz = (in_v.tangent.yyy * conv_mxt4x4_1(unity_ObjectToWorld).xyz);
          u_xlat2.xyz = ((conv_mxt4x4_0(unity_ObjectToWorld).xyz * in_v.tangent.xxx) + u_xlat2.xyz);
          u_xlat2.xyz = ((conv_mxt4x4_2(unity_ObjectToWorld).xyz * in_v.tangent.zzz) + u_xlat2.xyz);
          u_xlat0.x = dot(u_xlat2.xyz, u_xlat2.xyz);
          u_xlat0.x = max(u_xlat0.x, 0);
          u_xlat16_3 = rsqrt(u_xlat0.x);
          u_xlat1.xyz = (u_xlat2.xyz * float3(u_xlat16_3, u_xlat16_3, u_xlat16_3));
          out_v.texcoord3 = u_xlat1;
          u_xlat2.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat2.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat2.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat0.x = dot(u_xlat2.xyz, u_xlat2.xyz);
          u_xlat0.x = max(u_xlat0.x, 0);
          u_xlat16_3 = rsqrt(u_xlat0.x);
          u_xlat2.xyz = (u_xlat2.xyz * float3(u_xlat16_3, u_xlat16_3, u_xlat16_3));
          u_xlat4.xyz = (u_xlat1.yzx * u_xlat2.zxy);
          u_xlat1.xyz = ((u_xlat2.yzx * u_xlat1.zxy) + (-u_xlat4.xyz));
          #ifdef UNITY_ADRENO_ES3
          u_xlatb0 = (unity_WorldTransformParams.w>=0);
          #else
          u_xlatb0 = (unity_WorldTransformParams.w>=0);
          #endif
          u_xlat0.x = (u_xlatb0)?(1):((-1));
          u_xlat0.x = (u_xlat0.x * in_v.tangent.w);
          u_xlat1.xyz = (u_xlat0.xxx * u_xlat1.xyz);
          u_xlat1.w = u_xlat0.y;
          u_xlat2.w = u_xlat0.z;
          out_v.texcoord5 = u_xlat2;
          out_v.texcoord4 = u_xlat1;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      uniform UnityPerDraw;
      #endif
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_LODFade;
      //uniform float4 unity_WorldTransformParams;
      uniform float4 unity_LightData;
      uniform float4 unity_LightIndices[2];
      uniform float4 unity_ProbesOcclusion;
      //uniform float4 unity_SpecCube0_HDR;
      // uniform float4 unity_LightmapST;
      // uniform float4 unity_DynamicLightmapST;
      //uniform float4 unity_SHAr;
      //uniform float4 unity_SHAg;
      //uniform float4 unity_SHAb;
      //uniform float4 unity_SHBr;
      //uniform float4 unity_SHBg;
      //uniform float4 unity_SHBb;
      //uniform float4 unity_SHC;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      uniform UnityPerMaterial;
      #endif
      uniform float4 _Basemap_ST;
      uniform float4 _BaseColor;
      uniform float4 _ShadowColor;
      uniform float _NormalScale;
      uniform float _Metallic;
      uniform float _Smoothness;
      uniform float _Occlusion;
      uniform float4 _Emission;
      uniform float4 _SpecularColor;
      uniform float _SpecIntensity;
      uniform float _SurfaceType;
      uniform float4 _ScatterColor;
      uniform float _ScatterScale;
      uniform float4 _Detailmap_ST;
      uniform float _DetailScale;
      uniform float4 _DetailNormal_ST;
      uniform float _DetailNorScale;
      uniform float4 _DetailNorTilingAB;
      uniform float4 _DetailNorTilingCD;
      uniform int4 _DetailNorIndexABCD;
      uniform float4 _DetailNorScaleABCD;
      uniform int4 _DetailTexIndexABCD;
      uniform float4 _DetailTexTilingAB;
      uniform float4 _DetailTexTilingCD;
      uniform float4 _DetailTexAlphaABCD;
      uniform float4 _DetailTexBlendModeABCD;
      uniform float4 _DetailTexMetallicABCD;
      uniform float4 _DetailTexSmoothnessABCD;
      uniform float _Anisotropy;
      uniform float _Anisotropy2;
      uniform float4 _AnisoColor;
      uniform float4 _AnisoColor2;
      uniform float _AnisoDirection;
      uniform float _AnisoDirection2;
      uniform float _TwinkleType;
      uniform float4 _TwinkleColor;
      uniform float _TwinkleSize;
      uniform float _TwinklePower;
      uniform float _TwinkleIntensity;
      uniform float _ShiningSpeed;
      uniform float _ShineMask;
      uniform float _ShineSpeed;
      uniform float _UVFrequency;
      uniform float _ShineIntensity;
      uniform float _ShineIntensity2;
      uniform float4 _DiamondCol;
      uniform float4 _DiamondCol2;
      uniform float4 _DiamondCol3;
      uniform float _Power1;
      uniform float _Power2;
      uniform float _RotateRate;
      uniform float _HalfRimLightState;
      uniform float4 _HalfRimLightColor;
      uniform float4 _HalfRimLightDir;
      uniform float _HalfRimLightPower;
      uniform float _HalfRimLightIntensity;
      uniform float _EnvReflIntensity;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float3 u_xlat0_d;
      float4 u_xlat16_0;
      int u_xlatb0_d;
      float3 u_xlat1_d;
      float4 u_xlat16_1;
      float4 u_xlat16_2;
      float4 u_xlat16_3_d;
      float3 u_xlat4_d;
      float4 u_xlat16_5;
      float4 u_xlat6;
      float3 u_xlat16_7;
      float3 u_xlat16_8;
      float3 u_xlat16_9;
      float3 u_xlat16_10;
      float3 u_xlat16_11;
      float3 u_xlat16_12;
      float3 u_xlat16_13;
      float3 u_xlat16_14;
      float3 u_xlat16_15;
      float3 u_xlat16_18;
      float u_xlat16_19;
      float3 u_xlat16_23;
      float u_xlat16_35;
      float u_xlat49;
      float u_xlat16_50;
      float u_xlat16_51;
      float u_xlat16_55;
      float u_xlat16_56;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0 = tex2D(_Mask0, in_f.texcoord.xy);
          u_xlat16_1.xyz = tex2D(_Normalmap, in_f.texcoord.xy).xyz;
          u_xlat16_2.xyz = ((u_xlat16_1.xyz * float3(2, 2, 2)) + float3(-1, (-1), (-1)));
          u_xlat16_2.xy = (u_xlat16_2.xy * float2(_NormalScale, _NormalScale));
          u_xlat16_3_d.xyz = (u_xlat16_2.yyy * in_f.texcoord4.xyz);
          u_xlat16_2.xyw = ((u_xlat16_2.xxx * in_f.texcoord3.xyz) + u_xlat16_3_d.xyz);
          u_xlat16_2.xyz = ((u_xlat16_2.zzz * in_f.texcoord5.xyz) + u_xlat16_2.xyw);
          u_xlat16_3_d.x = in_f.texcoord3.w;
          u_xlat16_3_d.y = in_f.texcoord4.w;
          u_xlat16_3_d.z = in_f.texcoord5.w;
          u_xlat1_d.xyz = ((-u_xlat16_3_d.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat49 = dot(u_xlat1_d.xyz, u_xlat1_d.xyz);
          u_xlat49 = max(u_xlat49, 0);
          u_xlat16_50 = rsqrt(u_xlat49);
          u_xlat4_d.xyz = (u_xlat1_d.xyz * float3(u_xlat16_50, u_xlat16_50, u_xlat16_50));
          u_xlat16_3_d.x = (u_xlat16_0.x * _Metallic);
          u_xlat16_19 = (u_xlat16_0.z + (-1));
          u_xlat16_19 = ((_Occlusion * u_xlat16_19) + 1);
          u_xlat16_5 = tex2D(_Basemap, in_f.texcoord.xy);
          u_xlat6 = (u_xlat16_5 * _BaseColor);
          u_xlat16_35 = (((-u_xlat16_3_d.x) * 0.959999979) + 0.959999979);
          u_xlat16_51 = ((_Smoothness * u_xlat16_0.y) + (-u_xlat16_35));
          u_xlat16_7.xyz = (float3(u_xlat16_35, u_xlat16_35, u_xlat16_35) * u_xlat6.xyz);
          u_xlat16_8.xyz = ((u_xlat16_5.xyz * _BaseColor.xyz) + float3(-0.0399999991, (-0.0399999991), (-0.0399999991)));
          u_xlat16_8.xyz = ((u_xlat16_3_d.xxx * u_xlat16_8.xyz) + float3(0.0399999991, 0.0399999991, 0.0399999991));
          u_xlat16_3_d.x = (((-_Smoothness) * u_xlat16_0.y) + 1);
          u_xlat16_35 = (u_xlat16_3_d.x * u_xlat16_3_d.x);
          u_xlat16_35 = max(u_xlat16_35, 0.0078125);
          u_xlat16_51 = (u_xlat16_51 + 1);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_51 = min(max(u_xlat16_51, 0), 1);
          #else
          u_xlat16_51 = clamp(u_xlat16_51, 0, 1);
          #endif
          u_xlat16_55 = dot(u_xlat16_2.xyz, _MainLightPosition.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_55 = min(max(u_xlat16_55, 0), 1);
          #else
          u_xlat16_55 = clamp(u_xlat16_55, 0, 1);
          #endif
          u_xlat16_56 = ((-u_xlat16_55) + 1);
          u_xlat16_55 = ((_GlobalBackfaceBrightness * u_xlat16_56) + u_xlat16_55);
          u_xlat16_55 = (u_xlat16_55 * unity_LightData.z);
          u_xlat16_9.xyz = (float3(u_xlat16_55, u_xlat16_55, u_xlat16_55) * _MainLightColor.xyz);
          u_xlat16_55 = ((-u_xlat16_3_d.x) + 1);
          u_xlat16_10.xyz = ((u_xlat1_d.xyz * float3(u_xlat16_50, u_xlat16_50, u_xlat16_50)) + _MainLightPosition.xyz);
          u_xlat16_10.xyz = normalize(u_xlat16_10.xyz);
          u_xlat16_50 = dot(u_xlat16_2.xyz, u_xlat16_10.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_50 = min(max(u_xlat16_50, 0), 1);
          #else
          u_xlat16_50 = clamp(u_xlat16_50, 0, 1);
          #endif
          u_xlat16_55 = max(u_xlat16_55, 0.00999999978);
          u_xlat16_55 = (u_xlat16_55 * 32);
          u_xlat16_50 = log2(u_xlat16_50);
          u_xlat16_50 = (u_xlat16_50 * u_xlat16_55);
          u_xlat16_50 = exp2(u_xlat16_50);
          u_xlat16_50 = (u_xlat16_50 + u_xlat16_50);
          u_xlat16_10.xyz = ((float3(u_xlat16_50, u_xlat16_50, u_xlat16_50) * u_xlat16_8.xyz) + u_xlat16_7.xyz);
          u_xlat16_11.xyz = (float3(u_xlat16_19, u_xlat16_19, u_xlat16_19) * _AmbientColor.xyz);
          u_xlat16_50 = dot((-u_xlat4_d.xyz), u_xlat16_2.xyz);
          u_xlat16_50 = (u_xlat16_50 + u_xlat16_50);
          u_xlat16_12.xyz = ((u_xlat16_2.xyz * (-float3(u_xlat16_50, u_xlat16_50, u_xlat16_50))) + (-u_xlat4_d.xyz));
          u_xlat16_50 = (_GlobalCubemapRotation * 6.28000021);
          u_xlat16_13.x = sin(u_xlat16_50);
          u_xlat16_14.x = cos(u_xlat16_50);
          u_xlat16_15.x = (-u_xlat16_13.x);
          u_xlat16_15.y = u_xlat16_14.x;
          u_xlat16_14.x = dot(u_xlat16_15.yx, u_xlat16_12.xz);
          u_xlat16_15.z = u_xlat16_13.x;
          u_xlat16_14.z = dot(u_xlat16_15.zy, u_xlat16_12.xz);
          u_xlat16_50 = (((-u_xlat16_3_d.x) * 0.699999988) + 1.70000005);
          u_xlat16_50 = (u_xlat16_50 * u_xlat16_3_d.x);
          u_xlat16_50 = (u_xlat16_50 * 6);
          u_xlat16_14.y = u_xlat16_12.y;
          u_xlat16_1 = texCUBE(_GlobalCubemap, float4(u_xlat16_14.xyz, u_xlat16_50));
          u_xlat16_50 = (u_xlat16_1.w + (-1));
          u_xlat16_50 = ((_GlobalCubemap_HDR.w * u_xlat16_50) + 1);
          u_xlat16_50 = max(u_xlat16_50, 0);
          u_xlat16_50 = log2(u_xlat16_50);
          u_xlat16_50 = (u_xlat16_50 * _GlobalCubemap_HDR.y);
          u_xlat16_50 = exp2(u_xlat16_50);
          u_xlat16_50 = (u_xlat16_50 * _GlobalCubemap_HDR.x);
          u_xlat16_12.xyz = (u_xlat16_1.xyz * float3(u_xlat16_50, u_xlat16_50, u_xlat16_50));
          u_xlat16_12.xyz = (float3(u_xlat16_19, u_xlat16_19, u_xlat16_19) * u_xlat16_12.xyz);
          u_xlat16_12.xyz = (u_xlat16_12.xyz * float3(float3(_GlobalCubemapIntensity, _GlobalCubemapIntensity, _GlobalCubemapIntensity)));
          u_xlat16_50 = dot(u_xlat16_2.xyz, u_xlat4_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_50 = min(max(u_xlat16_50, 0), 1);
          #else
          u_xlat16_50 = clamp(u_xlat16_50, 0, 1);
          #endif
          u_xlat16_50 = ((-u_xlat16_50) + 1);
          u_xlat16_3_d.x = (u_xlat16_50 * u_xlat16_50);
          u_xlat16_3_d.x = (u_xlat16_3_d.x * u_xlat16_3_d.x);
          u_xlat16_19 = ((u_xlat16_35 * u_xlat16_35) + 1);
          u_xlat16_19 = (float(1) / u_xlat16_19);
          u_xlat16_13.xyz = ((-u_xlat16_8.xyz) + float3(u_xlat16_51, u_xlat16_51, u_xlat16_51));
          u_xlat16_3_d.xzw = ((u_xlat16_3_d.xxx * u_xlat16_13.xyz) + u_xlat16_8.xyz);
          u_xlat0_d.xyz = (u_xlat16_3_d.xzw * float3(u_xlat16_19, u_xlat16_19, u_xlat16_19));
          u_xlat16_3_d.xyz = (u_xlat0_d.xyz * u_xlat16_12.xyz);
          u_xlat16_3_d.xyz = ((u_xlat16_11.xyz * u_xlat16_7.xyz) + u_xlat16_3_d.xyz);
          u_xlat16_3_d.xyz = ((u_xlat16_10.xyz * u_xlat16_9.xyz) + u_xlat16_3_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlatb0_d = (_HalfRimLightState==1);
          #else
          u_xlatb0_d = (_HalfRimLightState==1);
          #endif
          if(u_xlatb0_d)
          {
              u_xlat16_7.xyz = normalize(_HalfRimLightDir.xyz);
              u_xlat16_51 = log2(u_xlat16_50);
              u_xlat16_51 = (u_xlat16_51 * _HalfRimLightPower);
              u_xlat16_51 = exp2(u_xlat16_51);
              u_xlat16_7.x = dot(u_xlat16_2.xyz, u_xlat16_7.xyz);
              u_xlat16_7.x = (u_xlat16_7.x * 0.5);
              #ifdef UNITY_ADRENO_ES3
              u_xlat16_7.x = min(max(u_xlat16_7.x, 0), 1);
              #else
              u_xlat16_7.x = clamp(u_xlat16_7.x, 0, 1);
              #endif
              u_xlat16_23.x = ((u_xlat16_7.x * (-2)) + 3);
              u_xlat16_7.x = (u_xlat16_7.x * u_xlat16_7.x);
              u_xlat16_7.x = (u_xlat16_7.x * u_xlat16_23.x);
              u_xlat16_23.xyz = (float3(u_xlat16_51, u_xlat16_51, u_xlat16_51) * _HalfRimLightColor.xyz);
              u_xlat16_7.xyz = (u_xlat16_7.xxx * u_xlat16_23.xyz);
              u_xlat16_7.xyz = (u_xlat16_7.xyz * float3(float3(_HalfRimLightIntensity, _HalfRimLightIntensity, _HalfRimLightIntensity)));
          }
          else
          {
              #ifdef UNITY_ADRENO_ES3
              u_xlatb0_d = (_HalfRimLightState==2);
              #else
              u_xlatb0_d = (_HalfRimLightState==2);
              #endif
              u_xlat16_50 = log2(u_xlat16_50);
              u_xlat16_50 = (u_xlat16_50 * _HalfRimLightPower);
              u_xlat16_50 = exp2(u_xlat16_50);
              u_xlat16_2.x = dot(u_xlat16_2.xyz, _CommonHalfRimLightDir.xyz);
              u_xlat16_2.x = (u_xlat16_2.x * 0.5);
              #ifdef UNITY_ADRENO_ES3
              u_xlat16_2.x = min(max(u_xlat16_2.x, 0), 1);
              #else
              u_xlat16_2.x = clamp(u_xlat16_2.x, 0, 1);
              #endif
              u_xlat16_18.x = ((u_xlat16_2.x * (-2)) + 3);
              u_xlat16_2.x = (u_xlat16_2.x * u_xlat16_2.x);
              u_xlat16_2.x = (u_xlat16_2.x * u_xlat16_18.x);
              u_xlat16_18.xyz = (float3(u_xlat16_50, u_xlat16_50, u_xlat16_50) * _HalfRimLightColor.xyz);
              u_xlat16_2.xyz = (u_xlat16_2.xxx * u_xlat16_18.xyz);
              u_xlat16_2.xyz = (u_xlat16_2.xyz * float3(float3(_HalfRimLightIntensity, _HalfRimLightIntensity, _HalfRimLightIntensity)));
              u_xlat16_7.xyz = (int(u_xlatb0_d))?(u_xlat16_2.xyz):(float3(0, 0, 0));
          }
          u_xlat16_7.xyz = u_xlat16_7.xyz;
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_7.xyz = min(max(u_xlat16_7.xyz, 0), 1);
          #else
          u_xlat16_7.xyz = clamp(u_xlat16_7.xyz, 0, 1);
          #endif
          out_f.color.xyz = ((u_xlat16_0.www * u_xlat16_7.xyz) + u_xlat16_3_d.xyz);
          out_f.color.w = u_xlat6.w;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
