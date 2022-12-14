
Shader "FB/Standard/SGamePBR"
{
    Properties
    {
        [MainTexture] _BaseMap("颜色贴图", 2D) = "white" {}
        [MainColor] _BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)

        [NoScaleOffset][Normal]_NormalMap("法线贴图", 2D) = "bump" {}

        [NoScaleOffset]_MetallicGlossMap("RGB: 金属度 AO 光滑度", 2D) = "white" {}
        _Metallic("金属度", Range(0.0, 1.0)) = 0.0
        _Smoothness("光滑度", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength("AO强度", Range(0.0, 1.0)) = 1.0

        _Reflectance("反射率", Range(0.0, 1.0)) = 0.5

        [MaterialToggle(_EMISSION_ON)] _Emission  ("Emission", float) = 0
        [NoScaleOffset]_EmissionMap("自发光遮罩", 2D) = "white" {}
        [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0,1)

        [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [Toggle]_PreZ("预写入深度", Float) = 0

            // Blending state
             [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("__blendop", Float) = 0.0
             [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("__src", Float) = 1.0
             [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("__dst", Float) = 0.0
             [Enum(Off, 0, On, 1)] _ZWrite("ZWriteMode", Float) = 1.0
             [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("ZTestMode", Float) = 4
             [Enum(UnityEngine.Rendering.CullMode)] _Cull("CullMode", Float) = 2.0
            //[Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask("ColorMask", Float) = 15
           /*
           [Header(Stencil)]
           [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Comparison", Float) = 8
           [IntRange]_StencilWriteMask("Stencil Write Mask", Range(0,255)) = 255
           [IntRange]_StencilReadMask("Stencil Read Mask", Range(0,255)) = 255
           [IntRange]_Stencil("Stencil ID", Range(0,255)) = 0
           [Enum(UnityEngine.Rendering.StencilOp)]_StencilPass("Stencil Pass", Float) = 0
           [Enum(UnityEngine.Rendering.StencilOp)]_StencilFail("Stencil Fail", Float) = 0
           [Enum(UnityEngine.Rendering.StencilOp)]_StencilZFail("Stencil ZFail", Float) = 0
           */
    }

    SubShader
    {

        Tags{"RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "SGameForward"
            Tags{"LightMode" = "UniversalForward"}

            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend]

            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 3.5
            
            // Key Word Start----------------------------------

            // Universal Pipeline keywords
            #pragma multi_compile _MAIN_LIGHT_SHADOWS

            // _ADDITIONAL_LIGHTS
            // _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile _ADDITIONAL_LIGHTS
            #pragma multi_compile _SHADOWS_SOFT

            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ _ALPHATEST_ON

            #pragma multi_compile_fog
            
            // Material Mutil_Compile
            #pragma multi_compile _ ENABLE_HQ_SHADOW
            #pragma multi_compile _ _EMISSION_ON

            // Key Word End----------------------------------

            #pragma vertex Vert_SGame
            #pragma fragment PBRFragment
            
            #include "SGamePBRLighting.hlsl"

            ENDHLSL
        }
    }
}
