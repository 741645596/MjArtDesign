Shader "WB/GaussianBlur"
{
    Properties
    {
        _MainTex("Source", 2D) = "white" {}
    }

    SubShader
    {
        ZTest Always ZWrite Off Cull Off
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "./Blur.hlsl"
        
        struct Attributes
        {
            float4 positionOS   : POSITION;
            float2 uv           : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Varyings
        {
            float4 positionHS    : SV_POSITION;
            float2 uv            : TEXCOORD0;
            float4 uvgrab : TEXCOORD1;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        Varyings Vert(Attributes input)
        {

            Varyings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
            output.positionHS = TransformObjectToHClip(input.positionOS.xyz);
#if UNITY_UV_STARTS_AT_TOP
            float scale = -1.0;
#else
            float scale = 1.0;
#endif
            output.uvgrab.xy = (float2(output.positionHS.x, output.positionHS.y * scale) + output.positionHS.w) * 0.5;
            output.uvgrab.zw = output.positionHS.zw;
            output.uv = input.uv;
            return output;
        }

        CBUFFER_START(UnityPerMaterial)
        float4 _CameraColorAttachmentA_TexelSize;
        float _BlurScale;
        CBUFFER_END
        Texture2D _CameraColorAttachmentA;
        
        ///水平blur
        float4 FragH(Varyings i) : SV_Target
        {
            return GaussianBlur7Tap(_CameraColorAttachmentA, i.uvgrab.xy , half2(_BlurScale,0));
        }

        //垂直blur
        float4 FragV(Varyings i) : SV_Target
        {
            return GaussianBlur7Tap(_CameraColorAttachmentA,i.uvgrab.xy ,half2(0,_BlurScale));
        }

        ENDHLSL

        //水平blur pass
        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment FragH

            ENDHLSL
        }

        //垂直blur pass
        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment FragV

            ENDHLSL
        }
    }
}