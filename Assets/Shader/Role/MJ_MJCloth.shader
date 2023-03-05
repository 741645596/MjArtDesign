Shader "MJ/MJCloth"
{
  Properties
  {
    [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", float) = 2
    _CustomView ("customView", Vector) = (1,1,1,1)
    _IndirectDiffuseIntensity ("_IndirectDiffuseIntensity", Range(0, 15)) = 1
    _ShadowColor ("ShadowColor", Color) = (1,1,1,1)
    _MetallicThesold ("MetallicThesold", Range(0, 1)) = 0.12
    _MetallicScale ("MetallicScale", Range(0, 3)) = 1
    _AnisoOffset ("anisoOffset", Range(-1, 1)) = 0
    _AnisoPower ("anisoPower", Range(0.1, 200)) = 1
    _AnisoIntensity ("anisoIntensity", Range(0, 2)) = 0.5
    _AnisoPower2 ("anisoPower", Range(0.1, 200)) = 1
    _AnisoIntensity2 ("anisoIntensity", Range(0, 2)) = 0.5
    _AnisoOffset2 ("anisoOffset2", Range(-1, 1)) = 0
    _AnisoPower3 ("anisoPower", Range(0.1, 200)) = 1
    _AnisoIntensity3 ("anisoIntensity", Range(0, 2)) = 0.5
    _AnisoOffset3 ("anisoOffset2", Range(-1, 1)) = 0
    _AnisoColor ("_AnisoColor", Color) = (1,1,1,1)
    _AnisoColor2 ("_AnisoColor2", Color) = (1,1,1,1)
    _AnisoColor3 ("_AnisoColor3", Color) = (1,1,1,1)
    _AnisoOffset4 ("anisoOffset", Range(-1, 1)) = 0
    _AnisoPower4 ("anisoPower", Range(0.1, 200)) = 1
    _AnisoIntensity4 ("anisoIntensity", Range(0, 2)) = 0.5
    _AnisoColor4 ("_AnisoColor3", Color) = (1,1,1,1)
    _GM ("R(Gloss)G(Metallic)", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)
    _AlphaScale ("Alpha Scale", float) = 1
    _Brightness ("Brightness", float) = 1
    [NoScaleOffset] _Albedo ("Albedo (RGB) Skin Smoothness or Transparency(A)", 2D) = "white" {}
    [NoScaleOffset] _MetallicMap ("Metallic Map", 2D) = "white" {}
    _DirectSpecularScale ("Direct Specular Scale", Range(0, 2)) = 1
    [NoScaleOffset] _Bump ("Bump Map", 2D) = "bump" {}
    _GlossMapScale ("Smoothness Scale", Range(0, 10)) = 1
    [HideInInspector] custom_SHAr ("Custom SHAr", Vector) = (0,0,0,0)
    [HideInInspector] custom_SHAg ("Custom SHAg", Vector) = (0,0,0,0)
    [HideInInspector] custom_SHAb ("Custom SHAb", Vector) = (0,0,0,0)
    [HideInInspector] custom_SHBr ("Custom SHAr", Vector) = (0,0,0,0)
    [HideInInspector] custom_SHBg ("Custom SHAg", Vector) = (0,0,0,0)
    [HideInInspector] custom_SHBb ("Custom SHAb", Vector) = (0,0,0,0)
    [HideInInspector] custom_SHC ("Custom SHC", Vector) = (0,0,0,0)
  }
  SubShader
  {
    Tags
    { 
      "PerformanceChecks" = "False"
      "RenderType" = "Opaque"
    }
    LOD 300
    Pass // ind: 1, name: FORWARD
    {
      Name "FORWARD"
      Tags
      { 
        "LIGHTMODE" = "FORWARDBASE"
        "PerformanceChecks" = "False"
        "RenderType" = "Opaque"
        "SHADOWSUPPORT" = "true"
      }
      LOD 300
      Cull Off
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,ambient,viewpos,rimLightDir,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      struct v2f
      {
          float2 uv;
          float3 worldNormal;
          float3 worldTangent;
          float3 worldBinormal;
          float3 worldPos;
          float3 worldView;
          float3 ambient;
          float3 viewpos;
          float3 rimLightDir;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _CustomView;
      uniform float4 _RimVector;
      //uniform float4 _WorldSpaceLightPos0;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _GlossMapScale;
      uniform float _AlphaScale;
      uniform float4 _GiColor;
      uniform float _MetallicThesold;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
      uniform float _AnisoOffset3;
      uniform float _AnisoPower3;
      uniform float _AnisoIntensity3;
      uniform float4 _AnisoColor3;
      uniform float _AnisoOffset4;
      uniform float _AnisoPower4;
      uniform float _AnisoIntensity4;
      uniform float4 _AnisoColor4;
      uniform sampler2D _Albedo;
      uniform sampler2D _Bump;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _GM;
      uniform float _MetallicScale;
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
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD6 :TEXCOORD6;
          float3 xlv_TEXCOORD8 :TEXCOORD8;
          float3 xlv_TEXCOORD9 :TEXCOORD9;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD8 :TEXCOORD8;
          float3 xlv_TEXCOORD9 :TEXCOORD9;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          v2f o_1;
          o_1 = v2f(float2(0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          o_1.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          o_1.uv = in_v.texcoord.xy;
          float4 tmpvar_3;
          tmpvar_3.w = 0;
          tmpvar_3.xyz = float3(in_v.normal);
          o_1.worldNormal = normalize(mul(unity_ObjectToWorld, tmpvar_3).xyz);
          float4 tmpvar_4;
          tmpvar_4.w = 0;
          tmpvar_4.xyz = in_v.tangent.xyz;
          o_1.worldTangent = normalize(mul(unity_ObjectToWorld, tmpvar_4).xyz);
          float3 a_5;
          a_5 = o_1.worldNormal;
          float3 b_6;
          b_6 = o_1.worldTangent;
          o_1.worldBinormal = normalize((((a_5.yzx * b_6.zxy) - (a_5.zxy * b_6.yzx)) * in_v.tangent.w));
          o_1.worldPos = mul(unity_ObjectToWorld, in_v.vertex).xyz;
          o_1.worldView = normalize((o_1.worldPos - _WorldSpaceCameraPos));
          float4 tmpvar_7;
          tmpvar_7.w = 0;
          tmpvar_7.xyz = normalize(_RimVector.xyz);
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV).xyz);
          float4 tmpvar_8;
          tmpvar_8.w = 0;
          tmpvar_8.xyz = normalize(_CustomView.xyz);
          o_1.viewpos = mul(tmpvar_8, unity_MatrixV).xyz;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
          out_v.xlv_TEXCOORD6 = o_1.ambient;
          out_v.xlv_TEXCOORD8 = o_1.viewpos;
          out_v.xlv_TEXCOORD9 = o_1.rimLightDir;
          out_v.vertex = o_1.pos;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float tmpvar_1;
          if(gl_FrontFacing)
          {
              tmpvar_1 = 1;
          }
          else
          {
              tmpvar_1 = (-1);
          }
          float4 final_col_2;
          float3 normalInTangent_3;
          float2 gm_4;
          float3 albedo_5;
          float4 albedo_alpha_6;
          float tmpvar_7;
          float tmpvar_8;
          float4 tmpvar_9;
          tmpvar_9 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          albedo_alpha_6 = tmpvar_9;
          albedo_alpha_6.xyz = (albedo_alpha_6.xyz * _Color.xyz);
          float3 tmpvar_10;
          tmpvar_10 = albedo_alpha_6.xyz;
          albedo_5 = tmpvar_10;
          float2 tmpvar_11;
          tmpvar_11 = tex2D(_GM, in_f.xlv_TEXCOORD0).xy;
          gm_4 = tmpvar_11;
          float tmpvar_12;
          tmpvar_12 = clamp((gm_4.x * _GlossMapScale), 0, 1.5);
          tmpvar_7 = tmpvar_12;
          tmpvar_8 = (gm_4.y * _MetallicScale);
          float3 normalTangent_13;
          float3 tmpvar_14;
          tmpvar_14 = ((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1);
          normalTangent_13 = tmpvar_14;
          float3 tmpvar_15;
          tmpvar_15 = normalize(normalTangent_13);
          normalInTangent_3 = tmpvar_15;
          float3 tmpvar_16;
          tmpvar_16 = normalize(normalize((((normalize(in_f.xlv_TEXCOORD3) * normalInTangent_3.y) + (normalize(in_f.xlv_TEXCOORD2) * normalInTangent_3.x)) + (normalize(in_f.xlv_TEXCOORD1) * normalInTangent_3.z))));
          float3 tmpvar_17;
          float _tmp_dvx_68 = (1 - tmpvar_8);
          tmpvar_17 = lerp(float3(0.04, 0.04, 0.04), albedo_5, float3(_tmp_dvx_68, _tmp_dvx_68, _tmp_dvx_68));
          float3 tmpvar_18;
          tmpvar_18 = _LightColor0.xyz;
          float3 viewDir_19;
          viewDir_19 = (-in_f.xlv_TEXCOORD5);
          float RNDL_20;
          float3 col_21;
          float HdotA_22;
          float D_23;
          float V_24;
          float nv_25;
          float3 h_26;
          float roughness_27;
          float perceptualRoughness_28;
          float tmpvar_29;
          float smoothness_30;
          smoothness_30 = tmpvar_7;
          tmpvar_29 = (1 - smoothness_30);
          perceptualRoughness_28 = tmpvar_29;
          float tmpvar_31;
          float perceptualRoughness_32;
          perceptualRoughness_32 = perceptualRoughness_28;
          tmpvar_31 = (perceptualRoughness_32 * perceptualRoughness_32);
          roughness_27 = tmpvar_31;
          float tmpvar_33;
          float tmpvar_34;
          tmpvar_34 = clamp(dot(tmpvar_16, _WorldSpaceLightPos0.xyz), 0, 1);
          tmpvar_33 = tmpvar_34;
          float3 tmpvar_35;
          tmpvar_35 = normalize((_WorldSpaceLightPos0.xyz + viewDir_19));
          h_26 = tmpvar_35;
          float tmpvar_36;
          float tmpvar_37;
          tmpvar_37 = clamp(dot(tmpvar_16, h_26), 0, 1);
          tmpvar_36 = tmpvar_37;
          float tmpvar_38;
          tmpvar_38 = abs(dot(tmpvar_16, viewDir_19));
          nv_25 = tmpvar_38;
          float tmpvar_39;
          float tmpvar_40;
          tmpvar_40 = clamp(dot(_WorldSpaceLightPos0.xyz, h_26), 0, 1);
          tmpvar_39 = tmpvar_40;
          float tmpvar_41;
          tmpvar_41 = ((tmpvar_33 * 0.5) + 0.5);
          float tmpvar_42;
          float NdotL_43;
          NdotL_43 = tmpvar_33;
          float NdotV_44;
          NdotV_44 = nv_25;
          float roughness_45;
          roughness_45 = roughness_27;
          tmpvar_42 = (0.5 / (((NdotL_43 * ((NdotV_44 * (1 - roughness_45)) + roughness_45)) + (NdotV_44 * ((NdotL_43 * (1 - roughness_45)) + roughness_45))) + 1E-05));
          V_24 = tmpvar_42;
          float tmpvar_46;
          float NdotH_47;
          NdotH_47 = tmpvar_36;
          float roughness_48;
          roughness_48 = roughness_27;
          float tmpvar_49;
          tmpvar_49 = (roughness_48 * roughness_48);
          float tmpvar_50;
          tmpvar_50 = ((((NdotH_47 * tmpvar_49) - NdotH_47) * NdotH_47) + 1);
          tmpvar_46 = ((0.3183099 * tmpvar_49) / ((tmpvar_50 * tmpvar_50) + 1E-07));
          D_23 = tmpvar_46;
          float tmpvar_51;
          tmpvar_51 = max(0, ((V_24 * D_23) * (3.141593 * tmpvar_33)));
          float3 tmpvar_52;
          tmpvar_52 = normalize((_WorldSpaceLightPos0.xyz + in_f.xlv_TEXCOORD8));
          h_26 = tmpvar_52;
          float tmpvar_53;
          tmpvar_53 = dot(tmpvar_16, tmpvar_52);
          HdotA_22 = tmpvar_53;
          float3 tmpvar_54;
          tmpvar_54 = (_GiColor * _IndirectDiffuseIntensity).xyz;
          float3 tmpvar_55;
          float x_56;
          x_56 = (1 - tmpvar_39);
          tmpvar_55 = (tmpvar_17 + ((1 - tmpvar_17) * ((x_56 * x_56) * ((x_56 * x_56) * x_56))));
          float3 tmpvar_57;
          tmpvar_57 = (((tmpvar_17 * 0.88) * (tmpvar_54 + (tmpvar_18 * tmpvar_41))) + ((tmpvar_51 * tmpvar_55) * _DirectSpecularScale));
          col_21 = tmpvar_57;
          float tmpvar_58;
          tmpvar_58 = clamp(tmpvar_1, 0, 1);
          col_21 = (col_21 + (((1 - float((tmpvar_8>=_MetallicThesold))) * (((_AnisoColor3 * pow(max(0, sin((3.141593 * (tmpvar_36 + _AnisoOffset3)))), _AnisoPower3)) * _AnisoIntensity3).xyz + ((_AnisoColor4 * pow(max(0, sin((3.141593 * (HdotA_22 + _AnisoOffset4)))), _AnisoPower4)) * _AnisoIntensity4).xyz)) * tmpvar_58));
          float tmpvar_59;
          tmpvar_59 = dot(tmpvar_16, in_f.xlv_TEXCOORD9);
          RNDL_20 = tmpvar_59;
          col_21 = (col_21 + ((_RimColor.xyz * clamp(pow(((1 - tmpvar_33) * clamp(RNDL_20, 0, 1)), _RimPower), 0, 1)) * _RimIntensity));
          float4 tmpvar_60;
          tmpvar_60.w = 1;
          tmpvar_60.xyz = float3(clamp((col_21 * tmpvar_18), 0, 1));
          final_col_2.xyz = tmpvar_60.xyz;
          final_col_2.w = _AlphaScale;
          out_f.color = final_col_2;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
