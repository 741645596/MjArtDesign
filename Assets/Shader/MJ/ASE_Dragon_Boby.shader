Shader "ASE_Dragon_Boby"
{
  Properties
  {
    _AlbedoAEmissionMask ("Albedo(A-Emission Mask)", 2D) = "white" {}
    _EmissionColorAIntensity ("Emission Color(A-Intensity)", Color) = (1,1,1,0)
    _SkyColorAIntensity ("Sky Color(A-Intensity)", Color) = (0,0,0,0)
    [Header(Specular)] _SpecularStrength ("Specular Strength", Range(0, 100)) = 1
    _SpecularColorASpecScale ("SpecularColor(A-Spec Scale)", Color) = (0.3921569,0.3921569,0.3921569,1)
    [Header(Matcap Reflection)] _MatcapIntensity ("Matcap Intensity", Range(0, 10)) = 1
    _MatcapTilling ("Matcap Tilling", Range(0, 20)) = 1
    _MatcapTex ("Matcap Tex", 2D) = "white" {}
    [HideInInspector] _texcoord ("", 2D) = "white" {}
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
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4x4 unity_MatrixV;
      uniform float4 _SpecularColorASpecScale;
      uniform float _SpecularStrength;
      uniform float4 _SkyColorAIntensity;
      uniform sampler2D _AlbedoAEmissionMask;
      uniform float4 _AlbedoAEmissionMask_ST;
      uniform sampler2D _MatcapTex;
      uniform float _MatcapTilling;
      uniform float _MatcapIntensity;
      uniform float4 _EmissionColorAIntensity;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float3 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
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
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float4 tex2DNode210_1;
          float3 normalizeResult202_2;
          float3 ase_worldNormal_3;
          float3 normalizeResult4_g16_4;
          float3 worldSpaceLightDir_5;
          float4 finalColor_6;
          float3 tmpvar_7;
          tmpvar_7 = (_WorldSpaceLightPos0.xyz - (in_f.xlv_TEXCOORD0 * _WorldSpaceLightPos0.w));
          worldSpaceLightDir_5 = tmpvar_7;
          float3 tmpvar_8;
          tmpvar_8 = normalize((normalize((_WorldSpaceCameraPos - in_f.xlv_TEXCOORD0)) + worldSpaceLightDir_5));
          normalizeResult4_g16_4 = tmpvar_8;
          float3 tmpvar_9;
          tmpvar_9 = in_f.xlv_TEXCOORD1.xyz;
          ase_worldNormal_3 = tmpvar_9;
          float3 tmpvar_10;
          tmpvar_10 = normalize(ase_worldNormal_3);
          float3 tmpvar_11;
          float3 inVec_12;
          inVec_12 = worldSpaceLightDir_5;
          tmpvar_11 = (inVec_12 * rsqrt(max(0.001, dot(inVec_12, inVec_12))));
          normalizeResult202_2 = tmpvar_11;
          float2 tmpvar_13;
          tmpvar_13 = TRANSFORM_TEX(in_f.xlv_TEXCOORD2.xy, _AlbedoAEmissionMask);
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_AlbedoAEmissionMask, tmpvar_13);
          tex2DNode210_1 = tmpvar_14;
          float tmpvar_15;
          tmpvar_15 = max(dot(normalizeResult4_g16_4, tmpvar_10), 0);
          float4 tmpvar_16;
          tmpvar_16.w = 0;
          tmpvar_16.xyz = ((_SpecularColorASpecScale.xyz * pow(tmpvar_15, (_SpecularColorASpecScale.w * 256))) * _SpecularStrength);
          float tmpvar_17;
          tmpvar_17 = max(dot(tmpvar_10, normalizeResult202_2), 0);
          float4 tmpvar_18;
          tmpvar_18.w = 0;
          tmpvar_18.xyz = float3(normalize(ase_worldNormal_3));
          float2 P_19;
          P_19 = (((mul(unity_MatrixV, tmpvar_18).xyz * 0.5) + 0.5) * _MatcapTilling).xy;
          finalColor_6 = (((tmpvar_16 + (((_SkyColorAIntensity * _SkyColorAIntensity.w) + tmpvar_17) * tex2DNode210_1)) + ((tex2D(_MatcapTex, P_19) * _SkyColorAIntensity) * _MatcapIntensity)) + ((tex2DNode210_1.w * _EmissionColorAIntensity) * _EmissionColorAIntensity.w));
          out_f.color = finalColor_6;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
