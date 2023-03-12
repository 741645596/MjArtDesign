// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Realtime/Effect/Unlit_Alpha_ReceiveShadow"
{
  Properties
  {
    _BaseMap ("Base Map", 2D) = "white" {}
    _BaseColor ("Base Color", Color) = (1,1,1,1)
    _ShadowColor ("Shadow Color", Color) = (0.5,0.5,0.5,1)
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
        "LIGHTMODE" = "BeforePostProcessingUI"
        "QUEUE" = "Transparent"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
      }
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha
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
      uniform sampler2D _BaseMap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float2 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 texcoord :TEXCOORD0;
          float3 texcoord1 :TEXCOORD1;
          float3 texcoord2 :TEXCOORD2;
          float4 texcoord3 :TEXCOORD3;
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
      uniform float4 _BaseMap_ST;
      uniform float4 _BaseColor;
      uniform float4 _ShadowColor;
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
          out_v.texcoord.xy = TRANSFORM_TEX(in_v.texcoord.xy, _BaseMap);
          out_v.texcoord1.xyz = u_xlat0.xyz;
          u_xlat1.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat1.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat1.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat9 = dot(u_xlat1.xyz, u_xlat1.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          out_v.texcoord2.xyz = (u_xlat1.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          out_v.texcoord3 = mul(ShadowVP, float4(u_xlat0.xyz,1.0));
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      uniform UnityPerMaterial;
      #endif
      uniform float4 _BaseMap_ST;
      uniform float4 _BaseColor;
      uniform float4 _ShadowColor;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float u_xlat0_d;
      float4 u_xlat1_d;
      float4 u_xlat16_1;
      float3 u_xlat2;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat0_d = ((-_ShadowColor.w) + 2);
          #ifdef UNITY_ADRENO_ES3
          u_xlat0_d = min(max(u_xlat0_d, 0), 1);
          #else
          u_xlat0_d = clamp(u_xlat0_d, 0, 1);
          #endif
          u_xlat16_1 = tex2D(_BaseMap, in_f.texcoord.xy);
          u_xlat2.xyz = ((_BaseColor.xyz * u_xlat16_1.xyz) + (-_ShadowColor.xyz));
          u_xlat1_d.w = (u_xlat16_1.w * _BaseColor.w);
          u_xlat1_d.xyz = ((float3(u_xlat0_d, u_xlat0_d, u_xlat0_d) * u_xlat2.xyz) + _ShadowColor.xyz);
          out_f.color = u_xlat1_d;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
