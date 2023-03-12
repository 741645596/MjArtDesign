// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/Laser_Alpha"
{
  Properties
  {
    [MaterialEnum(All, 0, Front, 2)] _RenderFace ("Render Face", float) = 2
    _Basemap ("Base map", 2D) = "white" {}
    _BaseColor ("Base Color", Color) = (1,1,1,1)
    [HDR] _ShadowColor ("Shadow Color", Color) = (0,0,0,1)
    [Space(10)] [Header(Normal)] [Space(10)] [Toggle(NORMAL_ON)] _Normalmap_On ("Normalmap Enable", float) = 0
    _Normalmap ("Normal map", 2D) = "bump" {}
    _NormalScale ("Normal Scale", Range(0, 2)) = 1
    [Space(10)] [Header(Laser)] [Space(10)] [NoScaleOffset] _Lasermap ("Laser map", 2D) = "white" {}
    _LaserPower ("Laser Power", Range(1, 5)) = 1
    _LaserIntensity ("Laser Intensity", Range(0, 1)) = 1
    [Space(10)] [Header(Specular)] [Space(10)] [Toggle(LASERSPEC_ON)] _SpecularEnable ("Specular Enable", float) = 0
    _SpecularColor1 ("Specular Color 1", Color) = (1,0,0,1)
    _SpecularGloss1 ("Specular Gloss 1", Range(1, 800)) = 800
    _ShiftValue1 ("ShiftValue 1", Range(-5, 5)) = 0
    [Space(10)] _SpecularColor2 ("Specular Color 2", Color) = (0,0,1,1)
    _SpecularGloss2 ("Specular Gloss 2", Range(1, 800)) = 600
    _ShiftValue2 ("ShiftValue 2", Range(-5, 5)) = 0
    [Header(Twinkle Param)] [Space] [Toggle(TWINKLE_ENABLE)] _TwinkleEnable ("Twinkle Enable", float) = 0
    _Twinklemap ("Twinkle map", 2D) = "black" {}
    [HDR] _TwinkleColor ("Twinkle Color", Color) = (1,1,1,1)
    _TwinkleSize ("Twinkle Size", Range(0, 10)) = 6
    _TwinklePower ("Twinkle Power", Range(1, 50)) = 18
    _TwinkleIntensity ("Twinkle Intensity", Range(0, 1)) = 0.15
    _ShiningSpeed ("Shining Speed", Range(0, 0.5)) = 0.1
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
      "RenderType" = "Transparent"
    }
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
      }
      ZWrite Off
      Cull Off
      Blend SrcAlpha OneMinusSrcAlpha, One One
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile LASERSPEC_ON _LOD100
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
      uniform float4x4 ShadowVP;
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightColor;
      //uniform float3 _WorldSpaceCameraPos;
      uniform float4 _AmbientSkyColor;
      uniform float4 _AmbientEquatorColor;
      uniform float4 _AmbientGroundColor;
      uniform float _AmbientIntensity;
      uniform sampler2D _Basemap;
      uniform sampler2D _Lasermap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 tangent :TANGENT0;
          float2 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float3 texcoord5 :TEXCOORD5;
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
      uniform float _LaserPower;
      uniform float _LaserIntensity;
      uniform float4 _SpecularColor1;
      uniform float _SpecularGloss1;
      uniform float _ShiftValue1;
      uniform float4 _SpecularColor2;
      uniform float _SpecularGloss2;
      uniform float _ShiftValue2;
      uniform float4 _TwinkleColor;
      uniform float _TwinkleSize;
      uniform float _TwinklePower;
      uniform float _TwinkleIntensity;
      uniform float _ShiningSpeed;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0;
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
          u_xlat1 = (u_xlat0.yyyy * conv_mxt4x4_1(ShadowVP));
          u_xlat1 = ((conv_mxt4x4_0(ShadowVP) * u_xlat0.xxxx) + u_xlat1);
          u_xlat1 = ((conv_mxt4x4_2(ShadowVP) * u_xlat0.zzzz) + u_xlat1);
          out_v.texcoord4.xyz = u_xlat0.xyz;
          u_xlat0 = (u_xlat1 + conv_mxt4x4_3(ShadowVP));
          out_v.texcoord1 = u_xlat0;
          u_xlat0.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat0.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat0.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          u_xlat0.xyz = (u_xlat0.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          out_v.texcoord3.xyz = u_xlat0.xyz;
          u_xlat0.xyz = (in_v.tangent.yyy * conv_mxt4x4_1(unity_ObjectToWorld).xyz);
          u_xlat0.xyz = ((conv_mxt4x4_0(unity_ObjectToWorld).xyz * in_v.tangent.xxx) + u_xlat0.xyz);
          u_xlat0.xyz = ((conv_mxt4x4_2(unity_ObjectToWorld).xyz * in_v.tangent.zzz) + u_xlat0.xyz);
          u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          u_xlat0.xyz = (u_xlat0.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          out_v.texcoord5.xyz = u_xlat0.xyz;
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
      uniform float _LaserPower;
      uniform float _LaserIntensity;
      uniform float4 _SpecularColor1;
      uniform float _SpecularGloss1;
      uniform float _ShiftValue1;
      uniform float4 _SpecularColor2;
      uniform float _SpecularGloss2;
      uniform float _ShiftValue2;
      uniform float4 _TwinkleColor;
      uniform float _TwinkleSize;
      uniform float _TwinklePower;
      uniform float _TwinkleIntensity;
      uniform float _ShiningSpeed;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float u_xlat16_0;
      float3 u_xlat16_1;
      float3 u_xlat16_2_d;
      float4 u_xlat3;
      float4 u_xlat16_3;
      float3 u_xlat16_4;
      float u_xlat15;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0 = max(_AmbientSkyColor.z, _AmbientSkyColor.y);
          u_xlat16_0 = max(u_xlat16_0, _AmbientSkyColor.x);
          u_xlat16_0 = ((-u_xlat16_0) + 3);
          u_xlat16_4.x = max(_AmbientGroundColor.z, _AmbientGroundColor.y);
          u_xlat16_4.x = max(u_xlat16_4.x, _AmbientGroundColor.x);
          u_xlat16_0 = ((-u_xlat16_4.x) + u_xlat16_0);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_0 = min(max(u_xlat16_0, 0), 1);
          #else
          u_xlat16_0 = clamp(u_xlat16_0, 0, 1);
          #endif
          u_xlat16_4.x = dot(in_f.texcoord3.xyz, in_f.texcoord3.xyz);
          u_xlat16_4.x = rsqrt(u_xlat16_4.x);
          u_xlat16_4.xyz = (u_xlat16_4.xxx * in_f.texcoord3.xyz);
          u_xlat16_1.x = (((gl_FrontFacing)?(4294967295):(uint(0))!=uint(0)))?(1):((-1));
          u_xlat16_4.xyz = (u_xlat16_4.xyz * u_xlat16_1.xxx);
          u_xlat16_1.x = ((-abs(u_xlat16_4.y)) + 1.60000002);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_1.x = min(max(u_xlat16_1.x, 0), 1);
          #else
          u_xlat16_1.x = clamp(u_xlat16_1.x, 0, 1);
          #endif
          u_xlat16_0 = (u_xlat16_0 * u_xlat16_1.x);
          u_xlat16_1.xyz = (float3(u_xlat16_0, u_xlat16_0, u_xlat16_0) * _AmbientEquatorColor.xyz);
          u_xlat16_2_d.xy = ((u_xlat16_4.yy * float2(0.699999988, (-0.699999988))) + float2(0.300000012, 0.300000012));
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_2_d.xy = min(max(u_xlat16_2_d.xy, 0), 1);
          #else
          u_xlat16_2_d.xy = clamp(u_xlat16_2_d.xy, 0, 1);
          #endif
          u_xlat16_1.xyz = ((_AmbientSkyColor.xyz * u_xlat16_2_d.xxx) + u_xlat16_1.xyz);
          u_xlat16_1.xyz = ((_AmbientGroundColor.xyz * u_xlat16_2_d.yyy) + u_xlat16_1.xyz);
          u_xlat16_1.xyz = (u_xlat16_1.xyz * float3(_AmbientIntensity, _AmbientIntensity, _AmbientIntensity));
          u_xlat16_1.xyz = (u_xlat16_1.xyz * float3(0.300000012, 0.300000012, 0.300000012));
          u_xlat3.xyz = ((-in_f.texcoord4.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat15 = dot(u_xlat3.xyz, u_xlat3.xyz);
          u_xlat15 = max(u_xlat15, 0);
          u_xlat16_0 = rsqrt(u_xlat15);
          u_xlat16_2_d.xyz = ((u_xlat3.xyz * float3(u_xlat16_0, u_xlat16_0, u_xlat16_0)) + _MainLightPosition.xyz);
          u_xlat16_2_d.xyz = normalize(u_xlat16_2_d.xyz);
          u_xlat16_0 = dot(u_xlat16_4.xyz, u_xlat16_2_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_0 = min(max(u_xlat16_0, 0), 1);
          #else
          u_xlat16_0 = clamp(u_xlat16_0, 0, 1);
          #endif
          u_xlat16_4.x = dot(u_xlat16_4.xyz, _MainLightPosition.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_4.x = min(max(u_xlat16_4.x, 0), 1);
          #else
          u_xlat16_4.x = clamp(u_xlat16_4.x, 0, 1);
          #endif
          u_xlat16_4.x = (u_xlat16_4.x * unity_LightData.z);
          u_xlat16_4.xyz = (u_xlat16_4.xxx * _MainLightColor.xyz);
          u_xlat16_0 = log2(u_xlat16_0);
          u_xlat16_0 = (u_xlat16_0 * _LaserPower);
          u_xlat16_2_d.x = exp2(u_xlat16_0);
          u_xlat16_2_d.y = 1;
          u_xlat16_3.xyz = tex2D(_Lasermap, u_xlat16_2_d.xy).xyz;
          u_xlat16_0 = ((-_LaserIntensity) + 1);
          u_xlat16_2_d.xyz = ((u_xlat16_3.xyz * float3(float3(_LaserIntensity, _LaserIntensity, _LaserIntensity))) + float3(u_xlat16_0, u_xlat16_0, u_xlat16_0));
          u_xlat16_3 = tex2D(_Basemap, in_f.texcoord.xy);
          u_xlat3 = (u_xlat16_3 * _BaseColor);
          u_xlat16_2_d.xyz = (u_xlat16_2_d.xyz * u_xlat3.xyz);
          out_f.color.w = u_xlat3.w;
          #ifdef UNITY_ADRENO_ES3
          out_f.color.w = min(max(out_f.color.w, 0), 1);
          #else
          out_f.color.w = clamp(out_f.color.w, 0, 1);
          #endif
          u_xlat16_1.xyz = (u_xlat16_1.xyz * u_xlat16_2_d.xyz);
          out_f.color.xyz = ((u_xlat16_2_d.xyz * u_xlat16_4.xyz) + u_xlat16_1.xyz);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
