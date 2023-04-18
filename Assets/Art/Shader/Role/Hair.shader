Shader "Weile/Hair"
{
    Properties
    {
        [Foldout] _CtrlName("控制面板",Range(0,1)) = 0
        [FoldoutItem] _Cutoff("_CutOff", Float) = 0.99
        [FoldoutItem][NoScaleOffset] _Albedo("_Albedo", 2D) = "white" {}
        [FoldoutItem][NoScaleOffset] _Bump("_Bump", 2D) = "white" {}
        [FoldoutItem][NoScaleOffset] _UV2Tex("_UV2Tex", 2D) = "white" {}

        [FoldoutItem] _Color("_Color", Color) = (0.61176, 0.61176, 0.61176, 1.00)
        [FoldoutItem] _GiColor("_GiColor", Color) = (1.0, 1.0, 1.00, 1.00)

        [FoldoutItem] _Blend("_Blend", Float) = 0
        [FoldoutItem] _BumpScale("_BumpScale", Float) = 1.0
        [FoldoutItem] _IndirectDiffuseIntensity("_IndirectDiffuseIntensity", Float) = 0.70

        [Foldout] _KkSpecName("各向异性高光",Range(0,1)) = 0

        [Header(Shift__)][Space(10)]
        [FoldoutItem] _Shift("_Shift", Float) = 0.024
        [FoldoutItem] _MPrimaryShift("_MPrimaryShift", Float) = 0.092
        [FoldoutItem] _ThirdShift("_ThirdShift", Float) = -0.056
        
        [Header(Spec1__)][Space(10)]
        [FoldoutItem] _SpecColor1("_SpecColor1", Color) = (0.83824, 0.85274, 1.00, 1.00)
        [FoldoutItem] _SpecPower1("_SpecPower1", Float) = 134
        [FoldoutItem] _SpecStrength("_SpecStrength", Float) = 0.51

        [Header(Spec2__)][Space(10)]
        [FoldoutItem] _SpecColor3("_SpecColor3", Color) = (1.0, 0.55882, 0.36029, 1.00)
        [FoldoutItem] _SpecPower3("_SpecPower3", Float) = 6.0
        [FoldoutItem] _SpecStrength3("_SpecStrength3", Float) = 0.56

        [Foldout] _RimName("RIM边缘光控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_RimVector("_RimVector", Vector) = (0.00, 0.30, -1.00, 1.00)
        [FoldoutItem]_u_RimColor("_RimColor", Color) = (1.00, 1.00, 1.00, 1.00)
        [FoldoutItem] _u_RimIntensity("_RimIntensity", Range(0 , 50)) = 1
        [FoldoutItem] _u_RimPower("_RimPower", Range(0 , 50)) = 0.40
    }

    SubShader
    {
        Tags {"RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent+1"}
        LOD 100

        Pass
        {
            Name "FORWARD"
            Tags
            {
                //"LIGHTMODE" = "UniversalForward"
                "LIGHTMODE" = "Fpass0"
                "QUEUE" = "Transparent+1"
                "RenderType" = "Transparent"
            }
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "HairCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            ENDHLSL
        }

        Pass
        {
                Name "ALPHA BLENDING"
                Tags
                {
                //"LIGHTMODE" = "UniversalForward"
                "LIGHTMODE" = "Fpass1"
                "QUEUE" = "Transparent+2"
                "RenderType" = "Transparent"
                }
                ZTest Less
                ZWrite Off
                Cull Front
                Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One


                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag1
                #include "HairCore.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                ENDHLSL
                }

        Pass
        {
                Name "ALPHA BLENDING"
                Tags
                {
                //"LIGHTMODE" = "UniversalForward"
                "LIGHTMODE" = "Fpass2"
                "QUEUE" = "Transparent+3"
                "RenderType" = "Transparent"
                }
                ZTest Less
                ZWrite Off
                Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One

                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag1
                #include "HairCore.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                ENDHLSL
        }
    }
    CustomEditor "FoldoutShaderGUI"
}


