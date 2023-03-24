// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_ShadowFadeCenterAndType', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_DynamicLightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_LightmapInd', a built-in variable

Shader "MJ/MJHair"
{
  Properties
  {
    _Shift ("Shift", Range(0, 1)) = 0.324
    [Toggle(_BACKFACE_SPEC)] _BackfaceSpecular ("BackFaceSpecular", float) = 0
    [Toggle(_UV2)] _UV2 ("UV2", float) = 0
    _MPrimaryShift ("primaryshift", Range(-1, 1)) = 0.1
    _SpecPower1 ("specPower1", Range(0, 1000)) = 1000
    _SpecStrength ("SpecStrength", Range(0, 10)) = 1
    _SpecColor1 ("SpecColor1", Color) = (1,1,1,1)
    _HairSpecFreq1 ("HairSpecularFrequency", Range(0, 2)) = 1
    _MSecondaryShift ("secondShift", Range(-1, 1)) = 0.05
    _SpecPower2 ("specPower2", Range(0, 1000)) = 1000
    _SpecStrength2 ("SpecStrength2", Range(0, 10)) = 1
    _SpecColor2 ("SpecColor2", Color) = (1,1,1,1)
    _HairSpecFreq2 ("HairSpecularFrequency2", Range(0, 2)) = 1
    _ThirdShift ("Thirdshift", Range(-1, 1)) = 0.1
    _SpecPower3 ("specPower3", Range(0, 1000)) = 1000
    _SpecStrength3 ("SpecStrength3", Range(0, 10)) = 1
    _HairSpecFreq3 ("HairSpecularFrequency3", Range(0, 2)) = 1
    _SpecColor3 ("SpecColor3", Color) = (1,1,1,1)
    _Color ("Color", Color) = (1,1,1,1)
    _AlphaScale ("Alpha Scale", float) = 1
    _Albedo ("Albedo", 2D) = "white" {}
    _UV2Tex ("UV2 Tex", 2D) = "white" {}
    _Blend ("Blend", Range(0, 0.99)) = 0
    _Cutoff ("Cutoff", Range(0, 0.99)) = 0.5
    [NoScaleOffset] _Bump ("Normal Map", 2D) = "bump" {}
    _BumpScale ("Scale", Range(0, 2)) = 1
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
      "QUEUE" = "Transparent+1"
      "RenderType" = "Transparent"
    }
    LOD 200
    Pass // ind: 1, name: FORWARD
    {
      Name "FORWARD"
      Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "FORWARDBASE"
        "QUEUE" = "Transparent+1"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
      Cull Off
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,uv1,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _UNITY_SHADOW
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      struct v2f
      {
          float4 uv;
          float4 uv1;
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
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _Cutoff;
      uniform float _BumpScale;
      uniform sampler2D _Albedo;
      uniform sampler2D _UV2Tex;
      uniform sampler2D _Bump;
      uniform float4 _GiColor;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
      uniform float _Shift;
      uniform float _IndirectDiffuseIntensity;
      uniform float _MPrimaryShift;
      uniform float _SpecPower1;
      uniform float _SpecStrength;
      uniform float4 _SpecColor1;
      uniform float _ThirdShift;
      uniform float _SpecPower3;
      uniform float _SpecStrength3;
      uniform float4 _SpecColor3;
      uniform float _Blend;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD6 :TEXCOORD6;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD6 :TEXCOORD6;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          v2f o_1;
          o_1 = v2f(float4(0, 0, 0, 0), float4(0, 0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          o_1.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          o_1.uv.xy = in_v.texcoord.xy;
          o_1.uv1.xy = in_v.texcoord1.xy;
          o_1.uv.zw = float2(0, 0);
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
          tmpvar_7.xyz = _RimVector.xyz;
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD7 = o_1.uv1;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
          out_v.xlv_TEXCOORD6 = o_1.rimLightDir;
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
          float alpha_3;
          float4 albedo_alpha_4;
          float3 tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(in_f.xlv_TEXCOORD5);
          float4 tmpvar_7;
          tmpvar_7 = tex2D(_Bump, in_f.xlv_TEXCOORD0.xy);
          float4 packednormal_8;
          packednormal_8 = tmpvar_7;
          float3 normal_9;
          float3 tmpvar_10;
          tmpvar_10 = ((packednormal_8.xyz * 2) - 1);
          normal_9.z = tmpvar_10.z;
          normal_9.xy = (tmpvar_10.xy * _BumpScale);
          float3 normal_11;
          normal_11 = normal_9;
          float3 tmpvar_12;
          tmpvar_12 = normalize((((normalize(in_f.xlv_TEXCOORD3) * normal_11.y) + (normalize(in_f.xlv_TEXCOORD2) * normal_11.x)) + (normalize(in_f.xlv_TEXCOORD1) * normal_11.z)));
          float4 tmpvar_13;
          tmpvar_13 = tex2D(_Albedo, in_f.xlv_TEXCOORD0.xy);
          float4 tmpvar_14;
          tmpvar_14 = (tmpvar_13 * _Color);
          albedo_alpha_4 = tmpvar_14;
          float4 tmpvar_15;
          tmpvar_15 = tex2D(_UV2Tex, in_f.xlv_TEXCOORD7.xy);
          float3 tmpvar_16;
          tmpvar_16 = lerp(albedo_alpha_4.xyz, tmpvar_15.xyz, float3(_Blend, _Blend, _Blend));
          albedo_alpha_4.xyz = float3(tmpvar_16);
          tmpvar_5 = albedo_alpha_4.xyz;
          float tmpvar_17;
          tmpvar_17 = albedo_alpha_4.w;
          alpha_3 = tmpvar_17;
          float x_18;
          x_18 = (alpha_3 - _Cutoff);
          if((x_18<0))
          {
              discard;
          }
          float3 tmpvar_19;
          tmpvar_19 = _LightColor0.xyz;
          float3 tmpvar_20;
          tmpvar_20 = normalize(_WorldSpaceLightPos0.xyz);
          float3 normal_21;
          normal_21 = tmpvar_12;
          float3 viewDir_22;
          viewDir_22 = (-tmpvar_6);
          float3 binormal_23;
          binormal_23 = in_f.xlv_TEXCOORD3;
          float3 rimLightDir_24;
          rimLightDir_24 = in_f.xlv_TEXCOORD6;
          float3 t3_25;
          float3 t1_26;
          float3 h_27;
          float tmpvar_28;
          tmpvar_28 = clamp(dot(normal_21, tmpvar_20), 0, 1);
          float3 tmpvar_29;
          tmpvar_29 = normalize((tmpvar_20 + viewDir_22));
          h_27 = tmpvar_29;
          float tmpvar_30;
          float tmpvar_31;
          tmpvar_31 = clamp(dot(tmpvar_20, h_27), 0, 1);
          tmpvar_30 = tmpvar_31;
          float3 T_32;
          T_32 = binormal_23;
          float3 N_33;
          N_33 = normal_21;
          float shift_34;
          shift_34 = (_MPrimaryShift + _Shift);
          float3 tmpvar_35;
          tmpvar_35 = normalize((T_32 + (shift_34 * N_33)));
          t1_26 = tmpvar_35;
          float3 T_36;
          T_36 = binormal_23;
          float3 N_37;
          N_37 = normal_21;
          float shift_38;
          shift_38 = (_ThirdShift + _Shift);
          float3 tmpvar_39;
          tmpvar_39 = normalize((T_36 + (shift_38 * N_37)));
          t3_25 = tmpvar_39;
          float tmpvar_40;
          float3 T_41;
          T_41 = t1_26;
          float3 V_42;
          V_42 = viewDir_22;
          float3 L_43;
          L_43 = tmpvar_20;
          float exponent_44;
          exponent_44 = _SpecPower1;
          float tmpvar_45;
          tmpvar_45 = dot(T_41, normalize((L_43 + V_42)));
          float tmpvar_46;
          tmpvar_46 = clamp((tmpvar_45 - (-1)), 0, 1);
          tmpvar_40 = ((tmpvar_46 * (tmpvar_46 * (3 - (2 * tmpvar_46)))) * pow(sqrt((1 - (tmpvar_45 * tmpvar_45))), exponent_44));
          float tmpvar_47;
          float3 T_48;
          T_48 = t3_25;
          float3 V_49;
          V_49 = viewDir_22;
          float3 L_50;
          L_50 = tmpvar_20;
          float exponent_51;
          exponent_51 = _SpecPower3;
          float tmpvar_52;
          tmpvar_52 = dot(T_48, normalize((L_50 + V_49)));
          float tmpvar_53;
          tmpvar_53 = clamp((tmpvar_52 - (-1)), 0, 1);
          tmpvar_47 = ((tmpvar_53 * (tmpvar_53 * (3 - (2 * tmpvar_53)))) * pow(sqrt((1 - (tmpvar_52 * tmpvar_52))), exponent_51));
          float x_54;
          x_54 = (1 - tmpvar_30);
          float tmpvar_55;
          tmpvar_55 = clamp(tmpvar_1, 0, 1);
          float tmpvar_56;
          tmpvar_56 = clamp(tmpvar_1, 0, 1);
          float4 tmpvar_57;
          tmpvar_57.w = 1;
          tmpvar_57.xyz = clamp((((tmpvar_5 * ((_GiColor * _IndirectDiffuseIntensity).xyz + (tmpvar_19 * clamp(tmpvar_28, 0.3, 1)))) + ((((((tmpvar_40 * _SpecColor1).xyz * _SpecStrength) + ((tmpvar_47 * _SpecColor3).xyz * _SpecStrength3)) * abs(dot(normal_21, viewDir_22))) * (tmpvar_5 + ((1 - tmpvar_5) * ((x_54 * x_54) * ((x_54 * x_54) * x_54))))) * tmpvar_55)) + (((_RimColor.xyz * clamp(pow(((1 - tmpvar_28) * clamp(dot(normal_21, rimLightDir_24), 0, 1)), _RimPower), 0, 1)) * _RimIntensity) * tmpvar_56)), 0, 1);
          final_col_2.xyz = tmpvar_57.xyz;
          final_col_2.w = alpha_3;
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
        "QUEUE" = "Transparent+1"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
      ZTest Less
      ZWrite Off
      Cull Front
      Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,uv1,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _UNITY_SHADOW
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      struct v2f
      {
          float4 uv;
          float4 uv1;
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
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _BumpScale;
      uniform sampler2D _Albedo;
      uniform sampler2D _UV2Tex;
      uniform sampler2D _Bump;
      uniform float4 _GiColor;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
      uniform float _Shift;
      uniform float _IndirectDiffuseIntensity;
      uniform float _MPrimaryShift;
      uniform float _SpecPower1;
      uniform float _SpecStrength;
      uniform float4 _SpecColor1;
      uniform float _ThirdShift;
      uniform float _SpecPower3;
      uniform float _SpecStrength3;
      uniform float4 _SpecColor3;
      uniform float _Blend;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD6 :TEXCOORD6;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD6 :TEXCOORD6;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          v2f o_1;
          o_1 = v2f(float4(0, 0, 0, 0), float4(0, 0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          o_1.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          o_1.uv.xy = in_v.texcoord.xy;
          o_1.uv1.xy = in_v.texcoord1.xy;
          o_1.uv.zw = float2(0, 0);
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
          tmpvar_7.xyz = _RimVector.xyz;
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD7 = o_1.uv1;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
          out_v.xlv_TEXCOORD6 = o_1.rimLightDir;
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
          float alpha_3;
          float4 albedo_alpha_4;
          float3 tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(in_f.xlv_TEXCOORD5);
          float4 tmpvar_7;
          tmpvar_7 = tex2D(_Bump, in_f.xlv_TEXCOORD0.xy);
          float4 packednormal_8;
          packednormal_8 = tmpvar_7;
          float3 normal_9;
          float3 tmpvar_10;
          tmpvar_10 = ((packednormal_8.xyz * 2) - 1);
          normal_9.z = tmpvar_10.z;
          normal_9.xy = (tmpvar_10.xy * _BumpScale);
          float3 normal_11;
          normal_11 = normal_9;
          float3 tmpvar_12;
          tmpvar_12 = normalize((((normalize(in_f.xlv_TEXCOORD3) * normal_11.y) + (normalize(in_f.xlv_TEXCOORD2) * normal_11.x)) + (normalize(in_f.xlv_TEXCOORD1) * normal_11.z)));
          float4 tmpvar_13;
          tmpvar_13 = tex2D(_Albedo, in_f.xlv_TEXCOORD0.xy);
          float4 tmpvar_14;
          tmpvar_14 = (tmpvar_13 * _Color);
          albedo_alpha_4 = tmpvar_14;
          float4 tmpvar_15;
          tmpvar_15 = tex2D(_UV2Tex, in_f.xlv_TEXCOORD7.xy);
          float3 tmpvar_16;
          tmpvar_16 = lerp(albedo_alpha_4.xyz, tmpvar_15.xyz, float3(_Blend, _Blend, _Blend));
          albedo_alpha_4.xyz = float3(tmpvar_16);
          tmpvar_5 = albedo_alpha_4.xyz;
          float tmpvar_17;
          tmpvar_17 = albedo_alpha_4.w;
          alpha_3 = tmpvar_17;
          float3 tmpvar_18;
          tmpvar_18 = _LightColor0.xyz;
          float3 tmpvar_19;
          tmpvar_19 = normalize(_WorldSpaceLightPos0.xyz);
          float3 normal_20;
          normal_20 = tmpvar_12;
          float3 viewDir_21;
          viewDir_21 = (-tmpvar_6);
          float3 binormal_22;
          binormal_22 = in_f.xlv_TEXCOORD3;
          float3 rimLightDir_23;
          rimLightDir_23 = in_f.xlv_TEXCOORD6;
          float3 t3_24;
          float3 t1_25;
          float3 h_26;
          float tmpvar_27;
          tmpvar_27 = clamp(dot(normal_20, tmpvar_19), 0, 1);
          float3 tmpvar_28;
          tmpvar_28 = normalize((tmpvar_19 + viewDir_21));
          h_26 = tmpvar_28;
          float tmpvar_29;
          float tmpvar_30;
          tmpvar_30 = clamp(dot(tmpvar_19, h_26), 0, 1);
          tmpvar_29 = tmpvar_30;
          float3 T_31;
          T_31 = binormal_22;
          float3 N_32;
          N_32 = normal_20;
          float shift_33;
          shift_33 = (_MPrimaryShift + _Shift);
          float3 tmpvar_34;
          tmpvar_34 = normalize((T_31 + (shift_33 * N_32)));
          t1_25 = tmpvar_34;
          float3 T_35;
          T_35 = binormal_22;
          float3 N_36;
          N_36 = normal_20;
          float shift_37;
          shift_37 = (_ThirdShift + _Shift);
          float3 tmpvar_38;
          tmpvar_38 = normalize((T_35 + (shift_37 * N_36)));
          t3_24 = tmpvar_38;
          float tmpvar_39;
          float3 T_40;
          T_40 = t1_25;
          float3 V_41;
          V_41 = viewDir_21;
          float3 L_42;
          L_42 = tmpvar_19;
          float exponent_43;
          exponent_43 = _SpecPower1;
          float tmpvar_44;
          tmpvar_44 = dot(T_40, normalize((L_42 + V_41)));
          float tmpvar_45;
          tmpvar_45 = clamp((tmpvar_44 - (-1)), 0, 1);
          tmpvar_39 = ((tmpvar_45 * (tmpvar_45 * (3 - (2 * tmpvar_45)))) * pow(sqrt((1 - (tmpvar_44 * tmpvar_44))), exponent_43));
          float tmpvar_46;
          float3 T_47;
          T_47 = t3_24;
          float3 V_48;
          V_48 = viewDir_21;
          float3 L_49;
          L_49 = tmpvar_19;
          float exponent_50;
          exponent_50 = _SpecPower3;
          float tmpvar_51;
          tmpvar_51 = dot(T_47, normalize((L_49 + V_48)));
          float tmpvar_52;
          tmpvar_52 = clamp((tmpvar_51 - (-1)), 0, 1);
          tmpvar_46 = ((tmpvar_52 * (tmpvar_52 * (3 - (2 * tmpvar_52)))) * pow(sqrt((1 - (tmpvar_51 * tmpvar_51))), exponent_50));
          float x_53;
          x_53 = (1 - tmpvar_29);
          float tmpvar_54;
          tmpvar_54 = clamp(tmpvar_1, 0, 1);
          float tmpvar_55;
          tmpvar_55 = clamp(tmpvar_1, 0, 1);
          float4 tmpvar_56;
          tmpvar_56.w = 1;
          tmpvar_56.xyz = clamp((((tmpvar_5 * ((_GiColor * _IndirectDiffuseIntensity).xyz + (tmpvar_18 * clamp(tmpvar_27, 0.3, 1)))) + ((((((tmpvar_39 * _SpecColor1).xyz * _SpecStrength) + ((tmpvar_46 * _SpecColor3).xyz * _SpecStrength3)) * abs(dot(normal_20, viewDir_21))) * (tmpvar_5 + ((1 - tmpvar_5) * ((x_53 * x_53) * ((x_53 * x_53) * x_53))))) * tmpvar_54)) + (((_RimColor.xyz * clamp(pow(((1 - tmpvar_27) * clamp(dot(normal_20, rimLightDir_23), 0, 1)), _RimPower), 0, 1)) * _RimIntensity) * tmpvar_55)), 0, 1);
          final_col_2.xyz = tmpvar_56.xyz;
          final_col_2.w = alpha_3;
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
        "QUEUE" = "Transparent+1"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
      ZTest Less
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,uv1,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _UNITY_SHADOW
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      struct v2f
      {
          float4 uv;
          float4 uv1;
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
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _BumpScale;
      uniform sampler2D _Albedo;
      uniform sampler2D _UV2Tex;
      uniform sampler2D _Bump;
      uniform float4 _GiColor;
      uniform float4 _RimColor;
      uniform float _RimPower;
      uniform float _RimIntensity;
      uniform float _Shift;
      uniform float _IndirectDiffuseIntensity;
      uniform float _MPrimaryShift;
      uniform float _SpecPower1;
      uniform float _SpecStrength;
      uniform float4 _SpecColor1;
      uniform float _ThirdShift;
      uniform float _SpecPower3;
      uniform float _SpecStrength3;
      uniform float4 _SpecColor3;
      uniform float _Blend;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD6 :TEXCOORD6;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float3 xlv_TEXCOORD6 :TEXCOORD6;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          v2f o_1;
          o_1 = v2f(float4(0, 0, 0, 0), float4(0, 0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          o_1.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          o_1.uv.xy = in_v.texcoord.xy;
          o_1.uv1.xy = in_v.texcoord1.xy;
          o_1.uv.zw = float2(0, 0);
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
          tmpvar_7.xyz = _RimVector.xyz;
          o_1.rimLightDir = normalize(mul(tmpvar_7, unity_MatrixV)).xyz;
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD7 = o_1.uv1;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
          out_v.xlv_TEXCOORD6 = o_1.rimLightDir;
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
          float alpha_3;
          float4 albedo_alpha_4;
          float3 tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(in_f.xlv_TEXCOORD5);
          float4 tmpvar_7;
          tmpvar_7 = tex2D(_Bump, in_f.xlv_TEXCOORD0.xy);
          float4 packednormal_8;
          packednormal_8 = tmpvar_7;
          float3 normal_9;
          float3 tmpvar_10;
          tmpvar_10 = ((packednormal_8.xyz * 2) - 1);
          normal_9.z = tmpvar_10.z;
          normal_9.xy = (tmpvar_10.xy * _BumpScale);
          float3 normal_11;
          normal_11 = normal_9;
          float3 tmpvar_12;
          tmpvar_12 = normalize((((normalize(in_f.xlv_TEXCOORD3) * normal_11.y) + (normalize(in_f.xlv_TEXCOORD2) * normal_11.x)) + (normalize(in_f.xlv_TEXCOORD1) * normal_11.z)));
          float4 tmpvar_13;
          tmpvar_13 = tex2D(_Albedo, in_f.xlv_TEXCOORD0.xy);
          float4 tmpvar_14;
          tmpvar_14 = (tmpvar_13 * _Color);
          albedo_alpha_4 = tmpvar_14;
          float4 tmpvar_15;
          tmpvar_15 = tex2D(_UV2Tex, in_f.xlv_TEXCOORD7.xy);
          float3 tmpvar_16;
          tmpvar_16 = lerp(albedo_alpha_4.xyz, tmpvar_15.xyz, float3(_Blend, _Blend, _Blend));
          albedo_alpha_4.xyz = float3(tmpvar_16);
          tmpvar_5 = albedo_alpha_4.xyz;
          float tmpvar_17;
          tmpvar_17 = albedo_alpha_4.w;
          alpha_3 = tmpvar_17;
          float3 tmpvar_18;
          tmpvar_18 = _LightColor0.xyz;
          float3 tmpvar_19;
          tmpvar_19 = normalize(_WorldSpaceLightPos0.xyz);
          float3 normal_20;
          normal_20 = tmpvar_12;
          float3 viewDir_21;
          viewDir_21 = (-tmpvar_6);
          float3 binormal_22;
          binormal_22 = in_f.xlv_TEXCOORD3;
          float3 rimLightDir_23;
          rimLightDir_23 = in_f.xlv_TEXCOORD6;
          float3 t3_24;
          float3 t1_25;
          float3 h_26;
          float tmpvar_27;
          tmpvar_27 = clamp(dot(normal_20, tmpvar_19), 0, 1);
          float3 tmpvar_28;
          tmpvar_28 = normalize((tmpvar_19 + viewDir_21));
          h_26 = tmpvar_28;
          float tmpvar_29;
          float tmpvar_30;
          tmpvar_30 = clamp(dot(tmpvar_19, h_26), 0, 1);
          tmpvar_29 = tmpvar_30;
          float3 T_31;
          T_31 = binormal_22;
          float3 N_32;
          N_32 = normal_20;
          float shift_33;
          shift_33 = (_MPrimaryShift + _Shift);
          float3 tmpvar_34;
          tmpvar_34 = normalize((T_31 + (shift_33 * N_32)));
          t1_25 = tmpvar_34;
          float3 T_35;
          T_35 = binormal_22;
          float3 N_36;
          N_36 = normal_20;
          float shift_37;
          shift_37 = (_ThirdShift + _Shift);
          float3 tmpvar_38;
          tmpvar_38 = normalize((T_35 + (shift_37 * N_36)));
          t3_24 = tmpvar_38;
          float tmpvar_39;
          float3 T_40;
          T_40 = t1_25;
          float3 V_41;
          V_41 = viewDir_21;
          float3 L_42;
          L_42 = tmpvar_19;
          float exponent_43;
          exponent_43 = _SpecPower1;
          float tmpvar_44;
          tmpvar_44 = dot(T_40, normalize((L_42 + V_41)));
          float tmpvar_45;
          tmpvar_45 = clamp((tmpvar_44 - (-1)), 0, 1);
          tmpvar_39 = ((tmpvar_45 * (tmpvar_45 * (3 - (2 * tmpvar_45)))) * pow(sqrt((1 - (tmpvar_44 * tmpvar_44))), exponent_43));
          float tmpvar_46;
          float3 T_47;
          T_47 = t3_24;
          float3 V_48;
          V_48 = viewDir_21;
          float3 L_49;
          L_49 = tmpvar_19;
          float exponent_50;
          exponent_50 = _SpecPower3;
          float tmpvar_51;
          tmpvar_51 = dot(T_47, normalize((L_49 + V_48)));
          float tmpvar_52;
          tmpvar_52 = clamp((tmpvar_51 - (-1)), 0, 1);
          tmpvar_46 = ((tmpvar_52 * (tmpvar_52 * (3 - (2 * tmpvar_52)))) * pow(sqrt((1 - (tmpvar_51 * tmpvar_51))), exponent_50));
          float x_53;
          x_53 = (1 - tmpvar_29);
          float tmpvar_54;
          tmpvar_54 = clamp(tmpvar_1, 0, 1);
          float tmpvar_55;
          tmpvar_55 = clamp(tmpvar_1, 0, 1);
          float4 tmpvar_56;
          tmpvar_56.w = 1;
          tmpvar_56.xyz = clamp((((tmpvar_5 * ((_GiColor * _IndirectDiffuseIntensity).xyz + (tmpvar_18 * clamp(tmpvar_27, 0.3, 1)))) + ((((((tmpvar_39 * _SpecColor1).xyz * _SpecStrength) + ((tmpvar_46 * _SpecColor3).xyz * _SpecStrength3)) * abs(dot(normal_20, viewDir_21))) * (tmpvar_5 + ((1 - tmpvar_5) * ((x_53 * x_53) * ((x_53 * x_53) * x_53))))) * tmpvar_54)) + (((_RimColor.xyz * clamp(pow(((1 - tmpvar_27) * clamp(dot(normal_20, rimLightDir_23), 0, 1)), _RimPower), 0, 1)) * _RimIntensity) * tmpvar_55)), 0, 1);
          final_col_2.xyz = tmpvar_56.xyz;
          final_col_2.w = alpha_3;
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
        "QUEUE" = "Transparent+1"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
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
      #define SHADER_TARGET 30
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
      "QUEUE" = "Transparent+1"
      "RenderType" = "Transparent"
    }
    LOD 200
    Pass // ind: 1, name: OPAQUE PASS
    {
      Name "OPAQUE PASS"
      Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "FORWARDBASE"
        "QUEUE" = "Transparent+1"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,uv1,worldNormal,worldTangent,worldBinormal,worldPos,worldView,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _UNITY_SHADOW
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      struct v2f
      {
          float4 uv;
          float4 uv1;
          float3 worldNormal;
          float3 worldTangent;
          float3 worldBinormal;
          float3 worldPos;
          float3 worldView;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixVP;
      //uniform float4 _WorldSpaceLightPos0;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _Cutoff;
      uniform sampler2D _Albedo;
      uniform sampler2D _UV2Tex;
      uniform sampler2D _Bump;
      uniform float4 _GiColor;
      uniform float _Shift;
      uniform float _IndirectDiffuseIntensity;
      uniform float _MPrimaryShift;
      uniform float _SpecPower1;
      uniform float _SpecStrength;
      uniform float4 _SpecColor1;
      uniform float _ThirdShift;
      uniform float _SpecPower3;
      uniform float _SpecStrength3;
      uniform float4 _SpecColor3;
      uniform float _Blend;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          v2f o_1;
          o_1 = v2f(float4(0, 0, 0, 0), float4(0, 0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          o_1.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          o_1.uv.xy = in_v.texcoord.xy;
          o_1.uv1.xy = in_v.texcoord1.xy;
          o_1.uv.zw = float2(0, 0);
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
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD7 = o_1.uv1;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
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
          float alpha_3;
          float4 albedo_alpha_4;
          float3 tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(in_f.xlv_TEXCOORD5);
          float4 tmpvar_7;
          tmpvar_7 = tex2D(_Bump, in_f.xlv_TEXCOORD0.xy);
          float4 packednormal_8;
          packednormal_8 = tmpvar_7;
          float3 tmpvar_9;
          tmpvar_9 = ((packednormal_8.xyz * 2) - 1);
          float3 normal_10;
          normal_10 = tmpvar_9;
          float3 tmpvar_11;
          tmpvar_11 = normalize((((normalize(in_f.xlv_TEXCOORD3) * normal_10.y) + (normalize(in_f.xlv_TEXCOORD2) * normal_10.x)) + (normalize(in_f.xlv_TEXCOORD1) * normal_10.z)));
          float4 tmpvar_12;
          tmpvar_12 = tex2D(_Albedo, in_f.xlv_TEXCOORD0.xy);
          float4 tmpvar_13;
          tmpvar_13 = (tmpvar_12 * _Color);
          albedo_alpha_4 = tmpvar_13;
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_UV2Tex, in_f.xlv_TEXCOORD7.xy);
          float3 tmpvar_15;
          tmpvar_15 = lerp(albedo_alpha_4.xyz, tmpvar_14.xyz, float3(_Blend, _Blend, _Blend));
          albedo_alpha_4.xyz = float3(tmpvar_15);
          tmpvar_5 = albedo_alpha_4.xyz;
          float tmpvar_16;
          tmpvar_16 = albedo_alpha_4.w;
          alpha_3 = tmpvar_16;
          float x_17;
          x_17 = (alpha_3 - _Cutoff);
          if((x_17<0))
          {
              discard;
          }
          float3 tmpvar_18;
          tmpvar_18 = _LightColor0.xyz;
          float3 tmpvar_19;
          tmpvar_19 = normalize(_WorldSpaceLightPos0.xyz);
          float3 normal_20;
          normal_20 = tmpvar_11;
          float3 viewDir_21;
          viewDir_21 = (-tmpvar_6);
          float3 binormal_22;
          binormal_22 = in_f.xlv_TEXCOORD3;
          float3 t3_23;
          float3 t1_24;
          float3 h_25;
          float3 tmpvar_26;
          tmpvar_26 = normalize((tmpvar_19 + viewDir_21));
          h_25 = tmpvar_26;
          float tmpvar_27;
          float tmpvar_28;
          tmpvar_28 = clamp(dot(tmpvar_19, h_25), 0, 1);
          tmpvar_27 = tmpvar_28;
          float3 T_29;
          T_29 = binormal_22;
          float3 N_30;
          N_30 = normal_20;
          float shift_31;
          shift_31 = (_MPrimaryShift + _Shift);
          float3 tmpvar_32;
          tmpvar_32 = normalize((T_29 + (shift_31 * N_30)));
          t1_24 = tmpvar_32;
          float3 T_33;
          T_33 = binormal_22;
          float3 N_34;
          N_34 = normal_20;
          float shift_35;
          shift_35 = (_ThirdShift + _Shift);
          float3 tmpvar_36;
          tmpvar_36 = normalize((T_33 + (shift_35 * N_34)));
          t3_23 = tmpvar_36;
          float tmpvar_37;
          float3 T_38;
          T_38 = t1_24;
          float3 V_39;
          V_39 = viewDir_21;
          float3 L_40;
          L_40 = tmpvar_19;
          float exponent_41;
          exponent_41 = _SpecPower1;
          float tmpvar_42;
          tmpvar_42 = dot(T_38, normalize((L_40 + V_39)));
          float tmpvar_43;
          tmpvar_43 = clamp((tmpvar_42 - (-1)), 0, 1);
          tmpvar_37 = ((tmpvar_43 * (tmpvar_43 * (3 - (2 * tmpvar_43)))) * pow(sqrt((1 - (tmpvar_42 * tmpvar_42))), exponent_41));
          float tmpvar_44;
          float3 T_45;
          T_45 = t3_23;
          float3 V_46;
          V_46 = viewDir_21;
          float3 L_47;
          L_47 = tmpvar_19;
          float exponent_48;
          exponent_48 = _SpecPower3;
          float tmpvar_49;
          tmpvar_49 = dot(T_45, normalize((L_47 + V_46)));
          float tmpvar_50;
          tmpvar_50 = clamp((tmpvar_49 - (-1)), 0, 1);
          tmpvar_44 = ((tmpvar_50 * (tmpvar_50 * (3 - (2 * tmpvar_50)))) * pow(sqrt((1 - (tmpvar_49 * tmpvar_49))), exponent_48));
          float x_51;
          x_51 = (1 - tmpvar_27);
          float tmpvar_52;
          tmpvar_52 = clamp(tmpvar_1, 0, 1);
          float4 tmpvar_53;
          tmpvar_53.w = 1;
          tmpvar_53.xyz = clamp(((tmpvar_5 * ((_GiColor * _IndirectDiffuseIntensity).xyz + (tmpvar_18 * clamp(clamp(dot(normal_20, tmpvar_19), 0, 1), 0.3, 1)))) + ((((((tmpvar_37 * _SpecColor1).xyz * _SpecStrength) + ((tmpvar_44 * _SpecColor3).xyz * _SpecStrength3)) * abs(dot(normal_20, viewDir_21))) * (tmpvar_5 + ((1 - tmpvar_5) * ((x_51 * x_51) * ((x_51 * x_51) * x_51))))) * tmpvar_52)), 0, 1);
          final_col_2.xyz = tmpvar_53.xyz;
          final_col_2.w = alpha_3;
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
        "QUEUE" = "Transparent+1"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
      ZTest Less
      ZWrite Off
      Cull Front
      Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,uv1,worldNormal,worldTangent,worldBinormal,worldPos,worldView,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _UNITY_SHADOW
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      struct v2f
      {
          float4 uv;
          float4 uv1;
          float3 worldNormal;
          float3 worldTangent;
          float3 worldBinormal;
          float3 worldPos;
          float3 worldView;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixVP;
      //uniform float4 _WorldSpaceLightPos0;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform sampler2D _Albedo;
      uniform sampler2D _UV2Tex;
      uniform sampler2D _Bump;
      uniform float4 _GiColor;
      uniform float _Shift;
      uniform float _IndirectDiffuseIntensity;
      uniform float _MPrimaryShift;
      uniform float _SpecPower1;
      uniform float _SpecStrength;
      uniform float4 _SpecColor1;
      uniform float _ThirdShift;
      uniform float _SpecPower3;
      uniform float _SpecStrength3;
      uniform float4 _SpecColor3;
      uniform float _Blend;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          v2f o_1;
          o_1 = v2f(float4(0, 0, 0, 0), float4(0, 0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          o_1.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          o_1.uv.xy = in_v.texcoord.xy;
          o_1.uv1.xy = in_v.texcoord1.xy;
          o_1.uv.zw = float2(0, 0);
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
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD7 = o_1.uv1;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
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
          float alpha_3;
          float4 albedo_alpha_4;
          float3 tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(in_f.xlv_TEXCOORD5);
          float4 tmpvar_7;
          tmpvar_7 = tex2D(_Bump, in_f.xlv_TEXCOORD0.xy);
          float4 packednormal_8;
          packednormal_8 = tmpvar_7;
          float3 tmpvar_9;
          tmpvar_9 = ((packednormal_8.xyz * 2) - 1);
          float3 normal_10;
          normal_10 = tmpvar_9;
          float3 tmpvar_11;
          tmpvar_11 = normalize((((normalize(in_f.xlv_TEXCOORD3) * normal_10.y) + (normalize(in_f.xlv_TEXCOORD2) * normal_10.x)) + (normalize(in_f.xlv_TEXCOORD1) * normal_10.z)));
          float4 tmpvar_12;
          tmpvar_12 = tex2D(_Albedo, in_f.xlv_TEXCOORD0.xy);
          float4 tmpvar_13;
          tmpvar_13 = (tmpvar_12 * _Color);
          albedo_alpha_4 = tmpvar_13;
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_UV2Tex, in_f.xlv_TEXCOORD7.xy);
          float3 tmpvar_15;
          tmpvar_15 = lerp(albedo_alpha_4.xyz, tmpvar_14.xyz, float3(_Blend, _Blend, _Blend));
          albedo_alpha_4.xyz = float3(tmpvar_15);
          tmpvar_5 = albedo_alpha_4.xyz;
          float tmpvar_16;
          tmpvar_16 = albedo_alpha_4.w;
          alpha_3 = tmpvar_16;
          float3 tmpvar_17;
          tmpvar_17 = _LightColor0.xyz;
          float3 tmpvar_18;
          tmpvar_18 = normalize(_WorldSpaceLightPos0.xyz);
          float3 normal_19;
          normal_19 = tmpvar_11;
          float3 viewDir_20;
          viewDir_20 = (-tmpvar_6);
          float3 binormal_21;
          binormal_21 = in_f.xlv_TEXCOORD3;
          float3 t3_22;
          float3 t1_23;
          float3 h_24;
          float3 tmpvar_25;
          tmpvar_25 = normalize((tmpvar_18 + viewDir_20));
          h_24 = tmpvar_25;
          float tmpvar_26;
          float tmpvar_27;
          tmpvar_27 = clamp(dot(tmpvar_18, h_24), 0, 1);
          tmpvar_26 = tmpvar_27;
          float3 T_28;
          T_28 = binormal_21;
          float3 N_29;
          N_29 = normal_19;
          float shift_30;
          shift_30 = (_MPrimaryShift + _Shift);
          float3 tmpvar_31;
          tmpvar_31 = normalize((T_28 + (shift_30 * N_29)));
          t1_23 = tmpvar_31;
          float3 T_32;
          T_32 = binormal_21;
          float3 N_33;
          N_33 = normal_19;
          float shift_34;
          shift_34 = (_ThirdShift + _Shift);
          float3 tmpvar_35;
          tmpvar_35 = normalize((T_32 + (shift_34 * N_33)));
          t3_22 = tmpvar_35;
          float tmpvar_36;
          float3 T_37;
          T_37 = t1_23;
          float3 V_38;
          V_38 = viewDir_20;
          float3 L_39;
          L_39 = tmpvar_18;
          float exponent_40;
          exponent_40 = _SpecPower1;
          float tmpvar_41;
          tmpvar_41 = dot(T_37, normalize((L_39 + V_38)));
          float tmpvar_42;
          tmpvar_42 = clamp((tmpvar_41 - (-1)), 0, 1);
          tmpvar_36 = ((tmpvar_42 * (tmpvar_42 * (3 - (2 * tmpvar_42)))) * pow(sqrt((1 - (tmpvar_41 * tmpvar_41))), exponent_40));
          float tmpvar_43;
          float3 T_44;
          T_44 = t3_22;
          float3 V_45;
          V_45 = viewDir_20;
          float3 L_46;
          L_46 = tmpvar_18;
          float exponent_47;
          exponent_47 = _SpecPower3;
          float tmpvar_48;
          tmpvar_48 = dot(T_44, normalize((L_46 + V_45)));
          float tmpvar_49;
          tmpvar_49 = clamp((tmpvar_48 - (-1)), 0, 1);
          tmpvar_43 = ((tmpvar_49 * (tmpvar_49 * (3 - (2 * tmpvar_49)))) * pow(sqrt((1 - (tmpvar_48 * tmpvar_48))), exponent_47));
          float x_50;
          x_50 = (1 - tmpvar_26);
          float tmpvar_51;
          tmpvar_51 = clamp(tmpvar_1, 0, 1);
          float4 tmpvar_52;
          tmpvar_52.w = 1;
          tmpvar_52.xyz = clamp(((tmpvar_5 * ((_GiColor * _IndirectDiffuseIntensity).xyz + (tmpvar_17 * clamp(clamp(dot(normal_19, tmpvar_18), 0, 1), 0.3, 1)))) + ((((((tmpvar_36 * _SpecColor1).xyz * _SpecStrength) + ((tmpvar_43 * _SpecColor3).xyz * _SpecStrength3)) * abs(dot(normal_19, viewDir_20))) * (tmpvar_5 + ((1 - tmpvar_5) * ((x_50 * x_50) * ((x_50 * x_50) * x_50))))) * tmpvar_51)), 0, 1);
          final_col_2.xyz = tmpvar_52.xyz;
          final_col_2.w = alpha_3;
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
        "QUEUE" = "Transparent+1"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
      ZTest Less
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One
      // m_ProgramMask = 6
      CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,uv1,worldNormal,worldTangent,worldBinormal,worldPos,worldView,pos)
#pragma exclude_renderers d3d11
      #pragma multi_compile DIRECTIONAL _UNITY_SHADOW
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      struct v2f
      {
          float4 uv;
          float4 uv1;
          float3 worldNormal;
          float3 worldTangent;
          float3 worldBinormal;
          float3 worldPos;
          float3 worldView;
          float4 pos;
      };
      
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixVP;
      //uniform float4 _WorldSpaceLightPos0;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform sampler2D _Albedo;
      uniform sampler2D _UV2Tex;
      uniform sampler2D _Bump;
      uniform float4 _GiColor;
      uniform float _Shift;
      uniform float _IndirectDiffuseIntensity;
      uniform float _MPrimaryShift;
      uniform float _SpecPower1;
      uniform float _SpecStrength;
      uniform float4 _SpecColor1;
      uniform float _ThirdShift;
      uniform float _SpecPower3;
      uniform float _SpecStrength3;
      uniform float4 _SpecColor3;
      uniform float _Blend;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD5 :TEXCOORD5;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          v2f o_1;
          o_1 = v2f(float4(0, 0, 0, 0), float4(0, 0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          o_1.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          o_1.uv.xy = in_v.texcoord.xy;
          o_1.uv1.xy = in_v.texcoord1.xy;
          o_1.uv.zw = float2(0, 0);
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
          out_v.xlv_TEXCOORD0 = o_1.uv;
          out_v.xlv_TEXCOORD7 = o_1.uv1;
          out_v.xlv_TEXCOORD1 = o_1.worldNormal;
          out_v.xlv_TEXCOORD2 = o_1.worldTangent;
          out_v.xlv_TEXCOORD3 = o_1.worldBinormal;
          out_v.xlv_TEXCOORD4 = o_1.worldPos;
          out_v.xlv_TEXCOORD5 = o_1.worldView;
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
          float alpha_3;
          float4 albedo_alpha_4;
          float3 tmpvar_5;
          float3 tmpvar_6;
          tmpvar_6 = normalize(in_f.xlv_TEXCOORD5);
          float4 tmpvar_7;
          tmpvar_7 = tex2D(_Bump, in_f.xlv_TEXCOORD0.xy);
          float4 packednormal_8;
          packednormal_8 = tmpvar_7;
          float3 tmpvar_9;
          tmpvar_9 = ((packednormal_8.xyz * 2) - 1);
          float3 normal_10;
          normal_10 = tmpvar_9;
          float3 tmpvar_11;
          tmpvar_11 = normalize((((normalize(in_f.xlv_TEXCOORD3) * normal_10.y) + (normalize(in_f.xlv_TEXCOORD2) * normal_10.x)) + (normalize(in_f.xlv_TEXCOORD1) * normal_10.z)));
          float4 tmpvar_12;
          tmpvar_12 = tex2D(_Albedo, in_f.xlv_TEXCOORD0.xy);
          float4 tmpvar_13;
          tmpvar_13 = (tmpvar_12 * _Color);
          albedo_alpha_4 = tmpvar_13;
          float4 tmpvar_14;
          tmpvar_14 = tex2D(_UV2Tex, in_f.xlv_TEXCOORD7.xy);
          float3 tmpvar_15;
          tmpvar_15 = lerp(albedo_alpha_4.xyz, tmpvar_14.xyz, float3(_Blend, _Blend, _Blend));
          albedo_alpha_4.xyz = float3(tmpvar_15);
          tmpvar_5 = albedo_alpha_4.xyz;
          float tmpvar_16;
          tmpvar_16 = albedo_alpha_4.w;
          alpha_3 = tmpvar_16;
          float3 tmpvar_17;
          tmpvar_17 = _LightColor0.xyz;
          float3 tmpvar_18;
          tmpvar_18 = normalize(_WorldSpaceLightPos0.xyz);
          float3 normal_19;
          normal_19 = tmpvar_11;
          float3 viewDir_20;
          viewDir_20 = (-tmpvar_6);
          float3 binormal_21;
          binormal_21 = in_f.xlv_TEXCOORD3;
          float3 t3_22;
          float3 t1_23;
          float3 h_24;
          float3 tmpvar_25;
          tmpvar_25 = normalize((tmpvar_18 + viewDir_20));
          h_24 = tmpvar_25;
          float tmpvar_26;
          float tmpvar_27;
          tmpvar_27 = clamp(dot(tmpvar_18, h_24), 0, 1);
          tmpvar_26 = tmpvar_27;
          float3 T_28;
          T_28 = binormal_21;
          float3 N_29;
          N_29 = normal_19;
          float shift_30;
          shift_30 = (_MPrimaryShift + _Shift);
          float3 tmpvar_31;
          tmpvar_31 = normalize((T_28 + (shift_30 * N_29)));
          t1_23 = tmpvar_31;
          float3 T_32;
          T_32 = binormal_21;
          float3 N_33;
          N_33 = normal_19;
          float shift_34;
          shift_34 = (_ThirdShift + _Shift);
          float3 tmpvar_35;
          tmpvar_35 = normalize((T_32 + (shift_34 * N_33)));
          t3_22 = tmpvar_35;
          float tmpvar_36;
          float3 T_37;
          T_37 = t1_23;
          float3 V_38;
          V_38 = viewDir_20;
          float3 L_39;
          L_39 = tmpvar_18;
          float exponent_40;
          exponent_40 = _SpecPower1;
          float tmpvar_41;
          tmpvar_41 = dot(T_37, normalize((L_39 + V_38)));
          float tmpvar_42;
          tmpvar_42 = clamp((tmpvar_41 - (-1)), 0, 1);
          tmpvar_36 = ((tmpvar_42 * (tmpvar_42 * (3 - (2 * tmpvar_42)))) * pow(sqrt((1 - (tmpvar_41 * tmpvar_41))), exponent_40));
          float tmpvar_43;
          float3 T_44;
          T_44 = t3_22;
          float3 V_45;
          V_45 = viewDir_20;
          float3 L_46;
          L_46 = tmpvar_18;
          float exponent_47;
          exponent_47 = _SpecPower3;
          float tmpvar_48;
          tmpvar_48 = dot(T_44, normalize((L_46 + V_45)));
          float tmpvar_49;
          tmpvar_49 = clamp((tmpvar_48 - (-1)), 0, 1);
          tmpvar_43 = ((tmpvar_49 * (tmpvar_49 * (3 - (2 * tmpvar_49)))) * pow(sqrt((1 - (tmpvar_48 * tmpvar_48))), exponent_47));
          float x_50;
          x_50 = (1 - tmpvar_26);
          float tmpvar_51;
          tmpvar_51 = clamp(tmpvar_1, 0, 1);
          float4 tmpvar_52;
          tmpvar_52.w = 1;
          tmpvar_52.xyz = clamp(((tmpvar_5 * ((_GiColor * _IndirectDiffuseIntensity).xyz + (tmpvar_17 * clamp(clamp(dot(normal_19, tmpvar_18), 0, 1), 0.3, 1)))) + ((((((tmpvar_36 * _SpecColor1).xyz * _SpecStrength) + ((tmpvar_43 * _SpecColor3).xyz * _SpecStrength3)) * abs(dot(normal_19, viewDir_20))) * (tmpvar_5 + ((1 - tmpvar_5) * ((x_50 * x_50) * ((x_50 * x_50) * x_50))))) * tmpvar_51)), 0, 1);
          final_col_2.xyz = tmpvar_52.xyz;
          final_col_2.w = alpha_3;
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
        "QUEUE" = "Transparent+1"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      LOD 200
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
