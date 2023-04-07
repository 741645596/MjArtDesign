Shader "Custom/MyShader" {
    Properties{
        _Basemap("Base map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _AmbientColor("Ambient Color", Color) = (0.5,0.5,0.5,1)
        [NoScaleOffset] _Normalmap("Normal map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0, 2)) = 1
        _Mask0("Mask", 2D) = "white" {}
        _Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 1
        _Occlusion("Occlusion", Range(0, 1)) = 1
        _CustomCubemap("Custom Cubemap", Cube) = "" {}
        _CubemapRotation("Cubemap Rotation", Range(0, 1)) = 0
        _CubemapIntensity("Cubemap Intensity", Range(0, 5)) = 1
        [NoScaleOffset] _EmissionMap("Emission Map", 2D) = "white" {}
        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0,0)
        _HalfRimLightColor("Half Rim Light Color", Color) = (1,1,1,1)
        _HalfRimLightDir("Half Rim Light Direction", Vector) = (-1,0.5,0,0)
        _HalfRimLightPower("Half Rim Light Power", Range(1, 10)) = 2
        _HalfRimLightIntensity("Half Rim Light Intensity", Range(0, 5)) = 2
    }

    SubShader{
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Assets/Art/shader/Core/ColorCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 clipPos : SV_POSITION;
                float4 lightmapUVOrVertexSH : TEXCOORD0;
                half4 vertexLight : TEXCOORD1;
                float4 worldNormal : TEXCOORD2;
                float4 worldTangent : TEXCOORD3;
                float4 worldBinormal : TEXCOORD4;
                float2 uv : TEXCOORD5;
                float3 worldViewDir : TEXCOORD6;
                float3 positionWS :TEXCOORD7;
                float3 rimDirView :TEXCOORD8;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Basemap_ST;
            float4 _Normalmap_ST;
            float4 _Mask0_ST;
            float4 _EmissionMap_ST;
            float4 _CustomCubemap_HDR;
            //
            float4 _BaseColor;
            float4    _AmbientColor;
            float   _NormalScale;
            float   _Metallic;
            float   _Smoothness;
            float _Occlusion;
            float _CubemapRotation;
            float  _CubemapIntensity;
            float4 _EmissionColor;
            float4 _HalfRimLightColor;
            float4 _HalfRimLightDir;
            float _HalfRimLightPower;
            float _HalfRimLightIntensity;
            CBUFFER_END
            sampler2D _Basemap;
            sampler2D _Normalmap;
            sampler2D _Mask0;
            sampler2D _EmissionMap;
            samplerCUBE _CustomCubemap;


            //float4x4 _ObjectToWorld;
            //float4x4 _WorldToObject;
            //float4x4 _MatrixVP;
            //float4x4 _ObjectToWorldIT;

            v2f vert(appdata v) {

                v2f o;
                o.uv = v.uv;
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);
                o.positionWS = positionWS;
                o.worldViewDir = normalize(_WorldSpaceCameraPos - positionWS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

                o.worldNormal = float4(normalInput.normalWS, positionWS.x);
                o.worldTangent = float4(normalInput.tangentWS, positionWS.y);
                o.worldBinormal = float4(normalInput.bitangentWS, positionWS.z);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);


                half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);

                o.vertexLight = half4(vertexLight, 0);


                //float3 rimVector = normalize(_u_RimVector);
                //o.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

                o.clipPos = positionCS;
                //o.worldReflection = reflect(-worldViewDir, worldNormal);
                //o.color = v.color;

                o.uv = v.uv;

                return o;
            }

            float4 frag(v2f i) : SV_Target {
                float4 tex = tex2D(_Basemap, i.uv);
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldTangent = normalize(i.worldTangent);
                float3 worldBinormal = normalize(i.worldBinormal);
                float3 worldViewDir = normalize(i.worldViewDir);
                float4 diffuse = tex ;

                // Lighting calculation goes here

                return diffuse;
            }
            ENDHLSL
        }
}
    CustomEditor "FoldoutShaderGUI"
}
