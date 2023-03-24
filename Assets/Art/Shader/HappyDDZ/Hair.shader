Shader "HappyDDZ/Hair"
{
    Properties
    {
        [Foldout] _CtrlName("控制面板",Range(0,1)) = 0
        [FoldoutItem] _Cutoff("_CutOff", Float) = 0.99
        [FoldoutItem] _MainTex("_MainTex", 2D) = "white" {}
        [FoldoutItem] _NormalMap("_NormalMap", 2D) = "white" {}
        [FoldoutItem] _ConfigMap("_ConfigMap", 2D) = "white" {}
        [FoldoutItem] _Occlusion("_Occlusion", Float) = 0.024
        [FoldoutItem] _NormalScale("_NormalScale", Float) = 1.0
        [FoldoutItem] _LambertBrightness("_LambertBrightness", Float) = 1.0
        [FoldoutItem] _BackBrightness1("_BackBrightness1", Float) = 1.0

        [Foldout] _KkSpecName("各向异性高光",Range(0,1)) = 0
        [FoldoutItem] _SpecularColor1("_SpecularColor1", Color) = (0.83824, 0.85274, 1.00, 1.00)
        [FoldoutItem] _SpecularGloss1("_SpecularGloss1", Float) = 0.024
        [FoldoutItem] _ShiftValue1("_ShiftValue1", Float) = 0.024
        [FoldoutItem] _SpecularColor2("_SpecularColor2", Color) = (0.83824, 0.85274, 1.00, 1.00)
        [FoldoutItem] _SpecularGloss2("_SpecularGloss2", Float) = 0.024
        [FoldoutItem] _ShiftValue2("_ShiftValue2", Float) = 0.024
        [FoldoutItem] _HairColor1("_HairColor1", Color) = (0.83824, 0.85274, 1.00, 1.00)
        [FoldoutItem] _HairColor2("_HairColor2", Color) = (0.83824, 0.85274, 1.00, 1.00)

        [Foldout] _RimName("RIM边缘光控制面板",Range(0,1)) = 0
        [FoldoutItem] _HalfRimLightColor("_HalfRimLightColor", Color) = (0, 0, 0, 0)
        [FoldoutItem] _HalfRimLightPower("_HalfRimLightPower", Range(0 , 50)) = 1
        [FoldoutItem] _HalfRimLightIntensity("_HalfRimLightIntensity", Range(0 , 50)) = 1
        [FoldoutItem] _HalfRimLightDir("_HalfRimLightDir", Vector) = (0, 0, 0, 0)
        //
        [FoldoutItem]_AmbientSkyColor("_AmbientSkyColor", Color) = (0, 0, 0, 0)
        [FoldoutItem]_AmbientEquatorColor("_AmbientEquatorColor", Color) = (0, 0, 0, 0)
        [FoldoutItem]_AmbientGroundColor("_AmbientGroundColor", Color) = (0, 0, 0, 0)
        [FoldoutItem] _AmbientIntensity("_AmbientIntensity", Float) = 0.024

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
            #include "../PBR/ColorCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _Cutoff;
            float4 _MainTex_ST;
            float4 _ConfigMap_ST;
            // 各向异性高光
            float4 _HairColor1;
            float4 _HairColor2;
            CBUFFER_END
            sampler2D _MainTex;
            sampler2D _ConfigMap;

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
                output.uv = input.uv;
                return output;
            }

            float4 frag(Varyings input, float facing : VFACE) : SV_Target
            {
                float4 albedoColor = tex2D(_MainTex, input.uv);
                float alpha = albedoColor.a;
                clip(alpha - _Cutoff);
                float3 configColor = tex2D(_ConfigMap, input.uv).rgb;
                albedoColor.rgb = albedoColor.rgb * lerp(_HairColor1, _HairColor2, configColor.r);
                return float4(albedoColor.rgb, 1);
            }
            ENDHLSL
        }
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
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "../PBR/ColorCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
        //half4 _MainTex_TexelSize;
        float4 _MainTex_ST;
        float4 _NormalMap_ST;
        float4 _ConfigMap_ST;
        float _NormalScale;
        //
        float _LambertBrightness;
        float _BackBrightness1;
        // 各向异性高光
        float4 _SpecularColor1;
        float _SpecularGloss1;
        float _ShiftValue1;
        float4 _SpecularColor2;
        float _SpecularGloss2;
        float _ShiftValue2;
        float _Occlusion;
        float4 _HairColor1;
        float4 _HairColor2;
        // 边缘光
        float4 _HalfRimLightColor;
        float _HalfRimLightPower;
        float4 _HalfRimLightDir;
        float _HalfRimLightIntensity;
        //
        float4 _AmbientSkyColor;
        float4	_AmbientEquatorColor;
        float4	_AmbientGroundColor;
        float _AmbientIntensity;
        CBUFFER_END
        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _ConfigMap;

        struct Attributes
        {
            float4 positionOS       : POSITION;
            float3 normal           : NORMAL;
            float4 tangent          : TANGENT;
            float2 uv               : TEXCOORD0;
        };

        struct Varyings
        {
            float4 vertex       : SV_POSITION;
            float2 uv           : TEXCOORD0;
            float4 tSpace0      : TEXCOORD1;
            float4 tSpace1      : TEXCOORD2;
            float4 tSpace2      : TEXCOORD3;
            float3 positionWS   : TEXCOORD4;
            float3 worldView    :TEXCOORD5;
        };

        half HairSpecular(float3 hDirWS, float3 nDirWS, half specularWidth) {

            float hDotn = dot(hDirWS, nDirWS);
            float sinTH = (sqrt(1 - pow(hDotn, 2)));
            half dirAtten = smoothstep(-1, 0, hDotn);
            half specular = dirAtten * saturate(pow(sinTH, specularWidth));
            return (specular);
        }

        float3 CalcBlendColor(float normalY)
        {
            float2 control = normalY * float2(0.7f, -0.7f) + 0.3f;
            float diffNormalY = saturate(1.6f - abs(normalY));

            float max_AmbientSkyColor = max(_AmbientSkyColor.r, max(_AmbientSkyColor.b, _AmbientSkyColor.g));
            float max_AmbientGroundColor = max(_AmbientGroundColor.r, max(_AmbientGroundColor.b, _AmbientGroundColor.g));

            float3 result = diffNormalY * saturate(3.0 - max_AmbientSkyColor - max_AmbientGroundColor) * _AmbientEquatorColor.rgb;
            result = result + control.r * _AmbientSkyColor.rgb + control.g * _AmbientGroundColor.rgb;

            return result;
        }

        Varyings vert(Attributes input)
        {
            Varyings output = (Varyings)0;

            output.vertex = TransformObjectToHClip(input.positionOS.xyz);
            output.uv = input.uv;

            float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
            float3 positionVS = TransformWorldToView(positionWS);
            float4 positionCS = TransformWorldToHClip(positionWS);
            output.positionWS = positionWS;
            output.worldView = normalize(_WorldSpaceCameraPos - positionWS);

            VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

            output.tSpace0 = float4(normalInput.normalWS, positionWS.x);
            output.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
            output.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

            return output;
        }

        float4 frag(Varyings input, float facing : VFACE) : SV_Target
        {
            float3 configColor = tex2D(_ConfigMap, input.uv).rgb;
            float AO = lerp(1, configColor.b, _Occlusion);
            float shif = configColor.g;


            float4 albedoColor = tex2D(_MainTex, input.uv);
            float alpha = albedoColor.a;
            albedoColor = albedoColor * saturate(lerp(_HairColor1, _HairColor2, configColor.r));



            float3 WorldNormal = normalize(input.tSpace0.xyz);
            float3 WorldTangent = input.tSpace1.xyz;
            float3 WorldBiTangent = input.tSpace2.xyz;

            float3 WorldPosition = float3(input.tSpace0.w, input.tSpace1.w, input.tSpace2.w);
            float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
            float3 Normal = UnpackNormalScale(tex2D(_NormalMap, input.uv), _NormalScale);
            float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
            bool backface = facing < 0.0f;
            if (backface)
            {
                normalWS = -normalWS;
            }
            // kk  算法的核心，使用副切并用法线进行偏正
            float3 worldView = normalize(input.worldView);
            float3 lightDir = normalize(_MainLightPosition.xyz);
            float3 hDir = normalize(worldView + lightDir);
            float HoL = saturate(dot(hDir, lightDir));
            float NoL = saturate(dot(normalWS, lightDir));
            float diffuseTeam = lerp(NoL, 1, _LambertBrightness);
            if (backface)
            {
                diffuseTeam = 1;
            }
            //
            float3 n1DirWS = normalize(WorldBiTangent + normalWS * (shif + _ShiftValue1));
            float3 specCol1 = HairSpecular(hDir, n1DirWS, _SpecularGloss1) * _SpecularColor1.rgb ;
            float3 n2DirWS = normalize(WorldBiTangent + normalWS * (shif + _ShiftValue2));
            float3 specCol2 = HairSpecular(hDir, n2DirWS, _SpecularGloss2) * _SpecularColor2.rgb;
            float3 spec = (specCol1 + specCol2) * max(diffuseTeam, 0.3f);
            float3 diffuseAndSpec = spec  + diffuseTeam * albedoColor.rgb;
            diffuseAndSpec = diffuseAndSpec * _MainLightColor.rgb ;
            // 新加入的
            float3 AmbientCol = CalcBlendColor(normalWS.y) * _AmbientIntensity * AO * 0.3f * pow(1 - NoL, 4);
            //
            float3 RimLightDir = normalize(_HalfRimLightDir);
            float Nov = saturate(dot(WorldViewDirection, normalWS));
            float nov_Pow = pow(saturate(1 - Nov), _HalfRimLightPower);
            float NoRim = saturate(dot(normalWS, RimLightDir) * 0.5f);
            float smoothValue = smoothstep(0, 1, NoRim);
            float3 rimColor = saturate(nov_Pow * smoothValue * _HalfRimLightIntensity) * _HalfRimLightColor.rgb;

            float3 result = rimColor +  AmbientCol;

            if (backface)
            {
                result += diffuseAndSpec * _BackBrightness1;
            }
            else
            {
                result += diffuseAndSpec;
            }
            return float4(diffuseAndSpec, alpha);
        }
        ENDHLSL
    }
            }
        CustomEditor "FoldoutShaderGUI"
}


