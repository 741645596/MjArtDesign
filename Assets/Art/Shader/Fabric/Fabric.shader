Shader "FB/Fabric"
{
    Properties
    {
        [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [MaterialToggle(_SILK_ON)] _Silk  ("Silk", float) = 0

        _SilkDefault("SilkDefault", float) = 0
        _WoolDefault("WoolDefault", float) = 0

        _Anisotropy("Anisotropy", Range(-1, 1)) = -0.65

        _BaseMap("Base Color Map", 2D) = "white" {}
        _BaseColor("BaseColor", Color) = (0.63, 0.58, 0.44, 1)

        _SpecColor("SpecColor", Color) = (0.87, 0.8, 0.6117, 1)
        _SpecTintStrength("SpecTintStrength",Range(0, 1)) = 0

        _Transmission_Tint("Transmission Tint", Color) = (0, 0, 0, 0)
        
        [Normal][NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Map Strength", Range(0, 4)) = 1

        [NoScaleOffset]_MaskMap("Mask Map _(R) AO(G) S(A) ", 2D) = "white" {}
        _Metallic("Metallic", Range(0, 1)) = 0.2
        _SmoothnessMax("Smoothness Max", Range(0, 1)) = 0.2
        _OcclusionStrength("AO强度", Range(0.0, 1.0)) = 1.0

        [MaterialToggle(_THREADMAP_ON)]_UseThreadMap("细节开启", Float) = 1
        _ThreadMap("Thread Map", 2D) = "white" {}
        _ThreadTilling("Thread Tilling",Range( 1 , 200))= 100
        _ThreadAOStrength("Thread AO Strength", Range(0, 1)) = 0.5
        _ThreadNormalStrength("Thread Normal Strength", Range(0, 1)) = 0.5
        _ThreadSmoothnessScale("Thread Smoothness Scale", Range(0, 1)) = 0.5

        [MaterialToggle(_FUZZMAP_ON)]_Fuzz("绒毛", Float) = 0
        [NoScaleOffset]_FuzzMap("Fuzz Map", 2D) = "black" {}
        _FuzzMapUVScale("Fuzz Map UV Scale", Range( 1 , 50))= 15
        _FuzzStrength("Fuzz Strength", Range(0, 2)) = 1
        
        [HideInInspector][NoScaleOffset]_preIntegratedFGD("preIntegratedFGD", 2D) = "white" {}

        

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _BlendOp("__blendop", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 0.0
        [HideInInspector] _ReceiveShadows("Receive Shadows", Float) = 1.0

    }

    SubShader
    {
        Tags { 
            "RenderPipeline"="UniversalRenderPipline" "RenderType"="Opaque" 
        }

        Pass{
            
            Name "SGameFabric"
            Tags{"LightMode" = "UniversalForward"}

            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend]

            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_instancing
            #define _SHADOWS_SOFT

            #pragma multi_compile_fog

            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ _SILK_ON
            #pragma shader_feature _ _THREADMAP_ON
            #pragma shader_feature _ _FUZZMAP_ON

            #pragma vertex Vert_SGame
            #pragma fragment FabricFragment

            #include "FabricLighting.hlsl"

            ENDHLSL 
        }
    }
}
