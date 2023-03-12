// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/TwinkleEffect"
{
  Properties
  {
    [HDR] _BaseColor ("Base Color", Color) = (1,1,1,1)
    _BaseMap ("Main Tex", 2D) = "white" {}
    [HDR] _BrightnessColor1 ("Brightness Color 1", Color) = (1,1,1,1)
    _Brightness1 ("Max Brightness", Range(1, 10)) = 1
    [HDR] _BrightnessColor2 ("Brightness Color 2", Color) = (0,0,0,0)
    _Brightness2 ("Min Brightness", Range(0, 10)) = 1
    _TexBrightness ("Tex Brightness", Range(0, 1)) = 1
    _Frequency ("Speed", Range(0, 10)) = 1
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
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_MatrixVP;
      //uniform float4 _Time;
      uniform sampler2D _BaseMap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float2 texcoord :TEXCOORD0;
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
      uniform float4 _BaseColor;
      uniform float4 _BaseMap_ST;
      uniform float4 _BrightnessColor1;
      uniform float _Brightness1;
      uniform float4 _BrightnessColor2;
      uniform float _Brightness2;
      uniform float _TexBrightness;
      uniform float _Frequency;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0;
      float4 u_xlat1;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0 = UnityObjectToClipPos(in_v.vertex);
          out_v.vertex = u_xlat0;
          out_v.texcoord.xy = TRANSFORM_TEX(in_v.texcoord.xy, _BaseMap);
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      uniform UnityPerMaterial;
      #endif
      uniform float4 _BaseColor;
      uniform float4 _BaseMap_ST;
      uniform float4 _BrightnessColor1;
      uniform float _Brightness1;
      uniform float4 _BrightnessColor2;
      uniform float _Brightness2;
      uniform float _TexBrightness;
      uniform float _Frequency;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float u_xlat0_d;
      float4 u_xlat16_0;
      float3 u_xlat16_1;
      float3 u_xlat16_2;
      float3 u_xlat16_4;
      float u_xlat16_10;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat0_d = (_Time.x * _Frequency);
          u_xlat0_d = (u_xlat0_d * 5);
          u_xlat0_d = frac(u_xlat0_d);
          u_xlat16_1.x = (u_xlat0_d * 3.14159989);
          u_xlat16_1.x = sin(u_xlat16_1.x);
          u_xlat16_1.x = ((u_xlat16_1.x * 0.5) + 0.5);
          u_xlat16_4.xyz = (_BrightnessColor1.xyz * float3(_Brightness1, _Brightness1, _Brightness1));
          u_xlat16_2.xyz = ((float3(_Brightness2, _Brightness2, _Brightness2) * _BrightnessColor2.xyz) + (-u_xlat16_4.xyz));
          u_xlat16_1.xyz = ((u_xlat16_1.xxx * u_xlat16_2.xyz) + u_xlat16_4.xyz);
          u_xlat16_0 = tex2D(_BaseMap, in_f.texcoord.xy);
          u_xlat16_10 = (u_xlat16_0.w + (-1));
          u_xlat16_10 = ((_TexBrightness * u_xlat16_10) + 1);
          u_xlat16_1.xyz = (u_xlat16_1.xyz * float3(u_xlat16_10, u_xlat16_10, u_xlat16_10));
          out_f.color.xyz = (u_xlat16_0.xyz * u_xlat16_1.xyz);
          out_f.color.w = u_xlat16_0.w;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
