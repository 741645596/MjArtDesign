Shader "MJ/TextureColor"
{
    Properties
    {
        [ToggleOff] _Receive_Shadows("接收阴影", Float) = 1.0
        _MainTex("BaseMap", 2D) = "white" {}
        _u_Color("_u_Color", Color) = (1.0, 1.0, 1.0, 1)
    }

    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            CBUFFER_START(UnityPerMaterial)
            //half4 _MainTex_TexelSize;
            half4 _MainTex_ST;
            float4 _u_Color;
            CBUFFER_END
            sampler2D _MainTex;

            struct Attributes
            {
                half4 positionOS       : POSITION;
                half2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                half4 vertex       : SV_POSITION;
                half2 uv           : TEXCOORD0;
                float3 worldPos : TEXCOORD2;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                float4 shadowCoord : TEXCOORD1;
#endif
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.worldPos = TransformObjectToWorld(input.positionOS.xyz);
                output.vertex = TransformWorldToHClip(output.worldPos);
                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                output.shadowCoord = TransformWorldToShadowCoord(output.worldPos);
#endif
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float3 resultColor = tex2D(_MainTex, input.uv).rgb * _u_Color.rgb;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                float4 shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                float4 shadowCoord = TransformWorldToShadowCoord(input.worldPos);
#else
                float4 shadowCoord = float4(0, 0, 0, 0);
#endif
                Light main = GetMainLight(shadowCoord);
                resultColor *= main.shadowAttenuation;

                return float4(resultColor, 1.0f);
            }
            ENDHLSL
        }
    }
}

