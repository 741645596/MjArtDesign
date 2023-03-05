Shader "MJ/MJJade"
{
  Properties
  {
    [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", float) = 2
    _CenterDark ("_CenterDark", Range(0, 1)) = 0.5
    _NoiseTex ("NoiseTex", 2D) = "white" {}
    _JadeColor1 ("JadeColor1", Color) = (1,1,1,1)
    _JadeColor2 ("JadeColor2", Color) = (1,1,1,1)
    _RimColor ("Rim Color", Color) = (1,1,1,1)
    _RimPower ("Rim Intensity", Range(0, 10)) = 0
    _RimIntensity ("Rim Intensity", Range(0, 10)) = 0
    _Emission ("Emission", 2D) = "black" {}
    _Parallex ("Parallex", 2D) = "black" {}
    _ParallexScale ("ParallexScale", Range(0, 10)) = 0
    _MetallicMapIndirectDiffuseIntensity ("_MetallicMapIndirectDiffuseIntensity", Range(0, 15)) = 1
    [NoScaleOffset] _Albedo ("Albedo (RGB) Skin Smoothness or Transparency(A)", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)
    _BumpScale ("Scale", float) = 1
    [NoScaleOffset] _Bump ("Bump Map", 2D) = "bump" {}
    _Metallic ("metallic", Range(0, 1)) = 1
    _Glossiness ("glossiness", Range(0, 1)) = 1
    _DirectSpecularScale ("Direct Specular Scale", Range(0, 2)) = 1
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
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,pos,cameraLightDir,tangentView)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt3x3_0(mat4x4) float3(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x)
      #define conv_mxt3x3_1(mat4x4) float3(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y)
      #define conv_mxt3x3_2(mat4x4) float3(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z)
      
      
      #define CODE_BLOCK_VERTEX
      struct v2f
      {
          float2 uv;
          float3 worldNormal;
          float3 worldTangent;
          float3 worldBinormal;
          float3 worldPos;
          float3 worldView;
          float4 pos;
          float3 cameraLightDir;
          float3 tangentView;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 unity_SpecCube0_HDR;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _Metallic;
      uniform float _Glossiness;
      uniform samplerCUBE custom_SpecCube;
      uniform float4 _GiColor;
      uniform float _DirectLightIntensity;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
      uniform float4 _JadeColor1;
      uniform float4 _JadeColor2;
      uniform sampler2D _Emission;
      uniform sampler2D _NoiseTex;
      uniform float _CenterDark;
      uniform sampler2D _Parallex;
      uniform float _ParallexScale;
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
          float3 xlv_TEXCOORD13 :TEXCOORD13;
          float3 xlv_TEXCOORD14 :TEXCOORD14;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD14 :TEXCOORD14;
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
          tmpvar_2 = in_v.tangent;
          v2f o_3;
          o_3 = v2f(float2(0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0), float3(0, 0, 0), float3(0, 0, 0));
          float4 tmpvar_4;
          tmpvar_4.w = 1;
          tmpvar_4.xyz = in_v.vertex.xyz;
          o_3.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_4));
          o_3.uv = in_v.texcoord.xy;
          float4 tmpvar_5;
          tmpvar_5.w = 0;
          tmpvar_5.xyz = float3(tmpvar_1);
          o_3.worldNormal = normalize(mul(unity_ObjectToWorld, tmpvar_5).xyz);
          float4 tmpvar_6;
          tmpvar_6.w = 0;
          tmpvar_6.xyz = tmpvar_2.xyz;
          o_3.worldTangent = normalize(mul(unity_ObjectToWorld, tmpvar_6).xyz);
          float3 a_7;
          a_7 = o_3.worldNormal;
          float3 b_8;
          b_8 = o_3.worldTangent;
          o_3.worldBinormal = normalize((((a_7.yzx * b_8.zxy) - (a_7.zxy * b_8.yzx)) * in_v.tangent.w));
          o_3.worldPos = mul(unity_ObjectToWorld, in_v.vertex).xyz;
          o_3.worldView = normalize((o_3.worldPos - _WorldSpaceCameraPos));
          float3 tmpvar_9;
          tmpvar_9 = normalize(in_v.normal);
          float3 tmpvar_10;
          tmpvar_10 = normalize(in_v.tangent.xyz);
          float3 tmpvar_11;
          float3 tmpvar_12;
          tmpvar_11 = tmpvar_2.xyz;
          tmpvar_12 = (((tmpvar_9.yzx * tmpvar_10.zxy) - (tmpvar_9.zxy * tmpvar_10.yzx)) * in_v.tangent.w);
          float3x3 tmpvar_13;
          conv_mxt3x3_0(tmpvar_13).x = tmpvar_11.x;
          conv_mxt3x3_0(tmpvar_13).y = tmpvar_12.x;
          conv_mxt3x3_0(tmpvar_13).z = tmpvar_1.x;
          conv_mxt3x3_1(tmpvar_13).x = tmpvar_11.y;
          conv_mxt3x3_1(tmpvar_13).y = tmpvar_12.y;
          conv_mxt3x3_1(tmpvar_13).z = tmpvar_1.y;
          conv_mxt3x3_2(tmpvar_13).x = tmpvar_11.z;
          conv_mxt3x3_2(tmpvar_13).y = tmpvar_12.z;
          conv_mxt3x3_2(tmpvar_13).z = tmpvar_1.z;
          float4 tmpvar_14;
          tmpvar_14.w = 0;
          tmpvar_14.xyz = o_3.worldView;
          o_3.tangentView = normalize(mul(tmpvar_13, mul(unity_WorldToObject, tmpvar_14).xyz));
          out_v.xlv_TEXCOORD0 = o_3.uv;
          out_v.xlv_TEXCOORD1 = o_3.worldNormal;
          out_v.xlv_TEXCOORD2 = o_3.worldTangent;
          out_v.xlv_TEXCOORD3 = o_3.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_3.worldPos;
          out_v.xlv_TEXCOORD5 = o_3.worldView;
          out_v.vertex = o_3.pos;
          out_v.xlv_TEXCOORD13 = o_3.cameraLightDir;
          out_v.xlv_TEXCOORD14 = o_3.tangentView;
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
          float2 tmpvar_5;
          float3 albedo_6;
          float3 normalInTangent_7;
          float tmpvar_8;
          float tmpvar_9;
          float tmpvar_10;
          float4 tmpvar_11;
          tmpvar_11 = tex2D(_Parallex, in_f.xlv_TEXCOORD0);
          tmpvar_5 = ((((tmpvar_11.x * _ParallexScale) * in_f.xlv_TEXCOORD14.xz) / in_f.xlv_TEXCOORD14.y) + in_f.xlv_TEXCOORD0);
          float3 tmpvar_12;
          float3 tmpvar_13;
          tmpvar_13 = normalize(((tex2D(_Bump, tmpvar_5).xyz * 2) - 1));
          tmpvar_12 = tmpvar_13;
          normalInTangent_7 = tmpvar_12;
          float3 tmpvar_14;
          if((tmpvar_1>0))
          {
              tmpvar_14 = normalInTangent_7;
          }
          else
          {
              tmpvar_14 = (-normalInTangent_7);
          }
          normalInTangent_7 = tmpvar_14;
          float4 tmpvar_15;
          tmpvar_15 = tex2D(_Albedo, tmpvar_5);
          tmpvar_8 = tmpvar_15.w;
          albedo_6 = (tmpvar_15.xyz * _Color.xyz);
          float4 tmpvar_16;
          float2 P_17;
          float _tmp_dvx_19 = (1.6 * tmpvar_5);
          P_17 = float2(_tmp_dvx_19, _tmp_dvx_19);
          tmpvar_16 = tex2D(_NoiseTex, P_17);
          tmpvar_9 = tmpvar_16.x;
          float4 tmpvar_18;
          tmpvar_18 = lerp(_JadeColor2, _JadeColor1, float4(tmpvar_9, tmpvar_9, tmpvar_9, tmpvar_9));
          albedo_6 = (albedo_6 * tmpvar_18.xyz);
          tmpvar_10 = _Glossiness;
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_14.y) + (in_f.xlv_TEXCOORD2 * tmpvar_14.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_14.z)));
          tmpvar_4 = lerp(albedo_6, float3(0.04, 0.04, 0.04), float3(_Metallic, _Metallic, _Metallic));
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
          float _tmp_dvx_20 = texCUBE(custom_SpecCube, R_22);
          tmpvar_24 = float4(_tmp_dvx_20, _tmp_dvx_20, _tmp_dvx_20, _tmp_dvx_20);
          envSample_21 = tmpvar_24;
          float4 data_25;
          data_25 = envSample_21;
          float3 normal_26;
          normal_26 = tmpvar_3;
          float3 viewDir_27;
          viewDir_27 = (-in_f.xlv_TEXCOORD5);
          float3 col_28;
          float D_29;
          float V_30;
          float3 diffuseTerm_31;
          float roughness_32;
          float perceptualRoughness_33;
          float3 h_34;
          float tmpvar_35;
          tmpvar_35 = clamp(dot(normal_26, _WorldSpaceLightPos0.xyz), 0, 1);
          float3 tmpvar_36;
          tmpvar_36 = normalize((_WorldSpaceLightPos0.xyz + viewDir_27));
          h_34 = tmpvar_36;
          float tmpvar_37;
          float tmpvar_38;
          tmpvar_38 = clamp(dot(normal_26, h_34), 0, 1);
          tmpvar_37 = tmpvar_38;
          float tmpvar_39;
          tmpvar_39 = abs(dot(normal_26, viewDir_27));
          float tmpvar_40;
          float tmpvar_41;
          tmpvar_41 = clamp(dot(_WorldSpaceLightPos0.xyz, h_34), 0, 1);
          tmpvar_40 = tmpvar_41;
          float tmpvar_42;
          float smoothness_43;
          smoothness_43 = tmpvar_10;
          tmpvar_42 = (1 - smoothness_43);
          perceptualRoughness_33 = tmpvar_42;
          float tmpvar_44;
          float perceptualRoughness_45;
          perceptualRoughness_45 = perceptualRoughness_33;
          tmpvar_44 = (perceptualRoughness_45 * perceptualRoughness_45);
          roughness_32 = tmpvar_44;
          float3 tmpvar_46;
          float _tmp_dvx_21 = ((tmpvar_35 * 0.5) + 0.5);
          tmpvar_46 = float3(_tmp_dvx_21, _tmp_dvx_21, _tmp_dvx_21);
          diffuseTerm_31 = tmpvar_46;
          float tmpvar_47;
          float NdotL_48;
          NdotL_48 = tmpvar_35;
          float NdotV_49;
          NdotV_49 = tmpvar_39;
          float roughness_50;
          roughness_50 = roughness_32;
          tmpvar_47 = (0.5 / (((NdotL_48 * ((NdotV_49 * (1 - roughness_50)) + roughness_50)) + (NdotV_49 * ((NdotL_48 * (1 - roughness_50)) + roughness_50))) + 1E-05));
          V_30 = tmpvar_47;
          float tmpvar_51;
          float NdotH_52;
          NdotH_52 = tmpvar_37;
          float roughness_53;
          roughness_53 = roughness_32;
          float tmpvar_54;
          tmpvar_54 = (roughness_53 * roughness_53);
          float tmpvar_55;
          tmpvar_55 = ((((NdotH_52 * tmpvar_54) - NdotH_52) * NdotH_52) + 1);
          tmpvar_51 = ((0.3183099 * tmpvar_54) / ((tmpvar_55 * tmpvar_55) + 1E-07));
          D_29 = tmpvar_51;
          float3 tmpvar_56;
          tmpvar_56 = clamp(tmpvar_4, 0, 1);
          float x_57;
          x_57 = (1 - tmpvar_40);
          float3 tmpvar_58;
          tmpvar_58 = ((clamp(tmpvar_4, 0, 1) * (((_GiColor * _IndirectDiffuseIntensity) * _MetallicMapIndirectDiffuseIntensity).xyz + (diffuseTerm_31 * _DirectLightIntensity))) + ((max(0, ((V_30 * D_29) * (3.141593 * tmpvar_35))) * (tmpvar_56 + ((1 - tmpvar_56) * ((x_57 * x_57) * ((x_57 * x_57) * x_57))))) * _DirectSpecularScale));
          float _tmp_dvx_22 = clamp(pow(tmpvar_39, 4), 0, 1);
          col_28 = lerp(tmpvar_58, (tmpvar_58 * _CenterDark), float3(_tmp_dvx_22, _tmp_dvx_22, _tmp_dvx_22));
          float _tmp_dvx_23 = clamp((_RimIntensity * pow((1 - tmpvar_39), _RimPower)), 0, 1);
          col_28 = lerp(col_28, (col_28 + (_RimColor.xyz * clamp(tmpvar_9, 0.3, 1))), float3(_tmp_dvx_23, _tmp_dvx_23, _tmp_dvx_23));
          float4 tmpvar_59;
          tmpvar_59 = tex2D(_Emission, in_f.xlv_TEXCOORD0);
          col_28 = (col_28 + tmpvar_59.xyz);
          float _tmp_dvx_24 = clamp(pow((1 - tmpvar_39), 5), 0, 1);
          float _tmp_dvx_25 = clamp(tmpvar_10, 0, 1);
          col_28 = (col_28 + ((((_Metallic * ((unity_SpecCube0_HDR.x * ((unity_SpecCube0_HDR.w * (data_25.w - 1)) + 1)) * data_25.xyz)) * (1 - ((0.28 * roughness_32) * perceptualRoughness_33))) * lerp(float3(1, 1, 1), float3(_tmp_dvx_25, _tmp_dvx_25, _tmp_dvx_25), float3(_tmp_dvx_24, _tmp_dvx_24, _tmp_dvx_24))) * _InDirectLightIntensity));
          float4 tmpvar_60;
          tmpvar_60.xyz = float3(clamp((col_28 * tmpvar_19), 0, 1));
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
      #pragma multi_compile SHADOWS_DEPTH
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4 unity_LightShadowBias;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4x4 unity_MatrixVP;
      struct appdata_t
      {
          float4 vertex :POSITION;
          float3 normal :NORMAL;
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
          float4 wPos_2;
          float4 tmpvar_3;
          tmpvar_3 = mul(unity_ObjectToWorld, in_v.vertex);
          wPos_2 = tmpvar_3;
          if((unity_LightShadowBias.z!=0))
          {
              float3x3 tmpvar_4;
              tmpvar_4[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
              tmpvar_4[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
              tmpvar_4[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
              float3 tmpvar_5;
              tmpvar_5 = normalize(mul(in_v.normal, tmpvar_4));
              float tmpvar_6;
              tmpvar_6 = dot(tmpvar_5, normalize((_WorldSpaceLightPos0.xyz - (tmpvar_3.xyz * _WorldSpaceLightPos0.w))));
              wPos_2.xyz = (tmpvar_3.xyz - (tmpvar_5 * (unity_LightShadowBias.z * sqrt((1 - (tmpvar_6 * tmpvar_6))))));
          }
          tmpvar_1 = mul(unity_MatrixVP, wPos_2);
          float4 clipPos_7;
          clipPos_7.xyw = tmpvar_1.xyw;
          clipPos_7.z = (tmpvar_1.z + clamp((unity_LightShadowBias.x / tmpvar_1.w), 0, 1));
          clipPos_7.z = lerp(clipPos_7.z, max(clipPos_7.z, (-tmpvar_1.w)), unity_LightShadowBias.y);
          out_v.vertex = clipPos_7;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          out_f.color = float4(0, 0, 0, 0);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
