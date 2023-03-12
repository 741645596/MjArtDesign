// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/FresnelAlpha"
{
  Properties
  {
    _Basemap ("Base map", 2D) = "white" {}
    _BaseColor ("Base Color", Color) = (1,1,1,1)
    [NoScaleOffset] _Normalmap ("Normal map", 2D) = "bump" {}
    _NormalScale ("Normal Scale", Range(0, 2)) = 1
    [NoScaleOffset] _Mask0 ("Mask (MSA)", 2D) = "white" {}
    [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
    _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    _Occlusion ("Occlusion", Range(0, 1)) = 1
    _MaximumAlpha ("Maximum Alpha", Range(0, 1)) = 1
    _CubemapAlpha ("Cubemap Alpha", Range(0, 1)) = 1
    _Power ("Power", Range(0, 5)) = 2
    _Intensity ("Intensity", Range(0, 1)) = 0
    [Header(Rim Light)] [Space] _HalfRimLightColor ("Rim Light Color", Color) = (1,1,1,1)
    _HalfRimLightPower ("Rim Light Power", Range(1, 10)) = 2
    _HalfRimLightIntensity ("Rim Light Intensity", Range(0, 5)) = 2
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
      "QUEUE" = "Transparent+10"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Transparent"
    }
    Pass // ind: 1, name: Forward
    {
      Name "Forward"
      Tags
      { 
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Transparent+10"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile _LOD100
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      #define conv_mxt4x4_3(mat4x4) float4(mat4x4[0].w,mat4x4[1].w,mat4x4[2].w,mat4x4[3].w)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_MatrixVP;
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
      uniform float _MaximumAlpha;
      uniform float _CubemapAlpha;
      uniform float _Power;
      uniform float _Intensity;
      uniform sampler2D _Basemap;
      uniform sampler2D _Mask0;
      uniform samplerCUBE _GlobalCubemap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 texcoord :TEXCOORD0;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 texcoord :TEXCOORD0;
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
      float u_xlat16_2;
      float u_xlat9;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat1 = (u_xlat0.yyyy * conv_mxt4x4_1(unity_MatrixVP));
          u_xlat1 = ((conv_mxt4x4_0(unity_MatrixVP) * u_xlat0.xxxx) + u_xlat1);
          u_xlat1 = ((conv_mxt4x4_2(unity_MatrixVP) * u_xlat0.zzzz) + u_xlat1);
          out_v.texcoord4.xyz = u_xlat0.xyz;
          u_xlat0 = (u_xlat1 + conv_mxt4x4_3(unity_MatrixVP));
          out_v.vertex = u_xlat0;
          out_v.texcoord.xy = TRANSFORM_TEX(in_v.texcoord.xy, _Basemap);
          u_xlat0.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat0.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat0.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          u_xlat0.xyz = (u_xlat0.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          out_v.texcoord3.xyz = u_xlat0.xyz;
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
      float3 u_xlat16_1;
      float3 u_xlat16_2_d;
      float4 u_xlat3;
      float4 u_xlat16_3;
      float4 u_xlat16_4;
      float3 u_xlat16_5;
      float3 u_xlat16_6;
      float3 u_xlat7;
      float u_xlat16_9;
      float3 u_xlat16_10;
      float3 u_xlat16_12;
      float u_xlat16_17;
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
          u_xlat16_25 = dot((-u_xlat0_d.xyz), u_xlat16_1.xyz);
          u_xlat16_25 = (u_xlat16_25 + u_xlat16_25);
          u_xlat16_2_d.xyz = ((u_xlat16_1.xyz * (-float3(u_xlat16_25, u_xlat16_25, u_xlat16_25))) + (-u_xlat0_d.xyz));
          u_xlat16_25 = dot(u_xlat16_1.xyz, u_xlat0_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_25 = min(max(u_xlat16_25, 0), 1);
          #else
          u_xlat16_25 = clamp(u_xlat16_25, 0, 1);
          #endif
          u_xlat16_25 = ((-u_xlat16_25) + 1);
          u_xlat16_26 = (_GlobalCubemapRotation * 6.28000021);
          u_xlat16_3.x = sin(u_xlat16_26);
          u_xlat16_4.x = cos(u_xlat16_26);
          u_xlat16_5.x = (-u_xlat16_3.x);
          u_xlat16_5.y = u_xlat16_4.x;
          u_xlat16_5.z = u_xlat16_3.x;
          u_xlat16_3.z = dot(u_xlat16_5.zy, u_xlat16_2_d.xz);
          u_xlat16_3.x = dot(u_xlat16_5.yx, u_xlat16_2_d.xz);
          u_xlat16_3.y = u_xlat16_2_d.y;
          u_xlat16_0.xy = tex2D(_Mask0, in_f.texcoord.xy).xy;
          u_xlat16_2_d.x = (((-u_xlat16_0.y) * _Smoothness) + 1);
          u_xlat16_10.x = (((-u_xlat16_2_d.x) * 0.699999988) + 1.70000005);
          u_xlat16_10.x = (u_xlat16_10.x * u_xlat16_2_d.x);
          u_xlat16_2_d.x = (u_xlat16_2_d.x * u_xlat16_2_d.x);
          u_xlat16_2_d.x = max(u_xlat16_2_d.x, 0.0078125);
          u_xlat16_2_d.x = ((u_xlat16_2_d.x * u_xlat16_2_d.x) + 1);
          u_xlat16_2_d.x = (float(1) / u_xlat16_2_d.x);
          u_xlat16_10.x = (u_xlat16_10.x * 6);
          u_xlat16_3 = texCUBE(_GlobalCubemap, float4(u_xlat16_3.xyz, u_xlat16_10.x));
          u_xlat16_10.x = (u_xlat16_3.w + (-1));
          u_xlat16_10.x = ((_GlobalCubemap_HDR.w * u_xlat16_10.x) + 1);
          u_xlat16_10.x = max(u_xlat16_10.x, 0);
          u_xlat16_10.x = log2(u_xlat16_10.x);
          u_xlat16_10.x = (u_xlat16_10.x * _GlobalCubemap_HDR.y);
          u_xlat16_10.x = exp2(u_xlat16_10.x);
          u_xlat16_10.x = (u_xlat16_10.x * _GlobalCubemap_HDR.x);
          u_xlat16_10.xyz = (u_xlat16_3.xyz * u_xlat16_10.xxx);
          u_xlat16_4.x = (u_xlat16_0.x + (-1));
          u_xlat16_4.x = ((_Occlusion * u_xlat16_4.x) + 1);
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
          u_xlat16_5.xyz = ((u_xlat16_12.xxx * u_xlat16_5.xyz) + float3(0.0399999991, 0.0399999991, 0.0399999991));
          u_xlat16_6.xyz = (float3(u_xlat16_28, u_xlat16_28, u_xlat16_28) + (-u_xlat16_5.xyz));
          u_xlat16_12.x = (u_xlat16_25 * u_xlat16_25);
          u_xlat16_25 = log2(u_xlat16_25);
          u_xlat16_25 = (u_xlat16_25 * _Power);
          u_xlat16_25 = exp2(u_xlat16_25);
          u_xlat16_25 = (u_xlat16_25 + (-_Intensity));
          u_xlat16_12.x = (u_xlat16_12.x * u_xlat16_12.x);
          u_xlat16_5.xyz = ((u_xlat16_12.xxx * u_xlat16_6.xyz) + u_xlat16_5.xyz);
          u_xlat7.xyz = (u_xlat16_2_d.xxx * u_xlat16_5.xyz);
          u_xlat16_2_d.xyz = (u_xlat16_10.xyz * u_xlat7.xyz);
          u_xlat16_26 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
          u_xlat16_26 = max(u_xlat16_26, _AmbientSkyColor.x);
          u_xlat16_26 = ((-u_xlat16_26) + 3);
          u_xlat16_12.x = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
          u_xlat16_12.x = max(u_xlat16_12.x, _AmbientGroundColor.x);
          u_xlat16_26 = (u_xlat16_26 + (-u_xlat16_12.x));
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_26 = min(max(u_xlat16_26, 0), 1);
          #else
          u_xlat16_26 = clamp(u_xlat16_26, 0, 1);
          #endif
          u_xlat16_12.x = ((-abs(u_xlat16_1.y)) + 1.60000002);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_12.x = min(max(u_xlat16_12.x, 0), 1);
          #else
          u_xlat16_12.x = clamp(u_xlat16_12.x, 0, 1);
          #endif
          u_xlat16_26 = (u_xlat16_26 * u_xlat16_12.x);
          u_xlat16_5.xyz = (float3(u_xlat16_26, u_xlat16_26, u_xlat16_26) * _AmbientEquatorColor.xyz);
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
          u_xlat16_5.xyz = ((_AmbientSkyColor.xyz * u_xlat16_12.xxx) + u_xlat16_5.xyz);
          u_xlat16_5.xyz = ((_AmbientGroundColor.xyz * u_xlat16_12.zzz) + u_xlat16_5.xyz);
          u_xlat16_5.xyz = (u_xlat16_5.xyz * float3(_AmbientIntensity, _AmbientIntensity, _AmbientIntensity));
          u_xlat16_4.xyw = (u_xlat16_4.xxx * u_xlat16_5.xyz);
          u_xlat3 = (u_xlat16_0 * _BaseColor);
          u_xlat16_5.xyz = (float3(u_xlat16_20, u_xlat16_20, u_xlat16_20) * u_xlat3.xyz);
          u_xlat16_4.xyz = (u_xlat16_4.xyw * u_xlat16_5.xyz);
          u_xlat16_2_d.xyz = ((u_xlat16_4.xyz * float3(0.300000012, 0.300000012, 0.300000012)) + u_xlat16_2_d.xyz);
          u_xlat16_9 = dot(u_xlat16_2_d.xyz, float3(0.298999995, 0.587000012, 0.114));
          u_xlat16_17 = ((-_Intensity) + 1);
          u_xlat16_17 = (float(1) / u_xlat16_17);
          u_xlat16_17 = (u_xlat16_17 * u_xlat16_25);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_17 = min(max(u_xlat16_17, 0), 1);
          #else
          u_xlat16_17 = clamp(u_xlat16_17, 0, 1);
          #endif
          u_xlat16_25 = ((u_xlat16_17 * (-2)) + 3);
          u_xlat16_17 = (u_xlat16_17 * u_xlat16_17);
          u_xlat16_17 = (u_xlat16_17 * u_xlat16_25);
          u_xlat16_25 = max(u_xlat3.w, _MaximumAlpha);
          u_xlat16_25 = (((-u_xlat16_0.w) * _BaseColor.w) + u_xlat16_25);
          u_xlat16_17 = ((u_xlat16_17 * u_xlat16_25) + u_xlat3.w);
          u_xlat16_9 = ((-u_xlat16_17) + u_xlat16_9);
          u_xlat16_17 = (u_xlat16_17 + u_xlat16_17);
          out_f.color.w = ((_CubemapAlpha * u_xlat16_9) + u_xlat16_17);
          #ifdef UNITY_ADRENO_ES3
          out_f.color.w = min(max(out_f.color.w, 0), 1);
          #else
          out_f.color.w = clamp(out_f.color.w, 0, 1);
          #endif
          u_xlat16_9 = ((-u_xlat16_1.x) + 1);
          u_xlat16_1.x = ((_GlobalBackfaceBrightness * u_xlat16_9) + u_xlat16_1.x);
          u_xlat16_1.x = (u_xlat16_1.x * unity_LightData.z);
          u_xlat16_1.xyz = (u_xlat16_1.xxx * _MainLightColor.xyz);
          out_f.color.xyz = ((u_xlat16_5.xyz * u_xlat16_1.xyz) + u_xlat16_2_d.xyz);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: CustomShadowCaster
    {
      Name "CustomShadowCaster"
      Tags
      { 
        "LIGHTMODE" = "CustomShadowCaster"
        "QUEUE" = "Transparent+10"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
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
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
      };
      
      struct OUT_Data_Vert
      {
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 vertex :Position;
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
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat0.xyz = ((float3(_LightDirection.x, _LightDirection.y, _LightDirection.z) * _ShadowBias.xxx) + u_xlat0.xyz);
          u_xlat1.xyz = (in_v.normal.yyy * conv_mxt4x4_1(unity_ObjectToWorld).xyz);
          u_xlat1.xyz = ((conv_mxt4x4_0(unity_ObjectToWorld).xyz * in_v.normal.xxx) + u_xlat1.xyz);
          u_xlat1.xyz = ((conv_mxt4x4_2(unity_ObjectToWorld).xyz * in_v.normal.zzz) + u_xlat1.xyz);
          u_xlat9 = dot(u_xlat1.xyz, u_xlat1.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          u_xlat1.xyz = (u_xlat1.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          u_xlat9 = dot(float3(_LightDirection.x, _LightDirection.y, _LightDirection.z), u_xlat1.xyz);
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
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          out_f.SV_TARGET0 = float4(0, 0, 0, 0);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
