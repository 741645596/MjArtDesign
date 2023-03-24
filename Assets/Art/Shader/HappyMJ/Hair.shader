Shader "HappyMJ/Hair"
{
    Properties
    {
        [Foldout] _CtrlName("控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_Cutoff("_CutOff", Float) = 0.99
        [FoldoutItem] _u_Albedo("_u_Albedo", 2D) = "white" {}
        [FoldoutItem] _u_Bump("_u_Bump", 2D) = "white" {}
        [FoldoutItem] _u_UV2Tex("_u_UV2Tex", 2D) = "white" {}

        [FoldoutItem] _u_Color("_u_Color", Color) = (0.61176, 0.61176, 0.61176, 1.00)
        [FoldoutItem] _u_GiColor("_u_GiColor", Color) = (1.0, 1.0, 1.00, 1.00)

        [FoldoutItem] _u_Blend("_u_Blend", Float) = 0
        [FoldoutItem] _u_BumpScale("_u_BumpScale", Float) = 1.0
        [FoldoutItem] _u_IndirectDiffuseIntensity("_u_IndirectDiffuseIntensity", Float) = 0.70

        [Foldout] _KkSpecName("各向异性高光",Range(0,1)) = 0
        [FoldoutItem] _u_Shift("_u_Shift", Float) = 0.024
        [FoldoutItem] _u_MPrimaryShift("_u_MPrimaryShift", Float) = 0.092
        [FoldoutItem] _u_ThirdShift("_u_ThirdShift", Float) = -0.056
        [FoldoutItem] _u_SpecColor1("_u_SpecColor1", Color) = (0.83824, 0.85274, 1.00, 1.00)
        [FoldoutItem] _u_SpecPower1("_u_SpecPower1", Float) = 134
        [FoldoutItem] _u_SpecStrength("_u_SpecStrength", Float) = 0.51
        [FoldoutItem] _u_SpecColor3("_u_SpecColor3", Color) = (1.0, 0.55882, 0.36029, 1.00)
        [FoldoutItem] _u_SpecPower3("_u_SpecPower3", Float) = 6.0
        [FoldoutItem] _u_SpecStrength3("_u_SpecStrength3", Float) = 0.56

        [Foldout] _RimName("RIM边缘光控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_RimVector("_u_RimVector", Vector) = (0.00, 0.30, -1.00, 1.00)
        [FoldoutItem]_u_RimColor("_u_RimColor", Color) = (1.00, 1.00, 1.00, 1.00)
        [FoldoutItem] _u_RimIntensity("_u_RimIntensity", Range(0 , 50)) = 1
        [FoldoutItem] _u_RimPower("_u_RimPower", Range(0 , 50)) = 0.40
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
                float  _u_Cutoff;
                //half4 _MainTex_TexelSize;
                float4 _u_Albedo_ST;
                float4 _u_Bump_ST;
                float4 _u_UV2Tex_ST;

                float4 _u_Color;
                float4 _u_GiColor;
                float  _u_Blend;
                float _u_BumpScale;
                float _u_IndirectDiffuseIntensity;
                // 各向异性高光
                float _u_Shift;
                float _u_MPrimaryShift;
                float _u_ThirdShift;
                float4 _u_SpecColor1;
                float _u_SpecPower1;
                float _u_SpecStrength;
                float4 _u_SpecColor3;
                float _u_SpecPower3;
                float _u_SpecStrength3;
                // 边缘光
                float3 _u_RimVector;
                float4 _u_RimColor;
                float _u_RimIntensity;
                float _u_RimPower;
                CBUFFER_END
                sampler2D _u_Albedo;
                sampler2D _u_Bump;
                sampler2D _u_UV2Tex;

                struct Attributes
                {
                    float4 positionOS       : POSITION;
                    float3 normal           : NORMAL;
                    float4 tangent          : TANGENT;
                    float2 uv               : TEXCOORD0;
                    float2 uv1              : TEXCOORD1;
                };

                struct Varyings
                {
                    float4 vertex       : SV_POSITION;
                    float2 uv           : TEXCOORD0;
                    float2 uv1          : TEXCOORD1;
                    float4 tSpace0      : TEXCOORD2;
                    float4 tSpace1      : TEXCOORD3;
                    float4 tSpace2      : TEXCOORD4;
                    float3 positionWS   : TEXCOORD5;
                    float3 worldView    :TEXCOORD6;
                    float3 rimDirView   :TEXCOORD7;
                };

                half HairSpecular(float3 hDirWS, float3 nDirWS, half specularWidth) {

                    float hDotn = dot(hDirWS, nDirWS);
                    float sinTH = (sqrt(1 - pow(hDotn, 2)));
                    half dirAtten = smoothstep(-1, 0, hDotn);
                    half specular = dirAtten * saturate(pow(sinTH, specularWidth));
                    return (specular);
                }

                Varyings vert(Attributes input)
                {
                    Varyings output = (Varyings)0;

                    output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                    output.uv = input.uv ;
                    output.uv1 = input.uv1;

                    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                    float3 positionVS = TransformWorldToView(positionWS);
                    float4 positionCS = TransformWorldToHClip(positionWS);
                    output.positionWS = positionWS;
                    output.worldView = normalize(positionWS - _WorldSpaceCameraPos);

                    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                    output.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                    output.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                    output.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

                    float3 rimVector = normalize(_u_RimVector);
                    output.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

                    return output;
                }

                float4 frag(Varyings input, float facing : VFACE) : SV_Target
                {
                    float4 albedoColor = tex2D(_u_Albedo, input.uv);
                    float Alpha = albedoColor.a * _u_Color.a;
                    clip(Alpha - _u_Cutoff);
                    float3 WorldNormal = normalize(input.tSpace0.xyz);
                    float3 WorldTangent = input.tSpace1.xyz;
                    float3 WorldBiTangent = input.tSpace2.xyz;

                    float3 WorldPosition = float3(input.tSpace0.w, input.tSpace1.w, input.tSpace2.w);
                    float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
                    float3 Normal = UnpackNormalScale(tex2D(_u_Bump, input.uv), _u_BumpScale);
                    float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                    // kk  算法的核心，使用副切并用法线进行偏正
                    float3 n1DirWS = normalize(WorldBiTangent + normalWS * (_u_Shift + _u_ThirdShift));
                    float3 worldView = -normalize(input.worldView);
                    float3 lightDir = normalize(_MainLightPosition.xyz);
                    float3 hDir = normalize(worldView + lightDir);
                    float HoL = saturate(dot(hDir, lightDir));
                    float NoL = saturate(dot(normalWS, lightDir));

                    float3 specCol3 = HairSpecular(hDir, n1DirWS, _u_SpecPower3) * _u_SpecColor3.rgb * _u_SpecStrength3;
                    //
                    float3 n2DirWS = normalize(WorldBiTangent + normalWS * (_u_Shift + _u_MPrimaryShift));
                    float3 specCol1 = HairSpecular(hDir, n2DirWS, _u_SpecPower1) * _u_SpecColor1.rgb * _u_SpecStrength;
                    float3 specColor = specCol1 + specCol3;

                    // 菲尼尔项
                    float F = Pow5(1 - HoL);

                    float3 uv2TexColor = tex2D(_u_UV2Tex, input.uv1).rgb;
                    float3 BaseColor = lerp(albedoColor.rgb * _u_Color.rgb, uv2TexColor.rgb, _u_Blend);
                    specColor = specColor * lerp(BaseColor, 1.0f, F);
                    //(isFront = (((((gl_FrontFacing) ? (4294967295u) : (0u)) != 0u)) ? (1.0) : (0.0)));
                    //float isFront= gl_FrontFacing ? 1.0f : 0.0f;
                    float isFront = 1.0f;
                    bool backface = facing < 0.0f;
                    if (backface)
                    {
                        float isFront = 0.0f;
                    }
                   
                   specColor = isFront * specColor;
                    float NoRim = saturate(dot(normalWS, input.rimDirView));
                    float3 RimColor =  min(pow(NoRim * (1- NoL), _u_RimPower), 1.0f) * _u_RimColor.rgb * _u_RimIntensity;
                    RimColor = isFront * RimColor;

                    float3 diffuse = _u_GiColor.rgb * _u_IndirectDiffuseIntensity + max(NoL, 0.3f) * _MainLightColor.rgb;

                    float3 result = diffuse * BaseColor + specColor + RimColor;

                    return float4(result, Alpha);
                }
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
                #pragma fragment frag
                #include "../PBR/ColorCore.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                CBUFFER_START(UnityPerMaterial)
            //half4 _MainTex_TexelSize;
            float4 _u_Albedo_ST;
            float4 _u_Bump_ST;
            float4 _u_UV2Tex_ST;

            float4 _u_Color;
            float4 _u_GiColor;
            float  _u_Blend;
            float _u_BumpScale;
            float _u_IndirectDiffuseIntensity;
            // 各向异性高光
            float _u_Shift;
            float _u_MPrimaryShift;
            float _u_ThirdShift;
            float4 _u_SpecColor1;
            float _u_SpecPower1;
            float _u_SpecStrength;
            float4 _u_SpecColor3;
            float _u_SpecPower3;
            float _u_SpecStrength3;
            // 边缘光
            float3 _u_RimVector;
            float4 _u_RimColor;
            float _u_RimIntensity;
            float _u_RimPower;
            CBUFFER_END
            sampler2D _u_Albedo;
            sampler2D _u_Bump;
            sampler2D _u_UV2Tex;

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float3 normal           : NORMAL;
                float4 tangent          : TANGENT;
                float2 uv               : TEXCOORD0;
                float2 uv1              : TEXCOORD1;
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float2 uv1          : TEXCOORD1;
                float4 tSpace0      : TEXCOORD2;
                float4 tSpace1      : TEXCOORD3;
                float4 tSpace2      : TEXCOORD4;
                float3 positionWS   : TEXCOORD5;
                float3 worldView    :TEXCOORD6;
                float3 rimDirView   :TEXCOORD7;
            };

            half HairSpecular(float3 hDirWS, float3 nDirWS, half specularWidth) {

                float hDotn = dot(hDirWS, nDirWS);
                float sinTH = (sqrt(1 - pow(hDotn, 2)));
                half dirAtten = smoothstep(-1, 0, hDotn);
                half specular = dirAtten * saturate(pow(sinTH, specularWidth));
                return (specular);
            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;
                output.uv1 = input.uv1;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);
                output.positionWS = positionWS;
                output.worldView = normalize(positionWS - _WorldSpaceCameraPos);

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                output.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                output.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                output.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

                float3 rimVector = normalize(_u_RimVector);
                output.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

                return output;
            }

            float4 frag(Varyings input, float facing : VFACE) : SV_Target
            {
                float4 albedoColor = tex2D(_u_Albedo, input.uv);
                float Alpha = albedoColor.a * _u_Color.a;
                float3 WorldNormal = normalize(input.tSpace0.xyz);
                float3 WorldTangent = input.tSpace1.xyz;
                float3 WorldBiTangent = input.tSpace2.xyz;

                float3 WorldPosition = float3(input.tSpace0.w, input.tSpace1.w, input.tSpace2.w);
                float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
                float3 Normal = UnpackNormalScale(tex2D(_u_Bump, input.uv), _u_BumpScale);
                float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                // kk  算法的核心，使用副切并用法线进行偏正
                float3 n1DirWS = normalize(WorldBiTangent + normalWS * (_u_Shift + _u_ThirdShift));
                float3 worldView = -normalize(input.worldView);
                float3 lightDir = normalize(_MainLightPosition.xyz);
                float3 hDir = normalize(worldView + lightDir);
                float HoL = saturate(dot(hDir, lightDir));
                float NoL = saturate(dot(normalWS, lightDir));

                float3 specCol3 = HairSpecular(hDir, n1DirWS, _u_SpecPower3) * _u_SpecColor3.rgb * _u_SpecStrength3;
                //
                float3 n2DirWS = normalize(WorldBiTangent + normalWS * (_u_Shift + _u_MPrimaryShift));
                float3 specCol1 = HairSpecular(hDir, n2DirWS, _u_SpecPower1) * _u_SpecColor1.rgb * _u_SpecStrength;
                float3 specColor = specCol1 + specCol3;

                // 菲尼尔项
                float F = Pow5(1 - HoL);

                float3 uv2TexColor = tex2D(_u_UV2Tex, input.uv1).rgb;
                float3 BaseColor = lerp(albedoColor.rgb * _u_Color.rgb, uv2TexColor.rgb, _u_Blend);
                specColor = specColor * lerp(BaseColor, 1.0f, F);
                //(isFront = (((((gl_FrontFacing) ? (4294967295u) : (0u)) != 0u)) ? (1.0) : (0.0)));
                //float isFront= gl_FrontFacing ? 1.0f : 0.0f;
                float isFront = 1.0f;

                specColor = isFront * specColor;
                float NoRim = saturate(dot(normalWS, input.rimDirView));
                float3 RimColor = min(pow(NoRim * (1 - NoL), _u_RimPower), 1.0f) * _u_RimColor.rgb * _u_RimIntensity;
                RimColor = isFront * RimColor;

                float3 diffuse = _u_GiColor.rgb * _u_IndirectDiffuseIntensity + max(NoL, 0.3f) * _MainLightColor.rgb;

                float3 result = diffuse * BaseColor + specColor + RimColor;

                return float4(result, Alpha);
            }
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
                #pragma fragment frag
                #include "../PBR/ColorCore.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                CBUFFER_START(UnityPerMaterial)
                //half4 _MainTex_TexelSize;
                float4 _u_Albedo_ST;
                float4 _u_Bump_ST;
                float4 _u_UV2Tex_ST;

                float4 _u_Color;
                float4 _u_GiColor;
                float  _u_Blend;
                float _u_BumpScale;
                float _u_IndirectDiffuseIntensity;
                // 各向异性高光
                float _u_Shift;
                float _u_MPrimaryShift;
                float _u_ThirdShift;
                float4 _u_SpecColor1;
                float _u_SpecPower1;
                float _u_SpecStrength;
                float4 _u_SpecColor3;
                float _u_SpecPower3;
                float _u_SpecStrength3;
                // 边缘光
                float3 _u_RimVector;
                float4 _u_RimColor;
                float _u_RimIntensity;
                float _u_RimPower;
                CBUFFER_END
                sampler2D _u_Albedo;
                sampler2D _u_Bump;
                sampler2D _u_UV2Tex;

                struct Attributes
                {
                    float4 positionOS       : POSITION;
                    float3 normal           : NORMAL;
                    float4 tangent          : TANGENT;
                    float2 uv               : TEXCOORD0;
                    float2 uv1              : TEXCOORD1;
                };

                struct Varyings
                {
                    float4 vertex       : SV_POSITION;
                    float2 uv           : TEXCOORD0;
                    float2 uv1          : TEXCOORD1;
                    float4 tSpace0      : TEXCOORD2;
                    float4 tSpace1      : TEXCOORD3;
                    float4 tSpace2      : TEXCOORD4;
                    float3 positionWS   : TEXCOORD5;
                    float3 worldView    :TEXCOORD6;
                    float3 rimDirView   :TEXCOORD7;
                };

                half HairSpecular(float3 hDirWS, float3 nDirWS, half specularWidth) {

                    float hDotn = dot(hDirWS, nDirWS);
                    float sinTH = (sqrt(1 - pow(hDotn, 2)));
                    half dirAtten = smoothstep(-1, 0, hDotn);
                    half specular = dirAtten * saturate(pow(sinTH, specularWidth));
                    return (specular);
                }

                Varyings vert(Attributes input)
                {
                    Varyings output = (Varyings)0;

                    output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                    output.uv = input.uv;
                    output.uv1 = input.uv1;

                    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                    float3 positionVS = TransformWorldToView(positionWS);
                    float4 positionCS = TransformWorldToHClip(positionWS);
                    output.positionWS = positionWS;
                    output.worldView = normalize(positionWS - _WorldSpaceCameraPos);

                    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                    output.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                    output.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                    output.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

                    float3 rimVector = normalize(_u_RimVector);
                    output.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

                    return output;
                }

                float4 frag(Varyings input, float facing : VFACE) : SV_Target
                {
                    float4 albedoColor = tex2D(_u_Albedo, input.uv);
                    float Alpha = albedoColor.a * _u_Color.a;
                    float3 WorldNormal = normalize(input.tSpace0.xyz);
                    float3 WorldTangent = input.tSpace1.xyz;
                    float3 WorldBiTangent = input.tSpace2.xyz;

                    float3 WorldPosition = float3(input.tSpace0.w, input.tSpace1.w, input.tSpace2.w);
                    float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
                    float3 Normal = UnpackNormalScale(tex2D(_u_Bump, input.uv), _u_BumpScale);
                    float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                    // kk  算法的核心，使用副切并用法线进行偏正
                    float3 n1DirWS = normalize(WorldBiTangent + normalWS * (_u_Shift + _u_ThirdShift));
                    float3 worldView = -normalize(input.worldView);
                    float3 lightDir = normalize(_MainLightPosition.xyz);
                    float3 hDir = normalize(worldView + lightDir);
                    float HoL = saturate(dot(hDir, lightDir));
                    float NoL = saturate(dot(normalWS, lightDir));

                    float3 specCol3 = HairSpecular(hDir, n1DirWS, _u_SpecPower3) * _u_SpecColor3.rgb * _u_SpecStrength3;
                    //
                    float3 n2DirWS = normalize(WorldBiTangent + normalWS * (_u_Shift + _u_MPrimaryShift));
                    float3 specCol1 = HairSpecular(hDir, n2DirWS, _u_SpecPower1) * _u_SpecColor1.rgb * _u_SpecStrength;
                    float3 specColor = specCol1 + specCol3;

                    // 菲尼尔项
                    float F = Pow5(1 - HoL);

                    float3 uv2TexColor = tex2D(_u_UV2Tex, input.uv1).rgb;
                    float3 BaseColor = lerp(albedoColor.rgb * _u_Color.rgb, uv2TexColor.rgb, _u_Blend);
                    specColor = specColor * lerp(BaseColor, 1.0f, F);
                    //(isFront = (((((gl_FrontFacing) ? (4294967295u) : (0u)) != 0u)) ? (1.0) : (0.0)));
                    //float isFront= gl_FrontFacing ? 1.0f : 0.0f;
                    float isFront = 1.0f;

                    specColor = isFront * specColor;
                    float NoRim = saturate(dot(normalWS, input.rimDirView));
                    float3 RimColor = min(pow(NoRim * (1 - NoL), _u_RimPower), 1.0f) * _u_RimColor.rgb * _u_RimIntensity;
                    RimColor = isFront * RimColor;

                    float3 diffuse = _u_GiColor.rgb * _u_IndirectDiffuseIntensity + max(NoL, 0.3f) * _MainLightColor.rgb;

                    float3 result = diffuse * BaseColor + specColor + RimColor;

                    return float4(result, Alpha);
                }
                ENDHLSL
            }

        }
        CustomEditor "FoldoutShaderGUI"
}


