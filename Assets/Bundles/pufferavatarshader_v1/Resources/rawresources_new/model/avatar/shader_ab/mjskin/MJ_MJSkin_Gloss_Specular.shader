Shader "MJ/MJSkin_Gloss_Specular"
{
  Properties
  {
    _StockSpecular ("StockSpecular", Color) = (1,1,1,1)
    [Toggle(_STOCKING)] _Stocking ("Stocking", float) = 0
    [Toggle(_TATTOO)] _Tattoo ("Tattoo", float) = 0
    [Toggle(_UV2)] _UV2 ("UV2", float) = 0
    [Toggle(_SHIMMER)] _Shimmer ("shimmer", float) = 0
    _ShimmerNoise ("ShimmerNoise", 2D) = "White" {}
    _ShimmerNoiseUV ("ShimmerNoiseUV", Range(0, 100)) = 1
    _ShimmerSpecIntensity ("ShimmerSpecIntensity", Range(0, 3000)) = 1
    _ShimmerNoiseCut ("ShimmerNoiseCut", Range(0, 1)) = 0
    _ShimmerNoiseRange ("ShimmerNoiseCut", Range(0, 1)) = 1
    [HDR] _ShimmerSpecColor ("ShimmerSpecColor", Color) = (1,1,1,1)
    _ShimmerSpecExp ("_ShimmerSpecExp", Range(0, 50)) = 3
    _TattooTex ("TattooTex", 2D) = "White" {}
    _StockColor ("Stock Color", Color) = (0,0,0,1)
    _StockFresnelExp ("StockThickness", Range(0, 5)) = 0.049
    _StockFresnelMult ("StockFresnelMult", Range(0, 5)) = 1.5
    _MinOpacity ("MinOpacity", Range(0, 1)) = 0
    _MaxOpacity ("MaxOpacity", Range(0, 1)) = 0.9
    _FresnalExp_1 ("_FresnalExp_1", Range(0, 50)) = 0.6
    _SpecularFresnelMult ("SpecularFresnelMult", Range(0, 1)) = 0.5
    _DirectSpecularExp ("_DirectSpecularExp", Range(0, 100)) = 2
    _GST ("R(Gloss) G(Specular) B(Translucency)", 2D) = "white" {}
    [NoScaleOffset] _Albedo ("Albedo (RGB) Skin Smoothness or Transparency(A)", 2D) = "white" {}
    _GlossMap ("Gloss Map", 2D) = "white" {}
    _SmoothMap ("SmoothMap", 2D) = "white" {}
    _BSSRDFTex ("SSS BRDF", 2D) = "white" {}
    _ShadowColor ("_ShadowColor", Color) = (1,1,1,1)
    _DiffuseIntensity ("_DiffuseIntensity", Range(0, 5)) = 4.5
    _RimColor2 ("Rim Color", Color) = (1,1,1,1)
    _RimPower2 ("Rim Intensity", Range(0, 10)) = 0
    _RimIntensity2 ("Rim Intensity", Range(0, 10)) = 0
    _RimColor3 ("Rim Color", Color) = (1,1,1,1)
    _RimPower3 ("Rim Intensity", Range(0, 10)) = 0
    _RimIntensity3 ("Rim Intensity", Range(0, 10)) = 0
    _RimVector2 ("_RimVector", Vector) = (1,1,1,1)
    _RimVector3 ("_RimVector", Vector) = (1,1,1,1)
    _ShadowNoise ("shadow noise", 2D) = "black" {}
    _ShadowNoiseIntensity ("shadow noise intensity", Range(0, 10)) = 0
    _AttenColor ("AttenColor", Color) = (0,0,0,1)
    _MaxSpecScale ("Max SecularScale", Range(0, 15)) = 15
    _ScatteringMapScale ("Scatter Map Scale", Range(0, 10)) = 10
    _TranslucencyColor ("TranslucencyColor", Color) = (1,1,1,1)
    _ScatterMap ("Scatter Map", 2D) = "white" {}
    _Translucency ("Translucency", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)
    _Brightness ("Brightness", float) = 1
    _Cutoff ("Alpha Cutoff", Range(0, 0.99)) = 0.8
    _SpecularScale ("GI Specular Scale", float) = 1
    _DirectSpecularScale ("Direct Specular Scale", Range(0, 50)) = 1
    _ScatteringShadowIntensity ("Direct Specular Scale", Range(0, 10)) = 0.25
    _BumpScale ("Scale", float) = 1
    [NoScaleOffset] _Bump ("Bump Map", 2D) = "bump" {}
    _Glossiness ("Smoothness", Range(0, 3)) = 0.5
    _GlossMapScale ("Smoothness Scale", Range(0, 2)) = 1
    _BlurBumpBias ("Diffuse Normal Map Blur Bias", Range(0, 9)) = 3
    _BlurStrength ("Blur Strength", Range(0, 1)) = 0.8
    _SubColor ("Subsurface Color", Color) = (1,0.4,0.25,1)
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
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,rimLightDir2,rimLightDir3,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _UNITY_SHADOW
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
          float3 rimLightDir2;
          float3 rimLightDir3;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _RimVector;
      uniform float4 _RimVector2;
      uniform float4 _RimVector3;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4x4 unity_WorldToObject;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float4 _GiColor;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform float _MaxSpecScale;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
      uniform sampler2D _GST;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
      uniform float4 _RimColor3;
      uniform float _RimPower3;
      uniform float _RimIntensity3;
      uniform float _ScatteringMapScale;
      uniform sampler2D _BSSRDFTex;
      uniform float4 _TranslucencyColor;
      uniform float _DiffuseIntensity;
      uniform float4 _AttenColor;
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
          float3 xlv_TEXCOORD10 :TEXCOORD10;
          float3 xlv_TEXCOORD11 :TEXCOORD11;
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
          float3 xlv_TEXCOORD11 :TEXCOORD11;
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
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          float4 tmpvar_8;
          tmpvar_8.w = 0;
          tmpvar_8.xyz = _RimVector2.xyz;
          o_1.rimLightDir2 = normalize(mul(tmpvar_8, unity_MatrixV)).xyz;
          float3 tmpvar_9;
          tmpvar_9 = normalize(_RimVector3.xyz);
          o_1.rimLightDir3 = tmpvar_9;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
          out_v.xlv_TEXCOORD9 = o_1.rimLightDir;
          out_v.xlv_TEXCOORD10 = o_1.rimLightDir2;
          out_v.xlv_TEXCOORD11 = o_1.rimLightDir3;
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
          float tmpvar_5;
          float4 gst_6;
          float3 albedo_7;
          float3 normalInTangent_8;
          float3 tmpvar_9;
          float3 tmpvar_10;
          float3 tmpvar_11;
          tmpvar_11 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_10 = tmpvar_11;
          normalInTangent_8 = tmpvar_10;
          float3 tmpvar_12;
          if((tmpvar_1>0))
          {
              tmpvar_12 = normalInTangent_8;
          }
          else
          {
              tmpvar_12 = (-normalInTangent_8);
          }
          normalInTangent_8 = tmpvar_12;
          albedo_7 = (tex2D(_Albedo, in_f.xlv_TEXCOORD0).xyz * _Color.xyz);
          float4 tmpvar_13;
          tmpvar_13 = tex2D(_GST, in_f.xlv_TEXCOORD0);
          gst_6 = tmpvar_13;
          tmpvar_9 = albedo_7;
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_12.y) + (in_f.xlv_TEXCOORD2 * tmpvar_12.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_12.z)));
          float _tmp_dvx_270 = (gst_6.z * _ScatteringMapScale);
          tmpvar_4 = float3(_tmp_dvx_270, _tmp_dvx_270, _tmp_dvx_270);
          tmpvar_5 = (_MaxSpecScale * gst_6.y);
          float3 tmpvar_14;
          tmpvar_14 = _LightColor0.xyz;
          float3 normal_15;
          normal_15 = tmpvar_3;
          float3 viewDir_16;
          viewDir_16 = (-in_f.xlv_TEXCOORD5);
          float oneminusNL_17;
          float hitRim_18;
          float RNDL_19;
          float3 directSpec_20;
          float3 col_21;
          float3 h_22;
          float tmpvar_23;
          tmpvar_23 = clamp(dot(normal_15, _WorldSpaceLightPos0.xyz), 0, 1);
          float3 tmpvar_24;
          tmpvar_24 = normalize((_WorldSpaceLightPos0.xyz + viewDir_16));
          h_22 = tmpvar_24;
          float tmpvar_25;
          float tmpvar_26;
          tmpvar_26 = clamp(dot(normal_15, h_22), 0, 1);
          tmpvar_25 = tmpvar_26;
          float tmpvar_27;
          float tmpvar_28;
          tmpvar_28 = clamp(dot(_WorldSpaceLightPos0.xyz, h_22), 0, 1);
          tmpvar_27 = tmpvar_28;
          float2 tmpvar_29;
          tmpvar_29.x = ((((tmpvar_23 + 1) - 1) * 0.5) + 0.5);
          tmpvar_29.y = gst_6.x;
          float3 tmpvar_30;
          tmpvar_30 = tex2D(_BSSRDFTex, tmpvar_29).xyz;
          float3 tmpvar_31;
          tmpvar_31 = tmpvar_30;
          float3 tmpvar_32;
          float _tmp_dvx_271 = ((tmpvar_27 * 0.5) + 0.5);
          tmpvar_32 = (_DiffuseIntensity * (tmpvar_31 + lerp(_AttenColor, float4(1, 1, 1, 1), float4(_tmp_dvx_271, _tmp_dvx_271, _tmp_dvx_271, _tmp_dvx_271)).xyz));
          col_21 = tmpvar_32;
          col_21 = (col_21 + ((_GiColor * _IndirectDiffuseIntensity).xyz + (tmpvar_4 * _TranslucencyColor.xyz)));
          col_21 = (col_21 * tmpvar_9);
          float tmpvar_33;
          tmpvar_33 = pow(tmpvar_25, 10);
          float3 tmpvar_34;
          float x_35;
          x_35 = (1 - tmpvar_27);
          tmpvar_34 = (float3(0.1546414, 0.1546414, 0.1546414) + (float3(0.8453586, 0.8453586, 0.8453586) * ((x_35 * x_35) * ((x_35 * x_35) * x_35))));
          float3 tmpvar_36;
          tmpvar_36 = ((tmpvar_5 * tmpvar_33) * tmpvar_34);
          directSpec_20 = tmpvar_36;
          col_21 = (col_21 + (directSpec_20 * _DirectSpecularScale));
          float4 tmpvar_37;
          tmpvar_37.w = 0;
          tmpvar_37.xyz = float3(col_21);
          float3 tmpvar_38;
          tmpvar_38 = tmpvar_37.xyz;
          col_21 = tmpvar_38;
          float tmpvar_39;
          tmpvar_39 = dot(normal_15, in_f.xlv_TEXCOORD9);
          RNDL_19 = tmpvar_39;
          hitRim_18 = ((1 - tmpvar_23) * clamp(RNDL_19, 0, 1));
          col_21 = (col_21 + (((_RimColor.xyz * clamp(pow(hitRim_18, _RimPower), 0, 1)) * _RimIntensity) * (clamp(gst_6.w, 0, 0.5) * 2)));
          float4 tmpvar_40;
          tmpvar_40.w = 1;
          tmpvar_40.xyz = float3(normal_15);
          float3 tmpvar_41;
          tmpvar_41 = mul(unity_WorldToObject, tmpvar_40).xyz;
          float4 tmpvar_42;
          tmpvar_42.w = 1;
          tmpvar_42.xyz = _WorldSpaceLightPos0.xyz;
          float tmpvar_43;
          tmpvar_43 = clamp(dot(mul(unity_WorldToObject, tmpvar_42).xyz, tmpvar_41), 0, 1);
          oneminusNL_17 = (1 - tmpvar_43);
          float4 tmpvar_44;
          tmpvar_44.w = 1;
          tmpvar_44.xyz = in_f.xlv_TEXCOORD11;
          float tmpvar_45;
          tmpvar_45 = dot(tmpvar_41, mul(unity_WorldToObject, tmpvar_44).xyz);
          RNDL_19 = tmpvar_45;
          hitRim_18 = (oneminusNL_17 * clamp(RNDL_19, 0, 1));
          float tmpvar_46;
          tmpvar_46 = pow(hitRim_18, _RimPower3);
          hitRim_18 = tmpvar_46;
          col_21 = lerp(col_21, (tmpvar_9 * _RimColor3.xyz), (clamp((0.5 - tmpvar_4), 0, 1) * clamp((tmpvar_46 * _RimIntensity3), 0, 1)));
          float4 tmpvar_47;
          tmpvar_47.w = 1;
          tmpvar_47.xyz = float3(clamp((col_21 * tmpvar_14), 0, 1));
          final_col_2.xyz = tmpvar_47.xyz;
          final_col_2.w = 1;
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
      }
      LOD 300
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile SHADOWS_SCREEN
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
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir2,rimLightDir3,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _UNITY_SHADOW
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
          float3 rimLightDir2;
          float3 rimLightDir3;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _RimVector2;
      uniform float4 _RimVector3;
      //uniform float4 _WorldSpaceLightPos0;
      //uniform float4x4 unity_WorldToObject;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float4 _GiColor;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform float _MaxSpecScale;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
      uniform sampler2D _GST;
      uniform float4 _RimColor3;
      uniform float _RimPower3;
      uniform float _RimIntensity3;
      uniform float _ScatteringMapScale;
      uniform sampler2D _BSSRDFTex;
      uniform float4 _TranslucencyColor;
      uniform float _DiffuseIntensity;
      uniform float4 _AttenColor;
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
          float3 xlv_TEXCOORD10 :TEXCOORD10;
          float3 xlv_TEXCOORD11 :TEXCOORD11;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD11 :TEXCOORD11;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          v2f o_1;
          o_1 = v2f(float2(0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
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
          tmpvar_7.xyz = _RimVector2.xyz;
          o_1.rimLightDir2 = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          float3 tmpvar_8;
          tmpvar_8 = normalize(_RimVector3.xyz);
          o_1.rimLightDir3 = tmpvar_8;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
          out_v.xlv_TEXCOORD10 = o_1.rimLightDir2;
          out_v.xlv_TEXCOORD11 = o_1.rimLightDir3;
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
          float tmpvar_5;
          float4 gst_6;
          float3 albedo_7;
          float3 normalInTangent_8;
          float3 tmpvar_9;
          float3 tmpvar_10;
          float3 tmpvar_11;
          tmpvar_11 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          tmpvar_10 = tmpvar_11;
          normalInTangent_8 = tmpvar_10;
          float3 tmpvar_12;
          if((tmpvar_1>0))
          {
              tmpvar_12 = normalInTangent_8;
          }
          else
          {
              tmpvar_12 = (-normalInTangent_8);
          }
          normalInTangent_8 = tmpvar_12;
          albedo_7 = (tex2D(_Albedo, in_f.xlv_TEXCOORD0).xyz * _Color.xyz);
          float4 tmpvar_13;
          tmpvar_13 = tex2D(_GST, in_f.xlv_TEXCOORD0);
          gst_6 = tmpvar_13;
          tmpvar_9 = albedo_7;
          tmpvar_3 = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_12.y) + (in_f.xlv_TEXCOORD2 * tmpvar_12.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_12.z)));
          float _tmp_dvx_272 = (gst_6.z * _ScatteringMapScale);
          tmpvar_4 = float3(_tmp_dvx_272, _tmp_dvx_272, _tmp_dvx_272);
          tmpvar_5 = (_MaxSpecScale * gst_6.y);
          float3 tmpvar_14;
          tmpvar_14 = _LightColor0.xyz;
          float3 normal_15;
          normal_15 = tmpvar_3;
          float3 viewDir_16;
          viewDir_16 = (-in_f.xlv_TEXCOORD5);
          float oneminusNL_17;
          float hitRim_18;
          float RNDL_19;
          float3 directSpec_20;
          float3 col_21;
          float3 h_22;
          float3 tmpvar_23;
          tmpvar_23 = normalize((_WorldSpaceLightPos0.xyz + viewDir_16));
          h_22 = tmpvar_23;
          float tmpvar_24;
          float tmpvar_25;
          tmpvar_25 = clamp(dot(normal_15, h_22), 0, 1);
          tmpvar_24 = tmpvar_25;
          float tmpvar_26;
          float tmpvar_27;
          tmpvar_27 = clamp(dot(_WorldSpaceLightPos0.xyz, h_22), 0, 1);
          tmpvar_26 = tmpvar_27;
          float2 tmpvar_28;
          tmpvar_28.x = ((((clamp(dot(normal_15, _WorldSpaceLightPos0.xyz), 0, 1) + 1) - 1) * 0.5) + 0.5);
          tmpvar_28.y = gst_6.x;
          float3 tmpvar_29;
          tmpvar_29 = tex2D(_BSSRDFTex, tmpvar_28).xyz;
          float3 tmpvar_30;
          tmpvar_30 = tmpvar_29;
          float3 tmpvar_31;
          float _tmp_dvx_273 = ((tmpvar_26 * 0.5) + 0.5);
          tmpvar_31 = (_DiffuseIntensity * (tmpvar_30 + lerp(_AttenColor, float4(1, 1, 1, 1), float4(_tmp_dvx_273, _tmp_dvx_273, _tmp_dvx_273, _tmp_dvx_273)).xyz));
          col_21 = tmpvar_31;
          col_21 = (col_21 + ((_GiColor * _IndirectDiffuseIntensity).xyz + (tmpvar_4 * _TranslucencyColor.xyz)));
          col_21 = (col_21 * tmpvar_9);
          float tmpvar_32;
          tmpvar_32 = pow(tmpvar_24, 10);
          float3 tmpvar_33;
          float x_34;
          x_34 = (1 - tmpvar_26);
          tmpvar_33 = (float3(0.1546414, 0.1546414, 0.1546414) + (float3(0.8453586, 0.8453586, 0.8453586) * ((x_34 * x_34) * ((x_34 * x_34) * x_34))));
          float3 tmpvar_35;
          tmpvar_35 = ((tmpvar_5 * tmpvar_32) * tmpvar_33);
          directSpec_20 = tmpvar_35;
          col_21 = (col_21 + (directSpec_20 * _DirectSpecularScale));
          float4 tmpvar_36;
          tmpvar_36.w = 0;
          tmpvar_36.xyz = float3(col_21);
          float3 tmpvar_37;
          tmpvar_37 = tmpvar_36.xyz;
          col_21 = tmpvar_37;
          float4 tmpvar_38;
          tmpvar_38.w = 1;
          tmpvar_38.xyz = float3(normal_15);
          float3 tmpvar_39;
          tmpvar_39 = mul(unity_WorldToObject, tmpvar_38).xyz;
          float4 tmpvar_40;
          tmpvar_40.w = 1;
          tmpvar_40.xyz = _WorldSpaceLightPos0.xyz;
          float tmpvar_41;
          tmpvar_41 = clamp(dot(mul(unity_WorldToObject, tmpvar_40).xyz, tmpvar_39), 0, 1);
          oneminusNL_17 = (1 - tmpvar_41);
          float4 tmpvar_42;
          tmpvar_42.w = 1;
          tmpvar_42.xyz = in_f.xlv_TEXCOORD11;
          float tmpvar_43;
          tmpvar_43 = dot(tmpvar_39, mul(unity_WorldToObject, tmpvar_42).xyz);
          RNDL_19 = tmpvar_43;
          hitRim_18 = (oneminusNL_17 * clamp(RNDL_19, 0, 1));
          float tmpvar_44;
          tmpvar_44 = pow(hitRim_18, _RimPower3);
          hitRim_18 = tmpvar_44;
          col_21 = lerp(col_21, (tmpvar_9 * _RimColor3.xyz), (clamp((0.5 - tmpvar_4), 0, 1) * clamp((tmpvar_44 * _RimIntensity3), 0, 1)));
          float4 tmpvar_45;
          tmpvar_45.w = 1;
          tmpvar_45.xyz = float3(clamp((col_21 * tmpvar_14), 0, 1));
          final_col_2.xyz = tmpvar_45.xyz;
          final_col_2.w = 1;
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
      }
      LOD 300
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile SHADOWS_SCREEN
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
