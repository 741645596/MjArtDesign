Shader "MJ/Diffuse"
{
  Properties
  {
    _Color ("Main Color", Color) = (1,1,1,1)
    _MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
    _BumpMap ("Normalmap", 2D) = "bump" {}
    _CubeTex ("Cube Tex", Cube) = "" {}
    _ReflectIntensity ("reflect rate", Range(0, 1)) = 0.5
    [KeywordEnum(Off, On)] _USEREFLECT ("reflect", float) = 0
    _ReflectMask ("mask", 2D) = "white" {}
    [KeywordEnum(Off, On)] _MIRROR ("mirror", float) = 0
    _MirrorMask ("MirrorMask (RGB)", 2D) = "white" {}
    _Alpha ("MirrorTransparent", float) = 1
    _ReflectionTex ("", 2D) = "white" {}
  }
  SubShader
  {
    Tags
    { 
    }
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "LIGHTMODE" = "FORWARDBASE"
      }
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile _MIRROR_OFF _USEREFLECT_OFF LIGHTMAP_OFF
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _ProjectionParams;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixVP;
      //uniform float4 _WorldSpaceLightPos0;
      uniform sampler2D _MainTex;
      uniform sampler2D _BumpMap;
      uniform float4 _Color;
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
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD7 :TEXCOORD7;
          float4 xlv_TEXCOORD8 :TEXCOORD8;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
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
          float3 tmpvar_2;
          float4 tmpvar_3;
          float4 tmpvar_4;
          tmpvar_4.w = 1;
          tmpvar_4.xyz = in_v.vertex.xyz;
          tmpvar_3 = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_4));
          float3 tmpvar_5;
          tmpvar_5 = mul(unity_ObjectToWorld, in_v.vertex).xyz;
          float3 tmpvar_6;
          tmpvar_6 = normalize((_WorldSpaceCameraPos - tmpvar_5));
          float4 tmpvar_7;
          tmpvar_7.w = 0;
          tmpvar_7.xyz = tmpvar_1.xyz;
          float3 tmpvar_8;
          tmpvar_8 = normalize(mul(unity_ObjectToWorld, tmpvar_7).xyz);
          float4 tmpvar_9;
          tmpvar_9.w = 0;
          tmpvar_9.xyz = in_v.tangent.xyz;
          float3 tmpvar_10;
          tmpvar_10 = normalize(mul(unity_ObjectToWorld, tmpvar_9).xyz);
          float3 I_11;
          I_11 = (-tmpvar_6);
          float3 tmpvar_12;
          tmpvar_12 = normalize((I_11 - (2 * (dot(tmpvar_8, I_11) * tmpvar_8))));
          tmpvar_2 = tmpvar_12;
          float4 o_13;
          float4 tmpvar_14;
          tmpvar_14 = (tmpvar_3 * 0.5);
          float2 tmpvar_15;
          tmpvar_15.x = tmpvar_14.x;
          tmpvar_15.y = (tmpvar_14.y * _ProjectionParams.x);
          o_13.xy = (tmpvar_15 + tmpvar_14.w);
          o_13.zw = tmpvar_3.zw;
          out_v.vertex = tmpvar_3;
          out_v.xlv_TEXCOORD0 = in_v.texcoord.xy;
          out_v.xlv_TEXCOORD3 = tmpvar_6;
          out_v.xlv_TEXCOORD2 = tmpvar_8;
          out_v.xlv_TEXCOORD1 = normalize((((tmpvar_8.yzx * tmpvar_10.zxy) - (tmpvar_8.zxy * tmpvar_10.yzx)) * in_v.tangent.w));
          out_v.xlv_TEXCOORD4 = tmpvar_10;
          out_v.xlv_TEXCOORD5 = tmpvar_5;
          out_v.xlv_TEXCOORD7 = tmpvar_2;
          out_v.xlv_TEXCOORD8 = o_13;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float4 maincolor_1;
          float4 tmpvar_2;
          tmpvar_2 = tex2D(_MainTex, in_f.xlv_TEXCOORD0);
          maincolor_1 = tmpvar_2;
          float3 tmpvar_3;
          tmpvar_3 = normalize(((tex2D(_BumpMap, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          float3 normal_4;
          normal_4 = tmpvar_3;
          float tmpvar_5;
          tmpvar_5 = clamp(dot(normalize((((in_f.xlv_TEXCOORD1 * normal_4.y) + (in_f.xlv_TEXCOORD4 * normal_4.x)) + (in_f.xlv_TEXCOORD2 * normal_4.z))), normalize(_WorldSpaceLightPos0.xyz)), 0, 1);
          maincolor_1.xyz = (maincolor_1.xyz * (_Color.xyz * ((tmpvar_5 * 0.5) + 0.5)));
          float4 tmpvar_6;
          tmpvar_6.w = 1;
          tmpvar_6.xyz = maincolor_1.xyz;
          out_f.color = tmpvar_6;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
