Shader "MJ/MJHair_low"
{
  Properties
  {
    _Shift ("Shift", Range(0, 1)) = 0.324
    [Toggle(_BACKFACE_SPEC)] _BackfaceSpecular ("BackFaceSpecular", float) = 0
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
    _Albedo ("Texture", 2D) = "white" {}
    _Cutoff ("Cutoff", Range(0, 0.99)) = 0.5
    [NoScaleOffset] _Bump ("Normal Map", 2D) = "bump" {}
    _BumpScale ("Scale", Range(0, 2)) = 1
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Transparent+1"
      "RenderType" = "Transparent"
    }
    LOD 200
    Pass // ind: 1, name: ALPHA BLENDING
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
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,worldNormal,worldTangent,worldBinormal,worldPos,worldView,rimLightDir,pos)
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
      //uniform float4x4 unity_MatrixVP;
      //uniform float4 _WorldSpaceLightPos0;
      uniform float4 _LightColor0;
      uniform float4 _Color;
      uniform float _BumpScale;
      uniform sampler2D _Albedo;
      uniform sampler2D _Bump;
      uniform float _SpecStrength;
      uniform float4 _SpecColor1;
      uniform float _SpecStrength3;
      uniform float4 _SpecColor3;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
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
          o_1 = v2f(float4(0, 0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float4(0, 0, 0, 0));
          float4 tmpvar_2;
          tmpvar_2.w = 1;
          tmpvar_2.xyz = in_v.vertex.xyz;
          o_1.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_2));
          o_1.uv.xy = in_v.texcoord.xy;
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
          float4 final_col_1;
          float alpha_2;
          float4 albedo_alpha_3;
          float3 tmpvar_4;
          float4 tmpvar_5;
          tmpvar_5 = tex2D(_Bump, in_f.xlv_TEXCOORD0.xy);
          float4 packednormal_6;
          packednormal_6 = tmpvar_5;
          float3 normal_7;
          float3 tmpvar_8;
          tmpvar_8 = ((packednormal_6.xyz * 2) - 1);
          normal_7.z = tmpvar_8.z;
          normal_7.xy = (tmpvar_8.xy * _BumpScale);
          float3 normal_9;
          normal_9 = normal_7;
          float3 tmpvar_10;
          tmpvar_10 = normalize((((normalize(in_f.xlv_TEXCOORD3) * normal_9.y) + (normalize(in_f.xlv_TEXCOORD2) * normal_9.x)) + (normalize(in_f.xlv_TEXCOORD1) * normal_9.z)));
          float4 tmpvar_11;
          tmpvar_11 = tex2D(_Albedo, in_f.xlv_TEXCOORD0.xy);
          float4 tmpvar_12;
          tmpvar_12 = (tmpvar_11 * _Color);
          albedo_alpha_3 = tmpvar_12;
          tmpvar_4 = albedo_alpha_3.xyz;
          float tmpvar_13;
          tmpvar_13 = albedo_alpha_3.w;
          alpha_2 = tmpvar_13;
          float3 tmpvar_14;
          tmpvar_14 = _LightColor0.xyz;
          float3 tmpvar_15;
          tmpvar_15 = normalize(_WorldSpaceLightPos0.xyz);
          float3 normal_16;
          normal_16 = tmpvar_10;
          float3 viewDir_17;
          viewDir_17 = (-in_f.xlv_TEXCOORD5);
          float3 h_18;
          float3 tmpvar_19;
          tmpvar_19 = normalize((tmpvar_15 + viewDir_17));
          h_18 = tmpvar_19;
          float tmpvar_20;
          float tmpvar_21;
          tmpvar_21 = clamp(dot(tmpvar_15, h_18), 0, 1);
          tmpvar_20 = tmpvar_21;
          float x_22;
          x_22 = (1 - tmpvar_20);
          float4 tmpvar_23;
          tmpvar_23.w = 1;
          tmpvar_23.xyz = clamp(((tmpvar_4 * (tmpvar_14 * clamp(clamp(dot(normal_16, tmpvar_15), 0, 1), 0.3, 1))) + ((((_SpecColor1.xyz * _SpecStrength) + (_SpecColor3.xyz * _SpecStrength3)) * abs(dot(normal_16, viewDir_17))) * (tmpvar_4 + ((1 - tmpvar_4) * ((x_22 * x_22) * ((x_22 * x_22) * x_22)))))), 0, 1);
          final_col_1.xyz = tmpvar_23.xyz;
          final_col_1.w = alpha_2;
          out_f.color = final_col_1;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
