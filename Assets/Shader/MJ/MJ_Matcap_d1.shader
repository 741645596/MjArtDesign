// Upgrade NOTE: commented out 'float4 unity_DynamicLightmapST', a built-in variable
// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

Shader "MJ/Matcap"
{
  Properties
  {
    _WhiteFace ("WhiteFace", 2D) = "black" {}
    _Back ("Back", 2D) = "black" {}
    _Back2 ("Back2", 2D) = "black" {}
    _Text ("Text", 2D) = "black" {}
    _Text2 ("Text2", 2D) = "black" {}
    _Text3 ("Text3", 2D) = "black" {}
    _Mask ("Mask", 2D) = "black" {}
    _Normal ("Normal", 2D) = "bump" {}
    _Back2Color ("Back2Color", Color) = (1,1,1,1)
    _ShadowColor ("ShadowColor", Color) = (0,0,0,0)
    _MainColor ("MainColor", Color) = (1,1,1,1)
    _AddTexture ("Add Texture", 2D) = "black" {}
    _AddTexOpacity ("Add Tex Opacity", Range(0, 1)) = 1
    [HideInInspector] _texcoord ("", 2D) = "white" {}
    [HideInInspector] __dirty ("", float) = 1
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Geometry+0"
      "RenderType" = "Opaque"
    }
    Pass // ind: 1, name: FORWARD
    {
      Name "FORWARD"
      Tags
      { 
        "LIGHTMODE" = "FORWARDBASE"
        "QUEUE" = "Geometry+0"
        "RenderType" = "Opaque"
        "SHADOWSUPPORT" = "true"
      }
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      #define conv_mxt3x3_0(mat4x4) float3(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x)
      #define conv_mxt3x3_1(mat4x4) float3(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y)
      #define conv_mxt3x3_2(mat4x4) float3(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_WorldTransformParams;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _texcoord_ST;
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_MatrixInvV;
      uniform float4 _LightColor0;
      uniform sampler2D _WhiteFace;
      uniform sampler2D _Normal;
      uniform float4 _Normal_ST;
      uniform sampler2D _Back;
      uniform sampler2D _Mask;
      uniform float4 _Mask_ST;
      uniform sampler2D _AddTexture;
      uniform float4 _AddTexture_ST;
      uniform float _AddTexOpacity;
      uniform sampler2D _Back2;
      uniform float4 _Back2Color;
      uniform sampler2D _Text;
      uniform sampler2D _Text2;
      uniform sampler2D _Text3;
      uniform float4 _ShadowColor;
      uniform float4 _MainColor;
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
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 xlv_TEXCOORD3 :TEXCOORD3;
          float4 xlv_TEXCOORD7 :TEXCOORD7;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 xlv_TEXCOORD3 :TEXCOORD3;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float3 worldBinormal_1;
          float tangentSign_2;
          float3 worldTangent_3;
          float4 tmpvar_4;
          float4 tmpvar_5;
          tmpvar_5.w = 1;
          tmpvar_5.xyz = in_v.vertex.xyz;
          float3 tmpvar_6;
          tmpvar_6 = mul(unity_ObjectToWorld, in_v.vertex).xyz;
          float3x3 tmpvar_7;
          tmpvar_7[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
          tmpvar_7[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
          tmpvar_7[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
          float3 tmpvar_8;
          tmpvar_8 = normalize(mul(in_v.normal, tmpvar_7));
          float3x3 tmpvar_9;
          tmpvar_9[0] = conv_mxt4x4_0(unity_ObjectToWorld).xyz;
          tmpvar_9[1] = conv_mxt4x4_1(unity_ObjectToWorld).xyz;
          tmpvar_9[2] = conv_mxt4x4_2(unity_ObjectToWorld).xyz;
          float3 tmpvar_10;
          tmpvar_10 = normalize(mul(tmpvar_9, in_v.tangent.xyz));
          worldTangent_3 = tmpvar_10;
          float tmpvar_11;
          tmpvar_11 = (in_v.tangent.w * unity_WorldTransformParams.w);
          tangentSign_2 = tmpvar_11;
          float3 tmpvar_12;
          tmpvar_12 = (((tmpvar_8.yzx * worldTangent_3.zxy) - (tmpvar_8.zxy * worldTangent_3.yzx)) * tangentSign_2);
          worldBinormal_1 = tmpvar_12;
          float4 tmpvar_13;
          tmpvar_13.x = worldTangent_3.x;
          tmpvar_13.y = worldBinormal_1.x;
          tmpvar_13.z = tmpvar_8.x;
          tmpvar_13.w = tmpvar_6.x;
          float4 tmpvar_14;
          tmpvar_14.x = worldTangent_3.y;
          tmpvar_14.y = worldBinormal_1.y;
          tmpvar_14.z = tmpvar_8.y;
          tmpvar_14.w = tmpvar_6.y;
          float4 tmpvar_15;
          tmpvar_15.x = worldTangent_3.z;
          tmpvar_15.y = worldBinormal_1.z;
          tmpvar_15.z = tmpvar_8.z;
          tmpvar_15.w = tmpvar_6.z;
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_5));
          out_v.xlv_TEXCOORD0 = TRANSFORM_TEX(in_v.texcoord.xy, _texcoord);
          out_v.xlv_TEXCOORD1 = tmpvar_13;
          out_v.xlv_TEXCOORD2 = tmpvar_14;
          out_v.xlv_TEXCOORD3 = tmpvar_15;
          out_v.xlv_TEXCOORD7 = tmpvar_4;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float4 c_1;
          float3 tmpvar_2;
          float3 tmpvar_3;
          float3 tmpvar_4;
          float3 tmpvar_5;
          tmpvar_5.x = in_f.xlv_TEXCOORD1.w;
          tmpvar_5.y = in_f.xlv_TEXCOORD2.w;
          tmpvar_5.z = in_f.xlv_TEXCOORD3.w;
          tmpvar_2 = in_f.xlv_TEXCOORD1.xyz;
          tmpvar_3 = in_f.xlv_TEXCOORD2.xyz;
          tmpvar_4 = in_f.xlv_TEXCOORD3.xyz;
          c_1 = float4(0, 0, 0, 0);
          float4 tex2DNode109_6;
          float4 tex2DNode180_7;
          float4 tex2DNode110_8;
          float3 ase_worldBitangent_9;
          float3 ase_worldTangent_10;
          float3 ase_worldNormal_11;
          float ase_lightAtten_12;
          float4 c_13;
          c_13 = float4(0, 0, 0, 0);
          ase_lightAtten_12 = 1;
          if((_LightColor0.w==0))
          {
              ase_lightAtten_12 = 0;
          }
          float2 tmpvar_14;
          tmpvar_14 = TRANSFORM_TEX(in_f.xlv_TEXCOORD0, _Normal);
          float3 tmpvar_15;
          tmpvar_15.x = tmpvar_2.z;
          tmpvar_15.y = tmpvar_3.z;
          tmpvar_15.z = tmpvar_4.z;
          ase_worldNormal_11 = tmpvar_15;
          float3 tmpvar_16;
          tmpvar_16.x = tmpvar_2.x;
          tmpvar_16.y = tmpvar_3.x;
          tmpvar_16.z = tmpvar_4.x;
          ase_worldTangent_10 = tmpvar_16;
          float3 tmpvar_17;
          tmpvar_17.x = tmpvar_2.y;
          tmpvar_17.y = tmpvar_3.y;
          tmpvar_17.z = tmpvar_4.y;
          ase_worldBitangent_9 = tmpvar_17;
          float3x3 tmpvar_18;
          conv_mxt3x3_0(tmpvar_18).x = ase_worldTangent_10.x;
          conv_mxt3x3_0(tmpvar_18).y = ase_worldTangent_10.y;
          conv_mxt3x3_0(tmpvar_18).z = ase_worldTangent_10.z;
          conv_mxt3x3_1(tmpvar_18).x = ase_worldBitangent_9.x;
          conv_mxt3x3_1(tmpvar_18).y = ase_worldBitangent_9.y;
          conv_mxt3x3_1(tmpvar_18).z = ase_worldBitangent_9.z;
          conv_mxt3x3_2(tmpvar_18).x = ase_worldNormal_11.x;
          conv_mxt3x3_2(tmpvar_18).y = ase_worldNormal_11.y;
          conv_mxt3x3_2(tmpvar_18).z = ase_worldNormal_11.z;
          float3 tmpvar_19;
          tmpvar_19 = ((tex2D(_Normal, tmpvar_14).xyz * 2) - 1);
          float3 tmpvar_20;
          tmpvar_20 = mul(unity_MatrixInvV, float4(0, 1, 0, 0)).xyz;
          float3 tmpvar_21;
          tmpvar_21 = (-normalize((_WorldSpaceCameraPos - tmpvar_5)));
          float3 tmpvar_22;
          tmpvar_22 = normalize(((tmpvar_20.yzx * tmpvar_21.zxy) - (tmpvar_20.zxy * tmpvar_21.yzx)));
          float3 tmpvar_23;
          tmpvar_23 = normalize(((tmpvar_21.yzx * tmpvar_22.zxy) - (tmpvar_21.zxy * tmpvar_22.yzx)));
          float3x3 tmpvar_24;
          conv_mxt3x3_0(tmpvar_24).x = tmpvar_22.x;
          conv_mxt3x3_0(tmpvar_24).y = tmpvar_22.y;
          conv_mxt3x3_0(tmpvar_24).z = tmpvar_22.z;
          conv_mxt3x3_1(tmpvar_24).x = tmpvar_23.x;
          conv_mxt3x3_1(tmpvar_24).y = tmpvar_23.y;
          conv_mxt3x3_1(tmpvar_24).z = tmpvar_23.z;
          conv_mxt3x3_2(tmpvar_24).x = tmpvar_21.x;
          conv_mxt3x3_2(tmpvar_24).y = tmpvar_21.y;
          conv_mxt3x3_2(tmpvar_24).z = tmpvar_21.z;
          float2 tmpvar_25;
          tmpvar_25 = ((mul(normalize(mul(tmpvar_18, tmpvar_19)), tmpvar_24).xy + 1) * 0.5);
          float2 tmpvar_26;
          tmpvar_26 = TRANSFORM_TEX(in_f.xlv_TEXCOORD0, _Mask);
          float4 tmpvar_27;
          tmpvar_27 = tex2D(_Mask, tmpvar_26);
          tex2DNode110_8 = tmpvar_27;
          float4 tmpvar_28;
          tmpvar_28 = tex2D(_WhiteFace, tmpvar_25);
          float4 tmpvar_29;
          tmpvar_29 = tex2D(_Back, tmpvar_25);
          float2 tmpvar_30;
          tmpvar_30 = TRANSFORM_TEX(in_f.xlv_TEXCOORD0, _AddTexture);
          float4 tmpvar_31;
          tmpvar_31 = tex2D(_AddTexture, tmpvar_30);
          tex2DNode180_7 = tmpvar_31;
          float4 tmpvar_32;
          tmpvar_32 = tex2D(_Back2, tmpvar_25);
          tex2DNode109_6 = tmpvar_32;
          float4 tmpvar_33;
          tmpvar_33 = (tex2DNode109_6 * _Back2Color);
          float4 tmpvar_34;
          tmpvar_34 = (tex2DNode109_6 - float4(0.5019608, 0.5019608, 0.5019608, 0));
          float4 tmpvar_35;
          tmpvar_35 = tex2D(_Text, tmpvar_25);
          float4 tmpvar_36;
          tmpvar_36 = tex2D(_Text2, tmpvar_25);
          float4 tmpvar_37;
          tmpvar_37 = tex2D(_Text3, tmpvar_25);
          float4 tmpvar_38;
          float _tmp_dvx_125 = (max((tex2DNode110_8.x - 0.6), 0) / 0.4);
          float _tmp_dvx_126 = (tex2DNode180_7.w * _AddTexOpacity);
          float _tmp_dvx_127 = ceil((tex2DNode110_8.x - 0.1));
          tmpvar_38 = lerp(lerp(lerp(lerp(lerp(lerp(tmpvar_28, tmpvar_29, float4(_tmp_dvx_127, _tmp_dvx_127, _tmp_dvx_127, _tmp_dvx_127)), tex2DNode180_7, float4(_tmp_dvx_126, _tmp_dvx_126, _tmp_dvx_126, _tmp_dvx_126)), lerp(lerp(tmpvar_33, float4(1, 1, 1, 1), (tmpvar_34 / (1 - tmpvar_34))), tmpvar_33, _Back2Color.wwww), float4(_tmp_dvx_125, _tmp_dvx_125, _tmp_dvx_125, _tmp_dvx_125)), tmpvar_35, tex2DNode110_8.yyyy), tmpvar_36, tex2DNode110_8.zzzz), tmpvar_37, tex2DNode110_8.wwww);
          float4 tmpvar_39;
          tmpvar_39 = lerp((tmpvar_38 * _ShadowColor), tmpvar_38, float4(ase_lightAtten_12, ase_lightAtten_12, ase_lightAtten_12, ase_lightAtten_12));
          c_13.xyz = (tmpvar_39 * _MainColor).xyz;
          c_13.w = 1;
          c_1 = c_13;
          out_f.color = c_1;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: FORWARD
    {
      Name "FORWARD"
      Tags
      { 
        "LIGHTMODE" = "FORWARDADD"
        "QUEUE" = "Geometry+0"
        "RenderType" = "Opaque"
        "SHADOWSUPPORT" = "true"
      }
      ZWrite Off
      Blend One One
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile POINT
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      #define conv_mxt3x3_0(mat4x4) float3(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x)
      #define conv_mxt3x3_1(mat4x4) float3(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y)
      #define conv_mxt3x3_2(mat4x4) float3(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z)
      
      
      #define CODE_BLOCK_VERTEX
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_WorldTransformParams;
      //uniform float4x4 unity_MatrixVP;
      uniform float4 _texcoord_ST;
      //uniform float3 _WorldSpaceCameraPos;
      //uniform float4x4 unity_MatrixInvV;
      uniform sampler2D _LightTexture0;
      uniform float4x4 unity_WorldToLight;
      uniform float4 _LightColor0;
      uniform sampler2D _WhiteFace;
      uniform sampler2D _Normal;
      uniform float4 _Normal_ST;
      uniform sampler2D _Back;
      uniform sampler2D _Mask;
      uniform float4 _Mask_ST;
      uniform sampler2D _AddTexture;
      uniform float4 _AddTexture_ST;
      uniform float _AddTexOpacity;
      uniform sampler2D _Back2;
      uniform float4 _Back2Color;
      uniform sampler2D _Text;
      uniform sampler2D _Text2;
      uniform sampler2D _Text3;
      uniform float4 _ShadowColor;
      uniform float4 _MainColor;
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
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD0 :TEXCOORD0;
          float3 xlv_TEXCOORD1 :TEXCOORD1;
          float3 xlv_TEXCOORD2 :TEXCOORD2;
          float3 xlv_TEXCOORD3 :TEXCOORD3;
          float3 xlv_TEXCOORD4 :TEXCOORD4;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float3 worldBinormal_1;
          float tangentSign_2;
          float3 worldTangent_3;
          float4 tmpvar_4;
          tmpvar_4.w = 1;
          tmpvar_4.xyz = in_v.vertex.xyz;
          float3x3 tmpvar_5;
          tmpvar_5[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
          tmpvar_5[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
          tmpvar_5[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
          float3 tmpvar_6;
          tmpvar_6 = normalize(mul(in_v.normal, tmpvar_5));
          float3x3 tmpvar_7;
          tmpvar_7[0] = conv_mxt4x4_0(unity_ObjectToWorld).xyz;
          tmpvar_7[1] = conv_mxt4x4_1(unity_ObjectToWorld).xyz;
          tmpvar_7[2] = conv_mxt4x4_2(unity_ObjectToWorld).xyz;
          float3 tmpvar_8;
          tmpvar_8 = normalize(mul(tmpvar_7, in_v.tangent.xyz));
          worldTangent_3 = tmpvar_8;
          float tmpvar_9;
          tmpvar_9 = (in_v.tangent.w * unity_WorldTransformParams.w);
          tangentSign_2 = tmpvar_9;
          float3 tmpvar_10;
          tmpvar_10 = (((tmpvar_6.yzx * worldTangent_3.zxy) - (tmpvar_6.zxy * worldTangent_3.yzx)) * tangentSign_2);
          worldBinormal_1 = tmpvar_10;
          float3 tmpvar_11;
          tmpvar_11.x = worldTangent_3.x;
          tmpvar_11.y = worldBinormal_1.x;
          tmpvar_11.z = tmpvar_6.x;
          float3 tmpvar_12;
          tmpvar_12.x = worldTangent_3.y;
          tmpvar_12.y = worldBinormal_1.y;
          tmpvar_12.z = tmpvar_6.y;
          float3 tmpvar_13;
          tmpvar_13.x = worldTangent_3.z;
          tmpvar_13.y = worldBinormal_1.z;
          tmpvar_13.z = tmpvar_6.z;
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_4));
          out_v.xlv_TEXCOORD0 = TRANSFORM_TEX(in_v.texcoord.xy, _texcoord);
          out_v.xlv_TEXCOORD1 = tmpvar_11;
          out_v.xlv_TEXCOORD2 = tmpvar_12;
          out_v.xlv_TEXCOORD3 = tmpvar_13;
          out_v.xlv_TEXCOORD4 = mul(unity_ObjectToWorld, in_v.vertex).xyz;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float3 tmpvar_1;
          float4 c_2;
          float atten_3;
          float3 lightCoord_4;
          float3 tmpvar_5;
          float3 tmpvar_6;
          float3 tmpvar_7;
          tmpvar_5 = in_f.xlv_TEXCOORD1;
          tmpvar_6 = in_f.xlv_TEXCOORD2;
          tmpvar_7 = in_f.xlv_TEXCOORD3;
          float4 tmpvar_8;
          tmpvar_8.w = 1;
          tmpvar_8.xyz = in_f.xlv_TEXCOORD4;
          lightCoord_4 = mul(unity_WorldToLight, tmpvar_8).xyz;
          float tmpvar_9;
          float _tmp_dvx_128 = dot(lightCoord_4, lightCoord_4);
          tmpvar_9 = tex2D(_LightTexture0, float2(_tmp_dvx_128, _tmp_dvx_128)).w;
          atten_3 = tmpvar_9;
          tmpvar_1 = _LightColor0.xyz;
          tmpvar_1 = (tmpvar_1 * atten_3);
          float4 tex2DNode109_10;
          float4 tex2DNode180_11;
          float4 tex2DNode110_12;
          float3 ase_worldBitangent_13;
          float3 ase_worldTangent_14;
          float3 ase_worldNormal_15;
          float3 ase_lightAttenRGB_16;
          float4 c_17;
          float3 tmpvar_18;
          tmpvar_18 = (tmpvar_1 / (_LightColor0.xyz + 1E-06));
          ase_lightAttenRGB_16 = tmpvar_18;
          float2 tmpvar_19;
          tmpvar_19 = TRANSFORM_TEX(in_f.xlv_TEXCOORD0, _Normal);
          float3 tmpvar_20;
          tmpvar_20.x = tmpvar_5.z;
          tmpvar_20.y = tmpvar_6.z;
          tmpvar_20.z = tmpvar_7.z;
          ase_worldNormal_15 = tmpvar_20;
          float3 tmpvar_21;
          tmpvar_21.x = tmpvar_5.x;
          tmpvar_21.y = tmpvar_6.x;
          tmpvar_21.z = tmpvar_7.x;
          ase_worldTangent_14 = tmpvar_21;
          float3 tmpvar_22;
          tmpvar_22.x = tmpvar_5.y;
          tmpvar_22.y = tmpvar_6.y;
          tmpvar_22.z = tmpvar_7.y;
          ase_worldBitangent_13 = tmpvar_22;
          float3x3 tmpvar_23;
          conv_mxt3x3_0(tmpvar_23).x = ase_worldTangent_14.x;
          conv_mxt3x3_0(tmpvar_23).y = ase_worldTangent_14.y;
          conv_mxt3x3_0(tmpvar_23).z = ase_worldTangent_14.z;
          conv_mxt3x3_1(tmpvar_23).x = ase_worldBitangent_13.x;
          conv_mxt3x3_1(tmpvar_23).y = ase_worldBitangent_13.y;
          conv_mxt3x3_1(tmpvar_23).z = ase_worldBitangent_13.z;
          conv_mxt3x3_2(tmpvar_23).x = ase_worldNormal_15.x;
          conv_mxt3x3_2(tmpvar_23).y = ase_worldNormal_15.y;
          conv_mxt3x3_2(tmpvar_23).z = ase_worldNormal_15.z;
          float3 tmpvar_24;
          tmpvar_24 = ((tex2D(_Normal, tmpvar_19).xyz * 2) - 1);
          float3 tmpvar_25;
          tmpvar_25 = mul(unity_MatrixInvV, float4(0, 1, 0, 0)).xyz;
          float3 tmpvar_26;
          tmpvar_26 = (-normalize((_WorldSpaceCameraPos - in_f.xlv_TEXCOORD4)));
          float3 tmpvar_27;
          tmpvar_27 = normalize(((tmpvar_25.yzx * tmpvar_26.zxy) - (tmpvar_25.zxy * tmpvar_26.yzx)));
          float3 tmpvar_28;
          tmpvar_28 = normalize(((tmpvar_26.yzx * tmpvar_27.zxy) - (tmpvar_26.zxy * tmpvar_27.yzx)));
          float3x3 tmpvar_29;
          conv_mxt3x3_0(tmpvar_29).x = tmpvar_27.x;
          conv_mxt3x3_0(tmpvar_29).y = tmpvar_27.y;
          conv_mxt3x3_0(tmpvar_29).z = tmpvar_27.z;
          conv_mxt3x3_1(tmpvar_29).x = tmpvar_28.x;
          conv_mxt3x3_1(tmpvar_29).y = tmpvar_28.y;
          conv_mxt3x3_1(tmpvar_29).z = tmpvar_28.z;
          conv_mxt3x3_2(tmpvar_29).x = tmpvar_26.x;
          conv_mxt3x3_2(tmpvar_29).y = tmpvar_26.y;
          conv_mxt3x3_2(tmpvar_29).z = tmpvar_26.z;
          float2 tmpvar_30;
          tmpvar_30 = ((mul(normalize(mul(tmpvar_23, tmpvar_24)), tmpvar_29).xy + 1) * 0.5);
          float2 tmpvar_31;
          tmpvar_31 = TRANSFORM_TEX(in_f.xlv_TEXCOORD0, _Mask);
          float4 tmpvar_32;
          tmpvar_32 = tex2D(_Mask, tmpvar_31);
          tex2DNode110_12 = tmpvar_32;
          float4 tmpvar_33;
          tmpvar_33 = tex2D(_WhiteFace, tmpvar_30);
          float4 tmpvar_34;
          tmpvar_34 = tex2D(_Back, tmpvar_30);
          float2 tmpvar_35;
          tmpvar_35 = TRANSFORM_TEX(in_f.xlv_TEXCOORD0, _AddTexture);
          float4 tmpvar_36;
          tmpvar_36 = tex2D(_AddTexture, tmpvar_35);
          tex2DNode180_11 = tmpvar_36;
          float4 tmpvar_37;
          tmpvar_37 = tex2D(_Back2, tmpvar_30);
          tex2DNode109_10 = tmpvar_37;
          float4 tmpvar_38;
          tmpvar_38 = (tex2DNode109_10 * _Back2Color);
          float4 tmpvar_39;
          tmpvar_39 = (tex2DNode109_10 - float4(0.5019608, 0.5019608, 0.5019608, 0));
          float4 tmpvar_40;
          tmpvar_40 = tex2D(_Text, tmpvar_30);
          float4 tmpvar_41;
          tmpvar_41 = tex2D(_Text2, tmpvar_30);
          float4 tmpvar_42;
          tmpvar_42 = tex2D(_Text3, tmpvar_30);
          float4 tmpvar_43;
          float _tmp_dvx_129 = (max((tex2DNode110_12.x - 0.6), 0) / 0.4);
          float _tmp_dvx_130 = (tex2DNode180_11.w * _AddTexOpacity);
          float _tmp_dvx_131 = ceil((tex2DNode110_12.x - 0.1));
          tmpvar_43 = lerp(lerp(lerp(lerp(lerp(lerp(tmpvar_33, tmpvar_34, float4(_tmp_dvx_131, _tmp_dvx_131, _tmp_dvx_131, _tmp_dvx_131)), tex2DNode180_11, float4(_tmp_dvx_130, _tmp_dvx_130, _tmp_dvx_130, _tmp_dvx_130)), lerp(lerp(tmpvar_38, float4(1, 1, 1, 1), (tmpvar_39 / (1 - tmpvar_39))), tmpvar_38, _Back2Color.wwww), float4(_tmp_dvx_129, _tmp_dvx_129, _tmp_dvx_129, _tmp_dvx_129)), tmpvar_40, tex2DNode110_12.yyyy), tmpvar_41, tex2DNode110_12.zzzz), tmpvar_42, tex2DNode110_12.wwww);
          float4 tmpvar_44;
          float _tmp_dvx_132 = max(max(ase_lightAttenRGB_16.x, ase_lightAttenRGB_16.y), ase_lightAttenRGB_16.z);
          tmpvar_44 = lerp((tmpvar_43 * _ShadowColor), tmpvar_43, float4(_tmp_dvx_132, _tmp_dvx_132, _tmp_dvx_132, _tmp_dvx_132));
          c_17.xyz = (tmpvar_44 * _MainColor).xyz;
          c_17.w = 1;
          c_2 = c_17;
          out_f.color = c_2;
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 3, name: META
    {
      Name "META"
      Tags
      { 
        "LIGHTMODE" = "META"
        "QUEUE" = "Geometry+0"
        "RenderType" = "Opaque"
      }
      Cull Off
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
      //uniform float4x4 unity_ObjectToWorld;
      //uniform float4x4 unity_WorldToObject;
      //uniform float4 unity_WorldTransformParams;
      //uniform float4x4 unity_MatrixVP;
      // uniform float4 unity_LightmapST;
      // uniform float4 unity_DynamicLightmapST;
      uniform float4 unity_MetaVertexControl;
      uniform float4 unity_MetaFragmentControl;
      uniform float unity_OneOverOutputBoost;
      uniform float unity_MaxOutputValue;
      uniform float unity_UseLinearSpace;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord1 :TEXCOORD1;
          float4 texcoord2 :TEXCOORD2;
      };
      
      struct OUT_Data_Vert
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 xlv_TEXCOORD0 :TEXCOORD0;
          float4 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 vertex :Position;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float3 worldBinormal_1;
          float tangentSign_2;
          float3 worldTangent_3;
          float4 vertex_4;
          vertex_4 = in_v.vertex;
          if(unity_MetaVertexControl.x)
          {
              vertex_4.xy = ((in_v.texcoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
              float tmpvar_5;
              if((in_v.vertex.z>0))
              {
                  tmpvar_5 = 0.0001;
              }
              else
              {
                  tmpvar_5 = 0;
              }
              vertex_4.z = tmpvar_5;
          }
          if(unity_MetaVertexControl.y)
          {
              vertex_4.xy = ((in_v.texcoord2.xy * unity_DynamicLightmapST.xy) + unity_DynamicLightmapST.zw);
              float tmpvar_6;
              if((vertex_4.z>0))
              {
                  tmpvar_6 = 0.0001;
              }
              else
              {
                  tmpvar_6 = 0;
              }
              vertex_4.z = tmpvar_6;
          }
          float4 tmpvar_7;
          tmpvar_7.w = 1;
          tmpvar_7.xyz = vertex_4.xyz;
          float3 tmpvar_8;
          tmpvar_8 = mul(unity_ObjectToWorld, in_v.vertex).xyz;
          float3x3 tmpvar_9;
          tmpvar_9[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
          tmpvar_9[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
          tmpvar_9[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
          float3 tmpvar_10;
          tmpvar_10 = normalize(mul(in_v.normal, tmpvar_9));
          float3x3 tmpvar_11;
          tmpvar_11[0] = conv_mxt4x4_0(unity_ObjectToWorld).xyz;
          tmpvar_11[1] = conv_mxt4x4_1(unity_ObjectToWorld).xyz;
          tmpvar_11[2] = conv_mxt4x4_2(unity_ObjectToWorld).xyz;
          float3 tmpvar_12;
          tmpvar_12 = normalize(mul(tmpvar_11, in_v.tangent.xyz));
          worldTangent_3 = tmpvar_12;
          float tmpvar_13;
          tmpvar_13 = (in_v.tangent.w * unity_WorldTransformParams.w);
          tangentSign_2 = tmpvar_13;
          float3 tmpvar_14;
          tmpvar_14 = (((tmpvar_10.yzx * worldTangent_3.zxy) - (tmpvar_10.zxy * worldTangent_3.yzx)) * tangentSign_2);
          worldBinormal_1 = tmpvar_14;
          float4 tmpvar_15;
          tmpvar_15.x = worldTangent_3.x;
          tmpvar_15.y = worldBinormal_1.x;
          tmpvar_15.z = tmpvar_10.x;
          tmpvar_15.w = tmpvar_8.x;
          float4 tmpvar_16;
          tmpvar_16.x = worldTangent_3.y;
          tmpvar_16.y = worldBinormal_1.y;
          tmpvar_16.z = tmpvar_10.y;
          tmpvar_16.w = tmpvar_8.y;
          float4 tmpvar_17;
          tmpvar_17.x = worldTangent_3.z;
          tmpvar_17.y = worldBinormal_1.z;
          tmpvar_17.z = tmpvar_10.z;
          tmpvar_17.w = tmpvar_8.z;
          out_v.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, tmpvar_7));
          out_v.xlv_TEXCOORD0 = tmpvar_15;
          out_v.xlv_TEXCOORD1 = tmpvar_16;
          out_v.xlv_TEXCOORD2 = tmpvar_17;
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          float4 tmpvar_1;
          float4 res_2;
          res_2 = float4(0, 0, 0, 0);
          if(unity_MetaFragmentControl.x)
          {
              res_2.w = 1;
              float3 tmpvar_3;
              float _tmp_dvx_133 = clamp(unity_OneOverOutputBoost, 0, 1);
              tmpvar_3 = clamp(pow(float3(0, 0, 0), float3(_tmp_dvx_133, _tmp_dvx_133, _tmp_dvx_133)), float3(0, 0, 0), float3(unity_MaxOutputValue, unity_MaxOutputValue, unity_MaxOutputValue));
              res_2.xyz = float3(tmpvar_3);
          }
          if(unity_MetaFragmentControl.y)
          {
              float3 emission_4;
              if(int(unity_UseLinearSpace))
              {
                  emission_4 = float3(0, 0, 0);
              }
              else
              {
                  emission_4 = float3(0, 0, 0);
              }
              float4 tmpvar_5;
              tmpvar_5.w = 1;
              tmpvar_5.xyz = float3(emission_4);
              res_2 = tmpvar_5;
          }
          tmpvar_1 = res_2;
          out_f.color = tmpvar_1;
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
        "QUEUE" = "Geometry+0"
        "RenderType" = "Opaque"
        "SHADOWSUPPORT" = "true"
      }
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile SHADOWS_DEPTH UNITY_PASS_SHADOWCASTER
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
      //uniform float4 unity_WorldTransformParams;
      //uniform float4x4 unity_MatrixVP;
      struct appdata_t
      {
          float4 tangent :TANGENT;
          float4 vertex :POSITION;
          float3 normal :NORMAL;
          float4 texcoord :TEXCOORD0;
      };
      
      struct OUT_Data_Vert
      {
          float2 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 xlv_TEXCOORD3 :TEXCOORD3;
          float4 xlv_TEXCOORD4 :TEXCOORD4;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float2 xlv_TEXCOORD1 :TEXCOORD1;
          float4 xlv_TEXCOORD2 :TEXCOORD2;
          float4 xlv_TEXCOORD3 :TEXCOORD3;
          float4 xlv_TEXCOORD4 :TEXCOORD4;
          float4 vertex :Position;
      };
      
      struct OUT_Data_Frag
      {
          float4 color :SV_Target0;
      };
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          float tangentSign_1;
          float3 worldTangent_2;
          float3 worldNormal_3;
          float2 tmpvar_4;
          float3 tmpvar_5;
          float4 tmpvar_6;
          tmpvar_6 = mul(unity_ObjectToWorld, in_v.vertex);
          tmpvar_5 = tmpvar_6.xyz;
          float3x3 tmpvar_7;
          tmpvar_7[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
          tmpvar_7[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
          tmpvar_7[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
          float3 tmpvar_8;
          tmpvar_8 = normalize(mul(in_v.normal, tmpvar_7));
          worldNormal_3 = tmpvar_8;
          float3x3 tmpvar_9;
          tmpvar_9[0] = conv_mxt4x4_0(unity_ObjectToWorld).xyz;
          tmpvar_9[1] = conv_mxt4x4_1(unity_ObjectToWorld).xyz;
          tmpvar_9[2] = conv_mxt4x4_2(unity_ObjectToWorld).xyz;
          float3 tmpvar_10;
          tmpvar_10 = normalize(mul(tmpvar_9, in_v.tangent.xyz));
          worldTangent_2 = tmpvar_10;
          float tmpvar_11;
          tmpvar_11 = (in_v.tangent.w * unity_WorldTransformParams.w);
          tangentSign_1 = tmpvar_11;
          float3 tmpvar_12;
          tmpvar_12 = (((worldNormal_3.yzx * worldTangent_2.zxy) - (worldNormal_3.zxy * worldTangent_2.yzx)) * tangentSign_1);
          float4 tmpvar_13;
          tmpvar_13.x = worldTangent_2.x;
          tmpvar_13.y = tmpvar_12.x;
          tmpvar_13.z = worldNormal_3.x;
          tmpvar_13.w = tmpvar_5.x;
          float4 tmpvar_14;
          tmpvar_14.x = worldTangent_2.y;
          tmpvar_14.y = tmpvar_12.y;
          tmpvar_14.z = worldNormal_3.y;
          tmpvar_14.w = tmpvar_5.y;
          float4 tmpvar_15;
          tmpvar_15.x = worldTangent_2.z;
          tmpvar_15.y = tmpvar_12.z;
          tmpvar_15.z = worldNormal_3.z;
          tmpvar_15.w = tmpvar_5.z;
          tmpvar_4 = in_v.texcoord.xy;
          float4 tmpvar_16;
          float4 wPos_17;
          wPos_17 = tmpvar_6;
          if((unity_LightShadowBias.z!=0))
          {
              float3x3 tmpvar_18;
              tmpvar_18[0] = conv_mxt4x4_0(unity_WorldToObject).xyz;
              tmpvar_18[1] = conv_mxt4x4_1(unity_WorldToObject).xyz;
              tmpvar_18[2] = conv_mxt4x4_2(unity_WorldToObject).xyz;
              float3 tmpvar_19;
              tmpvar_19 = normalize(mul(in_v.normal, tmpvar_18));
              float tmpvar_20;
              tmpvar_20 = dot(tmpvar_19, normalize((_WorldSpaceLightPos0.xyz - (tmpvar_6.xyz * _WorldSpaceLightPos0.w))));
              wPos_17.xyz = (tmpvar_6.xyz - (tmpvar_19 * (unity_LightShadowBias.z * sqrt((1 - (tmpvar_20 * tmpvar_20))))));
          }
          tmpvar_16 = mul(unity_MatrixVP, wPos_17);
          float4 clipPos_21;
          clipPos_21.xyw = tmpvar_16.xyw;
          clipPos_21.z = (tmpvar_16.z + clamp((unity_LightShadowBias.x / tmpvar_16.w), 0, 1));
          clipPos_21.z = lerp(clipPos_21.z, max(clipPos_21.z, (-tmpvar_16.w)), unity_LightShadowBias.y);
          out_v.vertex = clipPos_21;
          out_v.xlv_TEXCOORD1 = tmpvar_4;
          out_v.xlv_TEXCOORD2 = tmpvar_13;
          out_v.xlv_TEXCOORD3 = tmpvar_14;
          out_v.xlv_TEXCOORD4 = tmpvar_15;
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
  FallBack "Diffuse"
}
