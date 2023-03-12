// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/Fur"
{
  Properties
  {
    _Basemap ("Base map", 2D) = "white" {}
    _BaseColor ("Base Color", Color) = (1,1,1,1)
    [Space(20)] _Normalmap ("Normal map", 2D) = "bump" {}
    _NormalScale ("Normal Scale", Range(0, 5)) = 2
    _Smoothness ("Smoothness", Range(0, 1)) = 0
    [Space(20)] _FurLength ("Fur Length", Range(0, 1)) = 0.1
    _Lengthmap ("Length map", 2D) = "white" {}
    _GravityStrength ("Gravity Strength", Range(0, 1)) = 0.15
    [Space(20)] _SpecularColor ("Specular Color", Color) = (1,1,1,1)
    _ShadowColor ("Shadow Color", Color) = (0.25,0.25,0.25,1)
    _AmbientColor ("Ambient Color", Color) = (0.5,0.5,0.5,0.5)
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
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "LIGHTMODE" = "FurRendererBase"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
      Blend One Zero, SrcAlpha One
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
      uniform float4 _MainLightWorldToShadow[20];
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightColor;
      //uniform float3 _WorldSpaceCameraPos;
      uniform float _FUR_OFFSET;
      uniform sampler2D _Basemap;
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
      uniform float4 _Normalmap_ST;
      uniform float4 _BaseColor;
      uniform float _NormalScale;
      uniform float _Smoothness;
      uniform float _FurLength;
      uniform float _GravityStrength;
      uniform float4 _SpecularColor;
      uniform float4 _ShadowColor;
      uniform float4 _AmbientColor;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float3 u_xlat0;
      float4 u_xlat1;
      float u_xlat16_2;
      float u_xlat9;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat1 = mul(unity_MatrixVP, float4(u_xlat0.xyz,1.0));
          out_v.vertex = u_xlat1;
          out_v.texcoord.xy = TRANSFORM_TEX(in_v.texcoord.xy, _Basemap);
          out_v.texcoord.zw = TRANSFORM_TEX(in_v.texcoord.xy, _Normalmap);
          out_v.texcoord1 = float4(0, 0, 0, 0);
          u_xlat1.xyz = (u_xlat0.yyy * _MainLightWorldToShadow[1].xyz);
          u_xlat1.xyz = ((_MainLightWorldToShadow[0].xyz * u_xlat0.xxx) + u_xlat1.xyz);
          u_xlat1.xyz = ((_MainLightWorldToShadow[2].xyz * u_xlat0.zzz) + u_xlat1.xyz);
          out_v.texcoord4.xyz = u_xlat0.xyz;
          u_xlat0.xyz = (u_xlat1.xyz + _MainLightWorldToShadow[3].xyz);
          out_v.texcoord2.xyz = u_xlat0.xyz;
          out_v.texcoord2.w = 0;
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
      uniform float4 _Normalmap_ST;
      uniform float4 _BaseColor;
      uniform float _NormalScale;
      uniform float _Smoothness;
      uniform float _FurLength;
      uniform float _GravityStrength;
      uniform float4 _SpecularColor;
      uniform float4 _ShadowColor;
      uniform float4 _AmbientColor;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0_d;
      float4 u_xlat16_0;
      float4 u_xlat16_1;
      float3 u_xlat16_2_d;
      float3 u_xlat16_3;
      float u_xlat16_5;
      float u_xlat16_9;
      float u_xlat12;
      float u_xlat16_13;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat0_d.xyz = ((-in_f.texcoord4.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat12 = dot(u_xlat0_d.xyz, u_xlat0_d.xyz);
          u_xlat12 = max(u_xlat12, 0);
          u_xlat16_1.x = rsqrt(u_xlat12);
          u_xlat16_1.xyz = ((u_xlat0_d.xyz * u_xlat16_1.xxx) + _MainLightPosition.xyz);
          u_xlat16_1.xyz = normalize(u_xlat16_1.xyz);
          u_xlat16_2_d.xyz = normalize(in_f.texcoord3.xyz);
          u_xlat16_1.x = dot(u_xlat16_2_d.xyz, u_xlat16_1.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_1.x = min(max(u_xlat16_1.x, 0), 1);
          #else
          u_xlat16_1.x = clamp(u_xlat16_1.x, 0, 1);
          #endif
          u_xlat16_5 = dot(u_xlat16_2_d.xyz, _MainLightPosition.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_5 = min(max(u_xlat16_5, 0), 1);
          #else
          u_xlat16_5 = clamp(u_xlat16_5, 0, 1);
          #endif
          u_xlat16_1.x = log2(u_xlat16_1.x);
          u_xlat16_9 = (_Smoothness * 1024);
          u_xlat16_1.x = (u_xlat16_1.x * u_xlat16_9);
          u_xlat16_1.x = exp2(u_xlat16_1.x);
          u_xlat16_1.xzw = (u_xlat16_1.xxx * _SpecularColor.xyz);
          u_xlat16_2_d.x = (_Smoothness + 1);
          u_xlat16_1.xzw = (u_xlat16_1.xzw * u_xlat16_2_d.xxx);
          u_xlat16_1.xzw = (u_xlat16_1.xzw * _SpecularColor.www);
          u_xlat16_0 = tex2D(_Basemap, in_f.texcoord.xy);
          u_xlat0_d = (u_xlat16_0 * _BaseColor);
          u_xlat16_1.xzw = ((u_xlat16_1.xzw * float3(5, 5, 5)) + u_xlat0_d.xyz);
          u_xlat16_2_d.xyz = (_MainLightColor.xyz * unity_LightData.zzz);
          u_xlat16_2_d.xyz = (float3(u_xlat16_5, u_xlat16_5, u_xlat16_5) * u_xlat16_2_d.xyz);
          u_xlat16_3.xyz = ((-_ShadowColor.xyz) + float3(1, 1, 1));
          u_xlat16_2_d.xyz = ((u_xlat16_2_d.xyz * u_xlat16_3.xyz) + _ShadowColor.xyz);
          out_f.color.xyz = ((u_xlat16_2_d.xyz * u_xlat16_1.xzw) + _AmbientColor.xyz);
          u_xlat16_1.x = (((-_FUR_OFFSET) * _FUR_OFFSET) + 1);
          u_xlat16_1.x = max(u_xlat16_1.x, 0);
          out_f.color.w = (u_xlat0_d.w * u_xlat16_1.x);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: 
    {
      Tags
      { 
        "LIGHTMODE" = "FurRendererLayer"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
      Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One
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
      uniform float4 _MainLightWorldToShadow[20];
      uniform float _FUR_OFFSET;
      uniform sampler2D _Lengthmap;
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightColor;
      //uniform float3 _WorldSpaceCameraPos;
      uniform sampler2D _Basemap;
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
      uniform float4 _Normalmap_ST;
      uniform float4 _BaseColor;
      uniform float _NormalScale;
      uniform float _Smoothness;
      uniform float _FurLength;
      uniform float _GravityStrength;
      uniform float4 _SpecularColor;
      uniform float4 _ShadowColor;
      uniform float4 _AmbientColor;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0;
      float3 u_xlat16_0;
      float2 u_xlat16_1;
      float3 u_xlat2;
      float3 u_xlat3;
      float u_xlat14;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat16_0.xyz = ((-in_v.normal.xyz) + float3(0, (-1), 0));
          u_xlat16_0.xyz = (u_xlat16_0.xyz * float3(float3(_GravityStrength, _GravityStrength, _GravityStrength)));
          u_xlat16_0.xyz = ((float3(_FUR_OFFSET, _FUR_OFFSET, _FUR_OFFSET) * u_xlat16_0.xyz) + in_v.normal.xyz);
          u_xlat16_1.xy = TRANSFORM_TEX(in_v.texcoord.xy, _Basemap);
          u_xlat2.x = tex2Dlod(_Lengthmap, float4(float3(u_xlat16_1.xy, 0), 0)).x;
          out_v.texcoord.xy = u_xlat16_1.xy;
          u_xlat2.x = (u_xlat2.x * _FurLength);
          u_xlat16_0.xyz = (u_xlat16_0.xyz * u_xlat2.xxx);
          u_xlat16_0.xyz = ((u_xlat16_0.xyz * float3(_FUR_OFFSET, _FUR_OFFSET, _FUR_OFFSET)) + in_v.vertex.xyz);
          u_xlat2.xyz = mul(unity_ObjectToWorld, u_xlat16_0.xyz);
          u_xlat0 = mul(unity_MatrixVP, float4(u_xlat2.xyz,1.0));
          out_v.vertex = u_xlat0;
          out_v.texcoord.zw = TRANSFORM_TEX(in_v.texcoord.xy, _Normalmap);
          out_v.texcoord1 = float4(0, 0, 0, 0);
          u_xlat3.xyz = (u_xlat2.yyy * _MainLightWorldToShadow[1].xyz);
          u_xlat3.xyz = ((_MainLightWorldToShadow[0].xyz * u_xlat2.xxx) + u_xlat3.xyz);
          u_xlat3.xyz = ((_MainLightWorldToShadow[2].xyz * u_xlat2.zzz) + u_xlat3.xyz);
          out_v.texcoord4.xyz = u_xlat2.xyz;
          u_xlat2.xyz = (u_xlat3.xyz + _MainLightWorldToShadow[3].xyz);
          out_v.texcoord2.xyz = u_xlat2.xyz;
          out_v.texcoord2.w = 0;
          u_xlat2.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat2.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat2.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat14 = dot(u_xlat2.xyz, u_xlat2.xyz);
          u_xlat14 = max(u_xlat14, 0);
          u_xlat16_1.x = rsqrt(u_xlat14);
          u_xlat2.xyz = (u_xlat16_1.xxx * u_xlat2.xyz);
          out_v.texcoord3.xyz = u_xlat2.xyz;
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
      uniform float4 _Normalmap_ST;
      uniform float4 _BaseColor;
      uniform float _NormalScale;
      uniform float _Smoothness;
      uniform float _FurLength;
      uniform float _GravityStrength;
      uniform float4 _SpecularColor;
      uniform float4 _ShadowColor;
      uniform float4 _AmbientColor;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0_d;
      float4 u_xlat16_0_d;
      float4 u_xlat16_1_d;
      float3 u_xlat16_2;
      float3 u_xlat16_3;
      float u_xlat16_5;
      float u_xlat16_9;
      float u_xlat12;
      float u_xlat16_13;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat0_d.xyz = ((-in_f.texcoord4.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat12 = dot(u_xlat0_d.xyz, u_xlat0_d.xyz);
          u_xlat12 = max(u_xlat12, 0);
          u_xlat16_1_d.x = rsqrt(u_xlat12);
          u_xlat16_1_d.xyz = ((u_xlat0_d.xyz * u_xlat16_1_d.xxx) + _MainLightPosition.xyz);
          u_xlat16_1_d.xyz = normalize(u_xlat16_1_d.xyz);
          u_xlat16_2.xyz = normalize(in_f.texcoord3.xyz);
          u_xlat16_1_d.x = dot(u_xlat16_2.xyz, u_xlat16_1_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_1_d.x = min(max(u_xlat16_1_d.x, 0), 1);
          #else
          u_xlat16_1_d.x = clamp(u_xlat16_1_d.x, 0, 1);
          #endif
          u_xlat16_5 = dot(u_xlat16_2.xyz, _MainLightPosition.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_5 = min(max(u_xlat16_5, 0), 1);
          #else
          u_xlat16_5 = clamp(u_xlat16_5, 0, 1);
          #endif
          u_xlat16_1_d.x = log2(u_xlat16_1_d.x);
          u_xlat16_9 = (_Smoothness * 1024);
          u_xlat16_1_d.x = (u_xlat16_1_d.x * u_xlat16_9);
          u_xlat16_1_d.x = exp2(u_xlat16_1_d.x);
          u_xlat16_1_d.xzw = (u_xlat16_1_d.xxx * _SpecularColor.xyz);
          u_xlat16_2.x = (_Smoothness + 1);
          u_xlat16_1_d.xzw = (u_xlat16_1_d.xzw * u_xlat16_2.xxx);
          u_xlat16_1_d.xzw = (u_xlat16_1_d.xzw * _SpecularColor.www);
          u_xlat16_0_d = tex2D(_Basemap, in_f.texcoord.xy);
          u_xlat0_d = (u_xlat16_0_d * _BaseColor);
          u_xlat16_1_d.xzw = ((u_xlat16_1_d.xzw * float3(5, 5, 5)) + u_xlat0_d.xyz);
          u_xlat16_2.xyz = (_MainLightColor.xyz * unity_LightData.zzz);
          u_xlat16_2.xyz = (float3(u_xlat16_5, u_xlat16_5, u_xlat16_5) * u_xlat16_2.xyz);
          u_xlat16_3.xyz = ((-_ShadowColor.xyz) + float3(1, 1, 1));
          u_xlat16_2.xyz = ((u_xlat16_2.xyz * u_xlat16_3.xyz) + _ShadowColor.xyz);
          out_f.color.xyz = ((u_xlat16_2.xyz * u_xlat16_1_d.xzw) + _AmbientColor.xyz);
          u_xlat16_1_d.x = (((-_FUR_OFFSET) * _FUR_OFFSET) + 1);
          u_xlat16_1_d.x = max(u_xlat16_1_d.x, 0);
          out_f.color.w = (u_xlat0_d.w * u_xlat16_1_d.x);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
