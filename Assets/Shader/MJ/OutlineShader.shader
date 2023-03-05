Shader "OutlineShader"
{
  Properties
  {
    _OutlineColor ("Outline Color", Color) = (0,0,0,0)
    _OutlineWidth ("Outline Width", float) = 20
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
      //uniform float4x4 unity_MatrixVP;
      uniform float _OutlineWidth;
      uniform float4 _OutlineColor;
      struct appdata_t
      {
          float4 vertex :POSITION;
      };
      
      struct OUT_Data_Vert
      {
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 vertex :Position;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float4 tmpvar_1;
          tmpvar_1.w = in_v.vertex.w;
          tmpvar_1.xyz = (in_v.vertex.xyz + ((_OutlineWidth * (-0.001)) * normalize((in_v.vertex.xyz - _WorldSpaceCameraPos))));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = tmpvar_1.xyz;
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float4 finalColor_1;
          finalColor_1 = _OutlineColor;
          out_f.color = finalColor_1;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
