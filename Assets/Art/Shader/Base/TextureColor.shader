Shader "MJ/TextureColor"
{
    Properties
    {
        _MainTex("BaseMap", 2D) = "white" {}
        _u_Color("_u_Color", Color) = (1.0, 1.0, 1.0, 1)
        _u_ShadowIntencity("_u_ShadowIntencity", float) = 0.50
    }

    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
            "ShaderModel" = "2.0"
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _MainTex_TexelSize;
            half4 _MainTex_ST;
            float4 _u_Color;
            float _u_ShadowIntencity;
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
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float4 resultColor;
                _u_ShadowIntencity = _u_ShadowIntencity + 1.0f;
                _u_ShadowIntencity = clamp(0.0f, 1.0f, _u_ShadowIntencity);
                float4 mainColor = tex2D(_MainTex, input.uv);

                resultColor.rgb = _u_ShadowIntencity * _u_Color.rgb * mainColor.rgb;
                resultColor.a = _u_Color.a * mainColor.a;
                return resultColor;
            }
            ENDHLSL
        }
    }
}

