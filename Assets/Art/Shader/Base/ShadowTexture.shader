Shader "MJ/ShadowTexture"
{
    Properties
    {
        [Foldout] _BaseName("基础控制面板",Range(0,1)) = 0
        [FoldoutItem] [Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode", float) = 2
        [FoldoutItem] [Enum(UnityEngine.Rendering.BlendMode)] _SourceBlend("Source Blend Mode", Float) = 5
        [FoldoutItem] [Enum(UnityEngine.Rendering.BlendMode)] _DestBlend("Dest Blend Mode", Float) = 10
        [FoldoutItem] [Enum(Off, 0, On, 1)]_ZWriteMode("ZWriteMode", float) = 1
        [FoldoutItem][Enum(UnityEngine.Rendering.CompareFunction)] _ZTestMode("ZTestMode", float) = 4

        [Foldout] _StencilName("模板缓冲控制面板",Range(0,1)) = 0
        [FoldoutItem] _Stencil("Stencil ID[ref]", Float) = 0
        [FoldoutItem] _StencilWriteMask("Stencil Write Mask", Float) = 255
        [FoldoutItem] _StencilReadMask("Stencil Read Mask", Float) = 255
        [FoldoutItem] [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 3
        [FoldoutItem] [Enum(UnityEngine.Rendering.StencilOp)]_StencilOp("Stencil Operation", Float) = 3
        [FoldoutItem] [Enum(UnityEngine.Rendering.StencilOp)]_StencilFailOp("Stencil Fail Operation", Float) = 0
        [FoldoutItem][Enum(UnityEngine.Rendering.StencilOp)]_ZFailOp("Z Fail Operation", Float) = 0
        [FoldoutItem]_OffsetFactor("_OffsetFactor", Float) = 0
        [FoldoutItem]_OffsetUnits("_OffsetUnits", Float) = 0


        _MainTex("BaseMap", 2D) = "white" {}
        _u_TintColor("_u_TintColor", Color) = (0.5, 0.5, 0.5, 0.816)
    }

    SubShader
    {
        Tags {"RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent"}
        LOD 100

        ZTest [_ZTestMode]   //ZTest LEqual
        Cull [_CullMode]     //Cull off
        Blend[_SourceBlend][_DestBlend] //alpha 透贴
        ZWrite[_ZWriteMode] //ZWrite off
        Offset[_OffsetFactor],[_OffsetUnits]

        Stencil
        {
            Ref[_Stencil]                // 0
            ReadMask[_StencilReadMask]   // 255
            WriteMask[_StencilWriteMask] // 255
            Comp[_StencilComp]           // equal
            Pass[_StencilOp]             // incr sat
            Fail[_StencilFailOp]         // keep
            ZFail[_ZFailOp]              // keep

        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            //half4 _MainTex_TexelSize;
            float4 _MainTex_ST;
            float4 _u_TintColor;
            CBUFFER_END
            sampler2D _MainTex;

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float4 color : COLOR;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float4 color : COLOR;
                float2 uv           : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv * _MainTex_ST.xy  + _MainTex_ST.zw;
                output.color = input.color;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float4 resultColor;
                float4 mainColor = tex2D(_MainTex, input.uv);
                resultColor = mainColor * input.color * _u_TintColor;
                return resultColor;
            }
            ENDHLSL
        }
    }
    CustomEditor "FoldoutShaderGUI"
}


