Shader "MJ/MJEye"
{
  Properties
  {
    _Lum ("Luminance", Range(0, 10)) = 4
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _MaskTex ("MaskTex (RGB)", 2D) = "white" {}
    _GLCornea ("gloss", Range(0, 200)) = 0.5
    _SpecularScale ("Specular強度", Range(0, 1)) = 0.5
    _LightPos ("高光的灯位置", Vector) = (1,1,1,1)
    _ShadowIntensity ("阴影强度", Range(0, 1)) = 0.5
    _Color ("main Color", Color) = (1,1,1,1)
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
        "SHADOWSUPPORT" = "true"
      }
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      uniform float _Lum;
      uniform float _GLCornea;
      uniform float _SpecularScale;
      uniform float4 _Color;
      uniform sampler2D _MaskTex;
      uniform sampler2D _MainTex;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float4 xlv_TEXCOORD4 :TEXCOORD4;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float4 tmpvar_1;
          tmpvar_1.w = 1;
          tmpvar_1.xyz = in_v.vertex.xyz;
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = float3(_WorldSpaceCameraPos);
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_1));
          out_v.xlv_TEXCOORD0 = in_v.texcoord.xy;
          out_v.xlv_TEXCOORD1 = mul(unity_WorldToObject, _WorldSpaceLightPos0).xyz;
          out_v.xlv_TEXCOORD2 = (mul(unity_WorldToObject, tmpvar_2).xyz - in_v.vertex.xyz);
          out_v.xlv_TEXCOORD3 = in_v.normal;
          out_v.xlv_TEXCOORD4 = mul(unity_ObjectToWorld, in_v.vertex);
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float scale_1;
          float3 N_2;
          float3 lightDir_3;
          float3 viewDir_4;
          float3 tmpvar_5;
          tmpvar_5 = normalize(in_f.xlv_TEXCOORD2);
          viewDir_4 = tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(in_f.xlv_TEXCOORD1);
          lightDir_3 = tmpvar_6;
          float3 tmpvar_7;
          tmpvar_7 = normalize((lightDir_3 + viewDir_4));
          float3 tmpvar_8;
          tmpvar_8 = normalize(in_f.xlv_TEXCOORD3);
          N_2 = tmpvar_8;
          float tmpvar_9;
          tmpvar_9 = tex2D(_MaskTex, in_f.xlv_TEXCOORD0).x;
          scale_1 = tmpvar_9;
          float4 tmpvar_10;
          tmpvar_10 = tex2D(_MainTex, in_f.xlv_TEXCOORD0);
          float4 tmpvar_11;
          tmpvar_11.w = 1;
          tmpvar_11.xyz = clamp(((((tmpvar_10 * _Color).xyz * clamp(dot(lightDir_3, tmpvar_7), 0.2, 1)) * lerp(1.5, _Lum, (1 - scale_1))) + ((pow(clamp(dot(N_2, tmpvar_7), 0, 1), _GLCornea) * _SpecularScale) * (1 - scale_1))), 0, 1);
          out_f.color = tmpvar_11;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
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
        "SHADOWSUPPORT" = "true"
      }
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      uniform float _Lum;
      uniform float _GLCornea;
      uniform float _SpecularScale;
      uniform float4 _Color;
      uniform sampler2D _MaskTex;
      uniform sampler2D _MainTex;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float4 xlv_TEXCOORD4 :TEXCOORD4;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float4 tmpvar_1;
          tmpvar_1.w = 1;
          tmpvar_1.xyz = in_v.vertex.xyz;
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = float3(_WorldSpaceCameraPos);
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_1));
          out_v.xlv_TEXCOORD0 = in_v.texcoord.xy;
          out_v.xlv_TEXCOORD1 = mul(unity_WorldToObject, _WorldSpaceLightPos0).xyz;
          out_v.xlv_TEXCOORD2 = (mul(unity_WorldToObject, tmpvar_2).xyz - in_v.vertex.xyz);
          out_v.xlv_TEXCOORD3 = in_v.normal;
          out_v.xlv_TEXCOORD4 = mul(unity_ObjectToWorld, in_v.vertex);
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float scale_1;
          float3 N_2;
          float3 lightDir_3;
          float3 viewDir_4;
          float3 tmpvar_5;
          tmpvar_5 = normalize(in_f.xlv_TEXCOORD2);
          viewDir_4 = tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(in_f.xlv_TEXCOORD1);
          lightDir_3 = tmpvar_6;
          float3 tmpvar_7;
          tmpvar_7 = normalize((lightDir_3 + viewDir_4));
          float3 tmpvar_8;
          tmpvar_8 = normalize(in_f.xlv_TEXCOORD3);
          N_2 = tmpvar_8;
          float tmpvar_9;
          tmpvar_9 = tex2D(_MaskTex, in_f.xlv_TEXCOORD0).x;
          scale_1 = tmpvar_9;
          float4 tmpvar_10;
          tmpvar_10 = tex2D(_MainTex, in_f.xlv_TEXCOORD0);
          float4 tmpvar_11;
          tmpvar_11.w = 1;
          tmpvar_11.xyz = clamp(((((tmpvar_10 * _Color).xyz * clamp(dot(lightDir_3, tmpvar_7), 0.2, 1)) * lerp(1.5, _Lum, (1 - scale_1))) + ((pow(clamp(dot(N_2, tmpvar_7), 0, 1), _GLCornea) * _SpecularScale) * (1 - scale_1))), 0, 1);
          out_f.color = tmpvar_11;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
