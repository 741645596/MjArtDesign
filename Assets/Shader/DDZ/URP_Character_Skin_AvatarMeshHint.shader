// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Character/Skin_AvatarMeshHint"
{
  Properties
  {
    [Toggle(NORMAL_ON)] _NormalOn ("Normal On", float) = 1
    [Toggle(RIMLIGHT_ON)] _RimLightOn ("RimLight On", float) = 1
    [Space] _BaseColor ("Base Color", Color) = (1,1,1,1)
    _DesaturateScale ("Desaturate Scale", Range(-1, 1)) = 0
    _Basemap ("Base map", 2D) = "white" {}
    [HDR] _LightColor ("Light Color", Color) = (1,1,1,1)
    _LightRange ("Light Range", Range(0, 0.99)) = 0.99
    _Normalmap ("Normal map", 2D) = "bump" {}
    _NormalScale ("Normal Scale", Range(0, 2)) = 1
    _Configmap ("Config map (MSCA)", 2D) = "white" {}
    [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
    _Smoothness ("Smoothness", Range(0, 1)) = 0.2
    _Occlusion ("Occlusion", Range(0, 1)) = 1
    [Toggle(SPARKLE_ON)] _SparkleOn ("Sparkle On", float) = 0
    _Sparklemap ("Sparkle map", 2D) = "black" {}
    _SparkleControl ("Sparkle Control", Vector) = (1,1,1,1)
    _SparkleLipTransparency ("SparkleLip Transparency", Range(0, 1)) = 1
    [Toggle] _SparkleLipDyeEnable ("SparkleLip DyeEnable", float) = 0
    _SparkleLipDye ("SparkleLip Dye", Color) = (1,1,1,1)
    _SparkleEyeTransparency ("SparkleEye Transparency", Range(0, 1)) = 1
    [Toggle] _SparkleEyeDyeEnable ("SparkleEye DyeEnable", float) = 0
    _SparkleEyeDye ("SparkleEye Dye", Color) = (1,1,1,1)
    _SparkleTattooATransparency ("SparkleTattooA Transparency", Range(0, 1)) = 1
    [Toggle] _SparkleTattooADyeEnable ("SparkleTattooA DyeEnable", float) = 0
    _SparkleTattooADye ("SparkleTattooA Dye", Color) = (1,1,1,1)
    _LipSmoothness ("Lip Smoothness", Range(-1, 1)) = 0
    _EyeSmoothness ("Eye Smoothnes", Range(-1, 1)) = 0
    _TattooASmoothness ("TattooA Smoothness", Range(-1, 1)) = 0
    [Space] _SSS ("Scatter Range", Range(0, 2)) = 1
    _SSSIntensity ("Scatter Intensity", Range(0, 1)) = 0.4
    _Wrap ("Wrap", Range(0, 2)) = 0.7
    _ShadowColor ("Shadow Color", Color) = (0,0,0,1)
    [Header(Half Rim Light)] [Space] [MaterialEnum(Off, 0, CustomDir, 1, CommonDir, 2)] _HalfRimLightState ("Half Rim Light State", float) = 0
    _HalfRimLightColor ("Half Rim Light Color", Color) = (1,1,1,1)
    _HalfRimLightDir ("Half Rim Light Direction", Vector) = (-1,0.5,0,0)
    _HalfRimLightPower ("Half Rim Light Power", Range(1, 10)) = 1
    _HalfRimLightIntensity ("Half Rim Light Intensity", Range(0, 5)) = 1
    [HDR] _Emission ("Emission", Color) = (0,0,0,0)
    [Header(MeshHintSetting)] _MeshHintTex ("MeshHintTex", 2D) = "white" {}
    _MeshHintEffectTex ("MeshHintEffectTex", 2D) = "white" {}
    [Header(MeshHint)] _MeshHintColor ("MeshHintColor", Color) = (1,1,1,1)
    _MeshHintIntensity ("MeshHintIntensity", Range(0, 2)) = 1
    [Header(MeshHintEffect)] _MeshHintEffectEnable ("MeshHintEffectEnable", Range(0, 1)) = 1
    _MeshHintEffectColor ("MeshHintEffectColor", Color) = (1,1,1,1)
    _MeshHintEffectIntensity ("MeshHintEffectIntensity", Range(0, 15)) = 1
    _MeshHintEffectScale ("MeshHintEffectScale", Range(-1, 2)) = 1
    _MeshHintEffectOffset ("MeshHintEffectOffset", Vector) = (0,0,0,0)
    [Header(ID)] _MeshHintID ("MeshHintID", Range(0, 255)) = 1
  }
  SubShader
  {
    Tags
    { 
      "IGNOREPROJECTOR" = "true"
      "QUEUE" = "Geometry"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Opaque"
    }
    LOD 500
    Pass // ind: 1, name: 
    {
      Tags
      { 
      }
      ZClip Off
      ZWrite Off
      Cull Off
      Stencil
      { 
        Ref 0
        ReadMask 0
        WriteMask 0
        Pass Keep
        Fail Keep
        ZFail Keep
        PassFront Keep
        FailFront Keep
        ZFailFront Keep
        PassBack Keep
        FailBack Keep
        ZFailBack Keep
      } 
      // m_ProgramMask = 0
      
    } // end phase
    Pass // ind: 2, name: MESHHINT
    {
      Name "MESHHINT"
      Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "UniversalForwardOnly"
        "QUEUE" = "Geometry"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Opaque"
      }
      LOD 500
      ZWrite Off
      Blend One One
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile NORMAL_ON RIMLIGHT_ON SPARKLE_ON _LOD100
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _MeshHintColor;
      uniform float4 _MeshHintEffectColor;
      uniform int _MeshHintEffectEnable;
      uniform int _MeshHintID;
      uniform float _MeshHintEffectScale;
      uniform float _MeshHintIntensity;
      uniform float _MeshHintEffectIntensity;
      uniform float2 _MeshHintEffectOffset;
      uniform sampler2D _MeshHintTex;
      uniform sampler2D _MeshHintEffectTex;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float2 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 texcoord :TEXCOORD0;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      float4 u_xlat0;
      float4 u_xlat1;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          out_v.texcoord.xy = in_v.texcoord.xy;
          u_xlat0 = UnityObjectToClipPos(in_v.vertex);
          out_v.vertex = u_xlat0;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      float4 u_xlat16_0;
      float4 u_xlat1_d;
      float4 u_xlat16_1;
      int u_xlatb1;
      float4 u_xlat16_2;
      float3 u_xlat16_3;
      float u_xlat16_9;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0.xy = float2(int2(_MeshHintEffectEnable, _MeshHintID));
          u_xlat16_1.xy = tex2D(_MeshHintTex, in_f.texcoord.xy).xz;
          u_xlat16_3.x = ((u_xlat16_1.x * 255) + (-u_xlat16_0.y));
          #ifdef UNITY_ADRENO_ES3
          u_xlatb1 = (0.100000001>=abs(u_xlat16_3.x));
          #else
          u_xlatb1 = (0.100000001>=abs(u_xlat16_3.x));
          #endif
          u_xlat16_3.x = (u_xlat16_1.y * _MeshHintIntensity);
          u_xlat16_2.w = (u_xlat16_3.x * _MeshHintColor.w);
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_2.w = min(max(u_xlat16_2.w, 0), 1);
          #else
          u_xlat16_2.w = clamp(u_xlat16_2.w, 0, 1);
          #endif
          u_xlat16_2.xyz = (u_xlat16_1.yyy * _MeshHintColor.xyz);
          u_xlat16_2 = (int(u_xlatb1))?(u_xlat16_2):(float4(0, 0, 0, 0));
          u_xlat16_3.xy = (in_f.texcoord.xy + _MeshHintEffectOffset.xy);
          u_xlat16_3.xy = ((float2(_MeshHintEffectScale, _MeshHintEffectScale) * float2(0.5, 0.5)) + u_xlat16_3.xy);
          u_xlat16_9 = (_MeshHintEffectScale + 1);
          u_xlat16_3.xy = (u_xlat16_3.xy / float2(u_xlat16_9, u_xlat16_9));
          u_xlat16_1.xzw = tex2D(_MeshHintEffectTex, u_xlat16_3.xy).xyz;
          u_xlat1_d.xzw = (u_xlat16_1.xzw * _MeshHintEffectColor.xyz);
          u_xlat16_3.xyz = (u_xlat16_1.yyy * u_xlat1_d.xzw);
          u_xlat16_0.xyz = (u_xlat16_0.xxx * u_xlat16_3.xyz);
          u_xlat16_0.xyz = (u_xlat16_0.xyz * float3(float3(_MeshHintEffectIntensity, _MeshHintEffectIntensity, _MeshHintEffectIntensity)));
          u_xlat16_0.w = u_xlat16_0.x;
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_0.w = min(max(u_xlat16_0.w, 0), 1);
          #else
          u_xlat16_0.w = clamp(u_xlat16_0.w, 0, 1);
          #endif
          u_xlat16_0 = (u_xlat16_2 + u_xlat16_0);
          u_xlat16_9 = min(u_xlat16_0.w, 1);
          out_f.color.xyz = (float3(u_xlat16_9, u_xlat16_9, u_xlat16_9) * u_xlat16_0.xyz);
          out_f.color.w = u_xlat16_9;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 3, name: CustomShadowMask
    {
      Name "CustomShadowMask"
      Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "CustomShadowMask"
        "QUEUE" = "Geometry"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Opaque"
      }
      LOD 500
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
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightShadowParams;
      uniform float4x4 ShadowVP;
      uniform float4 ShadowMap_TexelSize;
      uniform float _ShadowNormalBias;
      uniform float _ShadowDepthBias;
      uniform sampler2D ShadowMap;
      uniform sampler2D hlslcc_zcmpShadowMap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
      };
      
      struct OUT_Data_Vert
      {
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
      };
      
      struct OUT_Data_Frag
      {
          float4 SV_TARGET0 :SV_TARGET0;
      };
      
      uniform UnityPerDraw;
      #endif
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_LODFade;
      //uniform float4 unity_WorldTransformParams;
      uniform float4 unity_LightData;
      uniform float4 unity_LightIndices[2];
      uniform float4 unity_ProbesOcclusion;
      //uniform float4 unity_SpecCube0_HDR;
      // uniform float4 unity_LightmapST;
      // uniform float4 unity_DynamicLightmapST;
      //uniform float4 unity_SHAr;
      //uniform float4 unity_SHAg;
      //uniform float4 unity_SHAb;
      //uniform float4 unity_SHBr;
      //uniform float4 unity_SHBg;
      //uniform float4 unity_SHBb;
      //uniform float4 unity_SHC;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0;
      float4 u_xlat1;
      float u_xlat16_2;
      float u_xlat9;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0 = mul(unity_ObjectToWorld, float4(in_v.vertex.xyz,1.0));
          out_v.vertex = mul(unity_MatrixVP, u_xlat0);
          out_v.texcoord4.xyz = u_xlat0.xyz;
          u_xlat0.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat0.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat0.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
          u_xlat9 = max(u_xlat9, 0);
          u_xlat16_2 = rsqrt(u_xlat9);
          out_v.texcoord3.xyz = (u_xlat0.xyz * float3(u_xlat16_2, u_xlat16_2, u_xlat16_2));
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      float4 u_xlat0_d;
      float3 u_xlat16_0;
      float4 u_xlat1_d;
      int u_xlatb1;
      float4 u_xlat2;
      float4 u_xlat3;
      float4 u_xlat4;
      float4 u_xlat5;
      float4 u_xlat6;
      float u_xlat16_7;
      float3 u_xlat9_d;
      int u_xlatb9;
      float2 u_xlat18;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0.x = dot(_MainLightPosition.xyz, _MainLightPosition.xyz);
          u_xlat16_0.x = rsqrt(u_xlat16_0.x);
          u_xlat16_0.xyz = (u_xlat16_0.xxx * _MainLightPosition.xyz);
          u_xlat1_d.x = dot(u_xlat16_0.xyz, in_f.texcoord3.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat1_d.x = min(max(u_xlat1_d.x, 0), 1);
          #else
          u_xlat1_d.x = clamp(u_xlat1_d.x, 0, 1);
          #endif
          u_xlat9_d.xyz = ((u_xlat16_0.xyz * float3(float3(_ShadowDepthBias, _ShadowDepthBias, _ShadowDepthBias))) + in_f.texcoord4.xyz);
          u_xlat1_d.x = ((-u_xlat1_d.x) + 1);
          u_xlat1_d.x = (u_xlat1_d.x * _ShadowNormalBias);
          u_xlat1_d.xyz = ((in_f.texcoord3.xyz * u_xlat1_d.xxx) + u_xlat9_d.xyz);
          u_xlat1_d.xyz = mul(ShadowVP, u_xlat1_d.xyz);
          u_xlat2.xy = (u_xlat1_d.xy * ShadowMap_TexelSize.zw);
          u_xlat2.xy = round(u_xlat2.xy);
          u_xlat1_d.xy = ((ShadowMap_TexelSize.zw * u_xlat1_d.xy) + (-u_xlat2.xy));
          u_xlat0_d = ((-u_xlat1_d.xyxy) + float4(0.5, 0.5, 1.5, 1.5));
          u_xlat0_d = (u_xlat0_d * u_xlat0_d);
          u_xlat3.zw = (u_xlat0_d.xy * float2(0.5, 0.5));
          u_xlat18.xy = ((u_xlat0_d.zw * float2(0.5, 0.5)) + (-u_xlat3.zw));
          u_xlat4.xy = max((-u_xlat1_d.xy), float2(0, 0));
          u_xlat3.xy = (((-u_xlat4.xy) * u_xlat4.xy) + u_xlat18.xy);
          u_xlat18.xy = max(u_xlat1_d.xy, float2(0, 0));
          u_xlat4 = (u_xlat1_d.xyxy + float4(0.5, 0.5, 1.5, 1.5));
          u_xlat4 = (u_xlat4 * u_xlat4);
          u_xlat5.zw = (u_xlat4.xy * float2(0.5, 0.5));
          u_xlat1_d.xy = ((u_xlat4.zw * float2(0.5, 0.5)) + (-u_xlat5.zw));
          u_xlat5.xy = (((-u_xlat18.xy) * u_xlat18.xy) + u_xlat1_d.xy);
          u_xlat6.y = dot(u_xlat5.xzxz, u_xlat3.yyww);
          u_xlat6.z = dot(u_xlat3.zxzx, u_xlat5.yyww);
          u_xlat6.x = dot(u_xlat3.zxzx, u_xlat3.yyww);
          u_xlat6.w = dot(u_xlat5.xzxz, u_xlat5.yyww);
          u_xlat1_d.xy = ((u_xlat4.xy * float2(0.5, 0.5)) + u_xlat5.xy);
          u_xlat4.xy = (u_xlat5.zw / u_xlat1_d.xy);
          u_xlat1_d.x = dot(u_xlat6, float4(1, 1, 1, 1));
          u_xlat5 = (u_xlat6 / u_xlat1_d.xxxx);
          u_xlat1_d.xy = ((u_xlat0_d.xy * float2(0.5, 0.5)) + u_xlat3.xy);
          u_xlat4.zw = (u_xlat3.xy / u_xlat1_d.xy);
          u_xlat0_d = (u_xlat2.xyxy + u_xlat4.xwzy);
          u_xlat1_d.xy = (u_xlat2.xy + u_xlat4.zw);
          u_xlat2.xy = (u_xlat2.xy + u_xlat4.xy);
          u_xlat2.xy = (u_xlat2.xy + float2(0.5, 0.5));
          u_xlat2.xy = (u_xlat2.xy * ShadowMap_TexelSize.xy);
          float3 txVec0 = float3(u_xlat2.xy, u_xlat1_d.z);
          u_xlat2.w = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec0, 0));
          u_xlat1_d.xy = (u_xlat1_d.xy + float2(-1.5, (-1.5)));
          u_xlat1_d.xy = (u_xlat1_d.xy * ShadowMap_TexelSize.xy);
          float3 txVec1 = float3(u_xlat1_d.xy, u_xlat1_d.z);
          u_xlat2.x = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec1, 0));
          u_xlat0_d = (u_xlat0_d + float4(0.5, (-1.5), (-1.5), 0.5));
          u_xlat0_d = (u_xlat0_d * ShadowMap_TexelSize.xyxy);
          float3 txVec2 = float3(u_xlat0_d.xy, u_xlat1_d.z);
          u_xlat2.y = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec2, 0));
          float3 txVec3 = float3(u_xlat0_d.zw, u_xlat1_d.z);
          u_xlat2.z = tex2Dlod(hlslcc_zcmpShadowMap, float4(txVec3, 0));
          u_xlat1_d.x = dot(u_xlat2, u_xlat5);
          u_xlat16_7 = ((-_MainLightShadowParams.x) + 1);
          u_xlat16_7 = ((u_xlat1_d.x * _MainLightShadowParams.x) + u_xlat16_7);
          #ifdef UNITY_ADRENO_ES3
          u_xlatb1 = (0>=u_xlat1_d.z);
          #else
          u_xlatb1 = (0>=u_xlat1_d.z);
          #endif
          #ifdef UNITY_ADRENO_ES3
          u_xlatb9 = (u_xlat1_d.z>=1);
          #else
          u_xlatb9 = (u_xlat1_d.z>=1);
          #endif
          u_xlatb1 = (u_xlatb9 || u_xlatb1);
          u_xlat0_d = (int(u_xlatb1))?(float4(1, 1, 1, 1)):(float4(u_xlat16_7, u_xlat16_7, u_xlat16_7, u_xlat16_7));
          out_f.SV_TARGET0 = u_xlat0_d;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack "URP/Character/Skin_New"
}
