Shader "MJ/mj_tengxun_Saizi"
{
    Properties
    {
        _u_MainTex("_u_MainTex", 2D) = "white" {}

        [Foldout] _AmbientName("环境光控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_AmbientColor("_u_AmbientColor[环境光颜色", Color) = (0.00, 0.00, 0.00, 1.00)
        
        [Foldout] _DiffuseName("漫反射控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_DiffuseLightDir("_u_DiffuseLightDir[漫反射用灯光，平行光]", Vector) = (0.05, 0.82, 0.38, 0)
        [FoldoutItem] _u_DiffuseLightColor("_u_DiffuseLightColor[漫反射灯光颜色]", Color) = (0.38971, 0.38971, 0.38971, 1.00)

        [Foldout] _SPECName("高光控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_SpecLightPos("_u_SpecLightPos[高光点光源有计算光源的衰减]", Vector) = (0.18, 0.62, 0.58, 0)
        [FoldoutItem] _u_SpecLightColor("_u_SpecLightColor[光源颜色]", Color) = (0.64706, 0.64706, 0.64706, 1)
        [FoldoutItem] _u_Shininess("_u_Shininess[高光光泽度]", Float) = 10.71222
        [FoldoutItem] _u_Intensity("_u_Intensity[强度同时控制到漫反射]", Float) = 1.0

        [Foldout] _EmissionName("自发光光控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_Emission("_u_Emission1", Float) = 0.41661
    }
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"   }
        LOD 100

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
                float4 vertex    : POSITION;
                float2 uv        : TEXCOORD0;
                float3 normalOS	 : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal  : TEXCOORD1;
                float lightDir : TEXCOORD2;
                float4 diffuseColor : TEXCOORD3;
                float lightInverseDis : TEXCOORD4;
            };


            CBUFFER_START(UnityPerMaterial)
                float4 _u_MainTex_ST;
                float4 _u_AmbientColor;
                float4 _u_DiffuseLightDir;
                float4 _u_DiffuseLightColor;
                float4 _u_SpecLightPos;
                float4 _u_SpecLightColor;
                float _u_Intensity;
                float _u_Shininess;
                float _u_Emission;
            CBUFFER_END
            sampler2D _u_MainTex;


            v2f vert(appdata v)
            {
                v2f o;
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 lightDir = _u_SpecLightPos.xyz - positionWS;
                o.lightInverseDis = 1.0f /length(lightDir);
                o.lightDir = normalize(lightDir);

                o.vertex = TransformWorldToHClip(positionWS);
                o.normal = TransformObjectToWorldNormal(v.normalOS);
                o.uv = v.uv;

                // 计算漫反射+ 环境光。
                float3 diffuselightDir = normalize(_u_DiffuseLightDir);
                float3 diffuseColor = saturate(dot(o.normal, diffuselightDir)) * _u_DiffuseLightColor.rgb;
                diffuseColor = diffuseColor + _u_AmbientColor.rgb * _u_DiffuseLightColor.rgb;
                o.diffuseColor.rgb = clamp(diffuseColor, 0.0f, 1.0f);
                o.diffuseColor.a = 1.0f;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 reflexLight = 2 * dot(normal, i.lightDir) * normal - i.lightDir;
                // phong  模型求高光, 使用了normal 代替normal ？？？
                float3 spec = pow(max(0.0, dot(reflexLight, normal)), _u_Shininess);
                spec = spec * i.lightInverseDis * _u_SpecLightColor.rgb;
                //
                float2 mainUV = i.uv * _u_MainTex_ST.xy + _u_MainTex_ST.zw;
                float4 mainColor= tex2D(_u_MainTex, mainUV);
                float4 diffuseColor = mainColor * i.diffuseColor;
                diffuseColor.a = diffuseColor.a * _u_Intensity + 1.0f;
                diffuseColor.rgb = diffuseColor.rgb * _u_Intensity;

                float4 emission = mainColor * _u_Emission;
                float4 resultColor = float4(spec + diffuseColor.rgb, diffuseColor.a) + emission;
                return resultColor;
                }
                ENDHLSL
            }
    }
   CustomEditor "FoldoutShaderGUI"
}

