// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/Fabric_TwoSided"
{
  Properties
  {
    [KeywordEnum(Standard, Fabric)] _LightingMode ("Lighting Mode", float) = 0
    [MaterialEnum(Opaque, 0, Transparent, 1, AlphaTest, 2, Transparent_ZWriteON, 3)] _SurfaceType ("Surface Type", float) = 0
    [MaterialEnum(Back, 2, Off, 0)] _CullMode ("Cull Mode", float) = 2
    [Toggle(NORMAL_ON)] _NormalOn ("Normal On", float) = 1
    [Toggle(SPECULAR_ON)] _SpecularOn ("Specular On", float) = 1
    [Toggle(RIMLIGHT_ON)] _RimLightOn ("RimLight On", float) = 1
    [Space] _Basemap ("Base map", 2D) = "white" {}
    _BaseColor ("Base Color", Color) = (0.5,0.5,0.5,1)
    [HDR] _ShadowColor ("Shadow Color", Color) = (0,0,0,1)
    _Normalmap ("Normal map", 2D) = "bump" {}
    _NormalScale ("Normal Scale", Range(0, 2)) = 1
    _Mask0 ("Mask 0", 2D) = "white" {}
    _Metallic ("Metallic", Range(0, 1)) = 1
    _Smoothness ("Smoothness", Range(0, 1)) = 1
    _Occlusion ("Occlusion", Range(0, 1)) = 1
    [Header(Fabric Param)] [Space] _SpecularColor ("Specular Color", Color) = (1,1,1,1)
    _SpecIntensity ("Specular Intensity", Range(0, 10)) = 1
    _ScatterColor ("Scatter Color", Color) = (0,0,0,0)
    _ScatterScale ("Scatter Scale", Range(0, 0.5)) = 0
    [Space] _Mask1 ("Mask 1", 2D) = "white" {}
    [Header(Detail Param)] [Space] [Toggle(DETAIL_ENABLE)] _DetailEnable ("Detail Enable", float) = 0
    _Detailmap ("Detail map", 2D) = "bump" {}
    _DetailScale ("Detail Scale", Range(0, 5)) = 1
    [Space] [Toggle(DETAILNOR_ENABLE)] _DetailNorEnable ("Detail Normal Enable", float) = 0
    _DetailNormal ("Detail Normal", 2DArray) = "bump" {}
    _DetailNorScale ("DetailNor Scale", Range(0, 5)) = 1
    _DetailNorIndexABCD ("DetailNor Index ABCD", Vector) = (0,0,0,0)
    _DetailNorTilingAB ("DetailNor Tiling AB", Vector) = (1,1,1,1)
    _DetailNorTilingCD ("DetailNor Tiling CD", Vector) = (1,1,1,1)
    _DetailNorScaleABCD ("DetailNor Scale ABCD", Vector) = (1,1,1,1)
    _DetailTexture ("Detail Texture", 2DArray) = "black" {}
    _DetailTexIndexABCD ("DetailNor Index ABCD", Vector) = (0,0,0,0)
    _DetailTexTilingAB ("DetailTex Tiling AB", Vector) = (1,1,1,1)
    _DetailTexTilingCD ("DetailTex Tiling CD", Vector) = (1,1,1,1)
    _DetailTexAlphaABCD ("Detail Alpha ABCD", Vector) = (1,1,1,1)
    _DetailTexBlendModeABCD ("Detail BlendMode ABCD", Vector) = (0,0,0,0)
    _DetailTexMetallicABCD ("Detail Metallic ABCD", Vector) = (1,1,1,1)
    _DetailTexSmoothnessABCD ("Detail Smoothness ABCD", Vector) = (1,1,1,1)
    [Header(Silk Param)] [Space] [Toggle(SILK_ENABLE)] _SilkEnable ("Silk Enable", float) = 0
    _Anisotropy ("Anisotropy", Range(0, 1)) = 0.75
    _Anisotropy2 ("Anisotropy", Range(0, 1)) = 0.75
    [HDR] _AnisoColor ("Aniso Color", Color) = (1,1,1,1)
    [HDR] _AnisoColor2 ("Aniso Color", Color) = (1,1,1,1)
    [Toggle(SILK_USE_FLOWMAP)] _SilkUseFlowmap ("Silk Use Flowmap", float) = 0
    _Flowmap ("Silk Flowmap", 2D) = "white" {}
    _AnisoDirection ("Aniso Direction", Range(0, 1)) = 0.5
    _AnisoDirection2 ("Aniso Direction", Range(0, 1)) = 0
    [Header(Twinkle Param)] [Space] [Toggle(TWINKLE_ENABLE)] _TwinkleEnable ("Twinkle Enable", float) = 0
    [MaterialEnum(Shapeless, 0, Shape, 1, shine, 2)] _TwinkleType ("Twinkle Type", float) = 0
    _Twinklemap ("Twinkle map", 2D) = "black" {}
    [HDR] _TwinkleColor ("Twinkle Color", Color) = (1,1,1,1)
    _TwinkleSize ("Twinkle Size", Range(0, 40)) = 6
    _TwinklePower ("Twinkle Power", Range(1, 20)) = 18
    _TwinkleIntensity ("Twinkle Intensity", Range(0, 1)) = 0.15
    _ShiningSpeed ("Shining Speed", Range(0, 0.5)) = 0.1
    _ShineMask ("闪点筛选", Range(0, 1)) = 0.5
    _ShineIntensity ("闪点亮度1", Range(0, 400)) = 1
    _ShineIntensity2 ("闪点亮度2", Range(0, 400)) = 1
    _DiamondCol ("DiamondCol", Color) = (1,1,1,1)
    _DiamondCol2 ("DiamondCol2", Color) = (1,1,1,1)
    _DiamondCol3 ("DiamondCol3", Color) = (1,1,1,1)
    _Power1 ("Power1", Range(0.1, 100)) = 20
    _Power2 ("Power2", Range(0.1, 100)) = 20
    _RotateRate ("RotateRate", Range(0, 20)) = 2
    [Header(Half Rim Light)] [Space] [MaterialEnum(Off, 0, CustomDir, 1, CommonDir, 2)] _HalfRimLightState ("Half Rim Light State", float) = 0
    _HalfRimLightColor ("Half Rim Light Color", Color) = (1,1,1,1)
    _HalfRimLightDir ("Half Rim Light Direction", Vector) = (-1,0.5,0,0)
    _HalfRimLightPower ("Half Rim Light Power", Range(1, 10)) = 2
    _HalfRimLightIntensity ("Half Rim Light Intensity", Range(0, 5)) = 2
    [Header(Environment Lighting)] [Space] _EnvReflIntensity ("Intenisty", Range(0, 0.2)) = 0
    [Header(Emission)] [Space] [SingleLineTexture] _Emissionmap ("Emission Map", 2D) = "black" {}
    [HDR] _Emission ("Emission", Color) = (1,1,1,1)
    [Space(20)] [HideInInspector] _QueueIndex ("__queueindex", float) = 0
    [HideInInspector] _SrcBlend ("__src", float) = 1
    [HideInInspector] _DstBlend ("__dst", float) = 0
    [HideInInspector] _ZWrite ("__zw", float) = 1
    [Header(VFX Global Parameter)] [Space] [Toggle(HUE_ENABLE)] [HideInInspector] _HueEnable ("Enable Hue", float) = 0
    [HideInInspector] _HueColorShift ("Hue Color Shift", Range(0, 1)) = 0
    _VFXNoiseTexture ("Noise Texture(R:Diss; G:Dir Diss; B: Holo", 2D) = "white" {}
    [HideInInspector] _VFXNoiseTextureTiling ("Dissolve Noise Texture Tiling", Vector) = (1,1,0,0)
    [Header(Dissolve Parameter)] [Space] [Toggle(DISSOLVE_ENABLE)] [HideInInspector] _DissolveEnable ("Enable Dissolve", float) = 0
    [HideInInspector] _DissolveCutout ("Dissolve Cutout", Range(-2, 2)) = 0
    [HideInInspector] _DissolveEdgeWidth ("Dissolve Edge Width", Range(0, 1)) = 0
    [HideInInspector] _DissolveEdgeColor ("Dissolve Edge Color", Color) = (1,1,1,1)
    [Header(Directional Dissolve Parameter)] [Toggle(DIRECTIONAL_DISSOLVE_ENABLE)] [HideInInspector] _DirectionalDissolveEnable ("Enable Directional Dissolve", float) = 0
    [HideInInspector] _DissolvePoint ("Dissolve Point", Vector) = (0,0,0,0)
    [HideInInspector] _WorldClipMaxDis ("World Clip Max Distance", float) = 0
    [HideInInspector] _WorldDissolveEdgeWidth ("World Dissolve Edge Width", Range(0, 1)) = 0
    [HideInInspector] _WorldDissolveNoiseIntensity ("World Dissolve Noise Intensity", Range(0, 1)) = 0
    [HideInInspector] _WorldDissolveLerp ("World Dissolve Lerp", Vector) = (0,0,0,0)
    [HideInInspector] _WorldDissolveLerpColor ("World Dissolve Lerp Color", Color) = (1,1,1,1)
    _WorldDissolveEdgeColor ("World Dissolve Edge Color", Color) = (1,1,1,1)
    [Toggle(DISSOLVE_COLOR_TEXTURE_ENABLE)] [HideInInspector] _DissolveColorTextureEnable ("Enable Dissolve Color Texutre", float) = 0
    _WorldDissolveColorTexture ("World Dissolve Color Texture", 2D) = "white" {}
    [HideInInspector] _WorldDissolveColorTextureTiling ("World Dissolve Color Texture Tiling", Vector) = (1,1,0,0)
    [Header(Hologram Parameter)] [Space] [Toggle(HOLOGRAM_ENABLE)] [HideInInspector] _HologramEnable ("Enable Hologram", float) = 0
    [HideInInspector] _HologramTextureTiling ("Hologram Texture Tiling", Vector) = (1,1,0,0)
    [HideInInspector] _ScrollSpeed ("Scroll Speed(X:U Y:V)", Vector) = (0,0,0,1)
    [HideInInspector] _HologramColor ("Hologram Color", Color) = (1,1,1,1)
    [Header(Rim Parameter)] [Toggle(RIM_ENABLE)] [HideInInspector] _RimEnable ("Enable Rim", float) = 0
    [HideInInspector] _RimViewDir ("_RimViewDir", Vector) = (0,0,1,0)
    [HideInInspector] _RimColor ("Rim Color", Color) = (0,0,0,0)
    [HideInInspector] _RimPower ("Rim Power", float) = 0
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Transparent"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Transparent"
    }
    Pass // ind: 1, name: RenderBack
    {
      Name "RenderBack"
      Tags
      { 
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
      ZWrite Off
      Cull Front
      Blend Zero Zero, One One
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile NORMAL_ON RIMLIGHT_ON SPECULAR_ON _LIGHTINGMODE_STANDARD _LOD100
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      #define conv_mxt4x4_3(mat4x4) float4(mat4x4[0].w,mat4x4[1].w,mat4x4[2].w,mat4x4[3].w)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4 _ProjectionParams;
      //uniform float4x4 unity_MatrixVP;
      uniform float4x4 ShadowVP;
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightColor;
      //uniform float3 _WorldSpaceCameraPos;
      uniform float4 _AmbientSkyColor;
      uniform float4 _AmbientEquatorColor;
      uniform float4 _AmbientGroundColor;
      uniform float _AmbientIntensity;
      uniform float _GlobalCubemapRotation;
      uniform float _GlobalCubemapIntensity;
      uniform float4 _GlobalCubemap_HDR;
      uniform float _GlobalBackfaceBrightness;
      uniform sampler2D _Basemap;
      uniform sampler2D _Mask0;
      uniform sampler2D _Emissionmap;
      uniform samplerCUBE _GlobalCubemap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
          float4 texcoord2 :TEXCOORD2;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float4 texcoord7 :TEXCOORD7;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 texcoord :TEXCOORD0;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
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
      float4 u_xlat0;
      float4 u_xlat1;
      float4 u_xlat2;
      float u_xlat16_3;
      float u_xlat12;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat1 = mul(unity_MatrixVP, float4(u_xlat0.xyz,1.0));
          out_v.vertex = u_xlat1;
          out_v.texcoord.xy = TRANSFORM_TEX(in_v.texcoord.xy, _Basemap);
          out_v.texcoord.zw = in_v.texcoord.xy;
          out_v.texcoord1 = float4(0, 0, 0, 0);
          u_xlat2 = (u_xlat0.yyyy * conv_mxt4x4_1(ShadowVP));
          u_xlat2 = ((conv_mxt4x4_0(ShadowVP) * u_xlat0.xxxx) + u_xlat2);
          u_xlat2 = ((conv_mxt4x4_2(ShadowVP) * u_xlat0.zzzz) + u_xlat2);
          out_v.texcoord4.xyz = u_xlat0.xyz;
          u_xlat0 = (u_xlat2 + conv_mxt4x4_3(ShadowVP));
          out_v.texcoord2 = u_xlat0;
          u_xlat0.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat0.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat0.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat12 = dot(u_xlat0.xyz, u_xlat0.xyz);
          u_xlat12 = max(u_xlat12, 0);
          u_xlat16_3 = rsqrt(u_xlat12);
          u_xlat0.xyz = (u_xlat0.xyz * float3(u_xlat16_3, u_xlat16_3, u_xlat16_3));
          out_v.texcoord3.xyz = u_xlat0.xyz;
          u_xlat0.x = (u_xlat1.y * _ProjectionParams.x);
          u_xlat0.w = (u_xlat0.x * 0.5);
          u_xlat0.xz = (u_xlat1.xw * float2(0.5, 0.5));
          u_xlat1.xy = (u_xlat0.zz + u_xlat0.xw);
          out_v.texcoord7 = u_xlat1;
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
      float4 u_xlat0_d;
      float4 u_xlat16_0;
      float2 u_xlatb0;
      float3 u_xlat16_1;
      float3 u_xlat16_2;
      float4 u_xlat16_3_d;
      float3 u_xlat16_4;
      float3 u_xlat16_5;
      float3 u_xlat16_6;
      float3 u_xlat7;
      float3 u_xlat16_9;
      float3 u_xlat16_10;
      float3 u_xlat16_12;
      float u_xlat16_20;
      float u_xlat24;
      float u_xlat16_25;
      float u_xlat16_26;
      float u_xlat16_28;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat0_d.xyz = ((-in_f.texcoord4.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat24 = dot(u_xlat0_d.xyz, u_xlat0_d.xyz);
          u_xlat24 = max(u_xlat24, 0);
          u_xlat16_1.x = rsqrt(u_xlat24);
          u_xlat0_d.xyz = (u_xlat0_d.xyz * u_xlat16_1.xxx);
          u_xlat16_1.x = dot(in_f.texcoord3.xyz, in_f.texcoord3.xyz);
          u_xlat16_1.x = rsqrt(u_xlat16_1.x);
          u_xlat16_1.xyz = (u_xlat16_1.xxx * in_f.texcoord3.xyz);
          u_xlat16_25 = (((gl_FrontFacing)?(4294967295):(uint(0))!=uint(0)))?(1):((-1));
          u_xlat16_1.xyz = (float3(u_xlat16_25, u_xlat16_25, u_xlat16_25) * u_xlat16_1.xyz);
          u_xlat16_25 = dot((-u_xlat0_d.xyz), u_xlat16_1.xyz);
          u_xlat16_25 = (u_xlat16_25 + u_xlat16_25);
          u_xlat16_2.xyz = ((u_xlat16_1.xyz * (-float3(u_xlat16_25, u_xlat16_25, u_xlat16_25))) + (-u_xlat0_d.xyz));
          u_xlat16_25 = dot(u_xlat16_1.xyz, u_xlat0_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_25 = min(max(u_xlat16_25, 0), 1);
          #else
          u_xlat16_25 = clamp(u_xlat16_25, 0, 1);
          #endif
          u_xlat16_25 = ((-u_xlat16_25) + 1);
          u_xlat16_25 = (u_xlat16_25 * u_xlat16_25);
          u_xlat16_25 = (u_xlat16_25 * u_xlat16_25);
          u_xlat16_26 = (_GlobalCubemapRotation * 6.28000021);
          u_xlat16_3_d.x = sin(u_xlat16_26);
          u_xlat16_4.x = cos(u_xlat16_26);
          u_xlat16_5.x = (-u_xlat16_3_d.x);
          u_xlat16_5.y = u_xlat16_4.x;
          u_xlat16_5.z = u_xlat16_3_d.x;
          u_xlat16_3_d.z = dot(u_xlat16_5.zy, u_xlat16_2.xz);
          u_xlat16_3_d.x = dot(u_xlat16_5.yx, u_xlat16_2.xz);
          u_xlat16_3_d.y = u_xlat16_2.y;
          u_xlat16_0.xyz = tex2D(_Mask0, in_f.texcoord.xy).xyz;
          u_xlat16_2.x = (((-u_xlat16_0.y) * _Smoothness) + 1);
          u_xlat16_10.x = (((-u_xlat16_2.x) * 0.699999988) + 1.70000005);
          u_xlat16_10.x = (u_xlat16_10.x * u_xlat16_2.x);
          u_xlat16_2.x = (u_xlat16_2.x * u_xlat16_2.x);
          u_xlat16_2.x = max(u_xlat16_2.x, 0.0078125);
          u_xlat16_2.x = ((u_xlat16_2.x * u_xlat16_2.x) + 1);
          u_xlat16_2.x = (float(1) / u_xlat16_2.x);
          u_xlat16_10.x = (u_xlat16_10.x * 6);
          u_xlat16_3_d = texCUBE(_GlobalCubemap, float4(u_xlat16_3_d.xyz, u_xlat16_10.x));
          u_xlat16_10.x = (u_xlat16_3_d.w + (-1));
          u_xlat16_10.x = ((_GlobalCubemap_HDR.w * u_xlat16_10.x) + 1);
          u_xlat16_10.x = max(u_xlat16_10.x, 0);
          u_xlat16_10.x = log2(u_xlat16_10.x);
          u_xlat16_10.x = (u_xlat16_10.x * _GlobalCubemap_HDR.y);
          u_xlat16_10.x = exp2(u_xlat16_10.x);
          u_xlat16_10.x = (u_xlat16_10.x * _GlobalCubemap_HDR.x);
          u_xlat16_10.xyz = (u_xlat16_3_d.xyz * u_xlat16_10.xxx);
          u_xlat16_4.x = ((-_Occlusion) + 1);
          u_xlat16_4.x = ((u_xlat16_0.z * _Occlusion) + u_xlat16_4.x);
          u_xlat16_10.xyz = (u_xlat16_10.xyz * u_xlat16_4.xxx);
          u_xlat16_10.xyz = (u_xlat16_10.xyz * float3(float3(_GlobalCubemapIntensity, _GlobalCubemapIntensity, _GlobalCubemapIntensity)));
          u_xlat16_12.x = (u_xlat16_0.x * _Metallic);
          u_xlat16_20 = (((-u_xlat16_12.x) * 0.959999979) + 0.959999979);
          u_xlat16_28 = ((u_xlat16_0.y * _Smoothness) + (-u_xlat16_20));
          u_xlat16_28 = (u_xlat16_28 + 1);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_28 = min(max(u_xlat16_28, 0), 1);
          #else
          u_xlat16_28 = clamp(u_xlat16_28, 0, 1);
          #endif
          u_xlat16_0 = tex2D(_Basemap, in_f.texcoord.xy);
          u_xlat16_5.xyz = ((u_xlat16_0.xyz * _BaseColor.xyz) + float3(-0.0399999991, (-0.0399999991), (-0.0399999991)));
          u_xlat0_d = (u_xlat16_0 * _BaseColor);
          u_xlat16_5.xyz = ((u_xlat16_12.xxx * u_xlat16_5.xyz) + float3(0.0399999991, 0.0399999991, 0.0399999991));
          u_xlat16_6.xyz = (float3(u_xlat16_28, u_xlat16_28, u_xlat16_28) + (-u_xlat16_5.xyz));
          u_xlat16_5.xyz = ((float3(u_xlat16_25, u_xlat16_25, u_xlat16_25) * u_xlat16_6.xyz) + u_xlat16_5.xyz);
          u_xlat7.xyz = (u_xlat16_2.xxx * u_xlat16_5.xyz);
          u_xlat16_2.xyz = (u_xlat16_10.xyz * u_xlat7.xyz);
          u_xlat16_25 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
          u_xlat16_25 = max(u_xlat16_25, _AmbientSkyColor.x);
          u_xlat16_25 = ((-u_xlat16_25) + 3);
          u_xlat16_26 = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
          u_xlat16_26 = max(u_xlat16_26, _AmbientGroundColor.x);
          u_xlat16_25 = (u_xlat16_25 + (-u_xlat16_26));
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_25 = min(max(u_xlat16_25, 0), 1);
          #else
          u_xlat16_25 = clamp(u_xlat16_25, 0, 1);
          #endif
          u_xlat16_26 = ((-abs(u_xlat16_1.y)) + 1.60000002);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_26 = min(max(u_xlat16_26, 0), 1);
          #else
          u_xlat16_26 = clamp(u_xlat16_26, 0, 1);
          #endif
          u_xlat16_25 = (u_xlat16_25 * u_xlat16_26);
          u_xlat16_5.xyz = (float3(u_xlat16_25, u_xlat16_25, u_xlat16_25) * _AmbientEquatorColor.xyz);
          u_xlat16_12.xz = ((u_xlat16_1.yy * float2(0.699999988, (-0.699999988))) + float2(0.300000012, 0.300000012));
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_12.xz = min(max(u_xlat16_12.xz, 0), 1);
          #else
          u_xlat16_12.xz = clamp(u_xlat16_12.xz, 0, 1);
          #endif
          u_xlat16_1.x = dot(u_xlat16_1.xyz, _MainLightPosition.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_1.x = min(max(u_xlat16_1.x, 0), 1);
          #else
          u_xlat16_1.x = clamp(u_xlat16_1.x, 0, 1);
          #endif
          u_xlat16_9.xyz = ((_AmbientSkyColor.xyz * u_xlat16_12.xxx) + u_xlat16_5.xyz);
          u_xlat16_9.xyz = ((_AmbientGroundColor.xyz * u_xlat16_12.zzz) + u_xlat16_9.xyz);
          u_xlat16_9.xyz = (u_xlat16_9.xyz * float3(_AmbientIntensity, _AmbientIntensity, _AmbientIntensity));
          u_xlat16_9.xyz = (u_xlat16_4.xxx * u_xlat16_9.xyz);
          u_xlat16_4.xyz = (float3(u_xlat16_20, u_xlat16_20, u_xlat16_20) * u_xlat0_d.xyz);
          u_xlat16_26 = min(u_xlat0_d.w, 1);
          u_xlat16_9.xyz = (u_xlat16_9.xyz * u_xlat16_4.xyz);
          u_xlat16_9.xyz = ((u_xlat16_9.xyz * float3(0.300000012, 0.300000012, 0.300000012)) + u_xlat16_2.xyz);
          u_xlat16_2.x = ((-u_xlat16_1.x) + 1);
          u_xlat16_1.x = ((_GlobalBackfaceBrightness * u_xlat16_2.x) + u_xlat16_1.x);
          u_xlat16_1.x = (u_xlat16_1.x * unity_LightData.z);
          u_xlat16_2.xyz = (u_xlat16_1.xxx * _MainLightColor.xyz);
          u_xlat16_1.xyz = ((u_xlat16_4.xyz * u_xlat16_2.xyz) + u_xlat16_9.xyz);
          u_xlat16_0.xyz = tex2D(_Emissionmap, in_f.texcoord.xy).xyz;
          u_xlat16_1.xyz = ((u_xlat16_0.xyz * _Emission.xyz) + u_xlat16_1.xyz);
          out_f.color.xyz = min(u_xlat16_1.xyz, float3(4, 4, 4));
          u_xlatb0.xy = bool4(float4(float4(_SurfaceType, _SurfaceType, _SurfaceType, _SurfaceType)) != float4(1, 3, 0, 0)).xy;
          u_xlatb0.x = (u_xlatb0.y && u_xlatb0.x);
          out_f.color.w = (u_xlatb0.x)?(1):(u_xlat16_26);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: RenderFront
    {
      Name "RenderFront"
      Tags
      { 
        "LIGHTMODE" = "SRPDEFAULTUNLIT"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
      ZWrite Off
      Blend Zero Zero, SrcAlpha One
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile NORMAL_ON RIMLIGHT_ON SPECULAR_ON _LIGHTINGMODE_STANDARD _LOD100
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      #define conv_mxt4x4_3(mat4x4) float4(mat4x4[0].w,mat4x4[1].w,mat4x4[2].w,mat4x4[3].w)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4 _ProjectionParams;
      //uniform float4x4 unity_MatrixVP;
      uniform float4x4 ShadowVP;
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightColor;
      //uniform float3 _WorldSpaceCameraPos;
      uniform float4 _AmbientSkyColor;
      uniform float4 _AmbientEquatorColor;
      uniform float4 _AmbientGroundColor;
      uniform float _AmbientIntensity;
      uniform float _GlobalCubemapRotation;
      uniform float _GlobalCubemapIntensity;
      uniform float4 _GlobalCubemap_HDR;
      uniform float _GlobalBackfaceBrightness;
      uniform sampler2D _Basemap;
      uniform sampler2D _Mask0;
      uniform sampler2D _Emissionmap;
      uniform samplerCUBE _GlobalCubemap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
          float4 texcoord2 :TEXCOORD2;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float4 texcoord7 :TEXCOORD7;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 texcoord :TEXCOORD0;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
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
      float4 u_xlat0;
      float4 u_xlat1;
      float4 u_xlat2;
      float u_xlat16_3;
      float u_xlat12;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat1 = mul(unity_MatrixVP, float4(u_xlat0.xyz,1.0));
          out_v.vertex = u_xlat1;
          out_v.texcoord.xy = TRANSFORM_TEX(in_v.texcoord.xy, _Basemap);
          out_v.texcoord.zw = in_v.texcoord.xy;
          out_v.texcoord1 = float4(0, 0, 0, 0);
          u_xlat2 = (u_xlat0.yyyy * conv_mxt4x4_1(ShadowVP));
          u_xlat2 = ((conv_mxt4x4_0(ShadowVP) * u_xlat0.xxxx) + u_xlat2);
          u_xlat2 = ((conv_mxt4x4_2(ShadowVP) * u_xlat0.zzzz) + u_xlat2);
          out_v.texcoord4.xyz = u_xlat0.xyz;
          u_xlat0 = (u_xlat2 + conv_mxt4x4_3(ShadowVP));
          out_v.texcoord2 = u_xlat0;
          u_xlat0.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat0.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat0.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat12 = dot(u_xlat0.xyz, u_xlat0.xyz);
          u_xlat12 = max(u_xlat12, 0);
          u_xlat16_3 = rsqrt(u_xlat12);
          u_xlat0.xyz = (u_xlat0.xyz * float3(u_xlat16_3, u_xlat16_3, u_xlat16_3));
          out_v.texcoord3.xyz = u_xlat0.xyz;
          u_xlat0.x = (u_xlat1.y * _ProjectionParams.x);
          u_xlat0.w = (u_xlat0.x * 0.5);
          u_xlat0.xz = (u_xlat1.xw * float2(0.5, 0.5));
          u_xlat1.xy = (u_xlat0.zz + u_xlat0.xw);
          out_v.texcoord7 = u_xlat1;
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
      float4 u_xlat0_d;
      float4 u_xlat16_0;
      float2 u_xlatb0;
      float3 u_xlat16_1;
      float3 u_xlat16_2;
      float4 u_xlat16_3_d;
      float3 u_xlat16_4;
      float3 u_xlat16_5;
      float3 u_xlat16_6;
      float3 u_xlat7;
      float3 u_xlat16_9;
      float3 u_xlat16_10;
      float3 u_xlat16_12;
      float u_xlat16_20;
      float u_xlat24;
      float u_xlat16_25;
      float u_xlat16_26;
      float u_xlat16_28;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat0_d.xyz = ((-in_f.texcoord4.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat24 = dot(u_xlat0_d.xyz, u_xlat0_d.xyz);
          u_xlat24 = max(u_xlat24, 0);
          u_xlat16_1.x = rsqrt(u_xlat24);
          u_xlat0_d.xyz = (u_xlat0_d.xyz * u_xlat16_1.xxx);
          u_xlat16_1.x = dot(in_f.texcoord3.xyz, in_f.texcoord3.xyz);
          u_xlat16_1.x = rsqrt(u_xlat16_1.x);
          u_xlat16_1.xyz = (u_xlat16_1.xxx * in_f.texcoord3.xyz);
          u_xlat16_25 = (((gl_FrontFacing)?(4294967295):(uint(0))!=uint(0)))?(1):((-1));
          u_xlat16_1.xyz = (float3(u_xlat16_25, u_xlat16_25, u_xlat16_25) * u_xlat16_1.xyz);
          u_xlat16_25 = dot((-u_xlat0_d.xyz), u_xlat16_1.xyz);
          u_xlat16_25 = (u_xlat16_25 + u_xlat16_25);
          u_xlat16_2.xyz = ((u_xlat16_1.xyz * (-float3(u_xlat16_25, u_xlat16_25, u_xlat16_25))) + (-u_xlat0_d.xyz));
          u_xlat16_25 = dot(u_xlat16_1.xyz, u_xlat0_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_25 = min(max(u_xlat16_25, 0), 1);
          #else
          u_xlat16_25 = clamp(u_xlat16_25, 0, 1);
          #endif
          u_xlat16_25 = ((-u_xlat16_25) + 1);
          u_xlat16_25 = (u_xlat16_25 * u_xlat16_25);
          u_xlat16_25 = (u_xlat16_25 * u_xlat16_25);
          u_xlat16_26 = (_GlobalCubemapRotation * 6.28000021);
          u_xlat16_3_d.x = sin(u_xlat16_26);
          u_xlat16_4.x = cos(u_xlat16_26);
          u_xlat16_5.x = (-u_xlat16_3_d.x);
          u_xlat16_5.y = u_xlat16_4.x;
          u_xlat16_5.z = u_xlat16_3_d.x;
          u_xlat16_3_d.z = dot(u_xlat16_5.zy, u_xlat16_2.xz);
          u_xlat16_3_d.x = dot(u_xlat16_5.yx, u_xlat16_2.xz);
          u_xlat16_3_d.y = u_xlat16_2.y;
          u_xlat16_0.xyz = tex2D(_Mask0, in_f.texcoord.xy).xyz;
          u_xlat16_2.x = (((-u_xlat16_0.y) * _Smoothness) + 1);
          u_xlat16_10.x = (((-u_xlat16_2.x) * 0.699999988) + 1.70000005);
          u_xlat16_10.x = (u_xlat16_10.x * u_xlat16_2.x);
          u_xlat16_2.x = (u_xlat16_2.x * u_xlat16_2.x);
          u_xlat16_2.x = max(u_xlat16_2.x, 0.0078125);
          u_xlat16_2.x = ((u_xlat16_2.x * u_xlat16_2.x) + 1);
          u_xlat16_2.x = (float(1) / u_xlat16_2.x);
          u_xlat16_10.x = (u_xlat16_10.x * 6);
          u_xlat16_3_d = texCUBE(_GlobalCubemap, float4(u_xlat16_3_d.xyz, u_xlat16_10.x));
          u_xlat16_10.x = (u_xlat16_3_d.w + (-1));
          u_xlat16_10.x = ((_GlobalCubemap_HDR.w * u_xlat16_10.x) + 1);
          u_xlat16_10.x = max(u_xlat16_10.x, 0);
          u_xlat16_10.x = log2(u_xlat16_10.x);
          u_xlat16_10.x = (u_xlat16_10.x * _GlobalCubemap_HDR.y);
          u_xlat16_10.x = exp2(u_xlat16_10.x);
          u_xlat16_10.x = (u_xlat16_10.x * _GlobalCubemap_HDR.x);
          u_xlat16_10.xyz = (u_xlat16_3_d.xyz * u_xlat16_10.xxx);
          u_xlat16_4.x = ((-_Occlusion) + 1);
          u_xlat16_4.x = ((u_xlat16_0.z * _Occlusion) + u_xlat16_4.x);
          u_xlat16_10.xyz = (u_xlat16_10.xyz * u_xlat16_4.xxx);
          u_xlat16_10.xyz = (u_xlat16_10.xyz * float3(float3(_GlobalCubemapIntensity, _GlobalCubemapIntensity, _GlobalCubemapIntensity)));
          u_xlat16_12.x = (u_xlat16_0.x * _Metallic);
          u_xlat16_20 = (((-u_xlat16_12.x) * 0.959999979) + 0.959999979);
          u_xlat16_28 = ((u_xlat16_0.y * _Smoothness) + (-u_xlat16_20));
          u_xlat16_28 = (u_xlat16_28 + 1);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_28 = min(max(u_xlat16_28, 0), 1);
          #else
          u_xlat16_28 = clamp(u_xlat16_28, 0, 1);
          #endif
          u_xlat16_0 = tex2D(_Basemap, in_f.texcoord.xy);
          u_xlat16_5.xyz = ((u_xlat16_0.xyz * _BaseColor.xyz) + float3(-0.0399999991, (-0.0399999991), (-0.0399999991)));
          u_xlat0_d = (u_xlat16_0 * _BaseColor);
          u_xlat16_5.xyz = ((u_xlat16_12.xxx * u_xlat16_5.xyz) + float3(0.0399999991, 0.0399999991, 0.0399999991));
          u_xlat16_6.xyz = (float3(u_xlat16_28, u_xlat16_28, u_xlat16_28) + (-u_xlat16_5.xyz));
          u_xlat16_5.xyz = ((float3(u_xlat16_25, u_xlat16_25, u_xlat16_25) * u_xlat16_6.xyz) + u_xlat16_5.xyz);
          u_xlat7.xyz = (u_xlat16_2.xxx * u_xlat16_5.xyz);
          u_xlat16_2.xyz = (u_xlat16_10.xyz * u_xlat7.xyz);
          u_xlat16_25 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
          u_xlat16_25 = max(u_xlat16_25, _AmbientSkyColor.x);
          u_xlat16_25 = ((-u_xlat16_25) + 3);
          u_xlat16_26 = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
          u_xlat16_26 = max(u_xlat16_26, _AmbientGroundColor.x);
          u_xlat16_25 = (u_xlat16_25 + (-u_xlat16_26));
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_25 = min(max(u_xlat16_25, 0), 1);
          #else
          u_xlat16_25 = clamp(u_xlat16_25, 0, 1);
          #endif
          u_xlat16_26 = ((-abs(u_xlat16_1.y)) + 1.60000002);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_26 = min(max(u_xlat16_26, 0), 1);
          #else
          u_xlat16_26 = clamp(u_xlat16_26, 0, 1);
          #endif
          u_xlat16_25 = (u_xlat16_25 * u_xlat16_26);
          u_xlat16_5.xyz = (float3(u_xlat16_25, u_xlat16_25, u_xlat16_25) * _AmbientEquatorColor.xyz);
          u_xlat16_12.xz = ((u_xlat16_1.yy * float2(0.699999988, (-0.699999988))) + float2(0.300000012, 0.300000012));
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_12.xz = min(max(u_xlat16_12.xz, 0), 1);
          #else
          u_xlat16_12.xz = clamp(u_xlat16_12.xz, 0, 1);
          #endif
          u_xlat16_1.x = dot(u_xlat16_1.xyz, _MainLightPosition.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_1.x = min(max(u_xlat16_1.x, 0), 1);
          #else
          u_xlat16_1.x = clamp(u_xlat16_1.x, 0, 1);
          #endif
          u_xlat16_9.xyz = ((_AmbientSkyColor.xyz * u_xlat16_12.xxx) + u_xlat16_5.xyz);
          u_xlat16_9.xyz = ((_AmbientGroundColor.xyz * u_xlat16_12.zzz) + u_xlat16_9.xyz);
          u_xlat16_9.xyz = (u_xlat16_9.xyz * float3(_AmbientIntensity, _AmbientIntensity, _AmbientIntensity));
          u_xlat16_9.xyz = (u_xlat16_4.xxx * u_xlat16_9.xyz);
          u_xlat16_4.xyz = (float3(u_xlat16_20, u_xlat16_20, u_xlat16_20) * u_xlat0_d.xyz);
          u_xlat16_26 = min(u_xlat0_d.w, 1);
          u_xlat16_9.xyz = (u_xlat16_9.xyz * u_xlat16_4.xyz);
          u_xlat16_9.xyz = ((u_xlat16_9.xyz * float3(0.300000012, 0.300000012, 0.300000012)) + u_xlat16_2.xyz);
          u_xlat16_2.x = ((-u_xlat16_1.x) + 1);
          u_xlat16_1.x = ((_GlobalBackfaceBrightness * u_xlat16_2.x) + u_xlat16_1.x);
          u_xlat16_1.x = (u_xlat16_1.x * unity_LightData.z);
          u_xlat16_2.xyz = (u_xlat16_1.xxx * _MainLightColor.xyz);
          u_xlat16_1.xyz = ((u_xlat16_4.xyz * u_xlat16_2.xyz) + u_xlat16_9.xyz);
          u_xlat16_0.xyz = tex2D(_Emissionmap, in_f.texcoord.xy).xyz;
          u_xlat16_1.xyz = ((u_xlat16_0.xyz * _Emission.xyz) + u_xlat16_1.xyz);
          out_f.color.xyz = min(u_xlat16_1.xyz, float3(4, 4, 4));
          u_xlatb0.xy = bool4(float4(float4(_SurfaceType, _SurfaceType, _SurfaceType, _SurfaceType)) != float4(1, 3, 0, 0)).xy;
          u_xlatb0.x = (u_xlatb0.y && u_xlatb0.x);
          out_f.color.w = (u_xlatb0.x)?(1):(u_xlat16_26);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 3, name: CustomShadowCaster
    {
      Name "CustomShadowCaster"
      Tags
      { 
        "LIGHTMODE" = "CustomShadowCaster"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
      Cull Off
      ColorMask 0
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
      uniform float4 _ShadowBias;
      uniform float3 _LightDirection;
      uniform sampler2D _Basemap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 texcoord :TEXCOORD0;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Frag
      {
          float4 SV_TARGET0 :SV_TARGET0;
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
      float4 u_xlat0;
      float4 u_xlat1;
      float u_xlat16_2;
      float u_xlat9;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat0.xyz = ((_LightDirection.xyz * _ShadowBias.xxx) + u_xlat0.xyz);
          u_xlat1.xyz = (in_v.normal.yyy * conv_mxt4x4_1(unity_ObjectToWorld).xyz);
          u_xlat1.xyz = ((conv_mxt4x4_0(unity_ObjectToWorld).xyz * in_v.normal.xxx) + u_xlat1.xyz);
          u_xlat1.xyz = ((conv_mxt4x4_2(unity_ObjectToWorld).xyz * in_v.normal.zzz) + u_xlat1.xyz);
          u_xlat9 = dot(u_xlat1.xyz, u_xlat1.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          u_xlat1.xyz = (u_xlat1.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          u_xlat9 = dot(_LightDirection.xyz, u_xlat1.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat9 = min(max(u_xlat9, 0), 1);
          #else
          u_xlat9 = clamp(u_xlat9, 0, 1);
          #endif
          u_xlat9 = ((-u_xlat9) + 1);
          u_xlat9 = (u_xlat9 * _ShadowBias.y);
          u_xlat0.xyz = ((u_xlat1.xyz * float3(u_xlat9, u_xlat9, u_xlat9)) + u_xlat0.xyz);
          u_xlat0 = mul(unity_MatrixVP, float4(u_xlat0.xyz,1.0));
          out_v.vertex.z = max((-u_xlat0.w), u_xlat0.z);
          out_v.vertex.xyw = u_xlat0.xyw;
          out_v.texcoord.xy = TRANSFORM_TEX(in_v.texcoord.xy, _Basemap);
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
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
      float u_xlat16_0;
      int u_xlatb0;
      float u_xlat16_1;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0 = tex2D(_Basemap, in_f.texcoord.xy).w;
          u_xlat16_1 = ((u_xlat16_0 * _BaseColor.w) + (-0.100000001));
          #ifdef UNITY_ADRENO_ES3
          u_xlatb0 = (u_xlat16_1<0);
          #else
          u_xlatb0 = (u_xlat16_1<0);
          #endif
          if(u_xlatb0)
          {
              discard;
          }
          out_f.SV_TARGET0 = float4(0, 0, 0, 0);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 4, name: CustomShadowMask
    {
      Name "CustomShadowMask"
      Tags
      { 
        "LIGHTMODE" = "CustomShadowMask"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
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
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightShadowParams;
      uniform float4x4 ShadowVP;
      uniform float4 ShadowMap_TexelSize;
      uniform float _ShadowNormalBias;
      uniform float _ShadowDepthBias;
      uniform sampler2D _Basemap;
      uniform sampler2D ShadowMap;
      uniform sampler2D hlslcc_zcmpShadowMap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float2 texcoord :TEXCOORD0;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float2 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Frag
      {
          float4 SV_TARGET0 :SV_TARGET0;
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
      float4 u_xlat0;
      float4 u_xlat1;
      float u_xlat16_2;
      float u_xlat9;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0 = mul(unity_ObjectToWorld, float4(in_v.vertex.xyz,1.0));
          out_v.vertex = mul(unity_MatrixVP, u_xlat0);
          out_v.texcoord4.xyz = u_xlat0.xyz;
          u_xlat0.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat0.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat0.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          out_v.texcoord3.xyz = (u_xlat0.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          out_v.texcoord.xy = in_v.texcoord.xy;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
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
      float4 u_xlat0_d;
      float u_xlat16_0;
      int u_xlatb0;
      float4 u_xlat1_d;
      float3 u_xlat16_1;
      float4 u_xlat2;
      float4 u_xlat3;
      float4 u_xlat4;
      float4 u_xlat5;
      float4 u_xlat6;
      float u_xlat16_7;
      float3 u_xlat8;
      int u_xlatb8;
      float2 u_xlat18;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0 = tex2D(_Basemap, in_f.texcoord.xy).w;
          u_xlat16_1.x = ((u_xlat16_0 * _BaseColor.w) + (-0.100000001));
          #ifdef UNITY_ADRENO_ES3
          u_xlatb0 = (u_xlat16_1.x<0);
          #else
          u_xlatb0 = (u_xlat16_1.x<0);
          #endif
          if(u_xlatb0)
          {
              discard;
          }
          u_xlat16_1.x = dot(_MainLightPosition.xyz, _MainLightPosition.xyz);
          u_xlat16_1.x = rsqrt(u_xlat16_1.x);
          u_xlat16_1.xyz = (u_xlat16_1.xxx * _MainLightPosition.xyz);
          u_xlat0_d.x = dot(u_xlat16_1.xyz, in_f.texcoord3.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat0_d.x = min(max(u_xlat0_d.x, 0), 1);
          #else
          u_xlat0_d.x = clamp(u_xlat0_d.x, 0, 1);
          #endif
          u_xlat8.xyz = ((u_xlat16_1.xyz * float3(float3(_ShadowDepthBias, _ShadowDepthBias, _ShadowDepthBias))) + in_f.texcoord4.xyz);
          u_xlat0_d.x = ((-u_xlat0_d.x) + 1);
          u_xlat0_d.x = (u_xlat0_d.x * _ShadowNormalBias);
          u_xlat0_d.xyz = ((in_f.texcoord3.xyz * u_xlat0_d.xxx) + u_xlat8.xyz);
          u_xlat0_d.xyz = mul(ShadowVP, u_xlat0_d.xyz);
          u_xlat2.xy = (u_xlat0_d.xy * ShadowMap_TexelSize.zw);
          u_xlat2.xy = round(u_xlat2.xy);
          u_xlat0_d.xy = ((ShadowMap_TexelSize.zw * u_xlat0_d.xy) + (-u_xlat2.xy));
          u_xlat1_d = ((-u_xlat0_d.xyxy) + float4(0.5, 0.5, 1.5, 1.5));
          u_xlat1_d = (u_xlat1_d * u_xlat1_d);
          u_xlat3.zw = (u_xlat1_d.xy * float2(0.5, 0.5));
          u_xlat18.xy = ((u_xlat1_d.zw * float2(0.5, 0.5)) + (-u_xlat3.zw));
          u_xlat4.xy = max((-u_xlat0_d.xy), float2(0, 0));
          u_xlat3.xy = (((-u_xlat4.xy) * u_xlat4.xy) + u_xlat18.xy);
          u_xlat18.xy = max(u_xlat0_d.xy, float2(0, 0));
          u_xlat4 = (u_xlat0_d.xyxy + float4(0.5, 0.5, 1.5, 1.5));
          u_xlat4 = (u_xlat4 * u_xlat4);
          u_xlat5.zw = (u_xlat4.xy * float2(0.5, 0.5));
          u_xlat0_d.xy = ((u_xlat4.zw * float2(0.5, 0.5)) + (-u_xlat5.zw));
          u_xlat5.xy = (((-u_xlat18.xy) * u_xlat18.xy) + u_xlat0_d.xy);
          u_xlat6.y = dot(u_xlat5.xzxz, u_xlat3.yyww);
          u_xlat6.z = dot(u_xlat3.zxzx, u_xlat5.yyww);
          u_xlat6.x = dot(u_xlat3.zxzx, u_xlat3.yyww);
          u_xlat6.w = dot(u_xlat5.xzxz, u_xlat5.yyww);
          u_xlat0_d.xy = ((u_xlat4.xy * float2(0.5, 0.5)) + u_xlat5.xy);
          u_xlat4.xy = (u_xlat5.zw / u_xlat0_d.xy);
          u_xlat0_d.x = dot(u_xlat6, float4(1, 1, 1, 1));
          u_xlat5 = (u_xlat6 / u_xlat0_d.xxxx);
          u_xlat0_d.xy = ((u_xlat1_d.xy * float2(0.5, 0.5)) + u_xlat3.xy);
          u_xlat4.zw = (u_xlat3.xy / u_xlat0_d.xy);
          u_xlat1_d = (u_xlat2.xyxy + u_xlat4.xwzy);
          u_xlat0_d.xy = (u_xlat2.xy + u_xlat4.zw);
          u_xlat2.xy = (u_xlat2.xy + u_xlat4.xy);
          u_xlat2.xy = (u_xlat2.xy + float2(0.5, 0.5));
          u_xlat2.xy = (u_xlat2.xy * ShadowMap_TexelSize.xy);
          float3 txVec0 = float3(u_xlat2.xy, u_xlat0_d.z);
          u_xlat2.w = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec0, 0));
          u_xlat0_d.xy = (u_xlat0_d.xy + float2(-1.5, (-1.5)));
          u_xlat0_d.xy = (u_xlat0_d.xy * ShadowMap_TexelSize.xy);
          float3 txVec1 = float3(u_xlat0_d.xy, u_xlat0_d.z);
          u_xlat2.x = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec1, 0));
          u_xlat1_d = (u_xlat1_d + float4(0.5, (-1.5), (-1.5), 0.5));
          u_xlat1_d = (u_xlat1_d * ShadowMap_TexelSize.xyxy);
          float3 txVec2 = float3(u_xlat1_d.xy, u_xlat0_d.z);
          u_xlat2.y = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec2, 0));
          float3 txVec3 = float3(u_xlat1_d.zw, u_xlat0_d.z);
          u_xlat2.z = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec3, 0));
          u_xlat0_d.x = dot(u_xlat2, u_xlat5);
          u_xlat16_7 = ((-_MainLightShadowParams.x) + 1);
          u_xlat16_7 = ((u_xlat0_d.x * _MainLightShadowParams.x) + u_xlat16_7);
          #ifdef UNITY_ADRENO_ES3
          u_xlatb0 = (0>=u_xlat0_d.z);
          #else
          u_xlatb0 = (0>=u_xlat0_d.z);
          #endif
          #ifdef UNITY_ADRENO_ES3
          u_xlatb8 = (u_xlat0_d.z>=1);
          #else
          u_xlatb8 = (u_xlat0_d.z>=1);
          #endif
          u_xlatb0 = (u_xlatb8 || u_xlatb0);
          u_xlat0_d = (int(u_xlatb0))?(float4(1, 1, 1, 1)):(float4(u_xlat16_7, u_xlat16_7, u_xlat16_7, u_xlat16_7));
          out_f.SV_TARGET0 = u_xlat0_d;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Geometry"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Opaque"
    }
    LOD 10
  }
  FallBack Off
}
