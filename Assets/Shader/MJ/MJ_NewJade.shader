Shader "MJ/NewJade"
{
  Properties
  {
    _MainTex ("RGB(Diffuse), A(Mask)", 2D) = "white" {}
    _DiffuseIntensity ("DiffuseIntensity", Range(0, 1)) = 0.877
    _MainColor ("MainColor", Color) = (1,1,1,1)
    _AmbientCube ("AmbientCube", Cube) = "white" {}
    _MinDist ("MinDist", float) = 0.01
    _MaxDist ("MaxDist", float) = 0.9
    _AmbientMin ("AmbientMin", Range(-1, 1)) = 0.4
    [Toggle(_SPEC1)] _Specular1 ("Specular1", float) = 0
    _Exp ("SpecularExp", Range(0, 80)) = 15
    _Intensity ("SpecularIntensity", Range(0, 20)) = 0.28
    _Offset ("SpecularPositionController", Vector) = (0.03,2.34,2.96,1)
    [Toggle(_SPEC2)] _Specular2 ("Specular2", float) = 0
    _Exp2 ("SpecularExp2", Range(0, 80)) = 15
    _Intensity2 ("SpecularIntensity2", Range(0, 20)) = 0.28
    _Offset2 ("SpecularPositionController2", Vector) = (0.03,2.34,2.96,1)
  }
  SubShader
  {
    Tags
    { 
      "LIGHTMODE" = "FORWARDBASE"
      "QUEUE" = "Geometry"
      "RenderType" = "Opaque"
    }
    LOD 200
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "LIGHTMODE" = "FORWARDBASE"
        "QUEUE" = "Geometry"
        "RenderType" = "Opaque"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
      Blend SrcAlpha OneMinusSrcAlpha
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
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      uniform sampler2D _MainTex;
      uniform float _DiffuseIntensity;
      uniform float4 _MainColor;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_NORMAL :NORMAL;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
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
          float3 tmpvar_2;
          tmpvar_2 = mul(unity_ObjectToWorld, tmpvar_1).xyz;
          float3x3 tmpvar_3;
          tmpvar_3[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
          tmpvar_3[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
          tmpvar_3[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
          float4 tmpvar_4;
          tmpvar_4.w = 1;
          tmpvar_4.xyz = float3(tmpvar_2);
          out_v.vertex = mul(unity_MatrixVP, tmpvar_4);
          out_v.xlv_TEXCOORD0 = in_v.texcoord.xy;
          out_v.xlv_NORMAL = normalize(mul(in_v.normal, tmpvar_3));
          out_v.xlv_TEXCOORD1 = tmpvar_2;
          out_v.xlv_TEXCOORD2 = (-normalize((_WorldSpaceCameraPos - tmpvar_2)));
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float3 col_1;
          float4 DiffuseTex_2;
          float4 tmpvar_3;
          tmpvar_3 = tex2D(_MainTex, in_f.xlv_TEXCOORD0);
          DiffuseTex_2 = tmpvar_3;
          float3 tmpvar_4;
          tmpvar_4 = (DiffuseTex_2 * _DiffuseIntensity).xyz;
          col_1 = tmpvar_4;
          float4 tmpvar_5;
          tmpvar_5.w = 1;
          tmpvar_5.xyz = float3(col_1);
          float4 tmpvar_6;
          tmpvar_6 = (tmpvar_5 * _MainColor);
          out_f.color = tmpvar_6;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack "Diffuse"
}
