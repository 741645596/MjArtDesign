Shader "MJ/mj_tencent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _u_MainColor("MainColor", Color) = (0.99265, 0.99265, 0.99265, 1)
        _Offset("Offset", Vector) = (0, 0.3, 1.0, 1)
        _Offset2("Offset2", Vector) = (0, 0, 2.96, 1)
        _u_Intensity("Intensity", Range(0, 2)) = 0.30
        _u_Intensity2("Intensity2", Range(0, 2)) = 0.06
        _u_DiffuseIntensity("DiffuseIntensity", Range(0, 2)) = 0.50
        _u_Exp("Exp", Range(0, 200)) = 47
        _u_Exp2("Exp2", Range(0, 200)) = 48
    }
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"  }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}


            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normalOS	: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal  : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float3 offset1	: TEXCOORD3;
                float3 offset2	: TEXCOORD4;

            };


            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4  _u_MainColor;
                float _u_Intensity, _u_Intensity2, _u_DiffuseIntensity, _u_Exp, _u_Exp2;
                float4 _Offset, _Offset2;
            CBUFFER_END
            sampler2D _MainTex;
            

            v2f vert (appdata v)
            {
                v2f o;
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.vertex = TransformWorldToHClip(positionWS);
                o.normal = TransformObjectToWorldNormal(v.normalOS);
                o.viewDirWS = normalize(GetCameraPositionWS() - positionWS);//??????????????????
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.offset1 = mul(_Offset, UNITY_MATRIX_V).xyz;
                o.offset2 = mul(_Offset2, UNITY_MATRIX_V).xyz;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
              // ???????????????
              float3 normalWS = normalize(i.normal);
              // ??????????????????view ??????
              float3 customSpecView = normalize(i.offset1);
              float3 customSpecView2 = normalize(i.offset2);
              // ??????1
              float ndv1 = saturate(dot(normalWS, customSpecView));
              float spec1 = pow(ndv1, _u_Exp) * _u_Intensity;
              // ??????2
              float ndv2 = saturate(dot(normalWS, customSpecView2));
              float spec2 = pow(ndv2, _u_Exp2) * _u_Intensity2;
              // ??????????????????
              float3 albedo = tex2D(_MainTex, i.uv).rgb * _u_DiffuseIntensity;
              float3 spec = spec1 + spec2;
              float4 col = float4((albedo + spec) * _u_MainColor.rgb, _u_MainColor.a);
              return col;
            }
            ENDHLSL
        }
    }
}
