Shader "HappyMJ/JieMao"
{
    Properties
    {
        [Foldout] _CtrlName("控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_Cutoff("_CutOff", Float) = 0.99
        [FoldoutItem] _u_Albedo("_u_Albedo", 2D) = "white" {}
        [Foldout] _ShadowName("影子面板",Range(0,1)) = 0
        [FoldoutItem] _u_LightShadowData("_u_LightShadowData", Vector) = (0.60, 20.00, 0.50, -4.00)
    }

    SubShader
    {
        Tags {"RenderType" = "AlphaTest" "RenderPipeline" = "UniversalPipeline" "Queue" = "AlphaTest"}
        LOD 100

        Pass
        {
            Name "FORWARD"
            Tags
            {
                //"LIGHTMODE" = "UniversalForward"
                "LIGHTMODE" = "AlphaTest0"
                "QUEUE" = "AlphaTest+1"
                "RenderType" = "AlphaTest"
            }


            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            //half4 _MainTex_TexelSize;
            float4 _u_Albedo_ST;
            float  _u_Cutoff;
            CBUFFER_END
            sampler2D _u_Albedo;

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv * _u_Albedo_ST.xy + _u_Albedo_ST.zw;
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float4 mainColor = tex2D(_u_Albedo, input.uv) ;
                float Alpha = mainColor.a;
                clip(Alpha - _u_Cutoff);
                return float4(mainColor.rgb * 0.4f, 0.4f);
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "ALPHA BLENDING"
            Tags
            {
                //"LIGHTMODE" = "UniversalForward"
                "LIGHTMODE" = "AlphaTest1"
                "QUEUE" = "AlphaTest+2"
                "RenderType" = "Transparent"
            }
            ZTest Less
            ZWrite Off
            Cull Front
            //Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One
            Blend SrcAlpha OneMinusSrcAlpha


            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                //half4 _MainTex_TexelSize;
                float4 _u_Albedo_ST;
                float  _u_Cutoff;
                CBUFFER_END
                sampler2D _u_Albedo;

                struct Attributes
                {
                    float4 positionOS       : POSITION;
                    float2 uv               : TEXCOORD0;
                };

                struct Varyings
                {
                    float4 vertex       : SV_POSITION;
                    float2 uv           : TEXCOORD0;
                };

                Varyings vert(Attributes input)
                {
                    Varyings output = (Varyings)0;
                    output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                    output.uv = input.uv * _u_Albedo_ST.xy + _u_Albedo_ST.zw;
                    return output;
                }

                float4 frag(Varyings input) : SV_Target
                {
                    float4 mainColor = tex2D(_u_Albedo, input.uv) * 0.4f;
                    return float4(mainColor);
                }
                ENDHLSL
            }
        Pass
        {
            Name "ALPHA BLENDING"
            Tags
            {
                //"LIGHTMODE" = "UniversalForward"
                "LIGHTMODE" = "AlphaTest2"
                "QUEUE" = "AlphaTest+3"
                "RenderType" = "Transparent"
            }
            ZTest Less
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One
            Blend SrcAlpha OneMinusSrcAlpha


            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            //half4 _MainTex_TexelSize;
            float4 _u_Albedo_ST;
            CBUFFER_END
            sampler2D _u_Albedo;

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv * _u_Albedo_ST.xy + _u_Albedo_ST.zw;
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float4 mainColor = tex2D(_u_Albedo, input.uv) * 0.4f;
                return float4(mainColor);
            }
            ENDHLSL
        }
    }
    CustomEditor "FoldoutShaderGUI"
}
