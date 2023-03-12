// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/Gem"
{
  Properties
  {
    _Basemap ("Base map", 2D) = "white" {}
    _Cube ("Refraction Texture", Cube) = "" {}
    [HDR] _Color ("Color", Color) = (1,1,1,1)
    _Saturation ("Saturate", Range(0, 1.5)) = 1
    _ReflectionStrength ("Reflection Strength", Range(0, 50)) = 1
    _EnvironmentLight ("Environment Light", Range(0, 50)) = 1
    _Emission ("Emission", Range(0, 20)) = 1
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
      "QUEUE" = "Geometry"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Opaque"
    }
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Geometry"
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
      #define conv_mxt4x4_3(mat4x4) float4(mat4x4[0].w,mat4x4[1].w,mat4x4[2].w,mat4x4[3].w)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_MatrixVP;
      uniform sampler2D _Basemap;
      uniform samplerCUBE _Cube;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float3 texcoord :TEXCOORD0;
          float2 texcoord1 :TEXCOORD1;
          float texcoord2 :TEXCOORD2;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float3 texcoord :TEXCOORD0;
          float2 texcoord1 :TEXCOORD1;
          float texcoord2 :TEXCOORD2;
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
      float3 u_xlat0;
      float4 u_xlat1;
      float3 u_xlat16_2;
      float u_xlat16_5;
      float u_xlat9;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat1 = (u_xlat0.yyyy * conv_mxt4x4_1(unity_MatrixVP));
          u_xlat1 = ((conv_mxt4x4_0(unity_MatrixVP) * u_xlat0.xxxx) + u_xlat1);
          u_xlat1 = ((conv_mxt4x4_2(unity_MatrixVP) * u_xlat0.zzzz) + u_xlat1);
          u_xlat0.xyz = ((-u_xlat0.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat1 = (u_xlat1 + conv_mxt4x4_3(unity_MatrixVP));
          out_v.vertex = u_xlat1;
          u_xlat0.xyz = normalize(u_xlat0.xyz);
          u_xlat1.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat1.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat1.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat9 = dot(u_xlat1.xyz, u_xlat1.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2.x = rsqrt(u_xlat9);
          u_xlat1.xyz = (u_xlat1.xyz * u_xlat16_2.xxx);
          u_xlat16_2.x = dot(u_xlat0.xyz, u_xlat1.xyz);
          u_xlat16_5 = (u_xlat16_2.x + u_xlat16_2.x);
          u_xlat16_2.x = u_xlat16_2.x;
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_2.x = min(max(u_xlat16_2.x, 0), 1);
          #else
          u_xlat16_2.x = clamp(u_xlat16_2.x, 0, 1);
          #endif
          out_v.texcoord2 = ((-u_xlat16_2.x) + 1);
          u_xlat16_2.xyz = ((u_xlat1.xyz * (-float3(u_xlat16_5, u_xlat16_5, u_xlat16_5))) + u_xlat0.xyz);
          out_v.texcoord.xyz = (-u_xlat16_2.xyz);
          out_v.texcoord1.xy = in_v.texcoord.xy;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      uniform UnityPerMaterial;
      #endif
      uniform float4 _Color;
      uniform float _Saturation;
      uniform float _ReflectionStrength;
      uniform float _EnvironmentLight;
      uniform float _Emission;
      uniform float4 _Cube_HDR;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat16_0;
      float3 u_xlat16_1;
      float3 u_xlat16_2_d;
      float u_xlat16_10;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0 = texCUBE(_Cube, in_f.texcoord.xyz);
          u_xlat16_1.x = (u_xlat16_0.w + (-1));
          u_xlat16_1.x = ((_Cube_HDR.w * u_xlat16_1.x) + 1);
          u_xlat16_1.x = max(u_xlat16_1.x, 0);
          u_xlat16_1.x = log2(u_xlat16_1.x);
          u_xlat16_1.x = (u_xlat16_1.x * _Cube_HDR.y);
          u_xlat16_1.x = exp2(u_xlat16_1.x);
          u_xlat16_1.x = (u_xlat16_1.x * _Cube_HDR.x);
          u_xlat16_1.xyz = (u_xlat16_0.xyz * u_xlat16_1.xxx);
          u_xlat16_0.xyz = tex2D(_Basemap, in_f.texcoord1.xy).xyz;
          u_xlat16_2_d.xyz = (u_xlat16_0.xyz * _Color.xyz);
          u_xlat16_10 = dot(u_xlat16_2_d.xyz, float3(0.212500006, 0.715399981, 0.0720999986));
          u_xlat16_2_d.xyz = ((u_xlat16_0.xyz * _Color.xyz) + (-float3(u_xlat16_10, u_xlat16_10, u_xlat16_10)));
          u_xlat16_2_d.xyz = ((float3(_Saturation, _Saturation, _Saturation) * u_xlat16_2_d.xyz) + float3(u_xlat16_10, u_xlat16_10, u_xlat16_10));
          u_xlat16_1.xyz = (u_xlat16_1.xyz * u_xlat16_2_d.xyz);
          u_xlat16_2_d.xyz = ((u_xlat16_1.xyz * float3(float3(_EnvironmentLight, _EnvironmentLight, _EnvironmentLight))) + float3(float3(_Emission, _Emission, _Emission)));
          u_xlat16_2_d.xyz = (u_xlat16_1.xyz * u_xlat16_2_d.xyz);
          u_xlat16_1.xyz = (u_xlat16_1.xyz * float3(float3(_ReflectionStrength, _ReflectionStrength, _ReflectionStrength)));
          float _tmp_dvx_1 = in_f.texcoord2;
          out_f.color.xyz = ((u_xlat16_1.xyz * float3(_tmp_dvx_1, _tmp_dvx_1, _tmp_dvx_1)) + u_xlat16_2_d.xyz);
          out_f.color.w = 1;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
