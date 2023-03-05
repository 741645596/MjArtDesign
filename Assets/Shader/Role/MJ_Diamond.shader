Shader "MJ/Diamond"
{
  Properties
  {
    _Color ("Color", Color) = (1,1,1,1)
    [NoScaleOffset] _RefractTex ("折射球", Cube) = "" {}
    [NoScaleOffset] _ReflectTex ("反射球", Cube) = "" {}
    _ReflectionStrength ("反射强度", Range(0, 2)) = 1
    _EnvironmentLight ("环境光强度", Range(0, 2)) = 1
    _Emission ("自发光", Range(0, 2)) = 0
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Transparent"
    }
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "QUEUE" = "Transparent"
      }
      ZWrite Off
      Cull Front
      // m_ProgramMask = 6
      CGPROGRAM
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _Color;
      uniform samplerCUBE _RefractTex;
      uniform float _Emission;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
      };
      
      struct OUT_Data_Vert
      {
          float3 xlv_TEXCOORD0 :TEXCOORD0;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float3 xlv_TEXCOORD0 :TEXCOORD0;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float3 tmpvar_1;
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          float4 tmpvar_3;
          tmpvar_3.w = 1;
          tmpvar_3.xyz = float3(_WorldSpaceCameraPos);
          float3 tmpvar_4;
          tmpvar_4 = normalize((mul(unity_WorldToObject, tmpvar_3).xyz - in_v.vertex.xyz));
          float _tmp_dvx_85 = ((2 * (dot(in_v.normal, tmpvar_4) * in_v.normal)) - tmpvar_4);
          tmpvar_1 = float3(_tmp_dvx_85, _tmp_dvx_85, _tmp_dvx_85);
          float4 tmpvar_5;
          tmpvar_5.w = 0;
          tmpvar_5.xyz = float3(tmpvar_1);
          float3 tmpvar_6;
          tmpvar_6 = mul(unity_ObjectToWorld, tmpvar_5).xyz;
          tmpvar_1 = tmpvar_6;
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          out_v.xlv_TEXCOORD0 = tmpvar_6;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float3 refraction_1;
          float3 tmpvar_2;
          tmpvar_2 = (texCUBE(_RefractTex, in_f.xlv_TEXCOORD0).xyz * _Color.xyz);
          refraction_1 = tmpvar_2;
          float4 tmpvar_3;
          tmpvar_3.w = 1;
          tmpvar_3.xyz = float3((refraction_1 * _Emission));
          out_f.color = tmpvar_3;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: 
    {
      Tags
      { 
        "QUEUE" = "Transparent"
      }
      Blend One One
      // m_ProgramMask = 6
      CGPROGRAM
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _Color;
      uniform samplerCUBE _RefractTex;
      uniform samplerCUBE _ReflectTex;
      uniform float _ReflectionStrength;
      uniform float _EnvironmentLight;
      uniform float _Emission;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
      };
      
      struct OUT_Data_Vert
      {
          float3 xlv_TEXCOORD0 :TEXCOORD0;
          float xlv_TEXCOORD1 :TEXCOORD1;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float3 xlv_TEXCOORD0 :TEXCOORD0;
          float xlv_TEXCOORD1 :TEXCOORD1;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float3 tmpvar_1;
          float tmpvar_2;
          float4 tmpvar_3;
          tmpvar_3.w = 1;
          tmpvar_3.xyz = in_v.vertex.xyz;
          float4 tmpvar_4;
          tmpvar_4.w = 1;
          tmpvar_4.xyz = float3(_WorldSpaceCameraPos);
          float3 tmpvar_5;
          tmpvar_5 = normalize((mul(unity_WorldToObject, tmpvar_4).xyz - in_v.vertex.xyz));
          float _tmp_dvx_86 = ((2 * (dot(in_v.normal, tmpvar_5) * in_v.normal)) - tmpvar_5);
          tmpvar_1 = float3(_tmp_dvx_86, _tmp_dvx_86, _tmp_dvx_86);
          float4 tmpvar_6;
          tmpvar_6.w = 0;
          tmpvar_6.xyz = float3(tmpvar_1);
          float3 tmpvar_7;
          tmpvar_7 = mul(unity_ObjectToWorld, tmpvar_6).xyz;
          tmpvar_1 = tmpvar_7;
          float tmpvar_8;
          tmpvar_8 = clamp(dot(in_v.normal, tmpvar_5), 0, 1);
          tmpvar_2 = (1 - tmpvar_8);
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_3));
          out_v.xlv_TEXCOORD0 = tmpvar_7;
          out_v.xlv_TEXCOORD1 = tmpvar_2;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float4 reflection_1;
          float3 refraction_2;
          float3 tmpvar_3;
          tmpvar_3 = (texCUBE(_RefractTex, in_f.xlv_TEXCOORD0).xyz * _Color.xyz);
          refraction_2 = tmpvar_3;
          float4 tmpvar_4;
          tmpvar_4 = texCUBE(_ReflectTex, in_f.xlv_TEXCOORD0);
          reflection_1 = tmpvar_4;
          float4 tmpvar_5;
          tmpvar_5.w = 1;
          tmpvar_5.xyz = (((reflection_1 * _ReflectionStrength) * in_f.xlv_TEXCOORD1).xyz + (refraction_2 * ((reflection_1.xyz * _EnvironmentLight) + _Emission)));
          out_f.color = tmpvar_5;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 3, name: 
    {
      Tags
      { 
      }
      ZClip Off
      ZWrite Off
      Cull Off
      Stencil
      { 
        Ref 0
        ReadMask 0
        WriteMask 0
        Pass Keep
        Fail Keep
        ZFail Keep
        PassFront Keep
        FailFront Keep
        ZFailFront Keep
        PassBack Keep
        FailBack Keep
        ZFailBack Keep
      } 
      // m_ProgramMask = 0
      
    } // end phase
  }
  FallBack Off
}
