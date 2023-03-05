Shader "ASE_Outer"
{
  Properties
  {
    _BaseColor ("Base Color", Color) = (1,0.6440162,0.007352948,1)
    _UVxyTileszwMasks ("UV(xy-Tiles, zw-Masks)", Vector) = (1,1,1,1)
    _AlphaGradient ("Alpha Gradient", Range(0, 0.5)) = 0
    [Toggle(_USEVERTEXCOLORMASK_ON)] _UseVertexColorMask ("Use Vertex Color Mask", float) = 0
    [Header(Specular)] _SpecularIntensity ("Specular Intensity", Range(0, 5)) = 1
    _SpecularScale ("Specular Scale", Range(0.1, 256)) = 1
    _SpecularColor ("SpecularColor", Color) = (0.3921569,0.3921569,0.3921569,1)
    [Header(Tile)] _RTile1GTile2 ("R-Tile1 G-Tile2", 2D) = "white" {}
    [HDR] _TileColor ("Tile Color", Color) = (1,0.9344828,0.875,0)
    _Tile1Emission ("Tile1 Emission", Range(0, 100)) = 1
    _Tile2Emission ("Tile2 Emission", Range(0, 100)) = 1
    [Header(Animation)] _RMask1GMask2 ("R-Mask1 G-Mask2", 2D) = "white" {}
    _Speed ("Speed", float) = 1
  }
  SubShader
  {
    Tags
    { 
      "RenderType" = "Opaque"
    }
    LOD 100
    Pass // ind: 1, name: UNLIT
    {
      Name "UNLIT"
      Tags
      { 
        "LIGHTMODE" = "FORWARDBASE"
        "RenderType" = "Opaque"
      }
      LOD 100
      ZWrite Off
      Blend One OneMinusSrcAlpha
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
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      //uniform float4 _Time;
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _WorldSpaceLightPos0;
      uniform float4 _SpecularColor;
      uniform float _SpecularScale;
      uniform float _SpecularIntensity;
      uniform float _AlphaGradient;
      uniform float4 _BaseColor;
      uniform float _Tile1Emission;
      uniform sampler2D _RTile1GTile2;
      uniform float4 _UVxyTileszwMasks;
      uniform sampler2D _RMask1GMask2;
      uniform float _Speed;
      uniform float4 _TileColor;
      uniform float _Tile2Emission;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float4 color :COLOR;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float3 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 xlv_COLOR :COLOR;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float3 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float3 tmpvar_1;
          tmpvar_1 = in_v.normal;
          float4 tmpvar_2;
          tmpvar_2.w = in_v.vertex.w;
          float3 ase_worldNormal_3;
          float4 tmpvar_4;
          float4 tmpvar_5;
          float3 norm_6;
          norm_6 = tmpvar_1;
          float3x3 tmpvar_7;
          tmpvar_7[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
          tmpvar_7[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
          tmpvar_7[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
          float3 tmpvar_8;
          tmpvar_8 = normalize(mul(norm_6, tmpvar_7));
          ase_worldNormal_3 = tmpvar_8;
          tmpvar_4.xyz = float3(ase_worldNormal_3);
          tmpvar_5.xy = in_v.texcoord.xy;
          tmpvar_4.w = 0;
          tmpvar_5.zw = float2(0, 0);
          tmpvar_2.xyz = in_v.vertex.xyz;
          float4 tmpvar_9;
          tmpvar_9.w = 1;
          tmpvar_9.xyz = tmpvar_2.xyz;
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_9));
          out_v.xlv_TEXCOORD0 = mul(unity_ObjectToWorld, in_v.vertex).xyz;
          out_v.xlv_TEXCOORD1 = tmpvar_4;
          out_v.xlv_TEXCOORD2 = tmpvar_5;
          out_v.xlv_COLOR = in_v.color;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float3 temp_output_156_0_1;
          float4 tex2DNode138_2;
          float4 tex2DNode137_3;
          float3 normalizeResult201_4;
          float3 ase_worldNormal_5;
          float3 normalizeResult4_g16_6;
          float3 worldSpaceLightDir_7;
          float4 finalColor_8;
          float3 tmpvar_9;
          tmpvar_9 = (_WorldSpaceLightPos0.xyz - (in_f.xlv_TEXCOORD0 * _WorldSpaceLightPos0.w));
          worldSpaceLightDir_7 = tmpvar_9;
          float3 tmpvar_10;
          tmpvar_10 = normalize((normalize((_WorldSpaceCameraPos - in_f.xlv_TEXCOORD0)) + worldSpaceLightDir_7));
          normalizeResult4_g16_6 = tmpvar_10;
          float3 tmpvar_11;
          tmpvar_11 = in_f.xlv_TEXCOORD1.xyz;
          ase_worldNormal_5 = tmpvar_11;
          float3 tmpvar_12;
          tmpvar_12 = normalize(ase_worldNormal_5);
          float3 tmpvar_13;
          float3 inVec_14;
          inVec_14 = worldSpaceLightDir_7;
          tmpvar_13 = (inVec_14 * rsqrt(max(0.001, dot(inVec_14, inVec_14))));
          normalizeResult201_4 = tmpvar_13;
          float4 tmpvar_15;
          float2 P_16;
          P_16 = (in_f.xlv_TEXCOORD2.xy * _UVxyTileszwMasks.xy);
          tmpvar_15 = tex2D(_RTile1GTile2, P_16);
          tex2DNode137_3 = tmpvar_15;
          float4 tmpvar_17;
          float2 P_18;
          P_18 = ((in_f.xlv_TEXCOORD2.xy * _UVxyTileszwMasks.zw) + (_Time.y * _Speed));
          tmpvar_17 = tex2D(_RMask1GMask2, P_18);
          tex2DNode138_2 = tmpvar_17;
          float tmpvar_19;
          tmpvar_19 = pow(max(dot(normalizeResult4_g16_6, tmpvar_12), 0), _SpecularScale);
          float tmpvar_20;
          tmpvar_20 = max(dot(tmpvar_12, normalizeResult201_4), 0);
          float3 tmpvar_21;
          tmpvar_21 = ((((_SpecularColor.xyz * tmpvar_19) * _SpecularIntensity) + (((tmpvar_20 * 0.5) + _AlphaGradient) * _BaseColor.xyz)) + ((_Tile1Emission * ((tex2DNode137_3.x * tex2DNode138_2.x) * _TileColor.xyz)) + ((_TileColor.xyz * (tex2DNode137_3.y * tex2DNode138_2.y)) * _Tile2Emission)));
          temp_output_156_0_1 = tmpvar_21;
          float4 tmpvar_22;
          tmpvar_22.w = 0;
          tmpvar_22.xyz = float3(temp_output_156_0_1);
          finalColor_8 = tmpvar_22;
          out_f.color = finalColor_8;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
