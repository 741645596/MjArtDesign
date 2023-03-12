Shader "Obi/URP/GpuParticles"
{
  Properties
  {
    _Color ("Particle color", Color) = (1,1,1,1)
    _RadiusScale ("Radius scale", float) = 1
  }
  SubShader
  {
    Tags
    { 
      "RenderPipeline" = "UniversalRenderPipeline"
    }
    Pass 
    {
      Name "ParticleFwdBase"
      /*Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "UniversalForward"
        "QUEUE" = "Geometry"
        "RenderPipeline" = "UniversalRenderPipeline"
        "RenderType" = "Opaque"
      }*/
      Blend SrcAlpha OneMinusSrcAlpha
      // m_ProgramMask = 6
      CGPROGRAM
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #define conv_mxt4x4_0(mat4x4) float4(mat4x4[0].x,mat4x4[1].x,mat4x4[2].x,mat4x4[3].x)
      #define conv_mxt4x4_1(mat4x4) float4(mat4x4[0].y,mat4x4[1].y,mat4x4[2].y,mat4x4[3].y)
      #define conv_mxt4x4_2(mat4x4) float4(mat4x4[0].z,mat4x4[1].z,mat4x4[2].z,mat4x4[3].z)
      #define conv_mxt4x4_3(mat4x4) float4(mat4x4[0].w,mat4x4[1].w,mat4x4[2].w,mat4x4[3].w)
      
      
      #define CODE_BLOCK_VERTEX
      uniform float4 _MainLightPosition;
      //uniform float4x4 UNITY_MATRIX_P;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixInvV;
      //uniform float4x4 unity_MatrixVP;
      uniform float _RadiusScale;
      uniform float4x4 _LocalToWorldMatrix;
      uniform float4x4 _LocalToWorldRotationMatrix;
      uniform float _MaxScale;
      uniform float4 _Color;
      uniform float4 _LightColor0;
      struct appdata_t
      {
          float3 normal :NORMAL0;
          float4 color :COLOR0;
      };
      
      struct OUT_Data_Vert
      {
          float4 color :COLOR0;
          float4 texcoord :TEXCOORD0;
          float3 texcoord1 :TEXCOORD1;
          float3 texcoord2 :TEXCOORD2;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 color :COLOR0;
          float4 texcoord :TEXCOORD0;
          float3 texcoord1 :TEXCOORD1;
          float3 texcoord2 :TEXCOORD2;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
      };
      
      struct OUT_Data_Frag
      {
          float SV_Depth :SV_Depth;
          float4 color :SV_Target0;
      };
      
      //uniform UnityPerDraw;
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
      uniform graphicsCBufferPos;
      #endif
      uniform float4 _GraphicsCBufferPos[250];
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      uniform graphicsCBufferAnisotropy;
      #endif
      uniform float4 _GraphicsCBufferAnisotropy[750];
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0;
      uint u_xlatu0;
      float4 u_xlat1;
      float4 u_xlat2;
      float4 u_xlat3;
      int2 u_xlati3;
      float3 u_xlat4;
      float3 u_xlat5;
      float4 u_xlat6;
      float3 u_xlat7;
      float3 u_xlat8;
      float3 u_xlat9;
      float3 u_xlat10;
      float3 u_xlat11;
      float3 u_xlat12;
      float3 u_xlat13;
      float3 u_xlat14;
      float3 u_xlat15;
      float u_xlat16;
      float3 u_xlat18;
      float u_xlat19;
      float3 u_xlat20;
      float u_xlat32;
      int u_xlati32;
      float u_xlat35;
      int u_xlatb48;
      float u_xlat50;
      int u_xlati50;
      float4x4 TempArray0;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          conv_mxt4x4_0(TempArray0).xy = float2(1, 1);
          conv_mxt4x4_1(TempArray0).xy = float2(-1, 1);
          conv_mxt4x4_2(TempArray0).xy = float2(-1, (-1));
          conv_mxt4x4_3(TempArray0).xy = float2(1, (-1));
          u_xlatu0 = uint(in_v.normal.y);
          u_xlat0.xy = conv_mxt4x4_int(u_xlatu0)(TempArray0).xy;
          u_xlati32 = int(in_v.normal.x);
          u_xlat1 = (conv_mxt4x4_1(_LocalToWorldMatrix) * _GraphicsCBufferPos[u_xlati32].yyyy);
          u_xlat1 = ((conv_mxt4x4_0(_LocalToWorldMatrix) * _GraphicsCBufferPos[u_xlati32].xxxx) + u_xlat1);
          u_xlat1 = ((conv_mxt4x4_2(_LocalToWorldMatrix) * _GraphicsCBufferPos[u_xlati32].zzzz) + u_xlat1);
          u_xlat1 = (u_xlat1 + conv_mxt4x4_3(_LocalToWorldMatrix));
          u_xlat2.xy = (u_xlat1.yy * conv_mxt4x4_1(unity_MatrixV).xy);
          u_xlat2.xy = ((conv_mxt4x4_0(unity_MatrixV).xy * u_xlat1.xx) + u_xlat2.xy);
          u_xlat2.xy = ((conv_mxt4x4_2(unity_MatrixV).xy * u_xlat1.zz) + u_xlat2.xy);
          u_xlat2.xy = (u_xlat2.xy + conv_mxt4x4_3(unity_MatrixV).xy);
          u_xlat18.xyz = (u_xlat2.yyy * conv_mxt4x4_1(unity_MatrixInvV).xyz);
          u_xlat2.xyz = ((conv_mxt4x4_0(unity_MatrixInvV).xyz * u_xlat2.xxx) + u_xlat18.xyz);
          u_xlat2.xyz = (u_xlat2.xyz + conv_mxt4x4_3(unity_MatrixInvV).xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlatb48 = (conv_mxt4x4_2(UNITY_MATRIX_P).w==0);
          #else
          u_xlatb48 = (conv_mxt4x4_2(UNITY_MATRIX_P).w==0);
          #endif
          u_xlat2.xyz = (int(u_xlatb48))?(u_xlat2.xyz):(conv_mxt4x4_3(unity_MatrixInvV).xyz);
          u_xlat2.xyz = ((-u_xlat1.xyz) + u_xlat2.xyz);
          u_xlati50 = (u_xlati32 * 3);
          u_xlati3.xy = float2(((int2(u_xlati32, u_xlati32) * int2(3, 3)) + int2(1, 2)));
          u_xlat32 = (_MaxScale * _GraphicsCBufferAnisotropy[u_xlati50].w);
          u_xlat32 = (u_xlat32 * _RadiusScale);
          u_xlat35 = (float(1) / u_xlat32);
          u_xlat4.xyz = (conv_mxt4x4_1(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati50].yyy);
          u_xlat4.xyz = ((conv_mxt4x4_0(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati50].xxx) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_2(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati50].zzz) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_3(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati50].www) + u_xlat4.xyz);
          u_xlat5.xyz = (float3(u_xlat35, u_xlat35, u_xlat35) * u_xlat4.xyz);
          u_xlat6.xyz = (conv_mxt4x4_1(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.x].yyy);
          u_xlat6.xyz = ((conv_mxt4x4_0(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.x].xxx) + u_xlat6.xyz);
          u_xlat6.xyz = ((conv_mxt4x4_2(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.x].zzz) + u_xlat6.xyz);
          u_xlat6.xyz = ((conv_mxt4x4_3(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.x].www) + u_xlat6.xyz);
          u_xlat50 = (_MaxScale * _GraphicsCBufferAnisotropy[u_xlati3.x].w);
          u_xlat50 = (u_xlat50 * _RadiusScale);
          u_xlat3.x = (float(1) / u_xlat50);
          u_xlat7.xyz = (float3(u_xlat50, u_xlat50, u_xlat50) * u_xlat6.xyz);
          u_xlat3.xzw = (u_xlat3.xxx * u_xlat6.xyz);
          u_xlat8.xyz = (u_xlat6.yyy * u_xlat3.xzw);
          u_xlat8.xyz = ((u_xlat5.xyz * u_xlat4.yyy) + u_xlat8.xyz);
          u_xlat9.xyz = (conv_mxt4x4_1(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.y].yyy);
          u_xlat9.xyz = ((conv_mxt4x4_0(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.y].xxx) + u_xlat9.xyz);
          u_xlat9.xyz = ((conv_mxt4x4_2(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.y].zzz) + u_xlat9.xyz);
          u_xlat9.xyz = ((conv_mxt4x4_3(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.y].www) + u_xlat9.xyz);
          u_xlat50 = (_MaxScale * _GraphicsCBufferAnisotropy[u_xlati3.y].w);
          u_xlat50 = (u_xlat50 * _RadiusScale);
          u_xlat19 = (float(1) / u_xlat50);
          u_xlat10.xyz = (float3(u_xlat50, u_xlat50, u_xlat50) * u_xlat9.xyz);
          u_xlat11.xyz = (float3(u_xlat19, u_xlat19, u_xlat19) * u_xlat9.xyz);
          u_xlat8.xyz = ((u_xlat11.xyz * u_xlat9.yyy) + u_xlat8.xyz);
          u_xlat12.xyz = (u_xlat2.yyy * u_xlat8.xyz);
          u_xlat13.xyz = (u_xlat6.xxx * u_xlat3.xzw);
          u_xlat3.xyz = (u_xlat6.zzz * u_xlat3.xzw);
          u_xlat3.xyz = ((u_xlat5.xyz * u_xlat4.zzz) + u_xlat3.xyz);
          u_xlat5.xyz = ((u_xlat5.xyz * u_xlat4.xxx) + u_xlat13.xyz);
          u_xlat5.xyz = ((u_xlat11.xyz * u_xlat9.xxx) + u_xlat5.xyz);
          u_xlat3.xyz = ((u_xlat11.xyz * u_xlat9.zzz) + u_xlat3.xyz);
          u_xlat2.xyw = ((u_xlat5.xyz * u_xlat2.xxx) + u_xlat12.xyz);
          u_xlat2.xyz = ((u_xlat3.xyz * u_xlat2.zzz) + u_xlat2.xyw);
          u_xlat11.x = conv_mxt4x4_2(unity_MatrixV).y;
          u_xlat11.y = conv_mxt4x4_0(unity_MatrixV).y;
          u_xlat11.z = conv_mxt4x4_1(unity_MatrixV).y;
          u_xlat12.xyz = ((-u_xlat2.xyz) * u_xlat11.xyz);
          u_xlat11.xyz = (((-u_xlat2.zxy) * u_xlat11.yzx) + (-u_xlat12.xyz));
          u_xlat11.xyz = normalize(u_xlat11.xyz);
          u_xlat12.xyz = ((-u_xlat2.zxy) * u_xlat11.xyz);
          u_xlat12.xyz = (((-u_xlat2.yzx) * u_xlat11.yzx) + (-u_xlat12.xyz));
          u_xlat12.xyz = normalize(u_xlat12.xyz);
          u_xlat13.xyz = (u_xlat6.yyy * u_xlat7.xyz);
          u_xlat14.xyz = (float3(u_xlat32, u_xlat32, u_xlat32) * u_xlat4.xyz);
          u_xlat13.xyz = ((u_xlat14.xyz * u_xlat4.yyy) + u_xlat13.xyz);
          u_xlat13.xyz = ((u_xlat10.xyz * u_xlat9.yyy) + u_xlat13.xyz);
          u_xlat15.xyz = (u_xlat12.yyy * u_xlat13.xyz);
          u_xlat6.xyw = (u_xlat6.xxx * u_xlat7.xyz);
          u_xlat7.xyz = (u_xlat6.zzz * u_xlat7.xyz);
          u_xlat20.xyz = ((u_xlat14.xyz * u_xlat4.zzz) + u_xlat7.xyz);
          u_xlat6.xyz = ((u_xlat14.xyz * u_xlat4.xxx) + u_xlat6.xyw);
          u_xlat6.xyz = ((u_xlat10.xyz * u_xlat9.xxx) + u_xlat6.xyz);
          u_xlat4.xyz = ((u_xlat10.xyz * u_xlat9.zzz) + u_xlat20.xyz);
          u_xlat7.xyz = ((u_xlat6.xyz * u_xlat12.xxx) + u_xlat15.xyz);
          u_xlat7.xyz = ((u_xlat4.xyz * u_xlat12.zzz) + u_xlat7.xyz);
          u_xlat7.xyz = (u_xlat0.yyy * u_xlat7.xyz);
          u_xlat9.xyz = (u_xlat11.xxx * u_xlat13.xyz);
          u_xlat9.xyz = ((u_xlat6.xyz * u_xlat11.zzz) + u_xlat9.xyz);
          u_xlat9.xyz = ((u_xlat4.xyz * u_xlat11.yyy) + u_xlat9.xyz);
          u_xlat7.xyz = ((u_xlat9.xyz * u_xlat0.xxx) + u_xlat7.xyz);
          out_v.texcoord.xy = u_xlat0.xy;
          u_xlat0.x = dot(u_xlat2.xyz, u_xlat2.xyz);
          u_xlat16 = (float(1) / u_xlat0.x);
          u_xlat0.x = sqrt(u_xlat0.x);
          out_v.texcoord.z = (float(1) / u_xlat0.x);
          u_xlat2.xyz = (u_xlat2.xyz * float3(u_xlat16, u_xlat16, u_xlat16));
          u_xlat0.x = ((-u_xlat16) + 1);
          u_xlat2.w = sqrt(u_xlat0.x);
          u_xlat2 = (int(u_xlatb48))?(float4(0, 0, 0, 1)):(u_xlat2);
          u_xlat0.xyz = (u_xlat2.yyy * u_xlat13.xyz);
          u_xlat0.xyz = ((u_xlat6.xyz * u_xlat2.xxx) + u_xlat0.xyz);
          u_xlat0.xyz = ((u_xlat4.xyz * u_xlat2.zzz) + u_xlat0.xyz);
          u_xlat0.xyz = (u_xlat0.xyz + u_xlat1.xyz);
          u_xlat0.xyz = ((u_xlat2.www * u_xlat7.xyz) + u_xlat0.xyz);
          out_v.texcoord.w = u_xlat2.w;
          out_v.vertex = mul(unity_MatrixVP, u_xlat0);
          out_v.color = (in_v.color * _Color);
          u_xlat2.xy = (u_xlat0.yy * conv_mxt4x4_1(unity_MatrixV).xy);
          u_xlat2.xy = ((conv_mxt4x4_0(unity_MatrixV).xy * u_xlat0.xx) + u_xlat2.xy);
          u_xlat2.xy = ((conv_mxt4x4_2(unity_MatrixV).xy * u_xlat0.zz) + u_xlat2.xy);
          u_xlat2.xy = (u_xlat2.xy + conv_mxt4x4_3(unity_MatrixV).xy);
          u_xlat18.xyz = (u_xlat2.yyy * conv_mxt4x4_1(unity_MatrixInvV).xyz);
          u_xlat2.xyz = ((conv_mxt4x4_0(unity_MatrixInvV).xyz * u_xlat2.xxx) + u_xlat18.xyz);
          u_xlat2.xyz = (u_xlat2.xyz + conv_mxt4x4_3(unity_MatrixInvV).xyz);
          u_xlat2.xyz = (int(u_xlatb48))?(u_xlat2.xyz):(conv_mxt4x4_3(unity_MatrixInvV).xyz);
          u_xlat0.xyz = (u_xlat0.xyz + (-u_xlat2.xyz));
          u_xlat2.xyz = ((-u_xlat1.xyz) + u_xlat2.xyz);
          u_xlat4.xyz = (u_xlat0.yyy * conv_mxt4x4_1(unity_MatrixV).xyz);
          u_xlat4.xyz = ((conv_mxt4x4_0(unity_MatrixV).xyz * u_xlat0.xxx) + u_xlat4.xyz);
          out_v.texcoord1.xyz = ((conv_mxt4x4_2(unity_MatrixV).xyz * u_xlat0.zzz) + u_xlat4.xyz);
          u_xlat4.xyz = (_MainLightPosition.yyy * conv_mxt4x4_1(unity_WorldToObject).xyz);
          u_xlat4.xyz = ((conv_mxt4x4_0(unity_WorldToObject).xyz * _MainLightPosition.xxx) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_2(unity_WorldToObject).xyz * _MainLightPosition.zzz) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_3(unity_WorldToObject).xyz * _MainLightPosition.www) + u_xlat4.xyz);
          u_xlat1.xyz = (((-u_xlat1.xyz) * _MainLightPosition.www) + u_xlat4.xyz);
          u_xlat4.xyz = mul(unity_ObjectToWorld, unity_MatrixV[0]);
          u_xlat4.xyz = (u_xlat1.yyy * u_xlat4.xyz);
          u_xlat6.xyz = (conv_mxt4x4_1(unity_MatrixV).xyz * conv_mxt4x4_0(unity_ObjectToWorld).yyy);
          u_xlat6.xyz = ((conv_mxt4x4_0(unity_MatrixV).xyz * conv_mxt4x4_0(unity_ObjectToWorld).xxx) + u_xlat6.xyz);
          u_xlat6.xyz = ((conv_mxt4x4_2(unity_MatrixV).xyz * conv_mxt4x4_0(unity_ObjectToWorld).zzz) + u_xlat6.xyz);
          u_xlat6.xyz = ((conv_mxt4x4_3(unity_MatrixV).xyz * conv_mxt4x4_0(unity_ObjectToWorld).www) + u_xlat6.xyz);
          u_xlat1.xyw = ((u_xlat6.xyz * u_xlat1.xxx) + u_xlat4.xyz);
          u_xlat4.xyz = (conv_mxt4x4_1(unity_MatrixV).xyz * conv_mxt4x4_2(unity_ObjectToWorld).yyy);
          u_xlat4.xyz = ((conv_mxt4x4_0(unity_MatrixV).xyz * conv_mxt4x4_2(unity_ObjectToWorld).xxx) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_2(unity_MatrixV).xyz * conv_mxt4x4_2(unity_ObjectToWorld).zzz) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_3(unity_MatrixV).xyz * conv_mxt4x4_2(unity_ObjectToWorld).www) + u_xlat4.xyz);
          out_v.texcoord2.xyz = ((u_xlat4.xyz * u_xlat1.zzz) + u_xlat1.xyw);
          u_xlat1.xyz = (u_xlat2.yyy * u_xlat8.xyz);
          u_xlat1.xyz = ((u_xlat5.xyz * u_xlat2.xxx) + u_xlat1.xyz);
          u_xlat1.xyz = ((u_xlat3.xyz * u_xlat2.zzz) + u_xlat1.xyz);
          u_xlat2.xyz = (u_xlat1.yyy * u_xlat8.xyz);
          u_xlat1.xyw = ((u_xlat5.xyz * u_xlat1.xxx) + u_xlat2.xyz);
          u_xlat1.xyz = ((u_xlat3.xyz * u_xlat1.zzz) + u_xlat1.xyw);
          u_xlat2.xyz = (u_xlat1.yyy * conv_mxt4x4_1(unity_MatrixV).xyz);
          u_xlat1.xyw = ((conv_mxt4x4_0(unity_MatrixV).xyz * u_xlat1.xxx) + u_xlat2.xyz);
          out_v.texcoord3.xyz = ((conv_mxt4x4_2(unity_MatrixV).xyz * u_xlat1.zzz) + u_xlat1.xyw);
          u_xlat1.xyz = (u_xlat0.yyy * u_xlat8.xyz);
          u_xlat0.xyw = ((u_xlat5.xyz * u_xlat0.xxx) + u_xlat1.xyz);
          u_xlat0.xyz = ((u_xlat3.xyz * u_xlat0.zzz) + u_xlat0.xyw);
          u_xlat1.xyz = (u_xlat0.yyy * u_xlat8.xyz);
          u_xlat0.xyw = ((u_xlat5.xyz * u_xlat0.xxx) + u_xlat1.xyz);
          u_xlat0.xyz = ((u_xlat3.xyz * u_xlat0.zzz) + u_xlat0.xyw);
          u_xlat1.xyz = (u_xlat0.yyy * conv_mxt4x4_1(unity_MatrixV).xyz);
          u_xlat0.xyw = ((conv_mxt4x4_0(unity_MatrixV).xyz * u_xlat0.xxx) + u_xlat1.xyz);
          out_v.texcoord4.xyz = ((conv_mxt4x4_2(unity_MatrixV).xyz * u_xlat0.zzz) + u_xlat0.xyw);
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      //uniform UnityPerDraw;
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
      float4 u_xlat0_d;
      float4 u_xlat1_d;
      float4 u_xlat2_d;
      float3 u_xlat16_3;
      float4 u_xlat16_4;
      float3 u_xlat16_5;
      float3 u_xlat6_d;
      int u_xlatb6;
      float u_xlat18_d;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat0_d.x = dot(in_f.texcoord.xy, in_f.texcoord.xy);
          u_xlat0_d.x = (u_xlat0_d.x / in_f.texcoord.w);
          u_xlat0_d.x = ((-u_xlat0_d.x) + 1);
          #ifdef UNITY_ADRENO_ES3
          u_xlatb6 = (u_xlat0_d.x<0);
          #else
          u_xlatb6 = (u_xlat0_d.x<0);
          #endif
          u_xlat0_d.x = sqrt(u_xlat0_d.x);
          u_xlat0_d.x = ((in_f.texcoord.z * u_xlat0_d.x) + 1);
          u_xlat0_d.x = (float(1) / u_xlat0_d.x);
          if(u_xlatb6)
          {
              discard;
          }
          u_xlat6_d.xyz = ((u_xlat0_d.xxx * in_f.texcoord4.xyz) + in_f.texcoord3.xyz);
          u_xlat1_d.xyz = (u_xlat0_d.xxx * in_f.texcoord1.xyz);
          u_xlat0_d.x = dot(u_xlat6_d.xyz, u_xlat6_d.xyz);
          u_xlat0_d.x = rsqrt(u_xlat0_d.x);
          u_xlat0_d.xyz = (u_xlat0_d.xxx * u_xlat6_d.xyz);
          u_xlat2_d = (u_xlat0_d.yyyy * conv_mxt4x4_1(unity_MatrixInvV).xyzz);
          u_xlat2_d = ((conv_mxt4x4_0(unity_MatrixInvV).xyzz * u_xlat0_d.xxxx) + u_xlat2_d);
          u_xlat2_d = ((conv_mxt4x4_2(unity_MatrixInvV).xyzz * u_xlat0_d.zzzz) + u_xlat2_d.xywz);
          u_xlat16_3.x = (u_xlat2_d.y * u_xlat2_d.y);
          u_xlat16_3.x = ((u_xlat2_d.x * u_xlat2_d.x) + (-u_xlat16_3.x));
          u_xlat16_4 = (u_xlat2_d.yzwx * u_xlat2_d.xywz);
          u_xlat16_5.x = dot(unity_SHBr, u_xlat16_4);
          u_xlat16_5.y = dot(unity_SHBg, u_xlat16_4);
          u_xlat16_5.z = dot(unity_SHBb, u_xlat16_4);
          u_xlat16_3.xyz = ((unity_SHC.xyz * u_xlat16_3.xxx) + u_xlat16_5.xyz);
          u_xlat2_d.w = 1;
          u_xlat16_4.x = dot(unity_SHAr, u_xlat2_d);
          u_xlat16_4.y = dot(unity_SHAg, u_xlat2_d);
          u_xlat16_4.z = dot(unity_SHAb, u_xlat2_d);
          u_xlat16_3.xyz = (u_xlat16_3.xyz + u_xlat16_4.xyz);
          u_xlat16_3.xyz = max(u_xlat16_3.xyz, float3(0, 0, 0));
          u_xlat2_d.xyz = normalize(in_f.texcoord2.xyz);
          u_xlat0_d.x = dot(u_xlat0_d.xyz, u_xlat2_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat0_d.x = min(max(u_xlat0_d.x, 0), 1);
          #else
          u_xlat0_d.x = clamp(u_xlat0_d.x, 0, 1);
          #endif
          u_xlat0_d.xyz = (u_xlat0_d.xxx * _LightColor0.xyz);
          u_xlat0_d.xyz = ((u_xlat0_d.xyz * unity_LightData.zzz) + u_xlat16_3.xyz);
          u_xlat0_d.xyz = (u_xlat0_d.xyz * in_f.color.xyz);
          u_xlat0_d.w = in_f.color.w;
          out_f.color = u_xlat0_d;
          u_xlat0_d.x = conv_mxt4x4_0(UNITY_MATRIX_P).z;
          u_xlat0_d.y = conv_mxt4x4_1(UNITY_MATRIX_P).z;
          u_xlat0_d.z = conv_mxt4x4_2(UNITY_MATRIX_P).z;
          u_xlat0_d.w = conv_mxt4x4_3(UNITY_MATRIX_P).z;
          u_xlat1_d.w = 1;
          u_xlat0_d.x = dot(u_xlat0_d, u_xlat1_d);
          u_xlat1_d.x = conv_mxt4x4_2(UNITY_MATRIX_P).w;
          u_xlat1_d.y = conv_mxt4x4_3(UNITY_MATRIX_P).w;
          u_xlat6_d.x = dot(u_xlat1_d.xy, u_xlat1_d.zw);
          u_xlat0_d.x = (u_xlat0_d.x / u_xlat6_d.x);
          out_f.SV_Depth = ((u_xlat0_d.x * 0.5) + 0.5);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: ShadowCaster
    {
      Name "ShadowCaster"
      Tags
      { 
        "LIGHTMODE" = "SHADOWCASTER"
        "RenderPipeline" = "UniversalRenderPipeline"
        "SHADOWSUPPORT" = "true"
      }
      Offset 1, 1
      Fog
      { 
        Mode  Off
      } 
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
      #define conv_mxt4x4_3(mat4x4) float4(mat4x4[0].w,mat4x4[1].w,mat4x4[2].w,mat4x4[3].w)
      
      
      #define CODE_BLOCK_VERTEX
      uniform float4 _MainLightPosition;
      //uniform float4x4 UNITY_MATRIX_P;
      //uniform float4x4 unity_MatrixV;
      //uniform float4x4 unity_MatrixInvV;
      //uniform float4x4 unity_MatrixVP;
      uniform float _RadiusScale;
      uniform float4x4 _LocalToWorldMatrix;
      uniform float4x4 _LocalToWorldRotationMatrix;
      uniform float _MaxScale;
      uniform float4 _Color;
      uniform float4 _ShadowBias;
      struct appdata_t
      {
          float3 normal :NORMAL0;
          float4 color :COLOR0;
      };
      
      struct OUT_Data_Vert
      {
          float4 color :COLOR0;
          float4 texcoord :TEXCOORD0;
          float3 texcoord1 :TEXCOORD1;
          float3 texcoord2 :TEXCOORD2;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
          float4 vertex :SV_POSITION;
      };
      
      struct v2f
      {
          float4 texcoord :TEXCOORD0;
          float3 texcoord1 :TEXCOORD1;
          float3 texcoord2 :TEXCOORD2;
          float3 texcoord3 :TEXCOORD3;
          float3 texcoord4 :TEXCOORD4;
      };
      
      struct OUT_Data_Frag
      {
          float SV_Depth :SV_Depth;
          float4 color :SV_Target0;
      };
      
      //uniform UnityPerDraw;
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
      uniform graphicsCBufferPos;
      #endif
      uniform float4 _GraphicsCBufferPos[250];
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      uniform graphicsCBufferAnisotropy;
      #endif
      uniform float4 _GraphicsCBufferAnisotropy[750];
      #if HLSLCC_ENABLE_UNIFORM_BUFFERS
      float4 u_xlat0;
      uint u_xlatu0;
      float4 u_xlat1;
      float4 u_xlat2;
      float4 u_xlat3;
      int2 u_xlati3;
      float4 u_xlat4;
      float3 u_xlat5;
      float4 u_xlat6;
      float4 u_xlat7;
      float3 u_xlat8;
      float3 u_xlat9;
      float3 u_xlat10;
      float4 u_xlat11;
      float3 u_xlat12;
      float3 u_xlat13;
      float3 u_xlat16;
      float u_xlat17;
      float u_xlat28;
      int u_xlati28;
      float u_xlat31;
      int u_xlatb42;
      float u_xlat44;
      int u_xlati44;
      float u_xlat45;
      float4x4 TempArray0;
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          conv_mxt4x4_0(TempArray0).xy = float2(1, 1);
          conv_mxt4x4_1(TempArray0).xy = float2(-1, 1);
          conv_mxt4x4_2(TempArray0).xy = float2(-1, (-1));
          conv_mxt4x4_3(TempArray0).xy = float2(1, (-1));
          out_v.color = (in_v.color * _Color);
          u_xlatu0 = uint(in_v.normal.y);
          u_xlat0.xy = conv_mxt4x4_int(u_xlatu0)(TempArray0).xy;
          out_v.texcoord.xy = u_xlat0.xy;
          u_xlati28 = int(in_v.normal.x);
          u_xlat1 = (conv_mxt4x4_1(_LocalToWorldMatrix) * _GraphicsCBufferPos[u_xlati28].yyyy);
          u_xlat1 = ((conv_mxt4x4_0(_LocalToWorldMatrix) * _GraphicsCBufferPos[u_xlati28].xxxx) + u_xlat1);
          u_xlat1 = ((conv_mxt4x4_2(_LocalToWorldMatrix) * _GraphicsCBufferPos[u_xlati28].zzzz) + u_xlat1);
          u_xlat1 = (u_xlat1 + conv_mxt4x4_3(_LocalToWorldMatrix));
          u_xlat2.xy = (u_xlat1.yy * conv_mxt4x4_1(unity_MatrixV).xy);
          u_xlat2.xy = ((conv_mxt4x4_0(unity_MatrixV).xy * u_xlat1.xx) + u_xlat2.xy);
          u_xlat2.xy = ((conv_mxt4x4_2(unity_MatrixV).xy * u_xlat1.zz) + u_xlat2.xy);
          u_xlat2.xy = (u_xlat2.xy + conv_mxt4x4_3(unity_MatrixV).xy);
          u_xlat16.xyz = (u_xlat2.yyy * conv_mxt4x4_1(unity_MatrixInvV).xyz);
          u_xlat2.xyz = ((conv_mxt4x4_0(unity_MatrixInvV).xyz * u_xlat2.xxx) + u_xlat16.xyz);
          u_xlat2.xyz = (u_xlat2.xyz + conv_mxt4x4_3(unity_MatrixInvV).xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlatb42 = (conv_mxt4x4_2(UNITY_MATRIX_P).w==0);
          #else
          u_xlatb42 = (conv_mxt4x4_2(UNITY_MATRIX_P).w==0);
          #endif
          u_xlat2.xyz = (int(u_xlatb42))?(u_xlat2.xyz):(conv_mxt4x4_3(unity_MatrixInvV).xyz);
          u_xlat2.xyz = ((-u_xlat1.xyz) + u_xlat2.xyz);
          u_xlati44 = (u_xlati28 * 3);
          u_xlati3.xy = float2(((int2(u_xlati28, u_xlati28) * int2(3, 3)) + int2(1, 2)));
          u_xlat28 = (_MaxScale * _GraphicsCBufferAnisotropy[u_xlati44].w);
          u_xlat28 = (u_xlat28 * _RadiusScale);
          u_xlat31 = (float(1) / u_xlat28);
          u_xlat4.xyz = (conv_mxt4x4_1(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati44].yyy);
          u_xlat4.xyz = ((conv_mxt4x4_0(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati44].xxx) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_2(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati44].zzz) + u_xlat4.xyz);
          u_xlat4.xyz = ((conv_mxt4x4_3(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati44].www) + u_xlat4.xyz);
          u_xlat5.xyz = (float3(u_xlat31, u_xlat31, u_xlat31) * u_xlat4.xyz);
          u_xlat6.xyz = (conv_mxt4x4_1(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.x].yyy);
          u_xlat6.xyz = ((conv_mxt4x4_0(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.x].xxx) + u_xlat6.xyz);
          u_xlat6.xyz = ((conv_mxt4x4_2(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.x].zzz) + u_xlat6.xyz);
          u_xlat6.xyz = ((conv_mxt4x4_3(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.x].www) + u_xlat6.xyz);
          u_xlat44 = (_MaxScale * _GraphicsCBufferAnisotropy[u_xlati3.x].w);
          u_xlat44 = (u_xlat44 * _RadiusScale);
          u_xlat3.x = (float(1) / u_xlat44);
          u_xlat7.xyz = (float3(u_xlat44, u_xlat44, u_xlat44) * u_xlat6.xyz);
          u_xlat3.xzw = (u_xlat3.xxx * u_xlat6.xyz);
          u_xlat8.xyz = (u_xlat6.yyy * u_xlat3.xzw);
          u_xlat8.xyz = ((u_xlat5.xyz * u_xlat4.yyy) + u_xlat8.xyz);
          u_xlat9.xyz = (conv_mxt4x4_1(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.y].yyy);
          u_xlat9.xyz = ((conv_mxt4x4_0(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.y].xxx) + u_xlat9.xyz);
          u_xlat9.xyz = ((conv_mxt4x4_2(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.y].zzz) + u_xlat9.xyz);
          u_xlat9.xyz = ((conv_mxt4x4_3(_LocalToWorldRotationMatrix).xyz * _GraphicsCBufferAnisotropy[u_xlati3.y].www) + u_xlat9.xyz);
          u_xlat44 = (_MaxScale * _GraphicsCBufferAnisotropy[u_xlati3.y].w);
          u_xlat44 = (u_xlat44 * _RadiusScale);
          u_xlat17 = (float(1) / u_xlat44);
          u_xlat10.xyz = (float3(u_xlat44, u_xlat44, u_xlat44) * u_xlat9.xyz);
          u_xlat11.xyz = (float3(u_xlat17, u_xlat17, u_xlat17) * u_xlat9.xyz);
          u_xlat8.xyz = ((u_xlat11.xyz * u_xlat9.yyy) + u_xlat8.xyz);
          u_xlat12.xyz = (u_xlat2.yyy * u_xlat8.xyz);
          u_xlat13.xyz = (u_xlat6.xxx * u_xlat3.xzw);
          u_xlat3.xyz = (u_xlat6.zzz * u_xlat3.xzw);
          u_xlat3.xyz = ((u_xlat5.xyz * u_xlat4.zzz) + u_xlat3.xyz);
          u_xlat5.xyz = ((u_xlat5.xyz * u_xlat4.xxx) + u_xlat13.xyz);
          u_xlat5.xyz = ((u_xlat11.xyz * u_xlat9.xxx) + u_xlat5.xyz);
          u_xlat3.xyz = ((u_xlat11.xyz * u_xlat9.zzz) + u_xlat3.xyz);
          u_xlat2.xyw = ((u_xlat5.xyz * u_xlat2.xxx) + u_xlat12.xyz);
          u_xlat2.xyz = ((u_xlat3.xyz * u_xlat2.zzz) + u_xlat2.xyw);
          u_xlat44 = dot(u_xlat2.xyz, u_xlat2.xyz);
          u_xlat45 = (float(1) / u_xlat44);
          u_xlat44 = sqrt(u_xlat44);
          out_v.texcoord.z = (float(1) / u_xlat44);
          u_xlat11.xyz = (u_xlat2.xyz * float3(u_xlat45, u_xlat45, u_xlat45));
          u_xlat44 = ((-u_xlat45) + 1);
          u_xlat11.w = sqrt(u_xlat44);
          u_xlat11 = (int(u_xlatb42))?(float4(0, 0, 0, 1)):(u_xlat11);
          out_v.texcoord.w = u_xlat11.w;
          u_xlat12.xyz = (u_xlat6.xxx * u_xlat7.xyz);
          u_xlat13.xyz = (float3(u_xlat28, u_xlat28, u_xlat28) * u_xlat4.xyz);
          u_xlat12.xyz = ((u_xlat13.xyz * u_xlat4.xxx) + u_xlat12.xyz);
          u_xlat12.xyz = ((u_xlat10.xyz * u_xlat9.xxx) + u_xlat12.xyz);
          u_xlat6.xyw = (u_xlat6.yyy * u_xlat7.xyz);
          u_xlat7.xyz = (u_xlat6.zzz * u_xlat7.xyz);
          u_xlat4.xzw = ((u_xlat13.xyz * u_xlat4.zzz) + u_xlat7.xyz);
          u_xlat6.xyz = ((u_xlat13.xyz * u_xlat4.yyy) + u_xlat6.xyw);
          u_xlat6.xyz = ((u_xlat10.xyz * u_xlat9.yyy) + u_xlat6.xyz);
          u_xlat4.xyz = ((u_xlat10.xyz * u_xlat9.zzz) + u_xlat4.xzw);
          u_xlat7.x = conv_mxt4x4_2(unity_MatrixV).y;
          u_xlat7.y = conv_mxt4x4_0(unity_MatrixV).y;
          u_xlat7.z = conv_mxt4x4_1(unity_MatrixV).y;
          u_xlat9.xyz = ((-u_xlat2.xyz) * u_xlat7.xyz);
          u_xlat7.xyz = (((-u_xlat2.zxy) * u_xlat7.yzx) + (-u_xlat9.xyz));
          u_xlat7.xyz = normalize(u_xlat7.xyz);
          u_xlat9.xyz = ((-u_xlat2.zxy) * u_xlat7.xyz);
          u_xlat2.xyz = (((-u_xlat2.yzx) * u_xlat7.yzx) + (-u_xlat9.xyz));
          u_xlat2.xyz = normalize(u_xlat2.xyz);
          u_xlat9.xyz = (u_xlat2.yyy * u_xlat6.xyz);
          u_xlat2.xyw = ((u_xlat12.xyz * u_xlat2.xxx) + u_xlat9.xyz);
          u_xlat2.xyz = ((u_xlat4.xyz * u_xlat2.zzz) + u_xlat2.xyw);
          u_xlat2.xyz = (u_xlat0.yyy * u_xlat2.xyz);
          u_xlat9.xyz = (u_xlat6.xyz * u_xlat7.xxx);
          u_xlat6.xyz = (u_xlat11.yyy * u_xlat6.xyz);
          u_xlat6.xyz = ((u_xlat12.xyz * u_xlat11.xxx) + u_xlat6.xyz);
          u_xlat7.xzw = ((u_xlat12.xyz * u_xlat7.zzz) + u_xlat9.xyz);
          u_xlat7.xyz = ((u_xlat4.xyz * u_xlat7.yyy) + u_xlat7.xzw);
          u_xlat4.xyz = ((u_xlat4.xyz * u_xlat11.zzz) + u_xlat6.xyz);
          u_xlat4.xyz = (u_xlat1.xyz + u_xlat4.xyz);
          u_xlat0.xyz = ((u_xlat7.xyz * u_xlat0.xxx) + u_xlat2.xyz);
          u_xlat0.xyz = ((u_xlat11.www * u_xlat0.xyz) + u_xlat4.xyz);
          u_xlat2.xy = (u_xlat0.yy * conv_mxt4x4_1(unity_MatrixV).xy);
          u_xlat2.xy = ((conv_mxt4x4_0(unity_MatrixV).xy * u_xlat0.xx) + u_xlat2.xy);
          u_xlat2.xy = ((conv_mxt4x4_2(unity_MatrixV).xy * u_xlat0.zz) + u_xlat2.xy);
          u_xlat2.xy = (u_xlat2.xy + conv_mxt4x4_3(unity_MatrixV).xy);
          u_xlat16.xyz = (u_xlat2.yyy * conv_mxt4x4_1(unity_MatrixInvV).xyz);
          u_xlat2.xyz = ((conv_mxt4x4_0(unity_MatrixInvV).xyz * u_xlat2.xxx) + u_xlat16.xyz);
          u_xlat2.xyz = (u_xlat2.xyz + conv_mxt4x4_3(unity_MatrixInvV).xyz);
          u_xlat2.xyz = (int(u_xlatb42))?(u_xlat2.xyz):(conv_mxt4x4_3(unity_MatrixInvV).xyz);
          u_xlat4.xyz = (u_xlat0.xyz + (-u_xlat2.xyz));
          u_xlat2.xyz = ((-u_xlat1.xyz) + u_xlat2.xyz);
          u_xlat6.xyz = (u_xlat4.yyy * conv_mxt4x4_1(unity_MatrixV).xyz);
          u_xlat6.xyz = ((conv_mxt4x4_0(unity_MatrixV).xyz * u_xlat4.xxx) + u_xlat6.xyz);
          out_v.texcoord1.xyz = ((conv_mxt4x4_2(unity_MatrixV).xyz * u_xlat4.zzz) + u_xlat6.xyz);
          u_xlat6.xyz = (u_xlat1.yyy * conv_mxt4x4_1(unity_ObjectToWorld).xyz);
          u_xlat6.xyz = ((conv_mxt4x4_0(unity_ObjectToWorld).xyz * u_xlat1.xxx) + u_xlat6.xyz);
          u_xlat1.xyz = ((conv_mxt4x4_2(unity_ObjectToWorld).xyz * u_xlat1.zzz) + u_xlat6.xyz);
          u_xlat1.xyz = ((conv_mxt4x4_3(unity_ObjectToWorld).xyz * u_xlat1.www) + u_xlat1.xyz);
          out_v.texcoord2.xyz = (((-u_xlat1.xyz) * _MainLightPosition.www) + _MainLightPosition.xyz);
          u_xlat1.xyz = (u_xlat2.yyy * u_xlat8.xyz);
          u_xlat1.xyz = ((u_xlat5.xyz * u_xlat2.xxx) + u_xlat1.xyz);
          u_xlat1.xyz = ((u_xlat3.xyz * u_xlat2.zzz) + u_xlat1.xyz);
          u_xlat2.xyz = (u_xlat1.yyy * u_xlat8.xyz);
          u_xlat2.xyz = ((u_xlat5.xyz * u_xlat1.xxx) + u_xlat2.xyz);
          u_xlat1.xyz = ((u_xlat3.xyz * u_xlat1.zzz) + u_xlat2.xyz);
          u_xlat2.xyz = (u_xlat1.yyy * conv_mxt4x4_1(unity_MatrixV).xyz);
          u_xlat2.xyz = ((conv_mxt4x4_0(unity_MatrixV).xyz * u_xlat1.xxx) + u_xlat2.xyz);
          out_v.texcoord3.xyz = ((conv_mxt4x4_2(unity_MatrixV).xyz * u_xlat1.zzz) + u_xlat2.xyz);
          u_xlat1.xyz = (u_xlat4.yyy * u_xlat8.xyz);
          u_xlat1.xyz = ((u_xlat5.xyz * u_xlat4.xxx) + u_xlat1.xyz);
          u_xlat1.xyz = ((u_xlat3.xyz * u_xlat4.zzz) + u_xlat1.xyz);
          u_xlat2.xyz = (u_xlat1.yyy * u_xlat8.xyz);
          u_xlat2.xyz = ((u_xlat5.xyz * u_xlat1.xxx) + u_xlat2.xyz);
          u_xlat1.xyz = ((u_xlat3.xyz * u_xlat1.zzz) + u_xlat2.xyz);
          u_xlat2.xyz = (u_xlat1.yyy * conv_mxt4x4_1(unity_MatrixV).xyz);
          u_xlat2.xyz = ((conv_mxt4x4_0(unity_MatrixV).xyz * u_xlat1.xxx) + u_xlat2.xyz);
          out_v.texcoord4.xyz = ((conv_mxt4x4_2(unity_MatrixV).xyz * u_xlat1.zzz) + u_xlat2.xyz);
          out_v.vertex = mul(unity_MatrixVP, u_xlat0);
          return out_v;
      }
      
      #define CODE_BLOCK_FRAGMENT
      float4 u_xlat0_d;
      float4 u_xlat1_d;
      float3 u_xlat2_d;
      float3 u_xlat3_d;
      float3 u_xlat4_d;
      int u_xlatb4;
      float u_xlat12_d;
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          u_xlat0_d.x = dot(in_f.texcoord.xy, in_f.texcoord.xy);
          u_xlat0_d.x = (u_xlat0_d.x / in_f.texcoord.w);
          u_xlat0_d.x = ((-u_xlat0_d.x) + 1);
          #ifdef UNITY_ADRENO_ES3
          u_xlatb4 = (u_xlat0_d.x<0);
          #else
          u_xlatb4 = (u_xlat0_d.x<0);
          #endif
          u_xlat0_d.x = sqrt(u_xlat0_d.x);
          u_xlat0_d.x = ((in_f.texcoord.z * u_xlat0_d.x) + 1);
          u_xlat0_d.x = (float(1) / u_xlat0_d.x);
          if(u_xlatb4)
          {
              discard;
          }
          u_xlat4_d.xyz = (u_xlat0_d.xxx * in_f.texcoord1.xyz);
          u_xlat1_d.xyz = ((u_xlat0_d.xxx * in_f.texcoord4.xyz) + in_f.texcoord3.xyz);
          u_xlat0_d.xyz = mul(unity_MatrixInvV, u_xlat4_d.xyz);
          u_xlat2_d.xyz = normalize(in_f.texcoord2.xyz);
          u_xlat0_d.xyz = ((u_xlat2_d.xyz * _ShadowBias.xxx) + u_xlat0_d.xyz);
          u_xlat1_d.xyz = normalize(u_xlat1_d.xyz);
          u_xlat3_d.xyz = (u_xlat1_d.yyy * conv_mxt4x4_1(unity_MatrixInvV).xyz);
          u_xlat1_d.xyw = ((conv_mxt4x4_0(unity_MatrixInvV).xyz * u_xlat1_d.xxx) + u_xlat3_d.xyz);
          u_xlat1_d.xyz = ((conv_mxt4x4_2(unity_MatrixInvV).xyz * u_xlat1_d.zzz) + u_xlat1_d.xyw);
          u_xlat12_d = dot(u_xlat2_d.xyz, u_xlat1_d.xyz);
          #ifdef UNITY_ADRENO_ES3
          u_xlat12_d = min(max(u_xlat12_d, 0), 1);
          #else
          u_xlat12_d = clamp(u_xlat12_d, 0, 1);
          #endif
          u_xlat12_d = ((-u_xlat12_d) + 1);
          u_xlat12_d = (u_xlat12_d * _ShadowBias.y);
          u_xlat0_d.xyz = ((u_xlat1_d.xyz * float3(u_xlat12_d, u_xlat12_d, u_xlat12_d)) + u_xlat0_d.xyz);
          u_xlat4_d.xz = (u_xlat0_d.yy * conv_mxt4x4_1(unity_MatrixVP).zw);
          u_xlat0_d.xy = ((conv_mxt4x4_0(unity_MatrixVP).zw * u_xlat0_d.xx) + u_xlat4_d.xz);
          u_xlat0_d.xy = ((conv_mxt4x4_2(unity_MatrixVP).zw * u_xlat0_d.zz) + u_xlat0_d.xy);
          u_xlat0_d.xy = (u_xlat0_d.xy + conv_mxt4x4_3(unity_MatrixVP).zw);
          u_xlat0_d.x = max((-u_xlat0_d.y), u_xlat0_d.x);
          u_xlat0_d = (u_xlat0_d.xxxx / u_xlat0_d.yyyy);
          out_f.color = u_xlat0_d;
          out_f.SV_Depth = ((u_xlat0_d.w * 0.5) + 0.5);
          return out_f;
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
