Shader "HappyMJ/Diamond"
{
    Properties
    {
        [Foldout] _MainName("主内容控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_BaseTex("_u_BaseTex", 2D) = "white" {}
        [FoldoutItem] _u_Normal("_u_Normal", 2D) = "white" {}
        [FoldoutItem] _u_BaseTexStrength("_u_BaseTexStrength", Range(0, 1)) = 0.788
        [FoldoutItem] _u_EnvTex("_u_EnvTex   (HDR)", Cube) = "grey" {}
        [FoldoutItem] _u_EnvTexStrength("_u_EnvTexStrength", float) = 0.873
        [FoldoutItem] _u_DispersionTex("_u_DispersionTex   (HDR)", Cube) = "grey" {}
        [FoldoutItem] _u_DispersionTexStrength("_u_DispersionTexStrength", float) = 5
        [FoldoutItem] _u_ReflectStrength("_u_ReflectStrength", float) = 1.0
    }

        SubShader
        {
            Tags {"RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent"}
            LOD 100
            /*Pass
            {
                Name "FORWARD"
                Tags
                {
                //"LIGHTMODE" = "UniversalForward"
                "LIGHTMODE" = "Fpass0"
                "QUEUE" = "Transparent+1"
                "RenderType" = "Transparent"
                }
                ZTest LEqual
                ZWrite 	On
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha

                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                CBUFFER_START(UnityPerMaterial)
                float4 _u_Normal_ST;
                float4 _u_BaseTex_ST;
                float4 _u_EnvTex_HDR;
                float4 _u_DispersionTex_HDR;
                float _u_BaseTexStrength;
                float _u_EnvTexStrength;
                float _u_DispersionTexStrength;
                float _u_ReflectStrength;
                CBUFFER_END
                sampler2D _u_Normal;
                sampler2D _u_BaseTex;
                samplerCUBE _u_DispersionTex;
                samplerCUBE _u_EnvTex;


            struct Attributes
            {
                float4 positionOS       : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float4 tSpace0 : TEXCOORD0;
                float4 tSpace1 : TEXCOORD1;
                float4 tSpace2 : TEXCOORD2;
                float3 worldView: TEXCOORD3;
                float2 uv      : TEXCOORD4;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                output.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                output.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                output.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);
                output.worldView = normalize(_WorldSpaceCameraPos.xyz - positionWS);

                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float3 Normal = UnpackNormalScale(tex2D(_u_Normal, input.uv), 1.0f);
                float3 WorldNormal = normalize(input.tSpace0.xyz);
                float3 WorldTangent = input.tSpace1.xyz;
                float3 WorldBiTangent = input.tSpace2.xyz;
                // 得到法线。
                float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                normalWS = normalize(normalWS);
                //
                float3 worldView = normalize(input.worldView);

                //
                float NdotV = dot(-worldView, normalWS);
                float sinNV2 = 1.0f - NdotV * NdotV;
                float _uu_xlat14 = 1.0f - (sinNV2 * 0.417 * 0.417);
                float3 reflectionView = float3(0, 0, 0);
                if (_uu_xlat14 > 0)
                {
                    float _uu_xlat3 = sqrt(_uu_xlat14);
                    float _uu_xlat12 = NdotV * 0.417 + _uu_xlat3;
                    float3 _uu_xlat0 = normalWS * _uu_xlat12;
                    reflectionView = worldView * -0.417 - _uu_xlat0.xyz;
                }

                float3 _uu_xlat10_0;
                _uu_xlat10_0.xyz = texCUBE(_u_EnvTex, reflectionView).xyz;
                //
                float3 _uu_xlat16_0;
                _uu_xlat16_0.xyz = _uu_xlat10_0.xyz * _u_BaseTexStrength;
                _uu_xlat16_0.xyz = pow(_uu_xlat16_0.xyz,2.2);

                return float4(_uu_xlat16_0.xyz,1);
            }
            ENDHLSL
        }*/
            Pass
            {
                Name "FORWARD"
                Tags
                {
                    //"LIGHTMODE" = "UniversalForward"
                    "LIGHTMODE" = "Fpass1"
                    "QUEUE" = "Transparent+1"
                    "RenderType" = "Transparent"
                }
                ZTest LEqual
                ZWrite 	On
                Cull Back
                Blend One One
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                CBUFFER_START(UnityPerMaterial)
                float4 _u_Normal_ST;
                float4 _u_BaseTex_ST;
                float4 _u_EnvTex_HDR;
                float4 _u_DispersionTex_HDR;
                float _u_BaseTexStrength;
                float _u_EnvTexStrength;
                float _u_DispersionTexStrength;
                float _u_ReflectStrength;
                CBUFFER_END
                sampler2D _u_Normal;
                sampler2D _u_BaseTex;
                samplerCUBE _u_DispersionTex;
                samplerCUBE _u_EnvTex;


            struct Attributes
            {
                float4 positionOS       : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float4 tSpace0 : TEXCOORD0;
                float4 tSpace1 : TEXCOORD1;
                float4 tSpace2 : TEXCOORD2;
                float3 worldView: TEXCOORD3;
                float2 uv      : TEXCOORD4;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                output.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                output.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                output.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);
                output.worldView = normalize(_WorldSpaceCameraPos.xyz - positionWS);

                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float3 Normal = UnpackNormalScale(tex2D(_u_Normal, input.uv), 1.0f);
                float3 WorldNormal = normalize(input.tSpace0.xyz);
                float3 WorldTangent = input.tSpace1.xyz;
                float3 WorldBiTangent = input.tSpace2.xyz;
                // 得到法线。
                float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                normalWS = normalize(normalWS);
                //
                float3 worldView = normalize(input.worldView);

                half3 reflectVector = reflect(-worldView, normalWS);

                //
                float3 envColor = texCUBE(_u_EnvTex, reflectVector).rgb * _u_EnvTexStrength;
                float3 dispersionColor = texCUBE(_u_DispersionTex, reflectVector).rgb * _u_DispersionTexStrength;
                //
                float gray = dot(envColor, float3(0.33, 0.33, 0.33));
                float3 reflectColor = gray * lerp(dispersionColor, 1, 0.25) * _u_ReflectStrength;
                float3 mainColor = tex2D(_u_BaseTex, input.uv).rgb * _u_BaseTexStrength;
                float3 resultColor = mainColor + reflectColor;
                return float4(resultColor,1);
            }
            ENDHLSL
            }
        }
        CustomEditor "FoldoutShaderGUI"
}