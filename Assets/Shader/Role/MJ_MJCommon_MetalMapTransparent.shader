// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_ShadowFadeCenterAndType', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_DynamicLightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_LightmapInd', a built-in variable

Shader "MJ/MJCommon_MetalMapTransparent"
{
  Properties
  {
    [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", float) = 2
    _MetallicMapIndirectDiffuseIntensity ("_MetallicMapIndirectDiffuseIntensity", Range(0, 15)) = 1
    [NoScaleOffset] _Albedo ("Albedo (RGB) Skin Smoothness or Transparency(A)", 2D) = "white" {}
    _InDirectLightIntensity ("间接光高光强度", Range(0, 3)) = 1
    _AlphaScale ("Alpha Scale", float) = 1
    _Color ("Color", Color) = (1,1,1,1)
    _GM ("GMMap", 2D) = "white" {}
    _BumpScale ("Scale", float) = 1
    _NormalBias ("Normal Bias", float) = -2
    _MetalMapScale ("MetalMapScale", Range(0, 3)) = 1
    [NoScaleOffset] _Bump ("Bump Map", 2D) = "bump" {}
    _DirectLightIntensity ("直接光强度", Range(0, 3)) = 1
    _GlossMap ("Gloss Map", 2D) = "white" {}
    _SmoothMap ("SmoothMap", 2D) = "white" {}
    _SmoothSpecial ("光滑度阈值", Range(0, 1)) = 0.2
    _MinSmooth ("MinSmooth", Range(0, 1)) = 1
    _MinSpecScale ("Min Specular Scale", Range(0, 1)) = 1
    _MaxSpecScale ("Max SecularScale", Range(0, 10)) = 1
    _Glossiness ("Smoothness", Range(0, 1)) = 0.5
    _GlossMapScale ("Smoothness Scale", Range(0, 1)) = 1
    _MetallicMap ("Metallic", 2D) = "white" {}
    _DirectSpecularExp ("_DirectSpecularExp", Range(0, 100)) = 10
    _AOColor ("_AOColor", Color) = (0,0,0,1)
    _SpecularScale ("GI Specular Scale", float) = 1
    _DirectSpecularScale ("Direct Specular Scale", Range(0, 20)) = 1
    _ScatteringShadowIntensity ("Direct Specular Scale", Range(0, 1)) = 0.25
    _cutoff ("Cutoff", Range(0, 1)) = 0.99
    _ShadowColor ("ShadowColor", Color) = (0,0,0,1)
    _Emission ("Emission", 2D) = "black" {}
    _EmissionScale ("EmissionScale", Range(0, 3)) = 1
    [KeywordEnum(Off, On)] _Specular ("Specular", float) = 1
    [KeywordEnum(Off, On)] _Customcube ("Customcube", float) = 0
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
      "QUEUE" = "Transparent"
      "RenderType" = "Transparent"
    }
    LOD 300
    Pass // ind: 1, name: FORWARD
    {
      Name "FORWARD"
      Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "FORWARDBASE"
        "PerformanceChecks" = "False"
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 300
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _SPECULAR_ON
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
          float3 rimLightDir;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _RimVector;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 unity_SpecCube0_HDR;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _GlossMapScale;
      uniform samplerCUBE custom_SpecCube;
      uniform float4 _AOColor;
      uniform float _cutoff;
      uniform float4 _GiColor;
      uniform float _DirectLightIntensity;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
      uniform sampler2D _GM;
      uniform float _MetalMapScale;
      uniform float _InDirectLightIntensity;
      uniform float _MetallicMapIndirectDiffuseIntensity;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
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
          o_1 = v2f(float2(0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
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
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
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
          float3 tmpvar_3;
          float3 tmpvar_4;
          float3 gmVar_5;
          float3 albedo_6;
          float3 normalInTangent_7;
          float tmpvar_8;
          float tmpvar_9;
          float tmpvar_10;
          float3 tmpvar_11;
          float3 tmpvar_12;
          tmpvar_12 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_11 = tmpvar_12;
          normalInTangent_7 = tmpvar_11;
          float3 tmpvar_13;
          if((tmpvar_1>0))
          {
              tmpvar_13 = normalInTangent_7;
          }
          else
          {
              tmpvar_13 = (-normalInTangent_7);
          }
          normalInTangent_7 = tmpvar_13;
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          tmpvar_8 = tmpvar_14.w;
          albedo_6 = (tmpvar_14.xyz * _Color.xyz);
          float x_15;
          x_15 = (tmpvar_8 - _cutoff);
          if((x_15<0))
          {
              discard;
          }
          float3 tmpvar_16;
          tmpvar_16 = tex2D(_GM, in_f.xlv_TEXCOORD0).xyz;
          gmVar_5 = tmpvar_16;
          tmpvar_10 = (gmVar_5.y * _MetalMapScale);
          float tmpvar_17;
          tmpvar_17 = clamp(((1 - gmVar_5.x) * _GlossMapScale), 0, 1.5);
          tmpvar_9 = tmpvar_17;
          float3 albedo_18;
          albedo_18 = albedo_6;
          float tmpvar_19;
          tmpvar_19 = (0.7790837 - (tmpvar_10 * 0.7790837));
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_13.y) + (in_f.xlv_TEXCOORD2 * tmpvar_13.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_13.z)));
          tmpvar_4 = (albedo_18 * tmpvar_19);
          float3 tmpvar_20;
          tmpvar_20 = _LightColor0.xyz;
          float3 worldView_21;
          worldView_21 = in_f.xlv_TEXCOORD5;
          float4 envSample_22;
          float3 R_23;
          float3 tmpvar_24;
          tmpvar_24 = (worldView_21 - (2 * (dot(tmpvar_3, worldView_21) * tmpvar_3)));
          R_23 = tmpvar_24;
          float4 tmpvar_25;
          float _tmp_dvx_38 = texCUBE(custom_SpecCube, R_23);
          tmpvar_25 = float4(_tmp_dvx_38, _tmp_dvx_38, _tmp_dvx_38, _tmp_dvx_38);
          envSample_22 = tmpvar_25;
          float4 data_26;
          data_26 = envSample_22;
          float3 normal_27;
          normal_27 = tmpvar_3;
          float3 viewDir_28;
          viewDir_28 = (-in_f.xlv_TEXCOORD5);
          float3 rimLightDirection_29;
          float3 col_30;
          float D_31;
          float V_32;
          float3 diffuseTerm_33;
          float roughness_34;
          float perceptualRoughness_35;
          float3 h_36;
          float tmpvar_37;
          tmpvar_37 = clamp(dot(normal_27, _WorldSpaceLightPos0.xyz), 0, 1);
          float3 tmpvar_38;
          tmpvar_38 = normalize((_WorldSpaceLightPos0.xyz + viewDir_28));
          h_36 = tmpvar_38;
          float tmpvar_39;
          float tmpvar_40;
          tmpvar_40 = clamp(dot(normal_27, h_36), 0, 1);
          tmpvar_39 = tmpvar_40;
          float tmpvar_41;
          tmpvar_41 = abs(dot(normal_27, viewDir_28));
          float tmpvar_42;
          float tmpvar_43;
          tmpvar_43 = clamp(dot(_WorldSpaceLightPos0.xyz, h_36), 0, 1);
          tmpvar_42 = tmpvar_43;
          float tmpvar_44;
          float smoothness_45;
          smoothness_45 = tmpvar_9;
          tmpvar_44 = (1 - smoothness_45);
          perceptualRoughness_35 = tmpvar_44;
          float tmpvar_46;
          float perceptualRoughness_47;
          perceptualRoughness_47 = perceptualRoughness_35;
          tmpvar_46 = (perceptualRoughness_47 * perceptualRoughness_47);
          roughness_34 = tmpvar_46;
          float3 tmpvar_48;
          float _tmp_dvx_39 = ((tmpvar_37 * 0.5) + 0.5);
          tmpvar_48 = float3(_tmp_dvx_39, _tmp_dvx_39, _tmp_dvx_39);
          diffuseTerm_33 = tmpvar_48;
          float tmpvar_49;
          float NdotL_50;
          NdotL_50 = tmpvar_37;
          float NdotV_51;
          NdotV_51 = tmpvar_41;
          float roughness_52;
          roughness_52 = roughness_34;
          tmpvar_49 = (0.5 / (((NdotL_50 * ((NdotV_51 * (1 - roughness_52)) + roughness_52)) + (NdotV_51 * ((NdotL_50 * (1 - roughness_52)) + roughness_52))) + 1E-05));
          V_32 = tmpvar_49;
          float tmpvar_53;
          float NdotH_54;
          NdotH_54 = tmpvar_39;
          float roughness_55;
          roughness_55 = roughness_34;
          float tmpvar_56;
          tmpvar_56 = (roughness_55 * roughness_55);
          float tmpvar_57;
          tmpvar_57 = ((((NdotH_54 * tmpvar_56) - NdotH_54) * NdotH_54) + 1);
          tmpvar_53 = ((0.3183099 * tmpvar_56) / ((tmpvar_57 * tmpvar_57) + 1E-07));
          D_31 = tmpvar_53;
          float3 tmpvar_58;
          tmpvar_58 = clamp(tmpvar_4, 0, 1);
          float x_59;
          x_59 = (1 - tmpvar_42);
          rimLightDirection_29 = in_f.xlv_TEXCOORD9;
          col_30 = (((clamp(tmpvar_4, 0, 1) * (((_GiColor * _IndirectDiffuseIntensity) * _MetallicMapIndirectDiffuseIntensity).xyz + (diffuseTerm_33 * _DirectLightIntensity))) + ((max(0, ((V_32 * D_31) * (3.141593 * tmpvar_37))) * (tmpvar_58 + ((1 - tmpvar_58) * ((x_59 * x_59) * ((x_59 * x_59) * x_59))))) * _DirectSpecularScale)) + clamp(((_RimColor.xyz * clamp(pow(((1 - tmpvar_37) * clamp(dot(normal_27, rimLightDirection_29), 0, 1)), _RimPower), 0, 1)) * _RimIntensity), 0, 1));
          float _tmp_dvx_40 = clamp(pow((1 - tmpvar_41), 5), 0, 1);
          float _tmp_dvx_41 = clamp((tmpvar_9 + (1 - tmpvar_19)), 0, 1);
          col_30 = (col_30 + ((((tmpvar_10 * ((unity_SpecCube0_HDR.x * ((unity_SpecCube0_HDR.w * (data_26.w - 1)) + 1)) * data_26.xyz)) * (1 - ((0.28 * roughness_34) * perceptualRoughness_35))) * lerp(lerp(float3(0.2209163, 0.2209163, 0.2209163), albedo_18, float3(tmpvar_10, tmpvar_10, tmpvar_10)), float3(_tmp_dvx_41, _tmp_dvx_41, _tmp_dvx_41), float3(_tmp_dvx_40, _tmp_dvx_40, _tmp_dvx_40))) * _InDirectLightIntensity));
          float3 tmpvar_60;
          tmpvar_60 = lerp((_AOColor.xyz * col_30), col_30, gmVar_5.zzz);
          col_30 = tmpvar_60;
          float4 tmpvar_61;
          tmpvar_61.xyz = float3(clamp((tmpvar_60 * tmpvar_20), 0, 1));
          tmpvar_61.w = tmpvar_8;
          final_col_2.xyz = tmpvar_61.xyz;
          final_col_2.w = tmpvar_8;
          out_f.color = final_col_2;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: ALPHA BLENDING
    {
      Name "ALPHA BLENDING"
      Tags
      { 
        "LIGHTMODE" = "FORWARDBASE"
        "PerformanceChecks" = "False"
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 300
      ZTest Less
      ZWrite Off
      Cull Front
      Blend One OneMinusSrcAlpha, SrcAlpha One
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _SPECULAR_ON
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
          float3 rimLightDir;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _RimVector;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 unity_SpecCube0_HDR;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _GlossMapScale;
      uniform samplerCUBE custom_SpecCube;
      uniform float4 _AOColor;
      uniform float4 _GiColor;
      uniform float _DirectLightIntensity;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
      uniform sampler2D _GM;
      uniform float _MetalMapScale;
      uniform float _InDirectLightIntensity;
      uniform float _MetallicMapIndirectDiffuseIntensity;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
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
          o_1 = v2f(float2(0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
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
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
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
          float3 tmpvar_3;
          float3 tmpvar_4;
          float3 gmVar_5;
          float3 albedo_6;
          float3 normalInTangent_7;
          float tmpvar_8;
          float tmpvar_9;
          float tmpvar_10;
          float3 tmpvar_11;
          float3 tmpvar_12;
          tmpvar_12 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_11 = tmpvar_12;
          normalInTangent_7 = tmpvar_11;
          float3 tmpvar_13;
          if((tmpvar_1>0))
          {
              tmpvar_13 = normalInTangent_7;
          }
          else
          {
              tmpvar_13 = (-normalInTangent_7);
          }
          normalInTangent_7 = tmpvar_13;
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          tmpvar_8 = tmpvar_14.w;
          albedo_6 = (tmpvar_14.xyz * _Color.xyz);
          float3 tmpvar_15;
          tmpvar_15 = tex2D(_GM, in_f.xlv_TEXCOORD0).xyz;
          gmVar_5 = tmpvar_15;
          tmpvar_10 = (gmVar_5.y * _MetalMapScale);
          float tmpvar_16;
          tmpvar_16 = clamp(((1 - gmVar_5.x) * _GlossMapScale), 0, 1.5);
          tmpvar_9 = tmpvar_16;
          float3 albedo_17;
          albedo_17 = albedo_6;
          float tmpvar_18;
          tmpvar_18 = (0.7790837 - (tmpvar_10 * 0.7790837));
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_13.y) + (in_f.xlv_TEXCOORD2 * tmpvar_13.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_13.z)));
          tmpvar_4 = (albedo_17 * tmpvar_18);
          float3 tmpvar_19;
          tmpvar_19 = _LightColor0.xyz;
          float3 worldView_20;
          worldView_20 = in_f.xlv_TEXCOORD5;
          float4 envSample_21;
          float3 R_22;
          float3 tmpvar_23;
          tmpvar_23 = (worldView_20 - (2 * (dot(tmpvar_3, worldView_20) * tmpvar_3)));
          R_22 = tmpvar_23;
          float4 tmpvar_24;
          float _tmp_dvx_42 = texCUBE(custom_SpecCube, R_22);
          tmpvar_24 = float4(_tmp_dvx_42, _tmp_dvx_42, _tmp_dvx_42, _tmp_dvx_42);
          envSample_21 = tmpvar_24;
          float4 data_25;
          data_25 = envSample_21;
          float3 normal_26;
          normal_26 = tmpvar_3;
          float3 viewDir_27;
          viewDir_27 = (-in_f.xlv_TEXCOORD5);
          float3 rimLightDirection_28;
          float3 col_29;
          float D_30;
          float V_31;
          float3 diffuseTerm_32;
          float roughness_33;
          float perceptualRoughness_34;
          float3 h_35;
          float tmpvar_36;
          tmpvar_36 = clamp(dot(normal_26, _WorldSpaceLightPos0.xyz), 0, 1);
          float3 tmpvar_37;
          tmpvar_37 = normalize((_WorldSpaceLightPos0.xyz + viewDir_27));
          h_35 = tmpvar_37;
          float tmpvar_38;
          float tmpvar_39;
          tmpvar_39 = clamp(dot(normal_26, h_35), 0, 1);
          tmpvar_38 = tmpvar_39;
          float tmpvar_40;
          tmpvar_40 = abs(dot(normal_26, viewDir_27));
          float tmpvar_41;
          float tmpvar_42;
          tmpvar_42 = clamp(dot(_WorldSpaceLightPos0.xyz, h_35), 0, 1);
          tmpvar_41 = tmpvar_42;
          float tmpvar_43;
          float smoothness_44;
          smoothness_44 = tmpvar_9;
          tmpvar_43 = (1 - smoothness_44);
          perceptualRoughness_34 = tmpvar_43;
          float tmpvar_45;
          float perceptualRoughness_46;
          perceptualRoughness_46 = perceptualRoughness_34;
          tmpvar_45 = (perceptualRoughness_46 * perceptualRoughness_46);
          roughness_33 = tmpvar_45;
          float3 tmpvar_47;
          float _tmp_dvx_43 = ((tmpvar_36 * 0.5) + 0.5);
          tmpvar_47 = float3(_tmp_dvx_43, _tmp_dvx_43, _tmp_dvx_43);
          diffuseTerm_32 = tmpvar_47;
          float tmpvar_48;
          float NdotL_49;
          NdotL_49 = tmpvar_36;
          float NdotV_50;
          NdotV_50 = tmpvar_40;
          float roughness_51;
          roughness_51 = roughness_33;
          tmpvar_48 = (0.5 / (((NdotL_49 * ((NdotV_50 * (1 - roughness_51)) + roughness_51)) + (NdotV_50 * ((NdotL_49 * (1 - roughness_51)) + roughness_51))) + 1E-05));
          V_31 = tmpvar_48;
          float tmpvar_52;
          float NdotH_53;
          NdotH_53 = tmpvar_38;
          float roughness_54;
          roughness_54 = roughness_33;
          float tmpvar_55;
          tmpvar_55 = (roughness_54 * roughness_54);
          float tmpvar_56;
          tmpvar_56 = ((((NdotH_53 * tmpvar_55) - NdotH_53) * NdotH_53) + 1);
          tmpvar_52 = ((0.3183099 * tmpvar_55) / ((tmpvar_56 * tmpvar_56) + 1E-07));
          D_30 = tmpvar_52;
          float3 tmpvar_57;
          tmpvar_57 = clamp(tmpvar_4, 0, 1);
          float x_58;
          x_58 = (1 - tmpvar_41);
          rimLightDirection_28 = in_f.xlv_TEXCOORD9;
          col_29 = (((clamp(tmpvar_4, 0, 1) * (((_GiColor * _IndirectDiffuseIntensity) * _MetallicMapIndirectDiffuseIntensity).xyz + (diffuseTerm_32 * _DirectLightIntensity))) + ((max(0, ((V_31 * D_30) * (3.141593 * tmpvar_36))) * (tmpvar_57 + ((1 - tmpvar_57) * ((x_58 * x_58) * ((x_58 * x_58) * x_58))))) * _DirectSpecularScale)) + clamp(((_RimColor.xyz * clamp(pow(((1 - tmpvar_36) * clamp(dot(normal_26, rimLightDirection_28), 0, 1)), _RimPower), 0, 1)) * _RimIntensity), 0, 1));
          float _tmp_dvx_44 = clamp(pow((1 - tmpvar_40), 5), 0, 1);
          float _tmp_dvx_45 = clamp((tmpvar_9 + (1 - tmpvar_18)), 0, 1);
          col_29 = (col_29 + ((((tmpvar_10 * ((unity_SpecCube0_HDR.x * ((unity_SpecCube0_HDR.w * (data_25.w - 1)) + 1)) * data_25.xyz)) * (1 - ((0.28 * roughness_33) * perceptualRoughness_34))) * lerp(lerp(float3(0.2209163, 0.2209163, 0.2209163), albedo_17, float3(tmpvar_10, tmpvar_10, tmpvar_10)), float3(_tmp_dvx_45, _tmp_dvx_45, _tmp_dvx_45), float3(_tmp_dvx_44, _tmp_dvx_44, _tmp_dvx_44))) * _InDirectLightIntensity));
          float3 tmpvar_59;
          tmpvar_59 = lerp((_AOColor.xyz * col_29), col_29, gmVar_5.zzz);
          col_29 = tmpvar_59;
          float4 tmpvar_60;
          tmpvar_60.xyz = float3(((tmpvar_59 * tmpvar_19) * tmpvar_8));
          tmpvar_60.w = tmpvar_8;
          final_col_2.xyz = tmpvar_60.xyz;
          final_col_2.w = tmpvar_8;
          out_f.color = final_col_2;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 3, name: ALPHA BLENDING
    {
      Name "ALPHA BLENDING"
      Tags
      { 
        "LIGHTMODE" = "FORWARDBASE"
        "PerformanceChecks" = "False"
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 300
      ZTest Less
      ZWrite Off
      Blend One OneMinusSrcAlpha, SrcAlpha One
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _SPECULAR_ON
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
          float3 rimLightDir;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _RimVector;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 unity_SpecCube0_HDR;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _GlossMapScale;
      uniform samplerCUBE custom_SpecCube;
      uniform float4 _AOColor;
      uniform float4 _GiColor;
      uniform float _DirectLightIntensity;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
      uniform sampler2D _GM;
      uniform float _MetalMapScale;
      uniform float _InDirectLightIntensity;
      uniform float _MetallicMapIndirectDiffuseIntensity;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
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
          o_1 = v2f(float2(0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
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
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
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
          float3 tmpvar_3;
          float3 tmpvar_4;
          float3 gmVar_5;
          float3 albedo_6;
          float3 normalInTangent_7;
          float tmpvar_8;
          float tmpvar_9;
          float tmpvar_10;
          float3 tmpvar_11;
          float3 tmpvar_12;
          tmpvar_12 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_11 = tmpvar_12;
          normalInTangent_7 = tmpvar_11;
          float3 tmpvar_13;
          if((tmpvar_1>0))
          {
              tmpvar_13 = normalInTangent_7;
          }
          else
          {
              tmpvar_13 = (-normalInTangent_7);
          }
          normalInTangent_7 = tmpvar_13;
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          tmpvar_8 = tmpvar_14.w;
          albedo_6 = (tmpvar_14.xyz * _Color.xyz);
          float3 tmpvar_15;
          tmpvar_15 = tex2D(_GM, in_f.xlv_TEXCOORD0).xyz;
          gmVar_5 = tmpvar_15;
          tmpvar_10 = (gmVar_5.y * _MetalMapScale);
          float tmpvar_16;
          tmpvar_16 = clamp(((1 - gmVar_5.x) * _GlossMapScale), 0, 1.5);
          tmpvar_9 = tmpvar_16;
          float3 albedo_17;
          albedo_17 = albedo_6;
          float tmpvar_18;
          tmpvar_18 = (0.7790837 - (tmpvar_10 * 0.7790837));
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_13.y) + (in_f.xlv_TEXCOORD2 * tmpvar_13.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_13.z)));
          tmpvar_4 = (albedo_17 * tmpvar_18);
          float3 tmpvar_19;
          tmpvar_19 = _LightColor0.xyz;
          float3 worldView_20;
          worldView_20 = in_f.xlv_TEXCOORD5;
          float4 envSample_21;
          float3 R_22;
          float3 tmpvar_23;
          tmpvar_23 = (worldView_20 - (2 * (dot(tmpvar_3, worldView_20) * tmpvar_3)));
          R_22 = tmpvar_23;
          float4 tmpvar_24;
          float _tmp_dvx_46 = texCUBE(custom_SpecCube, R_22);
          tmpvar_24 = float4(_tmp_dvx_46, _tmp_dvx_46, _tmp_dvx_46, _tmp_dvx_46);
          envSample_21 = tmpvar_24;
          float4 data_25;
          data_25 = envSample_21;
          float3 normal_26;
          normal_26 = tmpvar_3;
          float3 viewDir_27;
          viewDir_27 = (-in_f.xlv_TEXCOORD5);
          float3 rimLightDirection_28;
          float3 col_29;
          float D_30;
          float V_31;
          float3 diffuseTerm_32;
          float roughness_33;
          float perceptualRoughness_34;
          float3 h_35;
          float tmpvar_36;
          tmpvar_36 = clamp(dot(normal_26, _WorldSpaceLightPos0.xyz), 0, 1);
          float3 tmpvar_37;
          tmpvar_37 = normalize((_WorldSpaceLightPos0.xyz + viewDir_27));
          h_35 = tmpvar_37;
          float tmpvar_38;
          float tmpvar_39;
          tmpvar_39 = clamp(dot(normal_26, h_35), 0, 1);
          tmpvar_38 = tmpvar_39;
          float tmpvar_40;
          tmpvar_40 = abs(dot(normal_26, viewDir_27));
          float tmpvar_41;
          float tmpvar_42;
          tmpvar_42 = clamp(dot(_WorldSpaceLightPos0.xyz, h_35), 0, 1);
          tmpvar_41 = tmpvar_42;
          float tmpvar_43;
          float smoothness_44;
          smoothness_44 = tmpvar_9;
          tmpvar_43 = (1 - smoothness_44);
          perceptualRoughness_34 = tmpvar_43;
          float tmpvar_45;
          float perceptualRoughness_46;
          perceptualRoughness_46 = perceptualRoughness_34;
          tmpvar_45 = (perceptualRoughness_46 * perceptualRoughness_46);
          roughness_33 = tmpvar_45;
          float3 tmpvar_47;
          float _tmp_dvx_47 = ((tmpvar_36 * 0.5) + 0.5);
          tmpvar_47 = float3(_tmp_dvx_47, _tmp_dvx_47, _tmp_dvx_47);
          diffuseTerm_32 = tmpvar_47;
          float tmpvar_48;
          float NdotL_49;
          NdotL_49 = tmpvar_36;
          float NdotV_50;
          NdotV_50 = tmpvar_40;
          float roughness_51;
          roughness_51 = roughness_33;
          tmpvar_48 = (0.5 / (((NdotL_49 * ((NdotV_50 * (1 - roughness_51)) + roughness_51)) + (NdotV_50 * ((NdotL_49 * (1 - roughness_51)) + roughness_51))) + 1E-05));
          V_31 = tmpvar_48;
          float tmpvar_52;
          float NdotH_53;
          NdotH_53 = tmpvar_38;
          float roughness_54;
          roughness_54 = roughness_33;
          float tmpvar_55;
          tmpvar_55 = (roughness_54 * roughness_54);
          float tmpvar_56;
          tmpvar_56 = ((((NdotH_53 * tmpvar_55) - NdotH_53) * NdotH_53) + 1);
          tmpvar_52 = ((0.3183099 * tmpvar_55) / ((tmpvar_56 * tmpvar_56) + 1E-07));
          D_30 = tmpvar_52;
          float3 tmpvar_57;
          tmpvar_57 = clamp(tmpvar_4, 0, 1);
          float x_58;
          x_58 = (1 - tmpvar_41);
          rimLightDirection_28 = in_f.xlv_TEXCOORD9;
          col_29 = (((clamp(tmpvar_4, 0, 1) * (((_GiColor * _IndirectDiffuseIntensity) * _MetallicMapIndirectDiffuseIntensity).xyz + (diffuseTerm_32 * _DirectLightIntensity))) + ((max(0, ((V_31 * D_30) * (3.141593 * tmpvar_36))) * (tmpvar_57 + ((1 - tmpvar_57) * ((x_58 * x_58) * ((x_58 * x_58) * x_58))))) * _DirectSpecularScale)) + clamp(((_RimColor.xyz * clamp(pow(((1 - tmpvar_36) * clamp(dot(normal_26, rimLightDirection_28), 0, 1)), _RimPower), 0, 1)) * _RimIntensity), 0, 1));
          float _tmp_dvx_48 = clamp(pow((1 - tmpvar_40), 5), 0, 1);
          float _tmp_dvx_49 = clamp((tmpvar_9 + (1 - tmpvar_18)), 0, 1);
          col_29 = (col_29 + ((((tmpvar_10 * ((unity_SpecCube0_HDR.x * ((unity_SpecCube0_HDR.w * (data_25.w - 1)) + 1)) * data_25.xyz)) * (1 - ((0.28 * roughness_33) * perceptualRoughness_34))) * lerp(lerp(float3(0.2209163, 0.2209163, 0.2209163), albedo_17, float3(tmpvar_10, tmpvar_10, tmpvar_10)), float3(_tmp_dvx_49, _tmp_dvx_49, _tmp_dvx_49), float3(_tmp_dvx_48, _tmp_dvx_48, _tmp_dvx_48))) * _InDirectLightIntensity));
          float3 tmpvar_59;
          tmpvar_59 = lerp((_AOColor.xyz * col_29), col_29, gmVar_5.zzz);
          col_29 = tmpvar_59;
          float4 tmpvar_60;
          tmpvar_60.xyz = float3(((tmpvar_59 * tmpvar_19) * tmpvar_8));
          tmpvar_60.w = tmpvar_8;
          final_col_2.xyz = tmpvar_60.xyz;
          final_col_2.w = tmpvar_8;
          out_f.color = final_col_2;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 4, name: SHADOWCASTER
    {
      Name "SHADOWCASTER"
      Tags
      { 
        "LIGHTMODE" = "SHADOWCASTER"
        "PerformanceChecks" = "False"
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 300
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f_vertex_lit members uv,diff,spec)
#pragma exclude_renderers d3d11
      #pragma multi_compile SHADOWS_DEPTH
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      #define conv_mxt4x4_3(mat4x4) float4(mat4x4[0].w,mat4x4[1].w,mat4x4[2].w,mat4x4[3].w)
      #define conv_mxt3x3_0(mat4x4) float3(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x)
      #define conv_mxt3x3_1(mat4x4) float3(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y)
      #define conv_mxt3x3_2(mat4x4) float3(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4 _Time;
      //uniform float4 _SinTime;
      //uniform float4 _CosTime;
      //uniform float4 unity_DeltaTime;
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _ProjectionParams;
      //uniform float4 _ScreenParams;
      //uniform float4 _ZBufferParams;
      //uniform float4 unity_OrthoParams;
      //uniform float4 unity_CameraWorldClipPlanes[6];
      //uniform float4x4 unity_CameraProjection;
      //uniform float4x4 unity_CameraInvProjection;
      //uniform float4x4 unity_WorldToCamera;
      //uniform float4x4 unity_CameraToWorld;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 _LightPositionRange;
      uniform float4 _LightProjectionParams;
      //uniform float4 unity_4LightPosX0;
      //uniform float4 unity_4LightPosY0;
      //uniform float4 unity_4LightPosZ0;
      //uniform float4 unity_4LightAtten0;
      //uniform float4 unity_LightColor[8];
      //uniform float4 unity_LightPosition[8];
      //uniform float4 unity_LightAtten[8];
      //uniform float4 unity_SpotDirection[8];
      //uniform float4 unity_SHAr;
      //uniform float4 unity_SHAg;
      //uniform float4 unity_SHAb;
      //uniform float4 unity_SHBr;
      //uniform float4 unity_SHBg;
      //uniform float4 unity_SHBb;
      //uniform float4 unity_SHC;
      //uniform float4 unity_OcclusionMaskSelector;
      uniform float4 unity_ProbesOcclusion;
      uniform float3 unity_LightColor0;
      uniform float3 unity_LightColor1;
      uniform float3 unity_LightColor2;
      uniform float3 unity_LightColor3;
      uniform float4x4 unity_ShadowSplitSpheres;
      uniform float4 unity_ShadowSplitSqRadii;
      //uniform float4 unity_LightShadowBias;
      //uniform float4 _LightSplitsNear;
      //uniform float4 _LightSplitsFar;
      //uniform float4x4x4 unity_WorldToShadow;
      //uniform float4 _LightShadowData;
      // uniform float4 unity_ShadowFadeCenterAndType;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_LODFade;
      //uniform float4 unity_WorldTransformParams;
      //uniform float4x4 glstate_matrix_transpose_modelview0;
      //uniform float4 glstate_lightmodel_ambient;
      //uniform float4 unity_AmbientSky;
      //uniform float4 unity_AmbientEquator;
      //uniform float4 unity_AmbientGround;
      uniform float4 unity_IndirectSpecColor;
      //uniform float4x4 UNITY_MATRIX_P;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixInvV;
      //uniform float4x4 unity_MatrixVP;
      //uniform int unity_StereoEyeIndex;
      uniform float4 unity_ShadowColor;
      //uniform float4 unity_FogColor;
      //uniform float4 unity_FogParams;
      // uniform sampler2D unity_Lightmap;
      // uniform sampler2D unity_LightmapInd;
      // uniform sampler2D unity_DynamicLightmap;
      uniform sampler2D unity_DynamicDirectionality;
      uniform sampler2D unity_DynamicNormal;
      // uniform float4 unity_LightmapST;
      // uniform float4 unity_DynamicLightmapST;
      //uniform samplerCUBE unity_SpecCube0;
      //uniform samplerCUBE unity_SpecCube1;
      SamplerState samplerunity_SpecCube1;
      //uniform float4 unity_SpecCube0_BoxMax;
      //uniform float4 unity_SpecCube0_BoxMin;
      //uniform float4 unity_SpecCube0_ProbePosition;
      //uniform float4 unity_SpecCube0_HDR;
      //uniform float4 unity_SpecCube1_BoxMax;
      //uniform float4 unity_SpecCube1_BoxMin;
      //uniform float4 unity_SpecCube1_ProbePosition;
      //uniform float4 unity_SpecCube1_HDR;
      //uniform float4 unity_Lightmap_HDR;
      uniform float4 unity_DynamicLightmap_HDR;
      uniform sampler _Albedo;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float4 vertex :Position;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      float2x2 xll_transpose_mf2x2(float2x2 m)
      {
      }
      
      float3x3 xll_transpose_mf3x3(float3x3 m)
      {
      }
      
      float4x4 xll_transpose_mf4x4(float4x4 m)
      {
      }
      
      float xll_saturate_f(float x)
      {
          return clamp(x, 0, 1);
      }
      
      float2 xll_saturate_vf2(float2 x)
      {
          return clamp(x, 0, 1);
      }
      
      float3 xll_saturate_vf3(float3 x)
      {
          return clamp(x, 0, 1);
      }
      
      float4 xll_saturate_vf4(float4 x)
      {
          return clamp(x, 0, 1);
      }
      
      float2x2 xll_saturate_mf2x2(float2x2 m)
      {
          return float2x2(clamp(conv_mxt2x2_0(m), 0, 1), clamp(conv_mxt2x2_1(m), 0, 1));
      }
      
      float3x3 xll_saturate_mf3x3(float3x3 m)
      {
          return float3x3(clamp(conv_mxt3x3_0(m), 0, 1), clamp(conv_mxt3x3_1(m), 0, 1), clamp(conv_mxt3x3_2(m), 0, 1));
      }
      
      float4x4 xll_saturate_mf4x4(float4x4 m)
      {
          return float4x4(clamp(conv_mxt4x4_0(m), 0, 1), clamp(conv_mxt4x4_1(m), 0, 1), clamp(conv_mxt4x4_2(m), 0, 1), clamp(conv_mxt4x4_3(m), 0, 1));
      }
      
      float3x3 xll_constructMat3_mf4x4(float4x4 m)
      {
          return float3x3(float3(conv_mxt4x4_0(m).xyz), float3(conv_mxt4x4_1(m).xyz), float3(conv_mxt4x4_2(m).xyz));
      }
      
      struct v2f_vertex_lit
      {
          float2 uv;
          float4 diff;
          float4 spec;
      };
      
      struct v2f_img
      {
          float4 pos;
          float2 uv;
      };
      
      struct appdata_img
      {
          float4 vertex;
          float2 texcoord;
      };
      
      struct v2f
      {
          float2 uv;
          float4 pos;
      };
      
      struct appdata_base
      {
          float4 vertex;
          float3 normal;
          float4 texcoord;
      };
      
      //float4x4 unity_MatrixMVP;
      //float4x4 unity_MatrixMV;
      //float4x4 unity_MatrixTMV;
      float4x4 unity_MatrixITMV;
      float4 UnityApplyLinearShadowBias(in float4 clipPos )
      {
          clipPos.z = (clipPos.z + xll_saturate_f((unity_LightShadowBias.x / clipPos.w)));
          float clamped = max(clipPos.z, (clipPos.w * (-1)));
          clipPos.z = lerp(clipPos.z, clamped, unity_LightShadowBias.y);
          return clipPos;
      }
      
      float3 UnityObjectToWorldNormal(in float3 norm )
      {
          return normalize(mul(norm, xll_constructMat3_mf4x4(unity_WorldToObject)));
      }
      
      float3 UnityWorldSpaceLightDir(in float3 worldPos )
      {
          return {(_WorldSpaceLightPos0.xyz - (worldPos * _WorldSpaceLightPos0.w))};
      }
      
      float4 UnityClipSpaceShadowCasterPos(in float4 vertex, in float3 normal )
      {
          float4 wPos = mul(unity_ObjectToWorld, vertex);
          if((unity_LightShadowBias.z!=0))
          {
              float3 wNormal = UnityObjectToWorldNormal(normal);
              float3 wLight = normalize(UnityWorldSpaceLightDir(wPos.xyz));
              float shadowCos = dot(wNormal, wLight);
              float shadowSine = sqrt((1 - (shadowCos * shadowCos)));
              float normalBias = (unity_LightShadowBias.z * shadowSine);
              wPos.xyz = (wPos.xyz - (wNormal * normalBias));
          }
          return {mul(unity_MatrixVP, wPos)};
      }
      
      v2f vert(in appdata_base v )
      {
          OUT_Data_Vert out_v;
          v2f o;
          o.uv = float2(v.texcoord);
          o.pos = UnityClipSpaceShadowCasterPos(v.vertex, v.normal);
          o.pos = UnityApplyLinearShadowBias(o.pos);
          //return o;
          return out_v;
      }
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          unity_MatrixMVP = mul(unity_MatrixVP, unity_ObjectToWorld);
          unity_MatrixMV = mul(unity_MatrixV, unity_ObjectToWorld);
          unity_MatrixTMV = xll_transpose_mf4x4(unity_MatrixMV);
          unity_MatrixITMV = xll_transpose_mf4x4(mul(unity_WorldToObject, unity_MatrixInvV));
          v2f xl_retval;
          appdata_base xlt_v;
          xlt_v.vertex = float4(in_v.vertex);
          xlt_v.normal = float3(in_v.normal);
          xlt_v.texcoord = float4(in_v.texcoord);
          xl_retval = vert(xlt_v);
          out_v.xlv_TEXCOORD0 = float2(xl_retval.uv);
          out_v.vertex = float4(xl_retval.pos);
          return out_v;
      }
      
      #endif
      #define CODE_BLOCK_FRAGMENT
      #ifndef SHADER_TARGET
      #define SHADER_TARGET 20
      #endif
      #ifndef UNITY_NO_DXT5nm
      #define UNITY_NO_DXT5nm 1
      #endif
      #ifndef UNITY_NO_RGBM
      #define UNITY_NO_RGBM 1
      #endif
      #ifndef UNITY_ENABLE_REFLECTION_BUFFERS
      #define UNITY_ENABLE_REFLECTION_BUFFERS 1
      #endif
      #ifndef UNITY_FRAMEBUFFER_FETCH_AVAILABLE
      #define UNITY_FRAMEBUFFER_FETCH_AVAILABLE 1
      #endif
      #ifndef UNITY_ENABLE_NATIVE_SHADOW_LOOKUPS
      #define UNITY_ENABLE_NATIVE_SHADOW_LOOKUPS 1
      #endif
      #ifndef UNITY_NO_CUBEMAP_ARRAY
      #define UNITY_NO_CUBEMAP_ARRAY 1
      #endif
      #ifndef UNITY_NO_SCREENSPACE_SHADOWS
      #define UNITY_NO_SCREENSPACE_SHADOWS 1
      #endif
      #ifndef UNITY_PBS_USE_BRDF3
      #define UNITY_PBS_USE_BRDF3 1
      #endif
      #ifndef SHADER_API_MOBILE
      #define SHADER_API_MOBILE 1
      #endif
      #ifndef UNITY_HARDWARE_TIER1
      #define UNITY_HARDWARE_TIER1 1
      #endif
      #ifndef UNITY_COLORSPACE_GAMMA
      #define UNITY_COLORSPACE_GAMMA 1
      #endif
      #ifndef UNITY_LIGHTMAP_DLDR_ENCODING
      #define UNITY_LIGHTMAP_DLDR_ENCODING 1
      #endif
      #ifndef SHADOWS_DEPTH
      #define SHADOWS_DEPTH 1
      #endif
      #ifndef UNITY_VERSION
      #define UNITY_VERSION 201749
      #endif
      #ifndef SHADER_STAGE_VERTEX
      #define SHADER_STAGE_VERTEX 1
      #endif
      #ifndef SHADER_API_GLES
      #define SHADER_API_GLES 1
      #endif
      void xll_clip_f(float x)
      {
          if((x<0))
          {
              discard;
          }
      }
      
      void xll_clip_vf2(float2 x)
      {
          if(bool(bool2(x < float2(0, 0)).x || bool2(x < float2(0, 0)).y))
          {
              discard;
          }
      }
      
      void xll_clip_vf3(float3 x)
      {
          if(bool(bool3(x < float3(0, 0, 0)).x || bool3(x < float3(0, 0, 0)).y || bool3(x < float3(0, 0, 0)).z))
          {
              discard;
          }
      }
      
      void xll_clip_vf4(float4 x)
      {
          if(bool(bool4(x < float4(0, 0, 0, 0)).x || bool4(x < float4(0, 0, 0, 0)).y || bool4(x < float4(0, 0, 0, 0)).z || bool4(x < float4(0, 0, 0, 0)).w))
          {
              discard;
          }
      }
      
      float2x2 xll_transpose_mf2x2(float2x2 m)
      {
      }
      
      float3x3 xll_transpose_mf3x3(float3x3 m)
      {
      }
      
      float4x4 xll_transpose_mf4x4(float4x4 m)
      {
      }
      
      struct v2f_vertex_lit
      {
          float2 uv;
          float4 diff;
          float4 spec;
      };
      
      struct v2f_img
      {
          float4 pos;
          float2 uv;
      };
      
      struct appdata_img
      {
          float4 vertex;
          float2 texcoord;
      };
      
      struct v2f
      {
          float2 uv;
          float4 pos;
      };
      
      struct appdata_base
      {
          float4 vertex;
          float3 normal;
          float4 texcoord;
      };
      
      //uniform float4 _Time;
      //uniform float4 _SinTime;
      //uniform float4 _CosTime;
      //uniform float4 unity_DeltaTime;
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _ProjectionParams;
      //uniform float4 _ScreenParams;
      //uniform float4 _ZBufferParams;
      //uniform float4 unity_OrthoParams;
      //uniform float4 unity_CameraWorldClipPlanes[6];
      //uniform float4x4 unity_CameraProjection;
      //uniform float4x4 unity_CameraInvProjection;
      //uniform float4x4 unity_WorldToCamera;
      //uniform float4x4 unity_CameraToWorld;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 _LightPositionRange;
      uniform float4 _LightProjectionParams;
      //uniform float4 unity_4LightPosX0;
      //uniform float4 unity_4LightPosY0;
      //uniform float4 unity_4LightPosZ0;
      //uniform float4 unity_4LightAtten0;
      //uniform float4 unity_LightColor[8];
      //uniform float4 unity_LightPosition[8];
      //uniform float4 unity_LightAtten[8];
      //uniform float4 unity_SpotDirection[8];
      //uniform float4 unity_SHAr;
      //uniform float4 unity_SHAg;
      //uniform float4 unity_SHAb;
      //uniform float4 unity_SHBr;
      //uniform float4 unity_SHBg;
      //uniform float4 unity_SHBb;
      //uniform float4 unity_SHC;
      //uniform float4 unity_OcclusionMaskSelector;
      uniform float4 unity_ProbesOcclusion;
      uniform float3 unity_LightColor0;
      uniform float3 unity_LightColor1;
      uniform float3 unity_LightColor2;
      uniform float3 unity_LightColor3;
      uniform float4x4 unity_ShadowSplitSpheres;
      uniform float4 unity_ShadowSplitSqRadii;
      //uniform float4 unity_LightShadowBias;
      //uniform float4 _LightSplitsNear;
      //uniform float4 _LightSplitsFar;
      //uniform float4x4x4 unity_WorldToShadow;
      //uniform float4 _LightShadowData;
      // uniform float4 unity_ShadowFadeCenterAndType;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_LODFade;
      //uniform float4 unity_WorldTransformParams;
      //uniform float4x4 glstate_matrix_transpose_modelview0;
      //uniform float4 glstate_lightmodel_ambient;
      //uniform float4 unity_AmbientSky;
      //uniform float4 unity_AmbientEquator;
      //uniform float4 unity_AmbientGround;
      uniform float4 unity_IndirectSpecColor;
      //uniform float4x4 UNITY_MATRIX_P;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixInvV;
      //uniform float4x4 unity_MatrixVP;
      //uniform int unity_StereoEyeIndex;
      uniform float4 unity_ShadowColor;
      //uniform float4 unity_FogColor;
      //uniform float4 unity_FogParams;
      // uniform sampler2D unity_Lightmap;
      // uniform sampler2D unity_LightmapInd;
      // uniform sampler2D unity_DynamicLightmap;
      uniform sampler2D unity_DynamicDirectionality;
      uniform sampler2D unity_DynamicNormal;
      // uniform float4 unity_LightmapST;
      // uniform float4 unity_DynamicLightmapST;
      //uniform samplerCUBE unity_SpecCube0;
      //uniform samplerCUBE unity_SpecCube1;
      SamplerState samplerunity_SpecCube1;
      //uniform float4 unity_SpecCube0_BoxMax;
      //uniform float4 unity_SpecCube0_BoxMin;
      //uniform float4 unity_SpecCube0_ProbePosition;
      //uniform float4 unity_SpecCube0_HDR;
      //uniform float4 unity_SpecCube1_BoxMax;
      //uniform float4 unity_SpecCube1_BoxMin;
      //uniform float4 unity_SpecCube1_ProbePosition;
      //uniform float4 unity_SpecCube1_HDR;
      //float4x4 unity_MatrixMVP;
      //float4x4 unity_MatrixMV;
      //float4x4 unity_MatrixTMV;
      float4x4 unity_MatrixITMV;
      //uniform float4 unity_Lightmap_HDR;
      uniform float4 unity_DynamicLightmap_HDR;
      uniform sampler _Albedo;
      float4 frag(in v2f i )
      {
          OUT_Data_Frag out_f;
          float alpha = tex2D(_Albedo, i.uv).w;
          xll_clip_f((alpha - 0.5));
          //return float4(0, 0, 0, 0);
          return out_f;
      }
      
      varying float2 xlv_TEXCOORD0;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          unity_MatrixMVP = mul(unity_MatrixVP, unity_ObjectToWorld);
          unity_MatrixMV = mul(unity_MatrixV, unity_ObjectToWorld);
          unity_MatrixTMV = xll_transpose_mf4x4(unity_MatrixMV);
          unity_MatrixITMV = xll_transpose_mf4x4(mul(unity_WorldToObject, unity_MatrixInvV));
          float4 xl_retval;
          v2f xlt_i;
          xlt_i.uv = float2(in_f.xlv_TEXCOORD0);
          xlt_i.pos = float4(0, 0, 0, 0);
          xl_retval = frag(xlt_i);
          out_f.color = float4(xl_retval);
          return out_f;
      }
      
      #endif
      
      ENDCG
      
    } // end phase
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
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
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
          float3 rimLightDir;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _RimVector;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 unity_SpecCube0_HDR;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _GlossMapScale;
      uniform samplerCUBE custom_SpecCube;
      uniform float4 _AOColor;
      uniform float4 _GiColor;
      uniform float _DirectLightIntensity;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
      uniform sampler2D _GM;
      uniform float _MetalMapScale;
      uniform float _InDirectLightIntensity;
      uniform float _MetallicMapIndirectDiffuseIntensity;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
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
          o_1 = v2f(float2(0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
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
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
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
          float3 tmpvar_3;
          float3 tmpvar_4;
          float3 gmVar_5;
          float3 albedo_6;
          float3 normalInTangent_7;
          float tmpvar_8;
          float tmpvar_9;
          float tmpvar_10;
          float3 tmpvar_11;
          float3 tmpvar_12;
          tmpvar_12 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_11 = tmpvar_12;
          normalInTangent_7 = tmpvar_11;
          float3 tmpvar_13;
          if((tmpvar_1>0))
          {
              tmpvar_13 = normalInTangent_7;
          }
          else
          {
              tmpvar_13 = (-normalInTangent_7);
          }
          normalInTangent_7 = tmpvar_13;
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          tmpvar_8 = tmpvar_14.w;
          albedo_6 = (tmpvar_14.xyz * _Color.xyz);
          float3 tmpvar_15;
          tmpvar_15 = tex2D(_GM, in_f.xlv_TEXCOORD0).xyz;
          gmVar_5 = tmpvar_15;
          tmpvar_10 = (gmVar_5.y * _MetalMapScale);
          float tmpvar_16;
          tmpvar_16 = clamp(((1 - gmVar_5.x) * _GlossMapScale), 0, 1.5);
          tmpvar_9 = tmpvar_16;
          float3 albedo_17;
          albedo_17 = albedo_6;
          float tmpvar_18;
          tmpvar_18 = (0.7790837 - (tmpvar_10 * 0.7790837));
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_13.y) + (in_f.xlv_TEXCOORD2 * tmpvar_13.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_13.z)));
          tmpvar_4 = (albedo_17 * tmpvar_18);
          float3 tmpvar_19;
          tmpvar_19 = _LightColor0.xyz;
          float3 worldView_20;
          worldView_20 = in_f.xlv_TEXCOORD5;
          float4 envSample_21;
          float3 R_22;
          float3 tmpvar_23;
          tmpvar_23 = (worldView_20 - (2 * (dot(tmpvar_3, worldView_20) * tmpvar_3)));
          R_22 = tmpvar_23;
          float4 tmpvar_24;
          float _tmp_dvx_50 = texCUBE(custom_SpecCube, R_22);
          tmpvar_24 = float4(_tmp_dvx_50, _tmp_dvx_50, _tmp_dvx_50, _tmp_dvx_50);
          envSample_21 = tmpvar_24;
          float4 data_25;
          data_25 = envSample_21;
          float3 normal_26;
          normal_26 = tmpvar_3;
          float3 viewDir_27;
          viewDir_27 = (-in_f.xlv_TEXCOORD5);
          float3 rimLightDirection_28;
          float3 col_29;
          float D_30;
          float V_31;
          float3 diffuseTerm_32;
          float roughness_33;
          float perceptualRoughness_34;
          float3 h_35;
          float tmpvar_36;
          tmpvar_36 = clamp(dot(normal_26, _WorldSpaceLightPos0.xyz), 0, 1);
          float3 tmpvar_37;
          tmpvar_37 = normalize((_WorldSpaceLightPos0.xyz + viewDir_27));
          h_35 = tmpvar_37;
          float tmpvar_38;
          float tmpvar_39;
          tmpvar_39 = clamp(dot(normal_26, h_35), 0, 1);
          tmpvar_38 = tmpvar_39;
          float tmpvar_40;
          tmpvar_40 = abs(dot(normal_26, viewDir_27));
          float tmpvar_41;
          float tmpvar_42;
          tmpvar_42 = clamp(dot(_WorldSpaceLightPos0.xyz, h_35), 0, 1);
          tmpvar_41 = tmpvar_42;
          float tmpvar_43;
          float smoothness_44;
          smoothness_44 = tmpvar_9;
          tmpvar_43 = (1 - smoothness_44);
          perceptualRoughness_34 = tmpvar_43;
          float tmpvar_45;
          float perceptualRoughness_46;
          perceptualRoughness_46 = perceptualRoughness_34;
          tmpvar_45 = (perceptualRoughness_46 * perceptualRoughness_46);
          roughness_33 = tmpvar_45;
          float3 tmpvar_47;
          float _tmp_dvx_51 = ((tmpvar_36 * 0.5) + 0.5);
          tmpvar_47 = float3(_tmp_dvx_51, _tmp_dvx_51, _tmp_dvx_51);
          diffuseTerm_32 = tmpvar_47;
          float tmpvar_48;
          float NdotL_49;
          NdotL_49 = tmpvar_36;
          float NdotV_50;
          NdotV_50 = tmpvar_40;
          float roughness_51;
          roughness_51 = roughness_33;
          tmpvar_48 = (0.5 / (((NdotL_49 * ((NdotV_50 * (1 - roughness_51)) + roughness_51)) + (NdotV_50 * ((NdotL_49 * (1 - roughness_51)) + roughness_51))) + 1E-05));
          V_31 = tmpvar_48;
          float tmpvar_52;
          float NdotH_53;
          NdotH_53 = tmpvar_38;
          float roughness_54;
          roughness_54 = roughness_33;
          float tmpvar_55;
          tmpvar_55 = (roughness_54 * roughness_54);
          float tmpvar_56;
          tmpvar_56 = ((((NdotH_53 * tmpvar_55) - NdotH_53) * NdotH_53) + 1);
          tmpvar_52 = ((0.3183099 * tmpvar_55) / ((tmpvar_56 * tmpvar_56) + 1E-07));
          D_30 = tmpvar_52;
          float3 tmpvar_57;
          tmpvar_57 = clamp(tmpvar_4, 0, 1);
          float x_58;
          x_58 = (1 - tmpvar_41);
          rimLightDirection_28 = in_f.xlv_TEXCOORD9;
          col_29 = (((clamp(tmpvar_4, 0, 1) * (((_GiColor * _IndirectDiffuseIntensity) * _MetallicMapIndirectDiffuseIntensity).xyz + (diffuseTerm_32 * _DirectLightIntensity))) + ((max(0, ((V_31 * D_30) * (3.141593 * tmpvar_36))) * (tmpvar_57 + ((1 - tmpvar_57) * ((x_58 * x_58) * ((x_58 * x_58) * x_58))))) * _DirectSpecularScale)) + clamp(((_RimColor.xyz * clamp(pow(((1 - tmpvar_36) * clamp(dot(normal_26, rimLightDirection_28), 0, 1)), _RimPower), 0, 1)) * _RimIntensity), 0, 1));
          float _tmp_dvx_52 = clamp(pow((1 - tmpvar_40), 5), 0, 1);
          float _tmp_dvx_53 = clamp((tmpvar_9 + (1 - tmpvar_18)), 0, 1);
          col_29 = (col_29 + ((((tmpvar_10 * ((unity_SpecCube0_HDR.x * ((unity_SpecCube0_HDR.w * (data_25.w - 1)) + 1)) * data_25.xyz)) * (1 - ((0.28 * roughness_33) * perceptualRoughness_34))) * lerp(lerp(float3(0.2209163, 0.2209163, 0.2209163), albedo_17, float3(tmpvar_10, tmpvar_10, tmpvar_10)), float3(_tmp_dvx_53, _tmp_dvx_53, _tmp_dvx_53), float3(_tmp_dvx_52, _tmp_dvx_52, _tmp_dvx_52))) * _InDirectLightIntensity));
          float3 tmpvar_59;
          tmpvar_59 = lerp((_AOColor.xyz * col_29), col_29, gmVar_5.zzz);
          col_29 = tmpvar_59;
          float4 tmpvar_60;
          tmpvar_60.xyz = float3(clamp((tmpvar_59 * tmpvar_19), 0, 1));
          tmpvar_60.w = tmpvar_8;
          final_col_2.xyz = tmpvar_60.xyz;
          final_col_2.w = tmpvar_8;
          out_f.color = final_col_2;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: SHADOWCASTER
    {
      Name "SHADOWCASTER"
      Tags
      { 
        "LIGHTMODE" = "SHADOWCASTER"
        "PerformanceChecks" = "False"
        "RenderType" = "Opaque"
        "SHADOWSUPPORT" = "true"
      }
      LOD 300
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f_vertex_lit members uv,diff,spec)
#pragma exclude_renderers d3d11
      #pragma multi_compile SHADOWS_DEPTH
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      #define conv_mxt4x4_3(mat4x4) float4(mat4x4[0].w,mat4x4[1].w,mat4x4[2].w,mat4x4[3].w)
      #define conv_mxt3x3_0(mat4x4) float3(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x)
      #define conv_mxt3x3_1(mat4x4) float3(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y)
      #define conv_mxt3x3_2(mat4x4) float3(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4 _Time;
      //uniform float4 _SinTime;
      //uniform float4 _CosTime;
      //uniform float4 unity_DeltaTime;
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _ProjectionParams;
      //uniform float4 _ScreenParams;
      //uniform float4 _ZBufferParams;
      //uniform float4 unity_OrthoParams;
      //uniform float4 unity_CameraWorldClipPlanes[6];
      //uniform float4x4 unity_CameraProjection;
      //uniform float4x4 unity_CameraInvProjection;
      //uniform float4x4 unity_WorldToCamera;
      //uniform float4x4 unity_CameraToWorld;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 _LightPositionRange;
      uniform float4 _LightProjectionParams;
      //uniform float4 unity_4LightPosX0;
      //uniform float4 unity_4LightPosY0;
      //uniform float4 unity_4LightPosZ0;
      //uniform float4 unity_4LightAtten0;
      //uniform float4 unity_LightColor[8];
      //uniform float4 unity_LightPosition[8];
      //uniform float4 unity_LightAtten[8];
      //uniform float4 unity_SpotDirection[8];
      //uniform float4 unity_SHAr;
      //uniform float4 unity_SHAg;
      //uniform float4 unity_SHAb;
      //uniform float4 unity_SHBr;
      //uniform float4 unity_SHBg;
      //uniform float4 unity_SHBb;
      //uniform float4 unity_SHC;
      //uniform float4 unity_OcclusionMaskSelector;
      uniform float4 unity_ProbesOcclusion;
      uniform float3 unity_LightColor0;
      uniform float3 unity_LightColor1;
      uniform float3 unity_LightColor2;
      uniform float3 unity_LightColor3;
      uniform float4x4 unity_ShadowSplitSpheres;
      uniform float4 unity_ShadowSplitSqRadii;
      //uniform float4 unity_LightShadowBias;
      //uniform float4 _LightSplitsNear;
      //uniform float4 _LightSplitsFar;
      //uniform float4x4x4 unity_WorldToShadow;
      //uniform float4 _LightShadowData;
      // uniform float4 unity_ShadowFadeCenterAndType;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_LODFade;
      //uniform float4 unity_WorldTransformParams;
      //uniform float4x4 glstate_matrix_transpose_modelview0;
      //uniform float4 glstate_lightmodel_ambient;
      //uniform float4 unity_AmbientSky;
      //uniform float4 unity_AmbientEquator;
      //uniform float4 unity_AmbientGround;
      uniform float4 unity_IndirectSpecColor;
      //uniform float4x4 UNITY_MATRIX_P;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixInvV;
      //uniform float4x4 unity_MatrixVP;
      //uniform int unity_StereoEyeIndex;
      uniform float4 unity_ShadowColor;
      //uniform float4 unity_FogColor;
      //uniform float4 unity_FogParams;
      // uniform sampler2D unity_Lightmap;
      // uniform sampler2D unity_LightmapInd;
      // uniform sampler2D unity_DynamicLightmap;
      uniform sampler2D unity_DynamicDirectionality;
      uniform sampler2D unity_DynamicNormal;
      // uniform float4 unity_LightmapST;
      // uniform float4 unity_DynamicLightmapST;
      //uniform samplerCUBE unity_SpecCube0;
      //uniform samplerCUBE unity_SpecCube1;
      SamplerState samplerunity_SpecCube1;
      //uniform float4 unity_SpecCube0_BoxMax;
      //uniform float4 unity_SpecCube0_BoxMin;
      //uniform float4 unity_SpecCube0_ProbePosition;
      //uniform float4 unity_SpecCube0_HDR;
      //uniform float4 unity_SpecCube1_BoxMax;
      //uniform float4 unity_SpecCube1_BoxMin;
      //uniform float4 unity_SpecCube1_ProbePosition;
      //uniform float4 unity_SpecCube1_HDR;
      //uniform float4 unity_Lightmap_HDR;
      uniform float4 unity_DynamicLightmap_HDR;
      uniform sampler _Albedo;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float4 vertex :Position;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      float2x2 xll_transpose_mf2x2(float2x2 m)
      {
      }
      
      float3x3 xll_transpose_mf3x3(float3x3 m)
      {
      }
      
      float4x4 xll_transpose_mf4x4(float4x4 m)
      {
      }
      
      float xll_saturate_f(float x)
      {
          return clamp(x, 0, 1);
      }
      
      float2 xll_saturate_vf2(float2 x)
      {
          return clamp(x, 0, 1);
      }
      
      float3 xll_saturate_vf3(float3 x)
      {
          return clamp(x, 0, 1);
      }
      
      float4 xll_saturate_vf4(float4 x)
      {
          return clamp(x, 0, 1);
      }
      
      float2x2 xll_saturate_mf2x2(float2x2 m)
      {
          return float2x2(clamp(conv_mxt2x2_0(m), 0, 1), clamp(conv_mxt2x2_1(m), 0, 1));
      }
      
      float3x3 xll_saturate_mf3x3(float3x3 m)
      {
          return float3x3(clamp(conv_mxt3x3_0(m), 0, 1), clamp(conv_mxt3x3_1(m), 0, 1), clamp(conv_mxt3x3_2(m), 0, 1));
      }
      
      float4x4 xll_saturate_mf4x4(float4x4 m)
      {
          return float4x4(clamp(conv_mxt4x4_0(m), 0, 1), clamp(conv_mxt4x4_1(m), 0, 1), clamp(conv_mxt4x4_2(m), 0, 1), clamp(conv_mxt4x4_3(m), 0, 1));
      }
      
      float3x3 xll_constructMat3_mf4x4(float4x4 m)
      {
          return float3x3(float3(conv_mxt4x4_0(m).xyz), float3(conv_mxt4x4_1(m).xyz), float3(conv_mxt4x4_2(m).xyz));
      }
      
      struct v2f_vertex_lit
      {
          float2 uv;
          float4 diff;
          float4 spec;
      };
      
      struct v2f_img
      {
          float4 pos;
          float2 uv;
      };
      
      struct appdata_img
      {
          float4 vertex;
          float2 texcoord;
      };
      
      struct v2f
      {
          float2 uv;
          float4 pos;
      };
      
      struct appdata_base
      {
          float4 vertex;
          float3 normal;
          float4 texcoord;
      };
      
      //float4x4 unity_MatrixMVP;
      //float4x4 unity_MatrixMV;
      //float4x4 unity_MatrixTMV;
      float4x4 unity_MatrixITMV;
      float4 UnityApplyLinearShadowBias(in float4 clipPos )
      {
          clipPos.z = (clipPos.z + xll_saturate_f((unity_LightShadowBias.x / clipPos.w)));
          float clamped = max(clipPos.z, (clipPos.w * (-1)));
          clipPos.z = lerp(clipPos.z, clamped, unity_LightShadowBias.y);
          return clipPos;
      }
      
      float3 UnityObjectToWorldNormal(in float3 norm )
      {
          return normalize(mul(norm, xll_constructMat3_mf4x4(unity_WorldToObject)));
      }
      
      float3 UnityWorldSpaceLightDir(in float3 worldPos )
      {
          return {(_WorldSpaceLightPos0.xyz - (worldPos * _WorldSpaceLightPos0.w))};
      }
      
      float4 UnityClipSpaceShadowCasterPos(in float4 vertex, in float3 normal )
      {
          float4 wPos = mul(unity_ObjectToWorld, vertex);
          if((unity_LightShadowBias.z!=0))
          {
              float3 wNormal = UnityObjectToWorldNormal(normal);
              float3 wLight = normalize(UnityWorldSpaceLightDir(wPos.xyz));
              float shadowCos = dot(wNormal, wLight);
              float shadowSine = sqrt((1 - (shadowCos * shadowCos)));
              float normalBias = (unity_LightShadowBias.z * shadowSine);
              wPos.xyz = (wPos.xyz - (wNormal * normalBias));
          }
          return {mul(unity_MatrixVP, wPos)};
      }
      
      v2f vert(in appdata_base v )
      {
          OUT_Data_Vert out_v;
          v2f o;
          o.uv = float2(v.texcoord);
          o.pos = UnityClipSpaceShadowCasterPos(v.vertex, v.normal);
          o.pos = UnityApplyLinearShadowBias(o.pos);
          //return o;
          return out_v;
      }
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          unity_MatrixMVP = mul(unity_MatrixVP, unity_ObjectToWorld);
          unity_MatrixMV = mul(unity_MatrixV, unity_ObjectToWorld);
          unity_MatrixTMV = xll_transpose_mf4x4(unity_MatrixMV);
          unity_MatrixITMV = xll_transpose_mf4x4(mul(unity_WorldToObject, unity_MatrixInvV));
          v2f xl_retval;
          appdata_base xlt_v;
          xlt_v.vertex = float4(in_v.vertex);
          xlt_v.normal = float3(in_v.normal);
          xlt_v.texcoord = float4(in_v.texcoord);
          xl_retval = vert(xlt_v);
          out_v.xlv_TEXCOORD0 = float2(xl_retval.uv);
          out_v.vertex = float4(xl_retval.pos);
          return out_v;
      }
      
      #endif
      #define CODE_BLOCK_FRAGMENT
      #ifndef SHADER_TARGET
      #define SHADER_TARGET 20
      #endif
      #ifndef UNITY_NO_DXT5nm
      #define UNITY_NO_DXT5nm 1
      #endif
      #ifndef UNITY_NO_RGBM
      #define UNITY_NO_RGBM 1
      #endif
      #ifndef UNITY_ENABLE_REFLECTION_BUFFERS
      #define UNITY_ENABLE_REFLECTION_BUFFERS 1
      #endif
      #ifndef UNITY_FRAMEBUFFER_FETCH_AVAILABLE
      #define UNITY_FRAMEBUFFER_FETCH_AVAILABLE 1
      #endif
      #ifndef UNITY_ENABLE_NATIVE_SHADOW_LOOKUPS
      #define UNITY_ENABLE_NATIVE_SHADOW_LOOKUPS 1
      #endif
      #ifndef UNITY_NO_CUBEMAP_ARRAY
      #define UNITY_NO_CUBEMAP_ARRAY 1
      #endif
      #ifndef UNITY_NO_SCREENSPACE_SHADOWS
      #define UNITY_NO_SCREENSPACE_SHADOWS 1
      #endif
      #ifndef UNITY_PBS_USE_BRDF3
      #define UNITY_PBS_USE_BRDF3 1
      #endif
      #ifndef SHADER_API_MOBILE
      #define SHADER_API_MOBILE 1
      #endif
      #ifndef UNITY_HARDWARE_TIER1
      #define UNITY_HARDWARE_TIER1 1
      #endif
      #ifndef UNITY_COLORSPACE_GAMMA
      #define UNITY_COLORSPACE_GAMMA 1
      #endif
      #ifndef UNITY_LIGHTMAP_DLDR_ENCODING
      #define UNITY_LIGHTMAP_DLDR_ENCODING 1
      #endif
      #ifndef SHADOWS_DEPTH
      #define SHADOWS_DEPTH 1
      #endif
      #ifndef UNITY_VERSION
      #define UNITY_VERSION 201749
      #endif
      #ifndef SHADER_STAGE_VERTEX
      #define SHADER_STAGE_VERTEX 1
      #endif
      #ifndef SHADER_API_GLES
      #define SHADER_API_GLES 1
      #endif
      void xll_clip_f(float x)
      {
          if((x<0))
          {
              discard;
          }
      }
      
      void xll_clip_vf2(float2 x)
      {
          if(bool(bool2(x < float2(0, 0)).x || bool2(x < float2(0, 0)).y))
          {
              discard;
          }
      }
      
      void xll_clip_vf3(float3 x)
      {
          if(bool(bool3(x < float3(0, 0, 0)).x || bool3(x < float3(0, 0, 0)).y || bool3(x < float3(0, 0, 0)).z))
          {
              discard;
          }
      }
      
      void xll_clip_vf4(float4 x)
      {
          if(bool(bool4(x < float4(0, 0, 0, 0)).x || bool4(x < float4(0, 0, 0, 0)).y || bool4(x < float4(0, 0, 0, 0)).z || bool4(x < float4(0, 0, 0, 0)).w))
          {
              discard;
          }
      }
      
      float2x2 xll_transpose_mf2x2(float2x2 m)
      {
      }
      
      float3x3 xll_transpose_mf3x3(float3x3 m)
      {
      }
      
      float4x4 xll_transpose_mf4x4(float4x4 m)
      {
      }
      
      struct v2f_vertex_lit
      {
          float2 uv;
          float4 diff;
          float4 spec;
      };
      
      struct v2f_img
      {
          float4 pos;
          float2 uv;
      };
      
      struct appdata_img
      {
          float4 vertex;
          float2 texcoord;
      };
      
      struct v2f
      {
          float2 uv;
          float4 pos;
      };
      
      struct appdata_base
      {
          float4 vertex;
          float3 normal;
          float4 texcoord;
      };
      
      //uniform float4 _Time;
      //uniform float4 _SinTime;
      //uniform float4 _CosTime;
      //uniform float4 unity_DeltaTime;
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4 _ProjectionParams;
      //uniform float4 _ScreenParams;
      //uniform float4 _ZBufferParams;
      //uniform float4 unity_OrthoParams;
      //uniform float4 unity_CameraWorldClipPlanes[6];
      //uniform float4x4 unity_CameraProjection;
      //uniform float4x4 unity_CameraInvProjection;
      //uniform float4x4 unity_WorldToCamera;
      //uniform float4x4 unity_CameraToWorld;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 _LightPositionRange;
      uniform float4 _LightProjectionParams;
      //uniform float4 unity_4LightPosX0;
      //uniform float4 unity_4LightPosY0;
      //uniform float4 unity_4LightPosZ0;
      //uniform float4 unity_4LightAtten0;
      //uniform float4 unity_LightColor[8];
      //uniform float4 unity_LightPosition[8];
      //uniform float4 unity_LightAtten[8];
      //uniform float4 unity_SpotDirection[8];
      //uniform float4 unity_SHAr;
      //uniform float4 unity_SHAg;
      //uniform float4 unity_SHAb;
      //uniform float4 unity_SHBr;
      //uniform float4 unity_SHBg;
      //uniform float4 unity_SHBb;
      //uniform float4 unity_SHC;
      //uniform float4 unity_OcclusionMaskSelector;
      uniform float4 unity_ProbesOcclusion;
      uniform float3 unity_LightColor0;
      uniform float3 unity_LightColor1;
      uniform float3 unity_LightColor2;
      uniform float3 unity_LightColor3;
      uniform float4x4 unity_ShadowSplitSpheres;
      uniform float4 unity_ShadowSplitSqRadii;
      //uniform float4 unity_LightShadowBias;
      //uniform float4 _LightSplitsNear;
      //uniform float4 _LightSplitsFar;
      //uniform float4x4x4 unity_WorldToShadow;
      //uniform float4 _LightShadowData;
      // uniform float4 unity_ShadowFadeCenterAndType;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_LODFade;
      //uniform float4 unity_WorldTransformParams;
      //uniform float4x4 glstate_matrix_transpose_modelview0;
      //uniform float4 glstate_lightmodel_ambient;
      //uniform float4 unity_AmbientSky;
      //uniform float4 unity_AmbientEquator;
      //uniform float4 unity_AmbientGround;
      uniform float4 unity_IndirectSpecColor;
      //uniform float4x4 UNITY_MATRIX_P;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixInvV;
      //uniform float4x4 unity_MatrixVP;
      //uniform int unity_StereoEyeIndex;
      uniform float4 unity_ShadowColor;
      //uniform float4 unity_FogColor;
      //uniform float4 unity_FogParams;
      // uniform sampler2D unity_Lightmap;
      // uniform sampler2D unity_LightmapInd;
      // uniform sampler2D unity_DynamicLightmap;
      uniform sampler2D unity_DynamicDirectionality;
      uniform sampler2D unity_DynamicNormal;
      // uniform float4 unity_LightmapST;
      // uniform float4 unity_DynamicLightmapST;
      //uniform samplerCUBE unity_SpecCube0;
      //uniform samplerCUBE unity_SpecCube1;
      SamplerState samplerunity_SpecCube1;
      //uniform float4 unity_SpecCube0_BoxMax;
      //uniform float4 unity_SpecCube0_BoxMin;
      //uniform float4 unity_SpecCube0_ProbePosition;
      //uniform float4 unity_SpecCube0_HDR;
      //uniform float4 unity_SpecCube1_BoxMax;
      //uniform float4 unity_SpecCube1_BoxMin;
      //uniform float4 unity_SpecCube1_ProbePosition;
      //uniform float4 unity_SpecCube1_HDR;
      //float4x4 unity_MatrixMVP;
      //float4x4 unity_MatrixMV;
      //float4x4 unity_MatrixTMV;
      float4x4 unity_MatrixITMV;
      //uniform float4 unity_Lightmap_HDR;
      uniform float4 unity_DynamicLightmap_HDR;
      uniform sampler _Albedo;
      float4 frag(in v2f i )
      {
          OUT_Data_Frag out_f;
          float alpha = tex2D(_Albedo, i.uv).w;
          xll_clip_f((alpha - 0.5));
          //return float4(0, 0, 0, 0);
          return out_f;
      }
      
      varying float2 xlv_TEXCOORD0;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          unity_MatrixMVP = mul(unity_MatrixVP, unity_ObjectToWorld);
          unity_MatrixMV = mul(unity_MatrixV, unity_ObjectToWorld);
          unity_MatrixTMV = xll_transpose_mf4x4(unity_MatrixMV);
          unity_MatrixITMV = xll_transpose_mf4x4(mul(unity_WorldToObject, unity_MatrixInvV));
          float4 xl_retval;
          v2f xlt_i;
          xlt_i.uv = float2(in_f.xlv_TEXCOORD0);
          xlt_i.pos = float4(0, 0, 0, 0);
          xl_retval = frag(xlt_i);
          out_f.color = float4(xl_retval);
          return out_f;
      }
      
      #endif
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
