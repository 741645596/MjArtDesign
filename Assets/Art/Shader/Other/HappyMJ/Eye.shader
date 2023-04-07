Shader "HappyMJ/Eye"
{
    Properties
    {
        [Foldout] _BaseName("基础控制面板",Range(0,1)) = 0
        [FoldoutItem][Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode", float) = 2
        [FoldoutItem][Enum(UnityEngine.Rendering.BlendMode)] _SourceBlend("Source Blend Mode", Float) = 5
        [FoldoutItem][Enum(UnityEngine.Rendering.BlendMode)] _DestBlend("Dest Blend Mode", Float) = 10
        [FoldoutItem][Enum(Off, 0, On, 1)]_ZWriteMode("ZWriteMode", float) = 1
        [FoldoutItem][Enum(UnityEngine.Rendering.CompareFunction)] _ZTestMode("ZTestMode", float) = 4
        /*
        [Foldout] _StencilName("模板缓冲控制面板",Range(0,1)) = 0
        [FoldoutItem] _Stencil("Stencil ID[ref]", Float) = 0
        [FoldoutItem] _StencilWriteMask("Stencil Write Mask", Float) = 255
        [FoldoutItem] _StencilReadMask("Stencil Read Mask", Float) = 255
        [FoldoutItem][Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 3
        [FoldoutItem][Enum(UnityEngine.Rendering.StencilOp)]_StencilOp("Stencil Operation", Float) = 3
        [FoldoutItem][Enum(UnityEngine.Rendering.StencilOp)]_StencilFailOp("Stencil Fail Operation", Float) = 0
        [FoldoutItem][Enum(UnityEngine.Rendering.StencilOp)]_ZFailOp("Z Fail Operation", Float) = 0
        [FoldoutItem]_OffsetFactor("_OffsetFactor", Float) = 0
        [FoldoutItem]_OffsetUnits("_OffsetUnits", Float) = 0
        */
        [Foldout] _CtrlName("控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_MainTex("_u_MainTex", 2D) = "white" {}
        [FoldoutItem] _u_MaskTex("_u_MainTex", 2D) = "white" {}
        [FoldoutItem] _u_Color("_u_Color", Color) = (0.82353, 0.82353, 0.82353, 1.00)
        [FoldoutItem] _u_GLCornea("_u_GLCornea", Float) = 135.00
        [FoldoutItem] _u_SpecularScale("_u_SpecularScale", Float) = 1.00
        [FoldoutItem] _u_Lum("_u_Lum", Float) = 2.00
        [Foldout] _ShadowName("影子面板",Range(0,1)) = 0
        [FoldoutItem] _u_LightShadowData("_u_LightShadowData", Vector) = (0.60, 20.00, 0.50, -4.00)
        [FoldoutItem] _u_ShadowIntensity("_u_ShadowIntensity", Float) = 1.00
    }

        SubShader
        {
            Tags {"RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent"}
            LOD 100

            ZTest[_ZTestMode]   //ZTest LEqual
            Cull[_CullMode]     //Cull off
            Blend[_SourceBlend][_DestBlend] //alpha 透贴
            ZWrite[_ZWriteMode] //ZWrite off
            //Offset[_OffsetFactor],[_OffsetUnits]

            /*Stencil
            {
                Ref[_Stencil]                // 0
                ReadMask[_StencilReadMask]   // 255
                WriteMask[_StencilWriteMask] // 255
                Comp[_StencilComp]           // equal
                Pass[_StencilOp]             // incr sat
                Fail[_StencilFailOp]         // keep
                ZFail[_ZFailOp]              // keep

            }*/

            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                CBUFFER_START(UnityPerMaterial)
            //half4 _MainTex_TexelSize;
            float4 _u_MainTex_ST;
            float4 _u_MaskTex_ST;
            float4 _u_Color;
            float  _u_GLCornea;
            float  _u_SpecularScale;
            float  _u_Lum;
            CBUFFER_END
            sampler2D _u_MainTex;
            sampler2D _u_MaskTex;

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float3 normal : NORMAL;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 objNormal  : TEXCOORD1;
                float3 objSpacelightDir : TEXCOORD2;
                float3 objViewDir : TEXCOORD3;
                float3 worldPos :TEXCOORD4;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv * _u_MainTex_ST.xy + _u_MainTex_ST.zw;
                //output.objNormal = TransformObjectToWorldNormal(input.normal);
                output.objNormal = input.normal;
                output.objSpacelightDir = TransformWorldToObject(_MainLightPosition.xyz);
                output.objViewDir = TransformWorldToObject(_WorldSpaceCameraPos.xyz) - input.positionOS.xyz;
                output.worldPos = TransformObjectToWorld(input.positionOS.xyz);
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float3 viewDir = normalize(input.objViewDir);
                float3 lightDir = normalize(input.objSpacelightDir);
                float3 hDir = normalize(viewDir + lightDir);

                // 漫反射部分，
                float HoL = dot(lightDir, hDir);
                HoL = max(HoL, 0.2f);
                HoL = min(HoL, 1.0f);

                float3 mainColor = tex2D(_u_MainTex, input.uv).rgb * _u_Color.rgb;
                float3 diffuseColor = mainColor * HoL;

                // blinnPhong 高光
                float3 normal = normalize(input.objNormal);
                float  HoN = dot(hDir, normal);
                float spec = pow(saturate(HoN), _u_GLCornea) * _u_SpecularScale;

                float mask = 1.0f - tex2D(_u_MaskTex, input.uv).r;
                float diffuseParam = lerp(1.5f, _u_Lum, mask);

                float3 resultColor = diffuseColor * diffuseParam + spec * mask;
                return float4(resultColor, 1.0f);
            }
            ENDHLSL
        }
        }
        CustomEditor "FoldoutShaderGUI"
}


