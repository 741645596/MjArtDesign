// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Realtime/Scene/Unlit_Alpha_ReceiveShadowOnly"
{
  Properties
  {
    _ShadowColor ("Shadow Color", Color) = (0.3,0.3,0.3,0.7)
    _ShadowAttenDir ("阴影衰减方向", Vector) = (0,0,0,0)
    _ShadowAtten ("阴影衰减值", Range(0, 10)) = 10
    _ShadowAlpha ("阴影强度", Range(0, 1)) = 0
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Transparent+100"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Transparent"
    }
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Transparent+100"
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
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
      };
      
      struct OUT_Data_Vert
      {
          float3 texcoord1 :TEXCOORD1;
          float3 texcoord2 :TEXCOORD2;
          float3 texcoord3 :TEXCOORD3;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float3 texcoord1 :TEXCOORD1;
          float3 texcoord2 :TEXCOORD2;
          float3 texcoord3 :TEXCOORD3;
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
      float u_xlat16_2;
      float u_xlat9;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0 = mul(unity_ObjectToWorld, float4(in_v.vertex.xyz,1.0));
          out_v.vertex = mul(unity_MatrixVP, u_xlat0);
          out_v.texcoord1.xyz = u_xlat0.xyz;
          u_xlat0.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat0.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat0.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          out_v.texcoord2.xyz = (u_xlat0.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          out_v.texcoord3.xyz = in_v.vertex.xyz;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      uniform UnityPerMaterial;
      #endif
      uniform float4 _ShadowColor;
      uniform float4 _ShadowAttenDir;
      uniform float _ShadowAtten;
      uniform float _ShadowAlpha;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          out_f.color.xyz = _ShadowColor.xyz;
          out_f.color.w = 0;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
