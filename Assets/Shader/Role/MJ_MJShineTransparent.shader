// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_ShadowFadeCenterAndType', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_DynamicLightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_LightmapInd', a built-in variable

Shader "MJ/MJShineTransparent"
{
  Properties
  {
    _IndirectDiffuseIntensity ("_IndirectDiffuseIntensity", Range(1, 15)) = 1
    _ShineSpeed ("ShineSpeed", Range(0, 10)) = 1
    _DiamondCol ("DiamondCol", Color) = (1,1,1,1)
    _DiamondCol2 ("DiamondCol2", Color) = (1,1,1,1)
    _DiamondCol3 ("DiamondCol3", Color) = (1,1,1,1)
    _FracPower ("FracPower", Range(0, 100)) = 50
    _Mask ("Mask", Range(0, 1)) = 1
    _ShineIntensity ("ShineIntensity", Range(0, 400)) = 1
    _ShineIntensity2 ("ShineIntensity2", Range(0, 400)) = 1
    _Power1 ("Power1", Range(0, 100)) = 20
    _Power2 ("Power2", Range(0, 100)) = 20
    _RotateRate ("RotateRate", Range(0, 20)) = 2
    _ShineTex ("shine tex", 2D) = "white" {}
    _UVFrequency ("uv frequency", Range(0, 50)) = 1
    _ShadowColor ("shadowColor", Color) = (0,0,0,1)
    [NoScaleOffset] _Albedo ("Albedo (RGB) Skin Smoothness or Transparency(A)", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)
    _cutoff ("Cutoff", Range(0, 1)) = 0.5
    _BumpScale ("Scale", float) = 1
    _NormalBias ("Normal Bias", float) = -2
    [NoScaleOffset] _Bump ("Bump Map", 2D) = "bump" {}
    _DirectSpecularExp ("_DirectSpecularExp", Range(0, 100)) = 20
    _GlossMap ("Gloss Map", 2D) = "white" {}
    _SmoothMap ("SmoothMap", 2D) = "white" {}
    _SmoothSpecial ("光滑度阈值", Range(0, 1)) = 0.2
    _MinSmooth ("MinSmooth", Range(0, 1)) = 1
    _MinSpecScale ("Min Specular Scale", Range(0, 1)) = 1
    _MaxSpecScale ("Max SecularScale", Range(0, 10)) = 1
    _Glossiness ("Smoothness", Range(0, 1)) = 0.5
    _GlossMapScale ("Smoothness Scale", Range(0, 1)) = 1
    _SpecularScale ("GI Specular Scale", float) = 1
    _DirectSpecularScale ("Direct Specular Scale", Range(0, 100)) = 1
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
    Pass // ind: 1, name: OPAQUE PASS
    {
      Name "OPAQUE PASS"
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
      //uniform float4 _Time;
      //uniform float4 _WorldSpaceLightPos0;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _Glossiness;
      uniform float _cutoff;
      uniform float4 _GiColor;
      uniform float _DirectLightIntensity;
      uniform float _DirectSpecularScale;
      uniform float _IndirectDiffuseIntensity;
      uniform sampler2D _Bump;
      uniform sampler2D _Albedo;
      uniform float _ShineSpeed;
      uniform float _ShineIntensity2;
      uniform float _ShineIntensity;
      uniform float _Mask;
      uniform float4 _DiamondCol;
      uniform float4 _DiamondCol2;
      uniform float4 _DiamondCol3;
      uniform float _FracPower;
      uniform float _Power1;
      uniform float _Power2;
      uniform sampler2D _ShineTex;
      uniform float _UVFrequency;
      uniform float _RotateRate;
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
          float3 albedo_5;
          float3 normalInTangent_6;
          float alpha;
          float2 P_10;
          P_10 = (in_f.xlv_TEXCOORD0 * _UVFrequency);
          float3 ShineColor = tex2D(_ShineTex, P_10).xyz;
          float3 tmpvar_12;
          float3 tmpvar_13;
          normalInTangent_6 = normalize(((tex2D(_Bump, in_f.xlv_TEXCOORD0).xyz * 2) - 1));
          float3 tmpvar_14;
          if((tmpvar_1>0))
          {
              tmpvar_14 = normalInTangent_6;
          }
          else
          {
              tmpvar_14 = (-normalInTangent_6);
          }
          normalInTangent_6 = tmpvar_14;
          // 法线偏转了。


          float4 tmpvar_15;
          tmpvar_15 = tex2D(_Albedo, in_f.xlv_TEXCOORD0);
          alpha = tmpvar_15.w;
          albedo_5 = (tmpvar_15.xyz * _Color.xyz);
          float x_16;
          x_16 = (alpha - _cutoff);
          if((x_16<0))
          {
              discard;
          }
          float3 albedo_17;
          albedo_17 = albedo_5;
          // 得到基础颜色了
          float3 worldNormal = normalize((((in_f.xlv_TEXCOORD3 * tmpvar_14.y) + (in_f.xlv_TEXCOORD2 * tmpvar_14.x)) + (in_f.xlv_TEXCOORD1 * tmpvar_14.z)));

          float3 baseAlbedo = (albedo_17 * 0.8453586);
          float3 WorldviewDir = (-in_f.xlv_TEXCOORD5);
          float3 col_22;
          float3 shineColor_23;
          float D_25;

          float NoL = clamp(dot(worldNormal, _WorldSpaceLightPos0.xyz), 0, 1);
          float3 hDir = normalize((_WorldSpaceLightPos0.xyz + WorldviewDir));
          float NoH = clamp(dot(worldNormal, hDir), 0, 1);
          float NoV = abs(dot(worldNormal, WorldviewDir));
          float HoL = clamp(dot(_WorldSpaceLightPos0.xyz, hDir), 0, 1);

          float perceptualRoughness = (1 - _Glossiness);
          float roughness = (perceptualRoughness * perceptualRoughness);

          float diffuseTerm = ((NoL * 0.5) + 0.5);
          // Vis_SmithJointApprox_Plus 函数
          float V = (0.5 / (((NoL * ((NoV * (1 - roughness)) + roughness)) + (NoV * ((NoL * (1 - roughness)) + roughness))) + 1E-05));

          // D_GGX_UE4 函数
          float roughness2 = (roughness * roughness);
          float tmpvar_51;
          tmpvar_51 = (((NoH * roughness2) - NoH) * NoH) + 1;
          D = ((0.3183099 * roughness2) / ((tmpvar_51 * tmpvar_51) + 1E-07));

          float3 tmpvar_52;
          tmpvar_52 = clamp(baseAlbedo, 0, 1);
          float F = (1 - HoL)5;
          // PBR 直接高光计算
          float3  frenel= lerp(tmpvar_52, 1.0f, F);
          float SpecXXXXXXX = max(0, ((V * D) * (3.141593 * NoL)) * frenel * _DirectSpecularScale;

          // 用来计算 Shiness的Deon关系
          float rotateshine = (WorldviewDir.y - WorldviewDir.x - WorldviewDir.z) * _RotateRate + ShineColor.x ;
          rotateshine = rotateshine + (_Time.x * _ShineSpeed);
          float tmpvar_56;
          tmpvar_56 = (ShineColor.y * 2);
          float _tmp_dvx_56 = saturate(tmpvar_56 - 1);
          float _tmp_dvx_57 = saturate(tmpvar_56);
          float3 lerp12 = lerp(_DiamondCol.xyz, _DiamondCol2.xyz, _tmp_dvx_57);
          float3 lerp123 = lerp(lerp12, _DiamondCol3.xyz, _tmp_dvx_56);
          float3 ShineSpec1 = (pow(((frac((rotateshine + ShineColor.x)) * ShineColor.z) - _Mask), 3) * _ShineIntensity);
          float3 ShineSpec2 = (pow(saturate(ShineSpec1), _FracPower) * ShineColor.z) * _ShineIntensity2;

          shineColor_23 = lerp123 * ShineSpec2 ;
          float LoV = saturate(dot(_WorldSpaceLightPos0.xyz, WorldviewDir));
          float lerpP1P2 = lerp(_Power1, _Power2, LoV);
          shineColor_23 = SpecXXXXXXX * pow(NoH, lerpP1P2) * shineColor_23;

          float3 rimLightDirection = in_f.xlv_TEXCOORD9;
          float3 giDiffuse = ((_GiColor * _IndirectDiffuseIntensity).xyz + (diffuseTerm * _DirectLightIntensity));

          float NoRim = saturate(dot(worldNormal, rimLightDirection));
          float rimXXX = saturate(pow(((1 - NoL) * NoRim), _RimPower));
          float3 rimResult = saturate(_RimColor.xyz * rimXXX) * _RimIntensity);
          col_22 = ((clamp(baseAlbedo, 0, 1) * giDiffuse) + SpecXXXXXXX) + rimResult;
          col_22 = (col_22 + shineColor_23);
          //
          float4 tmpvar_57;
          tmpvar_57.xyz = float3(((col_22 * alpha) * _LightColor0.xyz));
          tmpvar_57.w = alpha;
          final_col_2.xyz = tmpvar_57.xyz;
          final_col_2.w = alpha;
          out_f.color = final_col_2;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
