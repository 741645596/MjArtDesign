Shader "MJ/mj_tencent_new"
{
    Properties
    {
        _u_AddTexture ("_u_AddTexture", 2D) = "white" {}
        _u_Back("_u_Back", 2D) = "white" {}
        _u_WhiteFace("_u_WhiteFace", 2D) = "white" {}
        _u_MainColor("MainColor", Color) = (1.0, 1.0, 1.0, 1)
        _u_AddTexOpacity("_u_AddTexOpacity", float) = 1.00

        [Foldout] _SPEC1Name("高光1控制面板",Range(0,1)) = 0
        [FoldoutItem][Toggle] _SpecCtrl1("高光1控制开关", Float) = 0.0
        [FoldoutItem]_Offset("Offset", Vector) = (2.0, 0.0, 4.0, 0)
        [FoldoutItem]_u_Exp("Exp", Range(0, 200)) = 47
        [FoldoutItem]_u_Intensity("Intensity", Range(0, 2)) = 0.30

        [Foldout] _SPEC2Name("高光2控制面板",Range(0,1)) = 0
        [FoldoutItem][Toggle] _SpecCtrl2("高光2控制开关", Float) = 0.0
        [FoldoutItem]_Offset2("Offset2", Vector) = (-1.0, 1.0, 5.0, 7.0)
        [FoldoutItem]_u_Exp2("Exp2", Range(0, 200)) = 48
        [FoldoutItem]_u_Intensity2("Intensity2", Range(0, 2)) = 0.06
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
            #pragma multi_compile __ _SPECCTRL1_ON
            #pragma multi_compile __ _SPECCTRL2_ON



            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex    : POSITION;
                float2 uv        : TEXCOORD0;
                float3 normalOS	 : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal  : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 offset1	: TEXCOORD3;
                float3 offset2	: TEXCOORD4;

            };


            CBUFFER_START(UnityPerMaterial)
                float4 _u_AddTexture_ST;
                float4 _u_Back_ST;
                float4 _u_WhiteFace_ST;
                half4  _u_MainColor;
                float _u_AddTexOpacity;
                float _u_Intensity, _u_Intensity2, _u_Exp, _u_Exp2;
                float4 _Offset, _Offset2;
            CBUFFER_END
            sampler2D _u_AddTexture;
            sampler2D _u_Back;
            sampler2D _u_WhiteFace;
            

            v2f vert (appdata v)
            {
                v2f o;
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.positionWS = positionWS;
                o.vertex = TransformWorldToHClip(positionWS);
                o.normal = TransformObjectToWorldNormal(v.normalOS);
                o.uv = v.uv;
#if			_SPECCTRL1_ON
                o.offset1 = mul(_Offset, UNITY_MATRIX_V).xyz;
#endif
#if			_SPECCTRL2_ON
                o.offset2 = mul(_Offset2, UNITY_MATRIX_V).xyz;
#endif
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
              // base
              float3 viewDirWS = normalize(GetCameraPositionWS() - i.positionWS);//正负相反光源
              float3 normalWS = normalize(i.normal);
              // diffuse 部分
              // matcap部分
              float3 viewDirVS = mul(normalize(viewDirWS), UNITY_MATRIX_V).xyz;
              float3 normalVS = mul(normalWS, UNITY_MATRIX_V).xyz;
              float2 xy = cross(normalize(normalVS), normalize(viewDirVS)).xy;
              float2 matCapUV = float2(-xy.y, xy.x) * 0.5f + 0.5f;
              float3 matCapColor = tex2D(_u_Back, matCapUV).rgb;
              // white face 部分
              float2 mainUV = i.uv * _u_WhiteFace_ST.xy + _u_WhiteFace_ST.zw;
              float4 whiteFaceColor = tex2D(_u_WhiteFace, mainUV);
              float3 diffuseColor = lerp(whiteFaceColor.rgb, matCapColor.rgb, whiteFaceColor.a);
              // AddTexture 部分
              float2 addTexUV = i.uv * _u_AddTexture_ST.xy + _u_AddTexture_ST.zw;
              float4 addTexColor = tex2D(_u_AddTexture, addTexUV);
              diffuseColor = lerp(diffuseColor.rgb, addTexColor.rgb, addTexColor.a * _u_AddTexOpacity);

              // 高光
              float3 resultColor = diffuseColor;
#if			_SPECCTRL1_ON
              // 高光1
              float3 customSpecView = normalize(i.offset1);
              float ndv1 = saturate(dot(normalWS, customSpecView));
              float spec1 = pow(ndv1, _u_Exp) * _u_Intensity;
              resultColor = resultColor + spec1;
#endif
#if			_SPECCTRL2_ON
              // 高光2
              float3 customSpecView2 = normalize(i.offset2);
              float ndv2 = saturate(dot(normalWS, customSpecView2));
              float spec2 = pow(ndv2, _u_Exp2) * _u_Intensity2;
              resultColor = resultColor + spec2;
#endif
              // 得到最综颜色
              resultColor = resultColor  * _u_MainColor.rgb;
              return float4(resultColor, _u_MainColor.a);
            }
            ENDHLSL
        }
    }
    CustomEditor "FoldoutShaderGUI"
}
