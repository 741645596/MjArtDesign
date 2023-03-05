Shader "MJ/MJCommon_Metallic"
{
  Properties
  {
    [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", float) = 2
    _MetallicMapIndirectDiffuseIntensity ("_MetallicMapIndirectDiffuseIntensity", Range(0, 15)) = 1
    _DirectSpecularExp ("_DirectSpecularExp", Range(0, 100)) = 10
    _InDirectLightIntensity ("间接光高光强度", Range(0, 3)) = 1
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
      }
      LOD 300
      Cull Off
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile LIGHTMAP_OFF
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
      uniform float _Metallic;
      uniform float _Glossiness;
      uniform samplerCUBE custom_SpecCube;
      uniform float4 _GiColor;
      uniform float _DirectLightIntensity;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
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
          float3 albedo_5;
          float3 normalInTangent_6;
          float tmpvar_7;
          float tmpvar_8;
          float3 tmpvar_9;
          float3 tmpvar_10;
          tmpvar_10 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_9 = tmpvar_10;
          normalInTangent_6 = tmpvar_9;
          float3 tmpvar_11;
          if((tmpvar_1>0))
          {
              tmpvar_11 = normalInTangent_6;
          }
          else
          {
              tmpvar_11 = (-normalInTangent_6);
          }
          normalInTangent_6 = tmpvar_11;
          float4 tmpvar_12;
          tmpvar_12 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          tmpvar_7 = tmpvar_12.w;
          albedo_5 = (tmpvar_12.xyz * _Color.xyz);
          tmpvar_8 = _Glossiness;
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_11.y) + (in_f.xlv_TEXCOORD2 * tmpvar_11.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_11.z)));
          tmpvar_4 = lerp(albedo_5, float3(0.04, 0.04, 0.04), float3(_Metallic, _Metallic, _Metallic));
          float3 tmpvar_13;
          float3 tmpvar_14;
          tmpvar_13 = _LightColor0.xyz;
          tmpvar_14 = _WorldSpaceLightPos0.xyz;
          float3 worldView_15;
          worldView_15 = in_f.xlv_TEXCOORD5;
          float4 envSample_16;
          float3 R_17;
          float3 tmpvar_18;
          tmpvar_18 = (worldView_15 - (2 * (dot(tmpvar_3, worldView_15) * tmpvar_3)));
          R_17 = tmpvar_18;
          float4 tmpvar_19;
          float _tmp_dvx_26 = texCUBE(custom_SpecCube, R_17);
          tmpvar_19 = float4(_tmp_dvx_26, _tmp_dvx_26, _tmp_dvx_26, _tmp_dvx_26);
          envSample_16 = tmpvar_19;
          float4 data_20;
          data_20 = envSample_16;
          float3 normal_21;
          normal_21 = tmpvar_3;
          float3 viewDir_22;
          viewDir_22 = (-in_f.xlv_TEXCOORD5);
          float3 rimLightDirection_23;
          float3 col_24;
          float D_25;
          float V_26;
          float3 diffuseTerm_27;
          float roughness_28;
          float perceptualRoughness_29;
          float3 h_30;
          float tmpvar_31;
          tmpvar_31 = clamp(dot(normal_21, tmpvar_14), 0, 1);
          float3 tmpvar_32;
          tmpvar_32 = normalize((tmpvar_14 + viewDir_22));
          h_30 = tmpvar_32;
          float tmpvar_33;
          float tmpvar_34;
          tmpvar_34 = clamp(dot(normal_21, h_30), 0, 1);
          tmpvar_33 = tmpvar_34;
          float tmpvar_35;
          tmpvar_35 = abs(dot(normal_21, viewDir_22));
          float tmpvar_36;
          float tmpvar_37;
          tmpvar_37 = clamp(dot(tmpvar_14, h_30), 0, 1);
          tmpvar_36 = tmpvar_37;
          float tmpvar_38;
          float smoothness_39;
          smoothness_39 = tmpvar_8;
          tmpvar_38 = (1 - smoothness_39);
          perceptualRoughness_29 = tmpvar_38;
          float tmpvar_40;
          float perceptualRoughness_41;
          perceptualRoughness_41 = perceptualRoughness_29;
          tmpvar_40 = (perceptualRoughness_41 * perceptualRoughness_41);
          roughness_28 = tmpvar_40;
          float3 tmpvar_42;
          float _tmp_dvx_27 = ((tmpvar_31 * 0.5) + 0.5);
          tmpvar_42 = float3(_tmp_dvx_27, _tmp_dvx_27, _tmp_dvx_27);
          diffuseTerm_27 = tmpvar_42;
          float tmpvar_43;
          float NdotL_44;
          NdotL_44 = tmpvar_31;
          float NdotV_45;
          NdotV_45 = tmpvar_35;
          float roughness_46;
          roughness_46 = roughness_28;
          tmpvar_43 = (0.5 / (((NdotL_44 * ((NdotV_45 * (1 - roughness_46)) + roughness_46)) + (NdotV_45 * ((NdotL_44 * (1 - roughness_46)) + roughness_46))) + 1E-05));
          V_26 = tmpvar_43;
          float tmpvar_47;
          float NdotH_48;
          NdotH_48 = tmpvar_33;
          float roughness_49;
          roughness_49 = roughness_28;
          float tmpvar_50;
          tmpvar_50 = (roughness_49 * roughness_49);
          float tmpvar_51;
          tmpvar_51 = ((((NdotH_48 * tmpvar_50) - NdotH_48) * NdotH_48) + 1);
          tmpvar_47 = ((0.3183099 * tmpvar_50) / ((tmpvar_51 * tmpvar_51) + 1E-07));
          D_25 = tmpvar_47;
          float3 tmpvar_52;
          tmpvar_52 = clamp(tmpvar_4, 0, 1);
          float x_53;
          x_53 = (1 - tmpvar_36);
          rimLightDirection_23 = in_f.xlv_TEXCOORD9;
          col_24 = (((clamp(tmpvar_4, 0, 1) * (((_GiColor * _IndirectDiffuseIntensity) * _MetallicMapIndirectDiffuseIntensity).xyz + (diffuseTerm_27 * _DirectLightIntensity))) + ((max(0, ((V_26 * D_25) * (3.141593 * tmpvar_31))) * (tmpvar_52 + ((1 - tmpvar_52) * ((x_53 * x_53) * ((x_53 * x_53) * x_53))))) * _DirectSpecularScale)) + clamp(((_RimColor.xyz * clamp(pow(((1 - tmpvar_31) * clamp(dot(normal_21, rimLightDirection_23), 0, 1)), _RimPower), 0, 1)) * _RimIntensity), 0, 1));
          float _tmp_dvx_28 = clamp(pow((1 - tmpvar_35), 5), 0, 1);
          float _tmp_dvx_29 = clamp(tmpvar_8, 0, 1);
          col_24 = (col_24 + ((((_Metallic * ((unity_SpecCube0_HDR.x * ((unity_SpecCube0_HDR.w * (data_20.w - 1)) + 1)) * data_20.xyz)) * (1 - ((0.28 * roughness_28) * perceptualRoughness_29))) * lerp(float3(1, 1, 1), float3(_tmp_dvx_29, _tmp_dvx_29, _tmp_dvx_29), float3(_tmp_dvx_28, _tmp_dvx_28, _tmp_dvx_28))) * _InDirectLightIntensity));
          float4 tmpvar_54;
          tmpvar_54.xyz = float3(clamp((col_24 * tmpvar_13), 0, 1));
          tmpvar_54.w = tmpvar_7;
          final_col_2.xyz = tmpvar_54.xyz;
          final_col_2.w = tmpvar_7;
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
      uniform float _Metallic;
      uniform float _Glossiness;
      uniform samplerCUBE custom_SpecCube;
      uniform float4 _GiColor;
      uniform float _DirectLightIntensity;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
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
          float3 albedo_5;
          float3 normalInTangent_6;
          float tmpvar_7;
          float tmpvar_8;
          float3 tmpvar_9;
          float3 tmpvar_10;
          tmpvar_10 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_9 = tmpvar_10;
          normalInTangent_6 = tmpvar_9;
          float3 tmpvar_11;
          if((tmpvar_1>0))
          {
              tmpvar_11 = normalInTangent_6;
          }
          else
          {
              tmpvar_11 = (-normalInTangent_6);
          }
          normalInTangent_6 = tmpvar_11;
          float4 tmpvar_12;
          tmpvar_12 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          tmpvar_7 = tmpvar_12.w;
          albedo_5 = (tmpvar_12.xyz * _Color.xyz);
          tmpvar_8 = _Glossiness;
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_11.y) + (in_f.xlv_TEXCOORD2 * tmpvar_11.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_11.z)));
          tmpvar_4 = lerp(albedo_5, float3(0.04, 0.04, 0.04), float3(_Metallic, _Metallic, _Metallic));
          float3 tmpvar_13;
          tmpvar_13 = _LightColor0.xyz;
          float3 worldView_14;
          worldView_14 = in_f.xlv_TEXCOORD5;
          float4 envSample_15;
          float3 R_16;
          float3 tmpvar_17;
          tmpvar_17 = (worldView_14 - (2 * (dot(tmpvar_3, worldView_14) * tmpvar_3)));
          R_16 = tmpvar_17;
          float4 tmpvar_18;
          float _tmp_dvx_30 = texCUBE(custom_SpecCube, R_16);
          tmpvar_18 = float4(_tmp_dvx_30, _tmp_dvx_30, _tmp_dvx_30, _tmp_dvx_30);
          envSample_15 = tmpvar_18;
          float4 data_19;
          data_19 = envSample_15;
          float3 normal_20;
          normal_20 = tmpvar_3;
          float3 viewDir_21;
          viewDir_21 = (-in_f.xlv_TEXCOORD5);
          float3 rimLightDirection_22;
          float3 col_23;
          float D_24;
          float V_25;
          float3 diffuseTerm_26;
          float roughness_27;
          float perceptualRoughness_28;
          float3 h_29;
          float tmpvar_30;
          tmpvar_30 = clamp(dot(normal_20, _WorldSpaceLightPos0.xyz), 0, 1);
          float3 tmpvar_31;
          tmpvar_31 = normalize((_WorldSpaceLightPos0.xyz + viewDir_21));
          h_29 = tmpvar_31;
          float tmpvar_32;
          float tmpvar_33;
          tmpvar_33 = clamp(dot(normal_20, h_29), 0, 1);
          tmpvar_32 = tmpvar_33;
          float tmpvar_34;
          tmpvar_34 = abs(dot(normal_20, viewDir_21));
          float tmpvar_35;
          float tmpvar_36;
          tmpvar_36 = clamp(dot(_WorldSpaceLightPos0.xyz, h_29), 0, 1);
          tmpvar_35 = tmpvar_36;
          float tmpvar_37;
          float smoothness_38;
          smoothness_38 = tmpvar_8;
          tmpvar_37 = (1 - smoothness_38);
          perceptualRoughness_28 = tmpvar_37;
          float tmpvar_39;
          float perceptualRoughness_40;
          perceptualRoughness_40 = perceptualRoughness_28;
          tmpvar_39 = (perceptualRoughness_40 * perceptualRoughness_40);
          roughness_27 = tmpvar_39;
          float3 tmpvar_41;
          float _tmp_dvx_31 = ((tmpvar_30 * 0.5) + 0.5);
          tmpvar_41 = float3(_tmp_dvx_31, _tmp_dvx_31, _tmp_dvx_31);
          diffuseTerm_26 = tmpvar_41;
          float tmpvar_42;
          float NdotL_43;
          NdotL_43 = tmpvar_30;
          float NdotV_44;
          NdotV_44 = tmpvar_34;
          float roughness_45;
          roughness_45 = roughness_27;
          tmpvar_42 = (0.5 / (((NdotL_43 * ((NdotV_44 * (1 - roughness_45)) + roughness_45)) + (NdotV_44 * ((NdotL_43 * (1 - roughness_45)) + roughness_45))) + 1E-05));
          V_25 = tmpvar_42;
          float tmpvar_46;
          float NdotH_47;
          NdotH_47 = tmpvar_32;
          float roughness_48;
          roughness_48 = roughness_27;
          float tmpvar_49;
          tmpvar_49 = (roughness_48 * roughness_48);
          float tmpvar_50;
          tmpvar_50 = ((((NdotH_47 * tmpvar_49) - NdotH_47) * NdotH_47) + 1);
          tmpvar_46 = ((0.3183099 * tmpvar_49) / ((tmpvar_50 * tmpvar_50) + 1E-07));
          D_24 = tmpvar_46;
          float3 tmpvar_51;
          tmpvar_51 = clamp(tmpvar_4, 0, 1);
          float x_52;
          x_52 = (1 - tmpvar_35);
          rimLightDirection_22 = in_f.xlv_TEXCOORD9;
          col_23 = (((clamp(tmpvar_4, 0, 1) * (((_GiColor * _IndirectDiffuseIntensity) * _MetallicMapIndirectDiffuseIntensity).xyz + (diffuseTerm_26 * _DirectLightIntensity))) + ((max(0, ((V_25 * D_24) * (3.141593 * tmpvar_30))) * (tmpvar_51 + ((1 - tmpvar_51) * ((x_52 * x_52) * ((x_52 * x_52) * x_52))))) * _DirectSpecularScale)) + clamp(((_RimColor.xyz * clamp(pow(((1 - tmpvar_30) * clamp(dot(normal_20, rimLightDirection_22), 0, 1)), _RimPower), 0, 1)) * _RimIntensity), 0, 1));
          float _tmp_dvx_32 = clamp(pow((1 - tmpvar_34), 5), 0, 1);
          float _tmp_dvx_33 = clamp(tmpvar_8, 0, 1);
          col_23 = (col_23 + ((((_Metallic * ((unity_SpecCube0_HDR.x * ((unity_SpecCube0_HDR.w * (data_19.w - 1)) + 1)) * data_19.xyz)) * (1 - ((0.28 * roughness_27) * perceptualRoughness_28))) * lerp(float3(1, 1, 1), float3(_tmp_dvx_33, _tmp_dvx_33, _tmp_dvx_33), float3(_tmp_dvx_32, _tmp_dvx_32, _tmp_dvx_32))) * _InDirectLightIntensity));
          float4 tmpvar_53;
          tmpvar_53.xyz = float3(clamp((col_23 * tmpvar_13), 0, 1));
          tmpvar_53.w = tmpvar_7;
          final_col_2.xyz = tmpvar_53.xyz;
          final_col_2.w = tmpvar_7;
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
