Shader "MJ/GlassRefraction"
{
  Properties
  {
    _MainTex ("Texture", 2D) = "white" {}
    _BumpMap ("Normal Map", 2D) = "bump" {}
    _Cubemap ("Environment Map", Cube) = "_Skybox" {}
    _Distortion ("Distortion", Range(0, 100)) = 10
    _RefractAmount ("Refract Amount", Range(0, 1)) = 1
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Transparent"
      "RenderType" = "Opaque"
    }
    Pass // ind: 1, name: 
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
    Pass // ind: 2, name: 
    {
      Tags
      { 
        "QUEUE" = "Transparent"
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
      #define conv_mxt3x3_0(mat4x4) float3(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x)
      #define conv_mxt3x3_1(mat4x4) float3(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y)
      #define conv_mxt3x3_2(mat4x4) float3(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _MainTex_ST;
      uniform float4 _BumpMap_ST;
      //uniform float3 _WorldSpaceCameraPos;
      uniform sampler2D _MainTex;
      uniform sampler2D _BumpMap;
      uniform samplerCUBE _Cubemap;
      uniform float _Distortion;
      uniform float _RefractAmount;
      uniform sampler2D _RefractionTex;
      uniform float4 _RefractionTex_TexelSize;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD4 :TEXCOORD4;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 xlv_TEXCOORD3 :TEXCOORD3;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD4 :TEXCOORD4;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 xlv_TEXCOORD3 :TEXCOORD3;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float4 tmpvar_1;
          float4 tmpvar_2;
          float4 tmpvar_3;
          tmpvar_3.w = 1;
          tmpvar_3.xyz = in_v.vertex.xyz;
          tmpvar_2 = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_3));
          tmpvar_1.xy = TRANSFORM_TEX(in_v.texcoord.xy, _MainTex);
          tmpvar_1.zw = TRANSFORM_TEX(in_v.texcoord.xy, _BumpMap);
          float4 o_4;
          float4 tmpvar_5;
          tmpvar_5 = (tmpvar_2 * 0.5);
          o_4.xy = (tmpvar_5.xy + tmpvar_5.w);
          o_4.zw = tmpvar_2.zw;
          float3 tmpvar_6;
          tmpvar_6 = mul(unity_ObjectToWorld, in_v.vertex).xyz;
          float3x3 tmpvar_7;
          tmpvar_7[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
          tmpvar_7[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
          tmpvar_7[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
          float3 tmpvar_8;
          tmpvar_8 = normalize(mul(in_v.normal, tmpvar_7));
          float3x3 tmpvar_9;
          tmpvar_9[0] = conv_mxt4x4_0(unity_ObjectToWorld).xyz;
          tmpvar_9[1] = conv_mxt4x4_1(unity_ObjectToWorld).xyz;
          tmpvar_9[2] = conv_mxt4x4_2(unity_ObjectToWorld).xyz;
          float3 tmpvar_10;
          tmpvar_10 = normalize(mul(tmpvar_9, in_v.tangent.xyz));
          float3 tmpvar_11;
          tmpvar_11 = (((tmpvar_10.yzx * tmpvar_8.zxy) - (tmpvar_10.zxy * tmpvar_8.yzx)) * in_v.tangent.w);
          float4 tmpvar_12;
          tmpvar_12.x = tmpvar_10.x;
          tmpvar_12.y = tmpvar_11.x;
          tmpvar_12.z = tmpvar_8.x;
          tmpvar_12.w = tmpvar_6.x;
          float4 tmpvar_13;
          tmpvar_13.x = tmpvar_10.y;
          tmpvar_13.y = tmpvar_11.y;
          tmpvar_13.z = tmpvar_8.y;
          tmpvar_13.w = tmpvar_6.y;
          float4 tmpvar_14;
          tmpvar_14.x = tmpvar_10.z;
          tmpvar_14.y = tmpvar_11.z;
          tmpvar_14.z = tmpvar_8.z;
          tmpvar_14.w = tmpvar_6.z;
          out_v.xlv_TEXCOORD0 = tmpvar_1;
          out_v.vertex = tmpvar_2;
          out_v.xlv_TEXCOORD4 = o_4;
          out_v.xlv_TEXCOORD1 = tmpvar_12;
          out_v.xlv_TEXCOORD2 = tmpvar_13;
          out_v.xlv_TEXCOORD3 = tmpvar_14;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float4 tmpvar_1;
          tmpvar_1.zw = in_f.xlv_TEXCOORD4.zw;
          float3 worldNormal_2;
          float3 worldViewDir_3;
          float3 tmpvar_4;
          tmpvar_4.x = in_f.xlv_TEXCOORD1.w;
          tmpvar_4.y = in_f.xlv_TEXCOORD2.w;
          tmpvar_4.z = in_f.xlv_TEXCOORD3.w;
          float3 tmpvar_5;
          float3 tmpvar_6;
          float3 tmpvar_7;
          tmpvar_5 = in_f.xlv_TEXCOORD1.xyz;
          tmpvar_6 = in_f.xlv_TEXCOORD2.xyz;
          tmpvar_7 = in_f.xlv_TEXCOORD3.xyz;
          float3x3 tmpvar_8;
          conv_mxt3x3_0(tmpvar_8).x = tmpvar_5.x;
          conv_mxt3x3_0(tmpvar_8).y = tmpvar_6.x;
          conv_mxt3x3_0(tmpvar_8).z = tmpvar_7.x;
          conv_mxt3x3_1(tmpvar_8).x = tmpvar_5.y;
          conv_mxt3x3_1(tmpvar_8).y = tmpvar_6.y;
          conv_mxt3x3_1(tmpvar_8).z = tmpvar_7.y;
          conv_mxt3x3_2(tmpvar_8).x = tmpvar_5.z;
          conv_mxt3x3_2(tmpvar_8).y = tmpvar_6.z;
          conv_mxt3x3_2(tmpvar_8).z = tmpvar_7.z;
          float3 tmpvar_9;
          tmpvar_9 = normalize((_WorldSpaceCameraPos - tmpvar_4));
          worldViewDir_3 = tmpvar_9;
          float3 tmpvar_10;
          tmpvar_10 = ((tex2D(_BumpMap, in_f.xlv_TEXCOORD0.zw).xyz * 2) - 1);
          float3 tmpvar_11;
          tmpvar_11 = mul(tmpvar_8, tmpvar_10);
          worldNormal_2 = tmpvar_11;
          tmpvar_1.xy = (in_f.xlv_TEXCOORD4.xy + ((tmpvar_10.xy * _Distortion) * _RefractionTex_TexelSize.xy));
          float2 P_12;
          P_12 = (tmpvar_1.xy / in_f.xlv_TEXCOORD4.w);
          float3 I_13;
          I_13 = (-worldViewDir_3);
          float4 tmpvar_14;
          tmpvar_14.w = 1;
          tmpvar_14.xyz = ((tex2D(_RefractionTex, P_12).xyz * _RefractAmount) + ((tex2D(_MainTex, in_f.xlv_TEXCOORD0.xy).xyz * texCUBE(_Cubemap, (I_13 - (2 * (dot(worldNormal_2, I_13) * worldNormal_2)))).xyz) * (1 - _RefractAmount)));
          out_f.color = tmpvar_14;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack "Diffuse"
}
