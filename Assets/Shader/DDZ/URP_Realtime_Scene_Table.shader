// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "URP/Realtime/Scene/Table"
{
  Properties
  {
    _Albedo ("Albedo", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)
    [Space] [Header(Normal map)] [Space] [Toggle(NORMAL_ON)] _NormalOn ("Normal On", float) = 1
    _Normal ("Normal", 2D) = "bump" {}
    _NormalIntensity ("NormalIntensity", Range(0, 10)) = 1
    _MetallicSmoothness ("MetallicSmoothness", 2D) = "white" {}
    _Metallic ("Metallic", Range(0, 1)) = 0
    _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    _Occlusion ("Occlusion", Range(0, 1)) = 1
    _AmbientColor ("Ambient Color", Color) = (0.7,0.7,0.7,0)
    [Space] [Header(Specular)] [Space] [Toggle(TABLESPEC_ON)] _SpecularOn ("Specular On", float) = 1
    _SpecularColor ("SpecularColor", Color) = (1,1,1,1)
    [Space] [Header(Cubemap)] [Space] [Toggle(CUBEMAP_ON)] _CubemapOn ("Cubemap On", float) = 1
    _Cubemap ("Cubemap", Cube) = "white" {}
    _RotationCube ("RotationCube", Range(0, 2)) = 0
    _ViewOffset ("View Offset", Vector) = (0,0,0,0)
    _CubeIntensity ("CubeIntensity", Range(0, 10)) = 4
    _CubeIntensity_Metallic ("CubeIntensity (metallic)", Range(0, 40)) = 0
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Geometry"
      "RenderPipeline" = "UniversalPipeline"
      "RenderType" = "Opaque"
    }
    Pass // ind: 1, name: Forward
    {
      Name "Forward"
      Tags
      { 
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Geometry"
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Opaque"
      }
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile CUBEMAP_ON NORMAL_ON TABLESPEC_ON _LOD100
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_MatrixVP;
      uniform float4x4 ShadowVP;
      uniform float4 _MainLightPosition;
      uniform float4 _MainLightColor;
      //uniform float3 _WorldSpaceCameraPos;
      uniform sampler2D _Albedo;
      uniform sampler2D _Normal;
      uniform sampler2D _MetallicSmoothness;
      uniform samplerCUBE _Cubemap;
      struct appdata_t
      {
          float4 vertex :POSITION0;
          float3 normal :NORMAL0;
          float4 tangent :TANGENT0;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float3 texcoord :TEXCOORD0;
          float4 texcoord1 :TEXCOORD1;
          float2 texcoord2 :TEXCOORD2;
          float4 texcoord3 :TEXCOORD3;
          float4 texcoord4 :TEXCOORD4;
          float4 texcoord5 :TEXCOORD5;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 texcoord2 :TEXCOORD2;
          float4 texcoord3 :TEXCOORD3;
          float4 texcoord4 :TEXCOORD4;
          float4 texcoord5 :TEXCOORD5;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
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
      uniform UnityPerMaterial;
      #endif
      uniform float4 _Albedo_ST;
      uniform float4 _MetallicSmoothness_ST;
      uniform float4 _Color;
      uniform float4 _SpecularColor;
      uniform float4 _Normal_ST;
      uniform float4 _AmbientColor;
      uniform float _RotationCube;
      uniform float4 _ViewOffset;
      uniform float _Smoothness;
      uniform float _NormalIntensity;
      uniform float _Metallic;
      uniform float _CubeIntensity;
      uniform float _CubeIntensity_Metallic;
      uniform float _Occlusion;
      uniform float4 _Cubemap_HDR;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float3 u_xlat0;
      int u_xlatb0;
      float4 u_xlat1;
      float4 u_xlat2;
      float u_xlat16_3;
      float3 u_xlat4;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          u_xlat0.xyz = mul(unity_ObjectToWorld, in_v.vertex.xyz);
          u_xlat1 = mul(unity_MatrixVP, float4(u_xlat0.xyz,1.0));
          out_v.vertex = u_xlat1;
          out_v.texcoord.xyz = in_v.normal.xyz;
          u_xlat1 = mul(ShadowVP, float4(u_xlat0.xyz,1.0));
          out_v.texcoord1 = u_xlat1;
          out_v.texcoord2.xy = TRANSFORM_TEX(in_v.texcoord.xy, _Albedo);
          u_xlat1.w = u_xlat0.x;
          u_xlat2.xyz = (in_v.tangent.yyy * conv_mxt4x4_1(unity_ObjectToWorld).xyz);
          u_xlat2.xyz = ((conv_mxt4x4_0(unity_ObjectToWorld).xyz * in_v.tangent.xxx) + u_xlat2.xyz);
          u_xlat2.xyz = ((conv_mxt4x4_2(unity_ObjectToWorld).xyz * in_v.tangent.zzz) + u_xlat2.xyz);
          u_xlat0.x = dot(u_xlat2.xyz, u_xlat2.xyz);
          u_xlat0.x = max(u_xlat0.x, 0);
          u_xlat16_3 = rsqrt(u_xlat0.x);
          u_xlat1.xyz = (u_xlat2.xyz * float3(u_xlat16_3, u_xlat16_3, u_xlat16_3));
          out_v.texcoord3 = u_xlat1;
          u_xlat2.x = dot(in_v.normal.xyz, conv_mxt4x4_0(unity_WorldToObject).xyz);
          u_xlat2.y = dot(in_v.normal.xyz, conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat2.z = dot(in_v.normal.xyz, conv_mxt4x4_2(unity_WorldToObject).xyz);
          u_xlat0.x = dot(u_xlat2.xyz, u_xlat2.xyz);
          u_xlat0.x = max(u_xlat0.x, 0);
          u_xlat16_3 = rsqrt(u_xlat0.x);
          u_xlat2.xyz = (u_xlat2.xyz * float3(u_xlat16_3, u_xlat16_3, u_xlat16_3));
          u_xlat4.xyz = (u_xlat1.yzx * u_xlat2.zxy);
          u_xlat1.xyz = ((u_xlat2.yzx * u_xlat1.zxy) + (-u_xlat4.xyz));
          #ifdef UNITY_ADRENO_ES3
          u_xlatb0 = (unity_WorldTransformParams.w>=0);
          #else
          u_xlatb0 = (unity_WorldTransformParams.w>=0);
          #endif
          u_xlat0.x = (u_xlatb0)?(1):((-1));
          u_xlat0.x = (u_xlat0.x * in_v.tangent.w);
          u_xlat1.xyz = (u_xlat0.xxx * u_xlat1.xyz);
          u_xlat1.w = u_xlat0.y;
          u_xlat2.w = u_xlat0.z;
          out_v.texcoord5 = u_xlat2;
          out_v.texcoord4 = u_xlat1;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
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
      uniform UnityPerMaterial;
      #endif
      uniform float4 _Albedo_ST;
      uniform float4 _MetallicSmoothness_ST;
      uniform float4 _Color;
      uniform float4 _SpecularColor;
      uniform float4 _Normal_ST;
      uniform float4 _AmbientColor;
      uniform float _RotationCube;
      uniform float4 _ViewOffset;
      uniform float _Smoothness;
      uniform float _NormalIntensity;
      uniform float _Metallic;
      uniform float _CubeIntensity;
      uniform float _CubeIntensity_Metallic;
      uniform float _Occlusion;
      uniform float4 _Cubemap_HDR;
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat16_0;
      float3 u_xlat1_d;
      float3 u_xlat16_1;
      float4 u_xlat16_2;
      float3 u_xlat16_3_d;
      float3 u_xlat16_4;
      float3 u_xlat16_5;
      float3 u_xlat16_6;
      float3 u_xlat16_7;
      float3 u_xlat16_11;
      float u_xlat16_24;
      float u_xlat25;
      float u_xlat16_26;
      float u_xlat16_27;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat16_0.x = in_f.texcoord3.w;
          u_xlat16_0.y = in_f.texcoord4.w;
          u_xlat16_0.z = in_f.texcoord5.w;
          u_xlat1_d.xyz = ((-u_xlat16_0.xyz) + _WorldSpaceCameraPos.xyz);
          u_xlat25 = dot(u_xlat1_d.xyz, u_xlat1_d.xyz);
          u_xlat25 = rsqrt(u_xlat25);
          u_xlat16_0.xyz = ((u_xlat1_d.xyz * float3(u_xlat25, u_xlat25, u_xlat25)) + _ViewOffset.xyz);
          u_xlat16_0.xyz = normalize(u_xlat16_0.xyz);
          u_xlat16_1.xyz = tex2D(_Normal, in_f.texcoord2.xy).xyz;
          u_xlat16_2.xyz = ((u_xlat16_1.xyz * float3(2, 2, 2)) + float3(-1, (-1), (-2)));
          u_xlat16_2.xy = (u_xlat16_2.xy * float2(float2(_NormalIntensity, _NormalIntensity)));
          u_xlat16_3_d.xyz = (u_xlat16_2.yyy * in_f.texcoord4.xyz);
          u_xlat16_2.xyw = ((u_xlat16_2.xxx * in_f.texcoord3.xyz) + u_xlat16_3_d.xyz);
          u_xlat16_24 = _NormalIntensity;
          #ifdef UNITY_ADRENO_ES3
          u_xlat16_24 = min(max(u_xlat16_24, 0), 1);
          #else
          u_xlat16_24 = clamp(u_xlat16_24, 0, 1);
          #endif
          u_xlat16_24 = ((u_xlat16_24 * u_xlat16_2.z) + 1);
          u_xlat16_2.xyz = ((float3(u_xlat16_24, u_xlat16_24, u_xlat16_24) * in_f.texcoord5.xyz) + u_xlat16_2.xyw);
          u_xlat16_24 = dot((-u_xlat16_0.xyz), u_xlat16_2.xyz);
          u_xlat16_24 = (u_xlat16_24 + u_xlat16_24);
          u_xlat16_0.xyz = ((u_xlat16_2.xyz * (-float3(u_xlat16_24, u_xlat16_24, u_xlat16_24))) + (-u_xlat16_0.xyz));
          u_xlat16_1.xyz = tex2D(_MetallicSmoothness, in_f.texcoord2.xy).xyz;
          u_xlat16_3_d.xy = (u_xlat16_1.xy * float2(_Metallic, _Smoothness));
          u_xlat16_24 = max(u_xlat16_3_d.y, 0.00999999978);
          u_xlat16_24 = ((-u_xlat16_24) + 1);
          u_xlat16_26 = (((-u_xlat16_24) * 0.699999988) + 1.70000005);
          u_xlat16_24 = (u_xlat16_24 * u_xlat16_26);
          u_xlat16_24 = (u_xlat16_24 * 6);
          u_xlat16_0 = texCUBE(_Cubemap, float4(u_xlat16_0.xyz, u_xlat16_24));
          u_xlat16_26 = (u_xlat16_0.w + (-1));
          u_xlat16_26 = ((_Cubemap_HDR.w * u_xlat16_26) + 1);
          u_xlat16_26 = max(u_xlat16_26, 0);
          u_xlat16_26 = log2(u_xlat16_26);
          u_xlat16_26 = (u_xlat16_26 * _Cubemap_HDR.y);
          u_xlat16_26 = exp2(u_xlat16_26);
          u_xlat16_26 = (u_xlat16_26 * _Cubemap_HDR.x);
          u_xlat16_11.xyz = (u_xlat16_0.xyz * float3(u_xlat16_26, u_xlat16_26, u_xlat16_26));
          u_xlat16_4.xyz = tex2D(_Albedo, in_f.texcoord2.xy).xyz;
          u_xlat16_5.xyz = (u_xlat16_4.xyz * _Color.xyz);
          u_xlat16_6.xyz = ((u_xlat16_5.xyz * float3(2, 2, 2)) + float3(-1, (-1), (-1)));
          u_xlat16_6.xyz = ((u_xlat16_3_d.xxx * u_xlat16_6.xyz) + float3(1, 1, 1));
          u_xlat16_6.xyz = (u_xlat16_6.xyz * _SpecularColor.xyz);
          u_xlat16_11.xyz = (u_xlat16_11.xyz * u_xlat16_6.xyz);
          u_xlat16_11.xyz = (u_xlat16_11.xyz * float3(0.0399999991, 0.0399999991, 0.0399999991));
          u_xlat16_26 = ((unity_LightData.z * 0.5) + 0.5);
          u_xlat16_11.xyz = (float3(u_xlat16_26, u_xlat16_26, u_xlat16_26) * u_xlat16_11.xyz);
          u_xlat16_11.xyz = (u_xlat16_11.xyz * float3(float3(_CubeIntensity, _CubeIntensity, _CubeIntensity)));
          u_xlat16_3_d.xyz = (u_xlat16_3_d.xxx * u_xlat16_11.xyz);
          u_xlat16_3_d.xyz = (u_xlat16_3_d.xyz * float3(_CubeIntensity_Metallic, _CubeIntensity_Metallic, _CubeIntensity_Metallic));
          u_xlat16_26 = (u_xlat16_1.z + (-1));
          u_xlat16_27 = (((-u_xlat16_1.x) * _Metallic) + 1);
          u_xlat16_26 = ((_Occlusion * u_xlat16_26) + 1);
          u_xlat16_6.xyz = ((-_AmbientColor.xyz) + float3(1, 1, 1));
          u_xlat16_6.xyz = ((float3(u_xlat16_26, u_xlat16_26, u_xlat16_26) * u_xlat16_6.xyz) + _AmbientColor.xyz);
          u_xlat16_3_d.xyz = (u_xlat16_3_d.xyz * u_xlat16_6.xyz);
          u_xlat16_7.xyz = normalize(_MainLightPosition.xyz);
          u_xlat16_2.x = dot(u_xlat16_2.xyz, u_xlat16_7.xyz);
          u_xlat16_2.x = max(u_xlat16_2.x, 0);
          u_xlat16_2.xyz = (u_xlat16_2.xxx * _MainLightColor.xyz);
          u_xlat16_2.xyz = ((u_xlat16_2.xyz * unity_LightData.zzz) + _AmbientColor.xyz);
          u_xlat16_2.xyz = (u_xlat16_5.xyz * u_xlat16_2.xyz);
          u_xlat16_2.xyz = (float3(u_xlat16_27, u_xlat16_27, u_xlat16_27) * u_xlat16_2.xyz);
          out_f.color.xyz = ((u_xlat16_2.xyz * u_xlat16_6.xyz) + u_xlat16_3_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          out_f.color.xyz = min(max(out_f.color.xyz, 0), 1);
          #else
          out_f.color.xyz = clamp(out_f.color.xyz, 0, 1);
          #endif
          out_f.color.w = 1;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
