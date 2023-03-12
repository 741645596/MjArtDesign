// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/Eye_New"
{
  Properties
  {
    _Basemap ("Base map", 2D) = "white" {}
    _Normalmap ("Normal map", 2D) = "bump" {}
    _NormalScale ("Normal Scale", Range(0, 2)) = 1
    [Space(20)] _Metallic ("Metallic", Range(0, 1)) = 0
    _Smoothness ("Smoothness", Range(0, 1)) = 0.9
    _OcclusionStrength ("Occlusion", Range(0, 1)) = 1
    _AmbientColor ("Ambient Color", Color) = (0.8,0.8,0.8,1)
    [Space(20)] _Mask ("Mask", 2D) = "white" {}
    _IrisSize ("Iris Size", Range(0.5, 4)) = 1
    _IrisColor ("Iris Color", Color) = (1,1,1,0)
    _IrisColorAlpha ("Iris Color Alpha", Range(0, 1)) = 0
    _IrisBrightness ("Iris Brightness", Range(0.3, 3)) = 2
    _PupilSize ("Pupil Size", Range(0.2, 2)) = 1
    _ScleraColor ("Sclera Color", Color) = (1,1,1,0)
    _ParallaxHeight ("Parallax Height", Range(0, 0.2)) = 0.003
    [Space(20)] _ReflectionTex1 ("Reflection Tex 1", 2D) = "black" {}
    _ReflColor1 ("Reflection Color 1", Color) = (1,1,1,0)
    _ReflectionAlpha1 ("Reflection Alpha 1", Range(0, 1)) = 0.2
    _ReflOffset1 ("Reflection Offset 1", Vector) = (0,0,0,0)
    [Space(20)] _ReflectionTex2 ("Reflection Tex 2", 2D) = "black" {}
    _ReflColor2 ("Reflection Color 2", Color) = (1,1,1,0)
    _ReflectionAlpha2 ("Reflection Alpha 2", Range(0, 1)) = 0.2
    _ReflOffset2 ("Reflection Offset 2", Vector) = (0,0,0,0)
    [Space(20)] _LensesMap ("Lenses", 2D) = "black" {}
    _LensesAlpha ("Lenses Alpha", Range(0, 1)) = 1
    [HDR] _LensesColor ("Lenses Color", Color) = (1,1,1,0)
    _LensesColorBrightness ("Lenses Color Brightness", Range(1, 5)) = 1
    _LensesColorAlpha ("Lenses Color Alpha", Range(0, 1)) = 0
    _LensesAngle ("Lenses Angle", Range(-1, 1)) = 0
    _LensesOS ("Lenses Offset & Size", Vector) = (0,0,1,1)
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
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Geometry"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Opaque"
    }
    Pass // ind: 1, name: Forward
    {
      Name "Forward"
      Tags
      { 
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Geometry"
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
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_MatrixVP;
      uniform float4x4 ShadowVP;
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightColor;
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixInvV;
      //uniform samplerCUBE unity_SpecCube0;
      uniform sampler2D _Basemap;
      uniform sampler2D _Normalmap;
      uniform sampler2D _Mask;
      uniform sampler2D _ReflectionTex1;
      uniform sampler2D _ReflectionTex2;
      uniform sampler2D _LensesMap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 tangent :TANGENT0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
          float4 texcoord2 :TEXCOORD2;
          float4 texcoord3 :TEXCOORD3;
          float4 texcoord4 :TEXCOORD4;
          float4 texcoord5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 texcoord :TEXCOORD0;
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
      float4 u_xlat0;
      float4 u_xlat1;
      float4 u_xlat2;
      float u_xlat16_3;
      float3 u_xlat4;
      float u_xlat16;
      int u_xlatb16;
      float u_xlat17;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyw = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat1 = mul(unity_MatrixVP, float4(u_xlat0.xyz,1.0));
          out_v.vertex = u_xlat1;
          out_v.texcoord.xy = in_v.texcoord.xy;
          out_v.texcoord.zw = float2(0, 0);
          out_v.texcoord1 = float4(0, 0, 0, 0);
          u_xlat1 = mul(ShadowVP, float4(u_xlat0.xyz,1.0));
          out_v.texcoord2 = u_xlat1;
          u_xlat1.w = u_xlat0.x;
          u_xlat2.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat2.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat2.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat17 = dot(u_xlat2.xyz, u_xlat2.xyz);
          u_xlat17 = max(u_xlat17, 0);
          u_xlat16_3 = rsqrt(u_xlat17);
          u_xlat1.xyz = (u_xlat2.xyz * float3(u_xlat16_3, u_xlat16_3, u_xlat16_3));
          out_v.texcoord3 = u_xlat1;
          u_xlat2.w = u_xlat0.y;
          u_xlat4.xyz = (in_v.tangent.yyy * conv_mxt4x4_1(unity_ObjectToWorld).xyz);
          u_xlat4.xyz = ((conv_mxt4x4_0(unity_ObjectToWorld).xyz * in_v.tangent.xxx) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_2(unity_ObjectToWorld).xyz * in_v.tangent.zzz) + u_xlat4.xyz);
          u_xlat16 = dot(u_xlat4.xyz, u_xlat4.xyz);
          u_xlat16 = max(u_xlat16, 0);
          u_xlat16_3 = rsqrt(u_xlat16);
          u_xlat2.xyz = (float3(u_xlat16_3, u_xlat16_3, u_xlat16_3) * u_xlat4.xyz);
          out_v.texcoord4 = u_xlat2;
          u_xlat4.xyz = (u_xlat1.zxy * u_xlat2.yzx);
          u_xlat1.xyz = ((u_xlat1.yzx * u_xlat2.zxy) + (-u_xlat4.xyz));
          #ifdef UNITY_ADRENO_ES3
          u_xlatb16 = (unity_WorldTransformParams.w>=0);
          #else
          u_xlatb16 = (unity_WorldTransformParams.w>=0);
          #endif
          u_xlat16 = (u_xlatb16)?(1):((-1));
          u_xlat16 = (u_xlat16 * in_v.tangent.w);
          u_xlat0.xyz = (float3(u_xlat16, u_xlat16, u_xlat16) * u_xlat1.xyz);
          out_v.texcoord5 = u_xlat0;
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
      uniform float _NormalScale;
      uniform float _Metallic;
      uniform float _Smoothness;
      uniform float _OcclusionStrength;
      uniform float4 _AmbientColor;
      uniform float _IrisSize;
      uniform float4 _IrisColor;
      uniform float _IrisColorAlpha;
      uniform float _IrisBrightness;
      uniform float _PupilSize;
      uniform float4 _ScleraColor;
      uniform float _ParallaxHeight;
      uniform float _ReflectionAlpha1;
      uniform float4 _ReflColor1;
      uniform float4 _ReflOffset1;
      uniform float _ReflectionAlpha2;
      uniform float4 _ReflColor2;
      uniform float4 _ReflOffset2;
      uniform float4 _LensesColor;
      uniform float _LensesColorBrightness;
      uniform float _LensesColorAlpha;
      uniform float _LensesAlpha;
      uniform float _LensesAngle;
      uniform float4 _LensesOS;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0_d;
      float4 u_xlat16_0;
      float4 u_xlat1_d;
      float4 u_xlat16_1;
      int u_xlatb1;
      float4 u_xlat16_2;
      float3 u_xlat16_3_d;
      float3 u_xlat16_4;
      float3 u_xlat5;
      float2 u_xlat16_5;
      float4 u_xlat16_6;
      float3 u_xlat16_7;
      float3 u_xlat16_8;
      float3 u_xlat9;
      float3 u_xlat10;
      float3 u_xlat11;
      float3 u_xlat16_12;
      float3 u_xlat16_13;
      float3 u_xlat16_14;
      float3 u_xlat16_15;
      float3 u_xlat16_16;
      float u_xlat16_17;
      float u_xlat18;
      float3 u_xlat16_18;
      float u_xlat16_21;
      float2 u_xlat16_34;
      float u_xlat16_36;
      float u_xlat16_54;
      float u_xlat16_55;
      float u_xlat16_57;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0.x = (_PupilSize + (-1));
          #ifdef UNITY_ADRENO_ES3
          u_xlatb1 = (1<_PupilSize);
          #else
          u_xlatb1 = (1<_PupilSize);
          #endif
          u_xlat16_17 = (_PupilSize * _PupilSize);
          u_xlat16_34.x = (_IrisSize + (-1));
          u_xlat16_34.x = (u_xlat16_34.x * 0.5);
          u_xlat16_34.xy = ((in_f.texcoord.xy * float2(_IrisSize, _IrisSize)) + (-u_xlat16_34.xx));
          u_xlat16_2.xy = (u_xlat16_34.xy + float2(-0.5, (-0.5)));
          u_xlat16_36 = length(u_xlat16_2.xy);
          u_xlat16_36 = min(u_xlat16_36, 1);
          u_xlat16_36 = (((-u_xlat16_36) * 5.61999989) + 1);
          u_xlat16_18.xyz = tex2D(_Mask, u_xlat16_34.xy).yzw;
          u_xlat16_36 = (u_xlat16_36 * u_xlat16_18.x);
          u_xlat16_17 = (u_xlat16_17 * u_xlat16_36);
          u_xlat16_17 = min(u_xlat16_17, 1);
          u_xlat16_17 = (u_xlatb1)?(u_xlat16_17):(u_xlat16_36);
          u_xlat16_0.x = ((u_xlat16_17 * u_xlat16_0.x) + 1);
          u_xlat16_2.xy = (u_xlat16_2.xy / u_xlat16_0.xx);
          u_xlat16_2.xy = (u_xlat16_2.xy + float2(0.5, 0.5));
          u_xlat16_2.xy = ((-u_xlat16_34.xy) + u_xlat16_2.xy);
          u_xlat16_0.xy = ((float2(u_xlat16_17, u_xlat16_17) * u_xlat16_2.xy) + u_xlat16_34.xy);
          u_xlat16_2 = tex2D(_Basemap, u_xlat16_0.xy);
          u_xlat16_0.x = max(u_xlat16_2.z, u_xlat16_2.y);
          u_xlat16_0.x = max(u_xlat16_0.x, u_xlat16_2.x);
          u_xlat16_3_d.xyz = ((u_xlat16_0.xxx * _IrisColor.xyz) + (-u_xlat16_2.xyz));
          u_xlat16_4.xyz = ((u_xlat16_0.xxx * _ScleraColor.xyz) + (-u_xlat16_2.xyz));
          u_xlat16_4.xyz = ((_ScleraColor.www * u_xlat16_4.xyz) + u_xlat16_2.xyz);
          u_xlat16_3_d.xyz = ((float3(_IrisColorAlpha, _IrisColorAlpha, _IrisColorAlpha) * u_xlat16_3_d.xyz) + u_xlat16_2.xyz);
          u_xlat16_3_d.xyz = ((-u_xlat16_4.xyz) + u_xlat16_3_d.xyz);
          u_xlat16_3_d.xyz = ((u_xlat16_18.xxx * u_xlat16_3_d.xyz) + u_xlat16_4.xyz);
          u_xlat16_0.xy = (_LensesOS.xy * float2(0.100000001, 0.100000001));
          u_xlat16_0.xy = max(u_xlat16_0.xy, float2(-1, (-1)));
          u_xlat16_0.xy = min(u_xlat16_0.xy, float2(1, 1));
          u_xlat16_0.xy = (u_xlat16_0.xy + u_xlat16_34.xy);
          u_xlat16_5.xy = tex2D(_Normalmap, u_xlat16_34.xy).xy;
          u_xlat16_34.xy = ((u_xlat16_5.xy * float2(2, 2)) + float2(-1, (-1)));
          u_xlat16_4.xy = (u_xlat16_34.xy * float2(_NormalScale, _NormalScale));
          u_xlat16_34.xy = max(_LensesOS.zw, float2(0.5, 0.5));
          u_xlat16_6.xy = (u_xlat16_34.xy + float2(-1, (-1)));
          u_xlat16_6.xy = (u_xlat16_6.xy * float2(0.5, 0.5));
          u_xlat16_0.xy = ((u_xlat16_0.xy * u_xlat16_34.xy) + (-u_xlat16_6.xy));
          u_xlat16_0 = tex2D(_LensesMap, u_xlat16_0.xy);
          u_xlat16_54 = max(u_xlat16_0.z, u_xlat16_0.y);
          u_xlat16_54 = max(u_xlat16_0.x, u_xlat16_54);
          u_xlat16_54 = (u_xlat16_54 * _LensesColorBrightness);
          u_xlat16_6.xyz = ((float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * _LensesColor.xyz) + (-u_xlat16_0.xyz));
          u_xlat16_6.xyz = ((float3(float3(_LensesColorAlpha, _LensesColorAlpha, _LensesColorAlpha)) * u_xlat16_6.xyz) + u_xlat16_0.xyz);
          u_xlat16_54 = (u_xlat16_18.x * u_xlat16_0.w);
          u_xlat16_54 = (u_xlat16_54 * _LensesAlpha);
          u_xlat16_6.xyz = ((-u_xlat16_3_d.xyz) + u_xlat16_6.xyz);
          u_xlat16_3_d.xyz = ((float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat16_6.xyz) + u_xlat16_3_d.xyz);
          u_xlat16_54 = (((-_Metallic) * 0.959999979) + 0.959999979);
          u_xlat16_6.xyz = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat16_3_d.xyz);
          u_xlat16_3_d.xyz = (u_xlat16_3_d.xyz + float3(-0.0399999991, (-0.0399999991), (-0.0399999991)));
          u_xlat16_3_d.xyz = ((float3(float3(_Metallic, _Metallic, _Metallic)) * u_xlat16_3_d.xyz) + float3(0.0399999991, 0.0399999991, 0.0399999991));
          u_xlat16_54 = ((_Smoothness * u_xlat16_18.y) + (-u_xlat16_54));
          u_xlat16_54 = (u_xlat16_54 + 1);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_54 = min(max(u_xlat16_54, 0), 1);
          #else
          u_xlat16_54 = clamp(u_xlat16_54, 0, 1);
          #endif
          u_xlat16_7.xyz = ((-u_xlat16_3_d.xyz) + float3(u_xlat16_54, u_xlat16_54, u_xlat16_54));
          u_xlat5.x = (conv_mxt4x4_0(unity_MatrixV).z * 100);
          u_xlat5.y = (conv_mxt4x4_1(unity_MatrixV).z * 100);
          u_xlat5.z = (conv_mxt4x4_2(unity_MatrixV).z * 100);
          u_xlat5.xyz = (u_xlat5.xyz + _WorldSpaceCameraPos.xyz);
          u_xlat16_8.x = in_f.texcoord3.w;
          u_xlat16_8.y = in_f.texcoord4.w;
          u_xlat16_8.z = in_f.texcoord5.w;
          u_xlat0_d.xyz = (-u_xlat16_8.xyz);
          u_xlat0_d.w = 0;
          u_xlat5.xyz = (u_xlat0_d.wyw + u_xlat5.xyz);
          u_xlat9.xyz = (u_xlat0_d.wyw + _WorldSpaceCameraPos.xyz);
          u_xlat10.xyz = (u_xlat0_d.xyz + _WorldSpaceCameraPos.xyz);
          u_xlat0_d.y = float(50);
          u_xlat0_d.w = float(1);
          u_xlat5.xyz = (u_xlat0_d.xyz + u_xlat5.xyz);
          u_xlat9.xyz = (u_xlat0_d.xwz + u_xlat9.xyz);
          u_xlat1_d.x = dot(u_xlat5.xyz, u_xlat5.xyz);
          u_xlat1_d.x = max(u_xlat1_d.x, 0);
          u_xlat16_54 = rsqrt(u_xlat1_d.x);
          u_xlat11.xyz = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat5.xyz);
          u_xlat16_8.xyz = ((u_xlat5.xyz * float3(u_xlat16_54, u_xlat16_54, u_xlat16_54)) + _MainLightPosition.xyz);
          u_xlat16_12.x = in_f.texcoord4.x;
          u_xlat16_12.y = in_f.texcoord5.x;
          u_xlat16_13.xyz = normalize(in_f.texcoord3.xyz);
          u_xlat16_12.z = u_xlat16_13.x;
          u_xlat16_4.z = 1;
          u_xlat16_14.x = dot(u_xlat16_12.xyz, u_xlat16_4.xyz);
          u_xlat16_15.z = u_xlat16_13.y;
          u_xlat16_15.x = in_f.texcoord4.y;
          u_xlat16_15.y = in_f.texcoord5.y;
          u_xlat16_14.y = dot(u_xlat16_15.xyz, u_xlat16_4.xyz);
          u_xlat16_13.x = in_f.texcoord4.z;
          u_xlat16_13.y = in_f.texcoord5.z;
          u_xlat16_14.z = dot(u_xlat16_13.xyz, u_xlat16_4.xyz);
          u_xlat16_4.xyz = (u_xlat16_4.xyz * float3(-2, (-2), 1));
          u_xlat16_14.xyz = normalize(u_xlat16_14.xyz);
          u_xlat16_16.xy = ((in_f.texcoord3.xy * float2(u_xlat16_54, u_xlat16_54)) + u_xlat16_14.xy);
          u_xlat16_16.z = (u_xlat16_13.z * u_xlat16_14.z);
          u_xlat16_14.xyz = normalize(u_xlat16_16.xyz);
          u_xlat16_54 = dot(u_xlat16_14.xyz, u_xlat11.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_54 = min(max(u_xlat16_54, 0), 1);
          #else
          u_xlat16_54 = clamp(u_xlat16_54, 0, 1);
          #endif
          u_xlat16_54 = ((-u_xlat16_54) + 1);
          u_xlat16_54 = (u_xlat16_54 * u_xlat16_54);
          u_xlat16_54 = (u_xlat16_54 * u_xlat16_54);
          u_xlat16_7.xyz = ((float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat16_7.xyz) + u_xlat16_3_d.xyz);
          u_xlat16_54 = (((-_Smoothness) * u_xlat16_18.y) + 1);
          u_xlat16_55 = (u_xlat16_54 * u_xlat16_54);
          u_xlat16_55 = max(u_xlat16_55, 0.0078125);
          u_xlat16_57 = ((u_xlat16_55 * u_xlat16_55) + 1);
          u_xlat16_57 = (float(1) / u_xlat16_57);
          u_xlat5.xyz = (u_xlat16_7.xyz * float3(u_xlat16_57, u_xlat16_57, u_xlat16_57));
          u_xlat16_57 = (((-u_xlat16_54) * 0.699999988) + 1.70000005);
          u_xlat16_54 = (u_xlat16_54 * u_xlat16_57);
          u_xlat16_54 = (u_xlat16_54 * 6);
          u_xlat16_57 = dot((-u_xlat11.xyz), u_xlat16_14.xyz);
          u_xlat16_57 = (u_xlat16_57 + u_xlat16_57);
          u_xlat16_7.xyz = ((u_xlat16_14.xyz * (-float3(u_xlat16_57, u_xlat16_57, u_xlat16_57))) + (-u_xlat11.xyz));
          u_xlat16_0 = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float4(u_xlat16_7.xyz, u_xlat16_54));
          u_xlat16_54 = (u_xlat16_0.w + (-1));
          u_xlat16_54 = ((unity_SpecCube0_HDR.w * u_xlat16_54) + 1);
          u_xlat16_54 = max(u_xlat16_54, 0);
          u_xlat16_54 = log2(u_xlat16_54);
          u_xlat16_54 = (u_xlat16_54 * unity_SpecCube0_HDR.y);
          u_xlat16_54 = exp2(u_xlat16_54);
          u_xlat16_54 = (u_xlat16_54 * unity_SpecCube0_HDR.x);
          u_xlat16_7.xyz = (u_xlat16_0.xyz * float3(u_xlat16_54, u_xlat16_54, u_xlat16_54));
          u_xlat16_54 = (u_xlat16_18.z + (-1));
          u_xlat16_54 = ((_OcclusionStrength * u_xlat16_54) + 1);
          u_xlat16_7.xyz = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat16_7.xyz);
          u_xlat16_16.xyz = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * _AmbientColor.xyz);
          u_xlat16_7.xyz = (u_xlat5.xyz * u_xlat16_7.xyz);
          u_xlat16_7.xyz = ((u_xlat16_16.xyz * u_xlat16_6.xyz) + u_xlat16_7.xyz);
          u_xlat1_d.x = dot(u_xlat16_8.xyz, u_xlat16_8.xyz);
          u_xlat1_d.x = max(u_xlat1_d.x, 0);
          u_xlat16_54 = rsqrt(u_xlat1_d.x);
          u_xlat1_d.xyw = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat16_8.xyz);
          u_xlat16_54 = dot(_MainLightPosition.xyz, u_xlat1_d.xyw);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_54 = min(max(u_xlat16_54, 0), 1);
          #else
          u_xlat16_54 = clamp(u_xlat16_54, 0, 1);
          #endif
          u_xlat16_57 = dot(u_xlat16_14.xyz, u_xlat1_d.xyw);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_57 = min(max(u_xlat16_57, 0), 1);
          #else
          u_xlat16_57 = clamp(u_xlat16_57, 0, 1);
          #endif
          u_xlat16_57 = (u_xlat16_57 * u_xlat16_57);
          u_xlat16_54 = (u_xlat16_54 * u_xlat16_54);
          u_xlat1_d.x = max(u_xlat16_54, 0.100000001);
          u_xlat18 = ((u_xlat16_55 * u_xlat16_55) + (-1));
          u_xlat18 = ((u_xlat16_57 * u_xlat18) + 1.00001001);
          u_xlat16_54 = (u_xlat18 * u_xlat18);
          u_xlat1_d.x = (u_xlat1_d.x * u_xlat16_54);
          u_xlat18 = ((u_xlat16_55 * 4) + 2);
          u_xlat16_54 = (u_xlat16_55 * u_xlat16_55);
          u_xlat1_d.x = (u_xlat18 * u_xlat1_d.x);
          u_xlat1_d.x = (u_xlat16_54 / u_xlat1_d.x);
          u_xlat16_54 = (u_xlat1_d.x + (-6.10351562E-05));
          u_xlat16_54 = max(u_xlat16_54, 0);
          u_xlat16_54 = min(u_xlat16_54, 100);
          u_xlat16_3_d.xyz = ((u_xlat16_3_d.xyz * float3(u_xlat16_54, u_xlat16_54, u_xlat16_54)) + u_xlat16_6.xyz);
          u_xlat16_54 = dot(u_xlat16_14.xyz, _MainLightPosition.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_54 = min(max(u_xlat16_54, 0), 1);
          #else
          u_xlat16_54 = clamp(u_xlat16_54, 0, 1);
          #endif
          u_xlat16_54 = (u_xlat16_54 * unity_LightData.z);
          u_xlat16_6.xyz = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * _MainLightColor.xyz);
          u_xlat16_3_d.xyz = ((u_xlat16_3_d.xyz * u_xlat16_6.xyz) + u_xlat16_7.xyz);
          u_xlat16_6.x = dot(u_xlat16_12.xyz, u_xlat16_4.xyz);
          u_xlat16_6.y = dot(u_xlat16_15.xyz, u_xlat16_4.xyz);
          u_xlat16_6.z = dot(u_xlat16_13.xyz, u_xlat16_4.xyz);
          u_xlat16_4.xyz = normalize(u_xlat16_6.xyz);
          u_xlat1_d.x = dot(u_xlat9.xyz, u_xlat9.xyz);
          u_xlat1_d.x = max(u_xlat1_d.x, 0);
          u_xlat16_54 = rsqrt(u_xlat1_d.x);
          u_xlat1_d.xyw = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat9.xyz);
          u_xlat16_54 = dot(u_xlat16_4.xyz, u_xlat1_d.xyw);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_54 = min(max(u_xlat16_54, 0), 1);
          #else
          u_xlat16_54 = clamp(u_xlat16_54, 0, 1);
          #endif
          u_xlat16_4.x = dot(_MainLightPosition.xyz, u_xlat1_d.xyw);
          u_xlat16_4.x = ((u_xlat16_4.x * 0.5) + 0.5);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_4.x = min(max(u_xlat16_4.x, 0), 1);
          #else
          u_xlat16_4.x = clamp(u_xlat16_4.x, 0, 1);
          #endif
          u_xlat16_4.x = ((-u_xlat16_4.x) + 1);
          u_xlat16_4.x = (u_xlat16_4.x * _IrisBrightness);
          u_xlat16_4.x = ((u_xlat16_4.x * (-0.899999976)) + _IrisBrightness);
          u_xlat16_54 = (u_xlat16_54 * u_xlat16_54);
          u_xlat16_21 = (u_xlat16_54 * u_xlat16_54);
          u_xlat16_54 = (u_xlat16_54 * u_xlat16_21);
          u_xlat16_54 = (u_xlat16_2.w * u_xlat16_54);
          u_xlat16_21 = (u_xlat16_4.x * u_xlat16_54);
          u_xlat16_54 = (((-u_xlat16_54) * u_xlat16_4.x) + 1);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_54 = min(max(u_xlat16_54, 0), 1);
          #else
          u_xlat16_54 = clamp(u_xlat16_54, 0, 1);
          #endif
          u_xlat16_54 = ((u_xlat16_54 * 0.5) + 0.00999999978);
          u_xlat16_4.xyz = (u_xlat16_3_d.xyz * float3(u_xlat16_21, u_xlat16_21, u_xlat16_21));
          u_xlat16_4.xyz = (u_xlat16_4.xyz / float3(u_xlat16_54, u_xlat16_54, u_xlat16_54));
          u_xlat1_d.x = dot(u_xlat10.xyz, u_xlat10.xyz);
          u_xlat1_d.x = max(u_xlat1_d.x, 0);
          u_xlat16_54 = rsqrt(u_xlat1_d.x);
          u_xlat1_d.xy = (float2(u_xlat16_54, u_xlat16_54) * u_xlat10.zx);
          u_xlat16_6.xy = (-u_xlat1_d.xy);
          u_xlat16_54 = ((-in_f.texcoord.y) + 0.5);
          u_xlat16_6.z = (-u_xlat16_54);
          u_xlat16_7.xyz = (u_xlat16_6.xyz * conv_mxt4x4_1(unity_MatrixInvV).xyz);
          u_xlat16_7.xyz = ((conv_mxt4x4_1(unity_MatrixInvV).zxy * u_xlat16_6.yzx) + (-u_xlat16_7.xyz));
          u_xlat16_7.xyz = normalize(u_xlat16_7.xyz);
          u_xlat16_8.xyz = (u_xlat16_6.xyz * u_xlat16_7.xyz);
          u_xlat16_8.xyz = ((u_xlat16_6.zxy * u_xlat16_7.yzx) + (-u_xlat16_8.xyz));
          u_xlat16_6.xw = normalize(u_xlat16_8.xyz);
          u_xlat16_6.xw = (u_xlat16_6.xw * u_xlat16_14.yy);
          u_xlat16_6.xw = ((u_xlat16_14.xx * u_xlat16_7.zx) + u_xlat16_6.xw);
          u_xlat16_6.xy = ((u_xlat16_14.zz * u_xlat16_6.yz) + u_xlat16_6.xw);
          u_xlat16_7.xyz = max(_ReflOffset2.xyz, float3(-1, (-1), (-1)));
          u_xlat16_7.xyz = min(u_xlat16_7.xyz, float3(1, 1, 1));
          u_xlat16_6.xy = ((u_xlat16_6.xy * u_xlat16_7.zz) + float2(1, 1));
          u_xlat16_6.xy = ((u_xlat16_6.xy * float2(0.5, 0.5)) + u_xlat16_7.xy);
          u_xlat16_1.xyw = tex2D(_ReflectionTex2, u_xlat16_6.xy).xyz;
          u_xlat16_54 = max(u_xlat16_1.w, u_xlat16_1.y);
          u_xlat16_54 = max(u_xlat16_1.x, u_xlat16_54);
          u_xlat16_6.xyz = ((float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * _ReflColor2.xyz) + (-u_xlat16_1.xyw));
          u_xlat16_6.xyz = ((_ReflColor2.www * u_xlat16_6.xyz) + u_xlat16_1.xyw);
          u_xlat16_54 = _ReflectionAlpha2;
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_54 = min(max(u_xlat16_54, 0), 1);
          #else
          u_xlat16_54 = clamp(u_xlat16_54, 0, 1);
          #endif
          u_xlat16_6.xyz = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat16_6.xyz);
          u_xlat16_6.xyz = (u_xlat16_18.yyy * u_xlat16_6.xyz);
          u_xlat5.x = conv_mxt4x4_0(unity_WorldToObject).x;
          u_xlat5.y = conv_mxt4x4_1(unity_WorldToObject).x;
          u_xlat5.z = conv_mxt4x4_2(unity_WorldToObject).x;
          u_xlat16_7.x = dot(u_xlat5.xyz, u_xlat16_14.xyz);
          u_xlat5.x = conv_mxt4x4_0(unity_WorldToObject).y;
          u_xlat5.y = conv_mxt4x4_1(unity_WorldToObject).y;
          u_xlat5.z = conv_mxt4x4_2(unity_WorldToObject).y;
          u_xlat16_7.y = dot(u_xlat5.xyz, u_xlat16_14.xyz);
          u_xlat5.x = conv_mxt4x4_0(unity_WorldToObject).z;
          u_xlat5.y = conv_mxt4x4_1(unity_WorldToObject).z;
          u_xlat5.z = conv_mxt4x4_2(unity_WorldToObject).z;
          u_xlat16_7.z = dot(u_xlat5.xyz, u_xlat16_14.xyz);
          u_xlat1_d.xyw = mul(unity_WorldToObject, unity_MatrixInvV[0]);
          u_xlat16_8.x = dot(u_xlat1_d.xyw, u_xlat16_7.xyz);
          u_xlat1_d.xyw = mul(unity_WorldToObject, unity_MatrixInvV[0]);
          u_xlat16_8.y = dot(u_xlat1_d.xyw, u_xlat16_7.xyz);
          u_xlat1_d.xyw = mul(unity_WorldToObject, unity_MatrixInvV[0]);
          u_xlat16_8.z = dot(u_xlat1_d.xyw, u_xlat16_7.xyz);
          u_xlat16_54 = dot(u_xlat16_8.xyz, u_xlat16_8.xyz);
          u_xlat16_54 = rsqrt(u_xlat16_54);
          u_xlat16_7.xyz = max(_ReflOffset1.xyz, float3(-1, (-1), (-1)));
          u_xlat16_7.xyz = min(u_xlat16_7.xyz, float3(1, 1, 1));
          u_xlat16_7.xyz = ((u_xlat16_8.xyz * float3(u_xlat16_54, u_xlat16_54, u_xlat16_54)) + u_xlat16_7.xyz);
          u_xlat16_54 = dot(u_xlat16_7.xy, u_xlat16_7.xy);
          u_xlat16_55 = (u_xlat16_7.z + 1);
          u_xlat16_54 = ((u_xlat16_55 * u_xlat16_55) + u_xlat16_54);
          u_xlat16_54 = sqrt(u_xlat16_54);
          u_xlat16_54 = (u_xlat16_54 * (-2));
          u_xlat16_7.xy = (u_xlat16_7.xy / float2(u_xlat16_54, u_xlat16_54));
          u_xlat16_7.xy = ((-u_xlat16_7.xy) + float2(0.5, 0.5));
          u_xlat16_1.xyw = tex2D(_ReflectionTex1, u_xlat16_7.xy).xyz;
          u_xlat16_54 = max(u_xlat16_1.w, u_xlat16_1.y);
          u_xlat16_54 = max(u_xlat16_1.x, u_xlat16_54);
          u_xlat16_7.xyz = ((float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * _ReflColor1.xyz) + (-u_xlat16_1.xyw));
          u_xlat16_7.xyz = ((_ReflColor1.www * u_xlat16_7.xyz) + u_xlat16_1.xyw);
          u_xlat16_54 = _ReflectionAlpha1;
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_54 = min(max(u_xlat16_54, 0), 1);
          #else
          u_xlat16_54 = clamp(u_xlat16_54, 0, 1);
          #endif
          u_xlat16_7.xyz = (float3(u_xlat16_54, u_xlat16_54, u_xlat16_54) * u_xlat16_7.xyz);
          u_xlat16_6.xyz = ((u_xlat16_7.xyz * u_xlat16_18.yyy) + u_xlat16_6.xyz);
          u_xlat16_4.xyz = (u_xlat16_4.xyz + u_xlat16_6.xyz);
          out_f.color.xyz = (u_xlat16_3_d.xyz + u_xlat16_4.xyz);
          out_f.color.w = 1;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
