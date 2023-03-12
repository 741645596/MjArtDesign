// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/Skin_New"
{
  Properties
  {
    [Toggle(NORMAL_ON)] _NormalOn ("Normal On", float) = 1
    [Toggle(RIMLIGHT_ON)] _RimLightOn ("RimLight On", float) = 1
    [Toggle(NORMAL_ENFORCE)] _NormalEnforce ("Normal Enforce", float) = 0
    [Space] _BaseColor ("Base Color", Color) = (1,1,1,1)
    _DesaturateScale ("Desaturate Scale", Range(-1, 1)) = 0
    _Basemap ("Base map", 2D) = "white" {}
    [HDR] _LightColor ("Light Color", Color) = (1,1,1,1)
    _LightRange ("Light Range", Range(0, 0.99)) = 0.99
    _Normalmap ("Normal map", 2D) = "bump" {}
    _NormalScale ("Normal Scale", Range(0, 2)) = 1
    _Configmap ("Config map (MSCA)", 2D) = "white" {}
    [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
    _Smoothness ("Smoothness", Range(0, 1)) = 0.2
    _Occlusion ("Occlusion", Range(0, 1)) = 1
    [Toggle(SPARKLE_ON)] _SparkleOn ("Sparkle On", float) = 0
    _Sparklemap ("Sparkle map", 2D) = "black" {}
    _SparkleControl ("Sparkle Control", Vector) = (1,1,1,1)
    _SparkleLipTransparency ("SparkleLip Transparency", Range(0, 1)) = 1
    [Toggle] _SparkleLipDyeEnable ("SparkleLip DyeEnable", float) = 0
    _SparkleLipDye ("SparkleLip Dye", Color) = (1,1,1,1)
    _SparkleEyeTransparency ("SparkleEye Transparency", Range(0, 1)) = 1
    [Toggle] _SparkleEyeDyeEnable ("SparkleEye DyeEnable", float) = 0
    _SparkleEyeDye ("SparkleEye Dye", Color) = (1,1,1,1)
    _SparkleTattooATransparency ("SparkleTattooA Transparency", Range(0, 1)) = 1
    [Toggle] _SparkleTattooADyeEnable ("SparkleTattooA DyeEnable", float) = 0
    _SparkleTattooADye ("SparkleTattooA Dye", Color) = (1,1,1,1)
    _LipSmoothness ("Lip Smoothness", Range(-1, 1)) = 0
    _EyeSmoothness ("Eye Smoothnes", Range(-1, 1)) = 0
    _TattooASmoothness ("TattooA Smoothness", Range(-1, 1)) = 0
    [Space] _SSS ("Scatter Range", Range(0, 2)) = 1
    _SSSIntensity ("Scatter Intensity", Range(0, 1)) = 0.4
    _Wrap ("Wrap", Range(0, 2)) = 0.7
    _ShadowColor ("Shadow Color", Color) = (0,0,0,1)
    [Header(Half Rim Light)] [Space] [MaterialEnum(Off, 0, CustomDir, 1, CommonDir, 2)] _HalfRimLightState ("Half Rim Light State", float) = 0
    _HalfRimLightColor ("Half Rim Light Color", Color) = (1,1,1,1)
    _HalfRimLightDir ("Half Rim Light Direction", Vector) = (-1,0.5,0,0)
    _HalfRimLightPower ("Half Rim Light Power", Range(1, 10)) = 1
    _HalfRimLightIntensity ("Half Rim Light Intensity", Range(0, 5)) = 1
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
    [HDR] _Emission ("Emission", Color) = (0,0,0,0)
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Geometry+1"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Opaque"
    }
    Pass // ind: 1, name: Forward
    {
      Name "Forward"
      Tags
      { 
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Geometry+1"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Opaque"
      }
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
      uniform sampler2D _Sparklemap;
      uniform sampler2D _SkinProfile;
      //uniform samplerCUBE unity_SpecCube0;
      uniform sampler2D _Basemap;
      uniform sampler2D _Configmap;
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
          float4 texcoord6 :TEXCOORD6;
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
      uniform float _DesaturateScale;
      uniform float4 _LightColor;
      uniform float _LightRange;
      uniform float _NormalScale;
      uniform float _Metallic;
      uniform float _Smoothness;
      uniform float _Occlusion;
      uniform float _SSS;
      uniform float _SSSIntensity;
      uniform float _Wrap;
      uniform float4 _ShadowColor;
      uniform float _HalfRimLightState;
      uniform float4 _HalfRimLightColor;
      uniform float4 _HalfRimLightDir;
      uniform float _HalfRimLightPower;
      uniform float _HalfRimLightIntensity;
      uniform float4 _SparkleControl;
      uniform float _SparkleEyeTransparency;
      uniform float _SparkleLipTransparency;
      uniform float _SparkleTattooATransparency;
      uniform float _LipSmoothness;
      uniform float _EyeSmoothness;
      uniform float _TattooASmoothness;
      uniform float _SparkleLipDyeEnable;
      uniform float _SparkleEyeDyeEnable;
      uniform float _SparkleTattooADyeEnable;
      uniform float4 _SparkleLipDye;
      uniform float4 _SparkleEyeDye;
      uniform float4 _SparkleTattooADye;
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
          out_v.texcoord.zw = float2(0, 0);
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
          out_v.texcoord6 = u_xlat1;
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
      uniform float _DesaturateScale;
      uniform float4 _LightColor;
      uniform float _LightRange;
      uniform float _NormalScale;
      uniform float _Metallic;
      uniform float _Smoothness;
      uniform float _Occlusion;
      uniform float _SSS;
      uniform float _SSSIntensity;
      uniform float _Wrap;
      uniform float4 _ShadowColor;
      uniform float _HalfRimLightState;
      uniform float4 _HalfRimLightColor;
      uniform float4 _HalfRimLightDir;
      uniform float _HalfRimLightPower;
      uniform float _HalfRimLightIntensity;
      uniform float4 _SparkleControl;
      uniform float _SparkleEyeTransparency;
      uniform float _SparkleLipTransparency;
      uniform float _SparkleTattooATransparency;
      uniform float _LipSmoothness;
      uniform float _EyeSmoothness;
      uniform float _TattooASmoothness;
      uniform float _SparkleLipDyeEnable;
      uniform float _SparkleEyeDyeEnable;
      uniform float _SparkleTattooADyeEnable;
      uniform float4 _SparkleLipDye;
      uniform float4 _SparkleEyeDye;
      uniform float4 _SparkleTattooADye;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float u_xlat0_d;
      float4 u_xlat16_0;
      float3 u_xlat1_d;
      float4 u_xlat16_1;
      float3 u_xlat10_1;
      float3 u_xlat16_2;
      float3 u_xlat16_3_d;
      float3 u_xlat16_4;
      float3 u_xlat16_5;
      float3 u_xlat6;
      float3 u_xlat16_7;
      float3 u_xlat16_13;
      float u_xlat16_26;
      float u_xlat16_27;
      float u_xlat16_28;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0.xyz = tex2D(_Basemap, in_f.texcoord.xy).xyz;
          u_xlat1_d.xyz = (u_xlat16_0.xyz * _BaseColor.xyz);
          u_xlat16_2.x = dot(u_xlat1_d.xyz, float3(0.298999995, 0.587000012, 0.114));
          u_xlat16_2.xyz = (((-u_xlat16_0.xyz) * _BaseColor.xyz) + u_xlat16_2.xxx);
          u_xlat16_2.xyz = ((float3(_DesaturateScale, _DesaturateScale, _DesaturateScale) * u_xlat16_2.xyz) + u_xlat1_d.xyz);
          u_xlat16_3_d.xyz = ((u_xlat16_2.xyz * _LightColor.xyz) + (-u_xlat16_2.xyz));
          u_xlat16_26 = ((-_LightRange) + 1);
          u_xlat16_26 = (float(1) / u_xlat16_26);
          u_xlat16_4.xyz = normalize(in_f.texcoord3.xyz);
          u_xlat0_d = dot(_MainLightPosition.xyz, u_xlat16_4.xyz);
          u_xlat0_d = ((u_xlat0_d * 0.5) + 0.469999999);
          u_xlat16_27 = (u_xlat0_d + (-_LightRange));
          u_xlat16_26 = (u_xlat16_26 * u_xlat16_27);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_26 = min(max(u_xlat16_26, 0), 1);
          #else
          u_xlat16_26 = clamp(u_xlat16_26, 0, 1);
          #endif
          u_xlat16_27 = ((u_xlat16_26 * (-2)) + 3);
          u_xlat16_26 = (u_xlat16_26 * u_xlat16_26);
          u_xlat16_26 = (u_xlat16_26 * u_xlat16_27);
          u_xlat16_2.xyz = ((float3(u_xlat16_26, u_xlat16_26, u_xlat16_26) * u_xlat16_3_d.xyz) + u_xlat16_2.xyz);
          u_xlat16_3_d.xyz = (u_xlat16_2.xyz + float3(-0.0399999991, (-0.0399999991), (-0.0399999991)));
          u_xlat16_0 = tex2D(_Configmap, in_f.texcoord.xy);
          u_xlat16_5.xy = (u_xlat16_0.xy * float2(_Metallic, _Smoothness));
          u_xlat16_3_d.xyz = ((u_xlat16_5.xxx * u_xlat16_3_d.xyz) + float3(0.0399999991, 0.0399999991, 0.0399999991));
          u_xlat10_1.xyz = tex2D(_Sparklemap, in_f.texcoord.xy).xyz;
          u_xlat16_26 = ((u_xlat10_1.x * _LipSmoothness) + u_xlat16_5.y);
          u_xlat16_27 = (((-u_xlat16_5.x) * 0.959999979) + 0.959999979);
          u_xlat16_26 = ((u_xlat10_1.y * _EyeSmoothness) + u_xlat16_26);
          u_xlat16_26 = ((u_xlat10_1.z * _TattooASmoothness) + u_xlat16_26);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_26 = min(max(u_xlat16_26, 0), 1);
          #else
          u_xlat16_26 = clamp(u_xlat16_26, 0, 1);
          #endif
          u_xlat16_28 = ((-u_xlat16_27) + u_xlat16_26);
          u_xlat16_26 = ((-u_xlat16_26) + 1);
          u_xlat16_2.xyz = (u_xlat16_2.xyz * float3(u_xlat16_27, u_xlat16_27, u_xlat16_27));
          u_xlat16_27 = (u_xlat16_28 + 1);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_27 = min(max(u_xlat16_27, 0), 1);
          #else
          u_xlat16_27 = clamp(u_xlat16_27, 0, 1);
          #endif
          u_xlat16_5.xyz = ((-u_xlat16_3_d.xyz) + float3(u_xlat16_27, u_xlat16_27, u_xlat16_27));
          u_xlat1_d.xyz = ((-in_f.texcoord4.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat0_d = dot(u_xlat1_d.xyz, u_xlat1_d.xyz);
          u_xlat0_d = max(u_xlat0_d, 0);
          u_xlat16_27 = rsqrt(u_xlat0_d);
          u_xlat1_d.xyz = (u_xlat1_d.xyz * float3(u_xlat16_27, u_xlat16_27, u_xlat16_27));
          u_xlat16_27 = dot(u_xlat16_4.xyz, u_xlat1_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_27 = min(max(u_xlat16_27, 0), 1);
          #else
          u_xlat16_27 = clamp(u_xlat16_27, 0, 1);
          #endif
          u_xlat16_27 = ((-u_xlat16_27) + 1);
          u_xlat16_27 = (u_xlat16_27 * u_xlat16_27);
          u_xlat16_27 = (u_xlat16_27 * u_xlat16_27);
          u_xlat16_3_d.xyz = ((float3(u_xlat16_27, u_xlat16_27, u_xlat16_27) * u_xlat16_5.xyz) + u_xlat16_3_d.xyz);
          u_xlat16_27 = (u_xlat16_26 * u_xlat16_26);
          u_xlat16_27 = max(u_xlat16_27, 0.0078125);
          u_xlat16_27 = ((u_xlat16_27 * u_xlat16_27) + 1);
          u_xlat16_27 = (float(1) / u_xlat16_27);
          u_xlat6.xyz = (u_xlat16_3_d.xyz * float3(u_xlat16_27, u_xlat16_27, u_xlat16_27));
          u_xlat16_3_d.x = dot((-u_xlat1_d.xyz), u_xlat16_4.xyz);
          u_xlat16_3_d.x = (u_xlat16_3_d.x + u_xlat16_3_d.x);
          u_xlat16_3_d.xyz = ((u_xlat16_4.xyz * (-u_xlat16_3_d.xxx)) + (-u_xlat1_d.xyz));
          u_xlat16_27 = (((-u_xlat16_26) * 0.699999988) + 1.70000005);
          u_xlat16_26 = (u_xlat16_26 * u_xlat16_27);
          u_xlat16_26 = (u_xlat16_26 * 6);
          u_xlat16_1 = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float4(u_xlat16_3_d.xyz, u_xlat16_26));
          u_xlat16_26 = (u_xlat16_1.w + (-1));
          u_xlat16_26 = ((unity_SpecCube0_HDR.w * u_xlat16_26) + 1);
          u_xlat16_26 = max(u_xlat16_26, 0);
          u_xlat16_26 = log2(u_xlat16_26);
          u_xlat16_26 = (u_xlat16_26 * unity_SpecCube0_HDR.y);
          u_xlat16_26 = exp2(u_xlat16_26);
          u_xlat16_26 = (u_xlat16_26 * unity_SpecCube0_HDR.x);
          u_xlat16_3_d.xyz = (u_xlat16_1.xyz * float3(u_xlat16_26, u_xlat16_26, u_xlat16_26));
          u_xlat16_26 = ((-_Occlusion) + 1);
          u_xlat16_26 = ((u_xlat16_0.w * _Occlusion) + u_xlat16_26);
          u_xlat16_5.z = (u_xlat16_0.z * _SSS);
          u_xlat16_3_d.xyz = (float3(u_xlat16_26, u_xlat16_26, u_xlat16_26) * u_xlat16_3_d.xyz);
          u_xlat16_3_d.xyz = (u_xlat6.xyz * u_xlat16_3_d.xyz);
          u_xlat16_27 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
          u_xlat16_27 = max(u_xlat16_27, _AmbientSkyColor.x);
          u_xlat16_27 = ((-u_xlat16_27) + 3);
          u_xlat16_28 = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
          u_xlat16_28 = max(u_xlat16_28, _AmbientGroundColor.x);
          u_xlat16_27 = (u_xlat16_27 + (-u_xlat16_28));
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_27 = min(max(u_xlat16_27, 0), 1);
          #else
          u_xlat16_27 = clamp(u_xlat16_27, 0, 1);
          #endif
          u_xlat16_28 = ((-abs(u_xlat16_4.y)) + 1.60000002);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_28 = min(max(u_xlat16_28, 0), 1);
          #else
          u_xlat16_28 = clamp(u_xlat16_28, 0, 1);
          #endif
          u_xlat16_27 = (u_xlat16_27 * u_xlat16_28);
          u_xlat16_7.xyz = (float3(u_xlat16_27, u_xlat16_27, u_xlat16_27) * _AmbientEquatorColor.xyz);
          u_xlat16_13.xz = ((u_xlat16_4.yy * float2(0.699999988, (-0.699999988))) + float2(0.300000012, 0.300000012));
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_13.xz = min(max(u_xlat16_13.xz, 0), 1);
          #else
          u_xlat16_13.xz = clamp(u_xlat16_13.xz, 0, 1);
          #endif
          u_xlat16_27 = dot(u_xlat16_4.xyz, _MainLightPosition.xyz);
          u_xlat16_27 = (u_xlat16_27 + _Wrap);
          u_xlat16_4.xyz = ((_AmbientSkyColor.xyz * u_xlat16_13.xxx) + u_xlat16_7.xyz);
          u_xlat16_4.xyz = ((_AmbientGroundColor.xyz * u_xlat16_13.zzz) + u_xlat16_4.xyz);
          u_xlat16_4.xyz = (u_xlat16_4.xyz * float3(_AmbientIntensity, _AmbientIntensity, _AmbientIntensity));
          u_xlat16_4.xyz = (float3(u_xlat16_26, u_xlat16_26, u_xlat16_26) * u_xlat16_4.xyz);
          u_xlat16_4.xyz = (u_xlat16_2.xyz * u_xlat16_4.xyz);
          u_xlat16_3_d.xyz = ((u_xlat16_4.xyz * float3(0.300000012, 0.300000012, 0.300000012)) + u_xlat16_3_d.xyz);
          u_xlat16_26 = (_Wrap + 1);
          u_xlat16_5.x = (u_xlat16_27 / u_xlat16_26);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_5.x = min(max(u_xlat16_5.x, 0), 1);
          #else
          u_xlat16_5.x = clamp(u_xlat16_5.x, 0, 1);
          #endif
          u_xlat16_0.xyz = tex2D(_SkinProfile, u_xlat16_5.xz).xyz;
          u_xlat16_4.xyz = ((-u_xlat16_5.xxx) + u_xlat16_0.xyz);
          u_xlat16_26 = _SSSIntensity;
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_26 = min(max(u_xlat16_26, 0), 1);
          #else
          u_xlat16_26 = clamp(u_xlat16_26, 0, 1);
          #endif
          u_xlat16_4.xyz = ((float3(u_xlat16_26, u_xlat16_26, u_xlat16_26) * u_xlat16_4.xyz) + u_xlat16_5.xxx);
          u_xlat16_4.xyz = (u_xlat16_4.xyz * unity_LightData.zzz);
          u_xlat16_4.xyz = (u_xlat16_4.xyz * _MainLightColor.xyz);
          out_f.color.xyz = ((u_xlat16_2.xyz * u_xlat16_4.xyz) + u_xlat16_3_d.xyz);
          out_f.color.w = 1;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: CustomShadowMask
    {
      Name "CustomShadowMask"
      Tags
      { 
        "LIGHTMODE" = "CustomShadowMask"
        "QUEUE" = "Geometry+1"
        "RenderPipeline" = "UniversalPipeline"
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
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightShadowParams;
      uniform float4x4 ShadowVP;
      uniform float4 ShadowMap_TexelSize;
      uniform float _ShadowNormalBias;
      uniform float _ShadowDepthBias;
      uniform sampler2D ShadowMap;
      uniform sampler2D hlslcc_zcmpShadowMap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
      };
      
      struct OUT_Data_Vert
      {
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
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
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      float4 u_xlat0_d;
      float3 u_xlat16_0;
      float4 u_xlat1_d;
      int u_xlatb1;
      float4 u_xlat2;
      float4 u_xlat3;
      float4 u_xlat4;
      float4 u_xlat5;
      float4 u_xlat6;
      float u_xlat16_7;
      float3 u_xlat9_d;
      int u_xlatb9;
      float2 u_xlat18;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0.x = dot(_MainLightPosition.xyz, _MainLightPosition.xyz);
          u_xlat16_0.x = rsqrt(u_xlat16_0.x);
          u_xlat16_0.xyz = (u_xlat16_0.xxx * _MainLightPosition.xyz);
          u_xlat1_d.x = dot(u_xlat16_0.xyz, in_f.texcoord3.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat1_d.x = min(max(u_xlat1_d.x, 0), 1);
          #else
          u_xlat1_d.x = clamp(u_xlat1_d.x, 0, 1);
          #endif
          u_xlat9_d.xyz = ((u_xlat16_0.xyz * float3(float3(_ShadowDepthBias, _ShadowDepthBias, _ShadowDepthBias))) + in_f.texcoord4.xyz);
          u_xlat1_d.x = ((-u_xlat1_d.x) + 1);
          u_xlat1_d.x = (u_xlat1_d.x * _ShadowNormalBias);
          u_xlat1_d.xyz = ((in_f.texcoord3.xyz * u_xlat1_d.xxx) + u_xlat9_d.xyz);
          u_xlat1_d.xyz = mul(ShadowVP, u_xlat1_d.xyz);
          u_xlat2.xy = (u_xlat1_d.xy * ShadowMap_TexelSize.zw);
          u_xlat2.xy = round(u_xlat2.xy);
          u_xlat1_d.xy = ((ShadowMap_TexelSize.zw * u_xlat1_d.xy) + (-u_xlat2.xy));
          u_xlat0_d = ((-u_xlat1_d.xyxy) + float4(0.5, 0.5, 1.5, 1.5));
          u_xlat0_d = (u_xlat0_d * u_xlat0_d);
          u_xlat3.zw = (u_xlat0_d.xy * float2(0.5, 0.5));
          u_xlat18.xy = ((u_xlat0_d.zw * float2(0.5, 0.5)) + (-u_xlat3.zw));
          u_xlat4.xy = max((-u_xlat1_d.xy), float2(0, 0));
          u_xlat3.xy = (((-u_xlat4.xy) * u_xlat4.xy) + u_xlat18.xy);
          u_xlat18.xy = max(u_xlat1_d.xy, float2(0, 0));
          u_xlat4 = (u_xlat1_d.xyxy + float4(0.5, 0.5, 1.5, 1.5));
          u_xlat4 = (u_xlat4 * u_xlat4);
          u_xlat5.zw = (u_xlat4.xy * float2(0.5, 0.5));
          u_xlat1_d.xy = ((u_xlat4.zw * float2(0.5, 0.5)) + (-u_xlat5.zw));
          u_xlat5.xy = (((-u_xlat18.xy) * u_xlat18.xy) + u_xlat1_d.xy);
          u_xlat6.y = dot(u_xlat5.xzxz, u_xlat3.yyww);
          u_xlat6.z = dot(u_xlat3.zxzx, u_xlat5.yyww);
          u_xlat6.x = dot(u_xlat3.zxzx, u_xlat3.yyww);
          u_xlat6.w = dot(u_xlat5.xzxz, u_xlat5.yyww);
          u_xlat1_d.xy = ((u_xlat4.xy * float2(0.5, 0.5)) + u_xlat5.xy);
          u_xlat4.xy = (u_xlat5.zw / u_xlat1_d.xy);
          u_xlat1_d.x = dot(u_xlat6, float4(1, 1, 1, 1));
          u_xlat5 = (u_xlat6 / u_xlat1_d.xxxx);
          u_xlat1_d.xy = ((u_xlat0_d.xy * float2(0.5, 0.5)) + u_xlat3.xy);
          u_xlat4.zw = (u_xlat3.xy / u_xlat1_d.xy);
          u_xlat0_d = (u_xlat2.xyxy + u_xlat4.xwzy);
          u_xlat1_d.xy = (u_xlat2.xy + u_xlat4.zw);
          u_xlat2.xy = (u_xlat2.xy + u_xlat4.xy);
          u_xlat2.xy = (u_xlat2.xy + float2(0.5, 0.5));
          u_xlat2.xy = (u_xlat2.xy * ShadowMap_TexelSize.xy);
          float3 txVec0 = float3(u_xlat2.xy, u_xlat1_d.z);
          u_xlat2.w = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec0, 0));
          u_xlat1_d.xy = (u_xlat1_d.xy + float2(-1.5, (-1.5)));
          u_xlat1_d.xy = (u_xlat1_d.xy * ShadowMap_TexelSize.xy);
          float3 txVec1 = float3(u_xlat1_d.xy, u_xlat1_d.z);
          u_xlat2.x = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec1, 0));
          u_xlat0_d = (u_xlat0_d + float4(0.5, (-1.5), (-1.5), 0.5));
          u_xlat0_d = (u_xlat0_d * ShadowMap_TexelSize.xyxy);
          float3 txVec2 = float3(u_xlat0_d.xy, u_xlat1_d.z);
          u_xlat2.y = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec2, 0));
          float3 txVec3 = float3(u_xlat0_d.zw, u_xlat1_d.z);
          u_xlat2.z = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec3, 0));
          u_xlat1_d.x = dot(u_xlat2, u_xlat5);
          u_xlat16_7 = ((-_MainLightShadowParams.x) + 1);
          u_xlat16_7 = ((u_xlat1_d.x * _MainLightShadowParams.x) + u_xlat16_7);
          #ifdef UNITY_ADRENO_ES3
          u_xlatb1 = (0>=u_xlat1_d.z);
          #else
          u_xlatb1 = (0>=u_xlat1_d.z);
          #endif
          #ifdef UNITY_ADRENO_ES3
          u_xlatb9 = (u_xlat1_d.z>=1);
          #else
          u_xlatb9 = (u_xlat1_d.z>=1);
          #endif
          u_xlatb1 = (u_xlatb9 || u_xlatb1);
          u_xlat0_d = (int(u_xlatb1))?(float4(1, 1, 1, 1)):(float4(u_xlat16_7, u_xlat16_7, u_xlat16_7, u_xlat16_7));
          out_f.SV_TARGET0 = u_xlat0_d;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
