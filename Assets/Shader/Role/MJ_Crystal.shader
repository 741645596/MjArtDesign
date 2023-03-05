Shader "MJ/Crystal"
{
  Properties
  {
    _Color ("Main Color", Color) = (1,1,1,1)
    _BaseTex ("basetexture", 2D) = "white" {}
    _BaseTexStrength ("BaseTex强度", Range(0, 3)) = 1
    _EnvTex ("环境图", Cube) = "" {}
    _EnvTexStrength ("环境图强度", Range(0, 3)) = 0.2
    _DispersionTex ("色散图", Cube) = "" {}
    _DispersionTexStrength ("色散图强度", Range(0, 5)) = 3
    _ReflectStrength ("反射强度", Range(0, 5)) = 1
    _Normal ("Normal", 2D) = "bump" {}
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
      Cull Off
      // m_ProgramMask = 6
      CGPROGRAM
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixVP;
      uniform samplerCUBE _EnvTex;
      uniform sampler2D _Normal;
      uniform float _BaseTexStrength;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float4 tmpvar_1;
          tmpvar_1.w = 0;
          tmpvar_1.xyz = float3(in_v.normal);
          float4 tmpvar_2;
          float3 tmpvar_3;
          float4 tmpvar_4;
          tmpvar_4.w = 1;
          tmpvar_4.xyz = in_v.vertex.xyz;
          tmpvar_2 = mul(unity_ObjectToWorld, in_v.vertex);
          tmpvar_3 = mul(unity_ObjectToWorld, tmpvar_1).xyz;
          float3 tmpvar_5;
          tmpvar_5 = normalize(tmpvar_3);
          tmpvar_3 = tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(mul(unity_ObjectToWorld, in_v.tangent).xyz);
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_4));
          out_v.xlv_TEXCOORD0 = in_v.texcoord.xy;
          out_v.xlv_TEXCOORD1 = tmpvar_2;
          out_v.xlv_TEXCOORD2 = tmpvar_5;
          out_v.xlv_TEXCOORD3 = normalize((_WorldSpaceCameraPos - tmpvar_2.xyz));
          out_v.xlv_TEXCOORD4 = tmpvar_6;
          out_v.xlv_TEXCOORD5 = normalize((((tmpvar_5.yzx * tmpvar_6.zxy) - (tmpvar_5.zxy * tmpvar_6.yzx)) * in_v.tangent.w));
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float tmpvar_1 = 1;
          // 解决报错
          /*if (gl_FrontFacing)
          {
              tmpvar_1 = 1;
          }
          else
          {
              tmpvar_1 = (-1);
          }*/
          float3 tangentNormal_2;
          float3 tmpvar_3;
          tmpvar_3 = ((tex2D(_Normal, in_f.xlv_TEXCOORD0).xyz * 2) - 1);
          tangentNormal_2 = tmpvar_3;
          float3 I_4;
          I_4 = (-normalize(in_f.xlv_TEXCOORD3));
          float3 N_5;
          N_5 = normalize(normalize((((in_f.xlv_TEXCOORD5 * tangentNormal_2.y) + (in_f.xlv_TEXCOORD4 * tangentNormal_2.x)) + (in_f.xlv_TEXCOORD2 * tangentNormal_2.z))));
          float3 tmpvar_6;
          float tmpvar_7;
          tmpvar_7 = dot(N_5, I_4);
          float tmpvar_8;
          tmpvar_8 = (1 - ((1 - (tmpvar_7 * tmpvar_7)) * 0.1736111));
          if((tmpvar_8<0))
          {
              tmpvar_6 = float3(0, 0, 0);
          }
          else
          {
              float _tmp_dvx_80 = ((0.4166667 * I_4) - (((0.4166667 * tmpvar_7) + sqrt(tmpvar_8)) * N_5));
              tmpvar_6 = float3(_tmp_dvx_80, _tmp_dvx_80, _tmp_dvx_80);
          }
          float4 tmpvar_9;
          float _tmp_dvx_81 = texCUBE(_EnvTex, tmpvar_6);
          tmpvar_9 = float4(_tmp_dvx_81, _tmp_dvx_81, _tmp_dvx_81, _tmp_dvx_81);
          float tmpvar_10;
          tmpvar_10 = clamp(tmpvar_1, 0, 1);
          float4 tmpvar_11;
          tmpvar_11.w = 1;
          tmpvar_11.xyz = (pow((tmpvar_9 * _BaseTexStrength).xyz, float3(2.2, 2.2, 2.2)) * (float3(1, 1, 1) - float3(tmpvar_10, tmpvar_10, tmpvar_10)));
          out_f.color = tmpvar_11;
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
      //uniform float4x4 unity_MatrixVP;
      uniform samplerCUBE _DispersionTex;
      uniform samplerCUBE _EnvTex;
      uniform float _ReflectStrength;
      uniform float _BaseTexStrength;
      uniform float _EnvTexStrength;
      uniform sampler2D _BaseTex;
      uniform sampler2D _Normal;
      uniform float _DispersionTexStrength;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float4 tmpvar_1;
          tmpvar_1.w = 0;
          tmpvar_1.xyz = float3(in_v.normal);
          float4 tmpvar_2;
          float4 tmpvar_3;
          tmpvar_3.w = 1;
          tmpvar_3.xyz = in_v.vertex.xyz;
          tmpvar_2 = mul(unity_ObjectToWorld, in_v.vertex);
          float3 tmpvar_4;
          tmpvar_4 = normalize(mul(unity_ObjectToWorld, tmpvar_1).xyz);
          float3 tmpvar_5;
          tmpvar_5 = normalize(mul(unity_ObjectToWorld, in_v.tangent).xyz);
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_3));
          out_v.xlv_TEXCOORD0 = in_v.texcoord.xy;
          out_v.xlv_TEXCOORD1 = tmpvar_2;
          out_v.xlv_TEXCOORD2 = tmpvar_4;
          out_v.xlv_TEXCOORD3 = (_WorldSpaceCameraPos - tmpvar_2.xyz);
          out_v.xlv_TEXCOORD4 = tmpvar_5;
          out_v.xlv_TEXCOORD5 = normalize((((tmpvar_4.yzx * tmpvar_5.zxy) - (tmpvar_4.zxy * tmpvar_5.yzx)) * in_v.tangent.w));
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float3 dispersion_1;
          float3 envColor_2;
          float3 tangentNormal_3;
          float3 tmpvar_4;
          tmpvar_4 = ((tex2D(_Normal, in_f.xlv_TEXCOORD0).xyz * 2) - 1);
          tangentNormal_3 = tmpvar_4;
          float3 tmpvar_5;
          tmpvar_5 = normalize(normalize((((in_f.xlv_TEXCOORD5 * tangentNormal_3.y) + (in_f.xlv_TEXCOORD4 * tangentNormal_3.x)) + (in_f.xlv_TEXCOORD2 * tangentNormal_3.z))));
          float3 tmpvar_6;
          float3 I_7;
          I_7 = (-normalize(in_f.xlv_TEXCOORD3));
          tmpvar_6 = (I_7 - (2 * (dot(tmpvar_5, I_7) * tmpvar_5)));
          float4 tmpvar_8;
          float _tmp_dvx_82 = texCUBE(_EnvTex, tmpvar_6);
          tmpvar_8 = float4(_tmp_dvx_82, _tmp_dvx_82, _tmp_dvx_82, _tmp_dvx_82);
          float3 tmpvar_9;
          tmpvar_9 = (tmpvar_8 * _EnvTexStrength).xyz;
          float3 tmpvar_10;
          float _tmp_dvx_83 = (((0.33 * tmpvar_9.x) + (0.33 * tmpvar_9.y)) + (0.33 * tmpvar_9.z));
          tmpvar_10 = float3(_tmp_dvx_83, _tmp_dvx_83, _tmp_dvx_83);
          float4 tmpvar_11;
          float _tmp_dvx_84 = texCUBE(_DispersionTex, tmpvar_6);
          tmpvar_11 = float4(_tmp_dvx_84, _tmp_dvx_84, _tmp_dvx_84, _tmp_dvx_84);
          float3 tmpvar_12;
          tmpvar_12 = (tmpvar_11 * _DispersionTexStrength).xyz;
          dispersion_1 = tmpvar_12;
          float3 tmpvar_13;
          tmpvar_13 = lerp(tmpvar_10, (dispersion_1 * tmpvar_10), float3(0.25, 0.25, 0.25));
          envColor_2 = tmpvar_13;
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_BaseTex, in_f.xlv_TEXCOORD0);
          float4 tmpvar_15;
          tmpvar_15.w = 1;
          tmpvar_15.xyz = ((envColor_2 * _ReflectStrength) + (tmpvar_14.xyz * _BaseTexStrength));
          out_f.color = tmpvar_15;
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
