Shader "MJ/Unlit"
{
    Properties
    {
        _MainTex("BaseMap", 2D) = "white" {}
    }

    SubShader
    {
        Tags {
            "RenderType" = "Opaque" 
            "IgnoreProjector" = "True" 
            "RenderPipeline" = "UniversalPipeline" 
            "ShaderModel"="2.0"
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
                return tex2D(_MainTex, input.uv);
            }
            ENDHLSL
        }
    }
}
