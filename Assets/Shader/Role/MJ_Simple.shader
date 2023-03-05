Shader "MJ/Simple"
{
  Properties
  {
    _Albedo ("Base (RGB)", 2D) = "white" {}
    _ShadowColor ("ShadowColor", Color) = (0.784,0.784,0.784,1)
    _Color ("main Color", Color) = (1,1,1,1)
    _Bump ("Normal", 2D) = "bump" {}
    [Toggle(_TATTOO)] _Tattoo ("Tattoo", float) = 0
    _TattooTex ("TattooTex", 2D) = "White" {}
    [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", float) = 2
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
        "RenderType" = "Opaque"
        "SHADOWSUPPORT" = "true"
      }
      Cull Off
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _Color;
      uniform float4 _ShadowColor;
      uniform sampler2D _Albedo;
      uniform sampler2D _Bump;
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
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float4 xlv_TEXCOORD5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
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
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          float3 tmpvar_3;
          tmpvar_3 = normalize(mul(unity_ObjectToWorld, tmpvar_1).xyz);
          float3 tmpvar_4;
          tmpvar_4 = normalize(mul(unity_ObjectToWorld, in_v.tangent).xyz);
          float3x3 tmpvar_5;
          tmpvar_5[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
          tmpvar_5[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
          tmpvar_5[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          out_v.xlv_TEXCOORD0 = in_v.texcoord.xy;
          out_v.xlv_TEXCOORD1 = mul(unity_WorldToObject, _WorldSpaceLightPos0).xyz;
          out_v.xlv_TEXCOORD2 = tmpvar_4;
          out_v.xlv_TEXCOORD3 = normalize((((tmpvar_3.yzx * tmpvar_4.zxy) - (tmpvar_3.zxy * tmpvar_4.yzx)) * in_v.tangent.w));
          out_v.xlv_TEXCOORD4 = normalize(mul(in_v.normal, tmpvar_5));
          out_v.xlv_TEXCOORD5 = mul(unity_ObjectToWorld, in_v.vertex);
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float3 normalInTangent_1;
          float4 tmpvar_2;
          tmpvar_2 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          float3 tmpvar_3;
          float3 tmpvar_4;
          tmpvar_4 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_3 = tmpvar_4;
          normalInTangent_1 = tmpvar_3;
          float3 tmpvar_5;
          tmpvar_5 = normalize(_WorldSpaceLightPos0.xyz);
          float tmpvar_6;
          tmpvar_6 = clamp(dot(normalize(normalize((((in_f.xlv_TEXCOORD3 * normalInTangent_1.y) + (in_f.xlv_TEXCOORD2 * normalInTangent_1.x)) + (in_f.xlv_TEXCOORD4 * normalInTangent_1.z)))), tmpvar_5), 0, 1);
          float4 tmpvar_7;
          tmpvar_7 = float4(tmpvar_6, tmpvar_6, tmpvar_6, tmpvar_6);
          float4 tmpvar_8;
          tmpvar_8.w = 1;
          tmpvar_8.xyz = (lerp(_ShadowColor, float4(1, 1, 1, 1), tmpvar_7).xyz * (tmpvar_2 * _Color).xyz);
          out_f.color = (tmpvar_8 * 1.1);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack "VertexLit"
}
