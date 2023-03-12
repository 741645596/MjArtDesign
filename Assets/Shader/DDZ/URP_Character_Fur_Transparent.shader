// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/Fur_Transparent"
{
  Properties
  {
    [MaterialEnum(off,0,on,1)] _ZWrite0 ("深度开启？", float) = 0
    _BaseMap ("基础纹理贴图", 2D) = "white" {}
    [Space] _OcclusionColor ("Occlusion Color", Color) = (1,1,1,1)
    _OColor ("暗部染色", Color) = (1,1,1,1)
    _ShadowColor ("阴影颜色", Color) = (0.5,0.5,0.5,1)
    [Space] [NoScaleOffset] _NoiseTex ("毛发噪声贴图", 2D) = "white" {}
    _NoiseAndFlowmapTiling ("XY:毛发贴图Tiling; ZW:毛发噪声粗细贴图Tiling", Vector) = (1,1,1,1)
    _FurLength ("毛发长度", Range(0, 0.1)) = 0.1
    _FurCut ("毛发裁剪粗细", Range(0, 1)) = 0.2
    [Space] [Toggle] _UseOSoffset ("使用世界方向生长", float) = 0
    _FurUVoffset ("XYZ: 毛发生长方向", Vector) = (0,-1,0,1)
    [Space(30)] [Header(Direct Diffuse)] [Space(10)] _LightFilter ("平行光毛发穿透", Range(0, 2)) = 1
    _FresnelLV ("毛发边缘亮度", Range(0.1, 200)) = 1
    [Space(30)] [Header(Direct Specular)] [Space(10)] _SpecularShift ("各向异性高光偏移", float) = 0
    _SpecularColor ("高光颜色", Color) = (1,1,1,1)
    _SpecPower ("高光范围", Range(0.1, 1)) = 0.5
    _SpecIntensity ("高光强度", Range(0, 5)) = 1
    _Occlusion ("高光noise", Range(-1, 1)) = 0.2
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Transparent"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Transparent"
    }
    Pass // ind: 1, name: Forward
    {
      Name "Forward"
      Tags
      { 
        "LIGHTMODE" = "BeforeTransparent"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
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
      //uniform float4x4 unity_MatrixVP;
      uniform float _FUR_OFFSET;
      uniform sampler2D _BaseMap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float2 texcoord :TEXCOORD0;
          float3 normal :NORMAL0;
      };
      
      struct OUT_Data_Vert
      {
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
          float4 texcoord2 :TEXCOORD2;
          float4 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float3 texcoord5 :TEXCOORD5;
          float3 texcoord6 :TEXCOORD6;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 texcoord :TEXCOORD0;
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
      uniform float4 _BaseMap_ST;
      uniform float4 _NoiseAndFlowmapTiling;
      uniform float _FurLength;
      uniform float _UseOSoffset;
      uniform float4 _FurUVoffset;
      uniform float _FurCut;
      uniform float _Occlusion;
      uniform float4 _OcclusionColor;
      uniform float4 _OColor;
      uniform float4 _ShadowColor;
      uniform float _RimStrength;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _FresnelLV;
      uniform float _LightFilter;
      uniform float _SpecularShift;
      uniform float _SpecPower;
      uniform float _SpecIntensity;
      uniform float4 _SpecularColor;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0;
      float3 u_xlat16_0;
      float3 u_xlat1;
      float2 u_xlat16_2;
      float2 u_xlat16_6;
      float u_xlat10;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat16_0.xy = (float2(_FUR_OFFSET, _FUR_OFFSET) * _FurUVoffset.xy);
          u_xlat1.xy = (u_xlat16_0.xy * float2(0.100000001, 0.100000001));
          u_xlat16_0.xy = ((float2(float2(_UseOSoffset, _UseOSoffset)) * (-u_xlat1.xy)) + u_xlat1.xy);
          u_xlat16_6.xy = (float2(1, 1) / _NoiseAndFlowmapTiling.xy);
          u_xlat16_2.xy = TRANSFORM_TEX(in_v.texcoord.xy, _BaseMap);
          u_xlat16_6.xy = ((u_xlat16_0.xy * u_xlat16_6.xy) + u_xlat16_2.xy);
          out_v.texcoord.zw = ((u_xlat16_2.xy * _NoiseAndFlowmapTiling.xy) + u_xlat16_0.xy);
          u_xlat1.x = tex2Dlod(_BaseMap, float4(float3(u_xlat16_6.xy, 0), 0)).w;
          out_v.texcoord.xy = u_xlat16_6.xy;
          u_xlat16_0.xyz = (in_v.normal.xyz * float3(_FurLength, _FurLength, _FurLength));
          u_xlat16_0.xyz = (u_xlat1.xxx * u_xlat16_0.xyz);
          u_xlat16_0.xyz = ((u_xlat16_0.xyz * float3(0.5, 0.5, 0.5)) + in_v.vertex.xyz);
          u_xlat1.xyz = mul(unity_ObjectToWorld, u_xlat16_0.xyz);
          u_xlat0 = (u_xlat1.yyyy * conv_mxt4x4_1(unity_MatrixVP));
          u_xlat0 = ((conv_mxt4x4_0(unity_MatrixVP) * u_xlat1.xxxx) + u_xlat0);
          u_xlat0 = ((conv_mxt4x4_2(unity_MatrixVP) * u_xlat1.zzzz) + u_xlat0);
          out_v.texcoord3.xyz = u_xlat1.xyz;
          u_xlat0 = (u_xlat0 + conv_mxt4x4_3(unity_MatrixVP));
          out_v.vertex = u_xlat0;
          out_v.texcoord1 = float4(0, 0, 0, 0);
          out_v.texcoord2 = float4(0, 0, 0, 0);
          out_v.texcoord3.w = 0;
          u_xlat1.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat1.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat1.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat10 = dot(u_xlat1.xyz, u_xlat1.xyz);
          u_xlat10 = max(u_xlat10, 0);
          u_xlat16_2.x = rsqrt(u_xlat10);
          u_xlat1.xyz = (u_xlat1.xyz * u_xlat16_2.xxx);
          out_v.texcoord4.xyz = u_xlat1.xyz;
          out_v.texcoord5.xyz = float3(0, 0, 0);
          out_v.texcoord6.xyz = float3(0, 0, 0);
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      float3 u_xlat16_0_d;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0_d.xyz = tex2D(_BaseMap, in_f.texcoord.xy).xyz;
          out_f.color.xyz = u_xlat16_0_d.xyz;
          out_f.color.w = 1;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: Forward
    {
      Name "Forward"
      Tags
      { 
        "LIGHTMODE" = "FurRendererLayer"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha
      ColorMask RGB
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile _LOD100
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_MatrixVP;
      struct appdata_t
      {
          float4 vertex :POSITION0;
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
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0 = UnityObjectToClipPos(in_v.vertex);
          out_v.vertex = u_xlat0;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          out_f.color = float4(0, 0, 0, 0);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
