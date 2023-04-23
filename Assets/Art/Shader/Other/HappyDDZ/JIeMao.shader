Shader "HappyDDZ/JIeMao"
{
    Properties
    {
        [Foldout] _BaseName("基础控制面板",Range(0,1)) = 0
        [FoldoutItem][Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode", float) = 2
        [FoldoutItem][Enum(UnityEngine.Rendering.BlendMode)] _SourceBlend("Source Blend Mode", Float) = 5
        [FoldoutItem][Enum(UnityEngine.Rendering.BlendMode)] _DestBlend("Dest Blend Mode", Float) = 10
        [FoldoutItem][Enum(Off, 0, On, 1)]_ZWriteMode("ZWriteMode", float) = 1
        [FoldoutItem][Enum(UnityEngine.Rendering.CompareFunction)] _ZTestMode("ZTestMode", float) = 4

        [Foldout] _BaseName("属性面板",Range(0,1)) = 0
        [FoldoutItem] _BaseMap ("_BaseMap", 2D) = "white" {}
        [FoldoutItem] _BaseColor("BaseColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags {"RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent+1"}
        LOD 100

        Pass
        {
                Name "Forward"
                Tags { "LightMode" = "UniversalForward" }

                ColorMask RGBA

                ZTest[_ZTestMode]   //LEqual
                Cull[_CullMode]     //Cull off
                Blend[_SourceBlend][_DestBlend] //alpha 透贴
                ZWrite[_ZWriteMode] //ZWrite off


                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                CBUFFER_END
                sampler2D _BaseMap;

                v2f vert (appdata v)
                {
                    v2f o;
                    float3 worldPos = TransformObjectToWorld(v.vertex);
                    o.vertex = TransformWorldToHClip(worldPos);
                    o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                    return o;
                }

                float4 frag (v2f i) : SV_Target
                {
                    float4 col = tex2D(_BaseMap, i.uv) * _BaseColor;
                    return col;
                }
                ENDHLSL
        }
    }
    CustomEditor "FoldoutShaderGUI"
}
