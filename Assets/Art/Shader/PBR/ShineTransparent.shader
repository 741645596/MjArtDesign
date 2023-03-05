Shader "HappyMJ/ShineTransparent"
{
    Properties
    {
        [Foldout] _PBRName("控制面板",Range(0,1)) = 0
        [FoldoutItem] _CutOff("_CutOff", Float) = 1.00
        [FoldoutItem] [NoScaleOffset] _Albedo("Albedo (RGB) Skin Smoothness or Transparency(A)", 2D) = "white" {}
        [FoldoutItem] [NoScaleOffset] _Bump("Bump Map", 2D) = "bump" {}
        [FoldoutItem] _ShineTex("shine tex", 2D) = "white" {}

        [FoldoutItem] _u_Color("_u_Color", Color) = (1.0, 1.0, 1.00, 1.00)
        [FoldoutItem] _u_DiamondCol("_u_DiamondCol", Color) = (1,1,1,1)
        [FoldoutItem] _u_DiamondCol2("_u_DiamondCol2", Color) = (0.59559, 1.00, 0.98327, 1.00)
        [FoldoutItem] _u_DiamondCol3("_u_DiamondCol3", Color) = (0.68716, 0.30947, 0.79412, 1.00)
        // 直接光
        [FoldoutItem] _u_DirectLightIntensity("_u_DirectLightIntensity", Float) = 0.0
        [FoldoutItem] _u_DirectSpecularScale("_u_DirectSpecularScale", Float) = 1.0
        [FoldoutItem] _u_FracPower("_u_FracPower", Range(0, 100)) = 50
        [FoldoutItem] _u_GiColor("_u_GiColor", Color) = (1.0, 1.0, 1.00, 1.00)
        [FoldoutItem] _u_Glossiness("_u_Glossiness", Float) = 0.14
        // 间接光
        [FoldoutItem] _u_InDirectLightIntensity("_u_InDirectLightIntensity", Float) = 1.20
        [FoldoutItem] _Mask("Mask", Range(0, 1)) = 0.67
        [FoldoutItem] _Power1("Power1", Range(0, 100)) = 20
        [FoldoutItem] _Power2("Power2", Range(0, 100)) = 20
        // 旋转的一个频率
        [FoldoutItem] _u_RotateRate("_u_RotateRate", Range(0, 20)) = 2
        [FoldoutItem] _u_ShineIntensity("_u_ShineIntensity", Range(0, 400)) = 1
        [FoldoutItem] _u_ShineIntensity2("_u_ShineIntensity2", Range(0, 400)) = 1
        [FoldoutItem] _u_ShineSpeed("_u_ShineSpeed", Range(0, 10)) = 1
        [FoldoutItem] _u_UVFrequency("_u_UVFrequency", Range(0, 50)) = 9.90


        [Foldout] _RimName("RIM边缘光控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_RimVector("_u_RimVector", Vector) = (0.00, 0.30, -1.00, 1.00)
        [FoldoutItem]_u_RimColor("_u_RimColor", Color) = (1.00, 1.00, 1.00, 1.00)
        [FoldoutItem] _u_RimIntensity("_u_RimIntensity", Range(0 , 50)) = 1
        [FoldoutItem] _u_RimPower("_u_RimPower", Range(0 , 50)) = 0.40

    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS


            #pragma vertex vert
            #pragma fragment frag

            #define SHADERPASS_FORWARD

            #include "ColorCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct VertexInput
            {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float4 texcoord : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                float4 lightmapUVOrVertexSH : TEXCOORD0;
                half4 vertexLight : TEXCOORD1;
                float4 tSpace0 : TEXCOORD2;
                float4 tSpace1 : TEXCOORD3;
                float4 tSpace2 : TEXCOORD4;
                float2 uv : TEXCOORD5;
                //
                float3 positionWS :TEXCOORD6;
                float3 worldView :TEXCOORD7;
                float3 rimDirView :TEXCOORD8;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _Albedo_ST;
            float4 _ShineTex_ST;
            float4 _Bump_ST;

            float _CutOff;
            float4 _u_Color;
            float4 _u_DiamondCol;
            float4 _u_DiamondCol2;
            float4 _u_DiamondCol3;
            // 直接光
            float _u_DirectLightIntensity;
            float _u_DirectSpecularScale;
            float _u_FracPower;
            float4 _u_GiColor;
            float _u_Glossiness;
            // 间接光
            float _u_InDirectLightIntensity;
            float _Mask;
            float _Power1;
            float _Power2;
            // 旋转的一个频率
            float _u_RotateRate;
            float _u_ShineIntensity;
            float _u_ShineIntensity2;
            float _u_ShineSpeed;
            float _u_UVFrequency;
            //
            float3 _u_RimVector;
            float4 _u_RimColor;
            float _u_RimIntensity;
            float _u_RimPower;

            CBUFFER_END
            sampler2D _Albedo;
            sampler2D _ShineTex;
            sampler2D _Bump;


            VertexOutput VertexFunction(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                o.uv.xy = v.texcoord.xy;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);
                o.positionWS = positionWS;
                o.worldView = normalize(positionWS - _WorldSpaceCameraPos);

                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

                o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);


                half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);

                o.vertexLight = half4(vertexLight, 0);


                float3 rimVector = normalize(_u_RimVector);
                o.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

                o.clipPos = positionCS;

                return o;
            }


            VertexOutput vert(VertexInput v)
            {
                return VertexFunction(v);
            }

            float4 frag (VertexOutput IN, float facing : VFACE) : SV_Target
            {
                float3 WorldNormal = normalize(IN.tSpace0.xyz);
                float3 WorldTangent = IN.tSpace1.xyz;
                float3 WorldBiTangent = IN.tSpace2.xyz;

                // cut off
                float2 uv_BaseMap = IN.uv.xy * _Albedo_ST.xy + _Albedo_ST.zw;
                float4 albedoColor = tex2D(_Albedo, uv_BaseMap);
                float Alpha = albedoColor.a;
                clip(Alpha - _CutOff);
                float3 Albedo = albedoColor.rgb * _u_Color.rgb;

                float3 ShineColor = tex2D(_ShineTex, IN.uv.xy * _u_UVFrequency).rgb;

                float2 uv_NormalMap = IN.uv.xy * _Bump_ST.xy + _Bump_ST.zw;
                float3 Normal = UnpackNormalScale(tex2D(_Bump, uv_NormalMap), 1.0f);
                bool backface = facing < 0.0f;
                if (backface)
                {
                    Normal = -Normal;
                }
                // 算法线
                float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                // 计算PBR相关数据
                float3 lightDir = _MainLightPosition; // 平行光就是方向了
                float3 WorldviewDir = IN.worldView;

                float NoL = saturate(dot(normalWS, lightDir));
                float3 hDir = normalize((lightDir + WorldviewDir));
                float NoH = saturate(dot(normalWS, hDir));
                float NoV = saturate(dot(normalWS, WorldviewDir));
                float HoL = saturate(dot(lightDir, hDir));
                float LoV = saturate(dot(lightDir, WorldviewDir));

                float perceptualRoughness = (1 - _u_Glossiness);
                float roughness = perceptualRoughness * perceptualRoughness;
                float roughness2 = roughness * roughness;
                float diffuseTerm = NoL * 0.5f + 0.5f; // lanbert  方案
                //  直接高光部分
                float V = Vis_SmithJointApprox_Plus(roughness, NoV, NoL);
                float D = D_GGX_UE4(roughness2, NoH);
                float F = Pow5(1 - HoL);
                // PBR 直接高光计算
                float3  frenel = lerp(saturate(Albedo * 0.8453586f), 1.0f, F);
                float SpecXXXXXXX = max(0, frenel * NoL * D * V * PI * _u_DirectSpecularScale);
                // shine
                // 用来计算 Shiness的Deon关系
                float rotateshine = (WorldviewDir.y - WorldviewDir.x - WorldviewDir.z) * _u_RotateRate + ShineColor.x;
                rotateshine = rotateshine + (_Time.x * _u_ShineSpeed);
                float tmpvar_56;
                tmpvar_56 = (ShineColor.y * 2);
                float _tmp_dvx_56 = saturate(tmpvar_56 - 1);
                float _tmp_dvx_57 = saturate(tmpvar_56);
                float3 lerp12 = lerp(_u_DiamondCol.rgb, _u_DiamondCol2.rgb, _tmp_dvx_57);
                float3 lerp123 = lerp(lerp12, _u_DiamondCol3.rgb, _tmp_dvx_56);
                float3 ShineSpec1 = pow(((frac((rotateshine + ShineColor.x)) * ShineColor.z) - _Mask), 3) * _u_ShineIntensity;
                float3 ShineSpec2 = pow(saturate(ShineSpec1), _u_FracPower) * ShineColor.z * _u_ShineIntensity2;

                float3 shineColor = lerp123 * ShineSpec2;
                
                float lerpP1P2 = lerp(_Power1, _Power2, LoV);
                shineColor = SpecXXXXXXX * pow(NoH, lerpP1P2) * shineColor;

                // 边缘光
                float3 rimLightDirection = IN.rimDirView;

                float3 giDiffuse = _u_GiColor.rgb * _u_InDirectLightIntensity + diffuseTerm * _u_DirectLightIntensity;
                float NoRim = saturate(dot(normalWS, rimLightDirection));
                float rimParam = saturate(1 - NoL) * NoRim;
                float rimXXX = saturate(pow(rimParam, _u_RimPower));
                float3 rimResult = saturate(_u_RimColor.rgb * rimXXX * _u_RimIntensity);

                float3 resultColor = saturate(Albedo) * giDiffuse + SpecXXXXXXX + rimResult;
                resultColor = resultColor + shineColor;

                resultColor = resultColor * Alpha * _MainLightColor.xyz;
                return float4(resultColor, 1.0f);
            }
            ENDHLSL
        }
        Pass
        {
            Name "ALPHA BLENDING"
            Tags
            {
                //"LightMode" = "UniversalForward" 
                "LIGHTMODE" = "Fpass1"
                "QUEUE" = "Transparent+2"
                "RenderType" = "Transparent"
             }
            ZTest Less
            ZWrite Off
            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha One

            HLSLPROGRAM
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS


            #pragma vertex vert
            #pragma fragment frag

            #define SHADERPASS_FORWARD

            #include "ColorCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct VertexInput
            {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float4 texcoord : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                float4 lightmapUVOrVertexSH : TEXCOORD0;
                half4 vertexLight : TEXCOORD1;
                float4 tSpace0 : TEXCOORD2;
                float4 tSpace1 : TEXCOORD3;
                float4 tSpace2 : TEXCOORD4;
                float2 uv : TEXCOORD5;
                //
                float3 positionWS :TEXCOORD6;
                float3 worldView :TEXCOORD7;
                float3 rimDirView :TEXCOORD8;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _Albedo_ST;
            float4 _ShineTex_ST;
            float4 _Bump_ST;

            float4 _u_Color;
            float4 _u_DiamondCol;
            float4 _u_DiamondCol2;
            float4 _u_DiamondCol3;
            // 直接光
            float _u_DirectLightIntensity;
            float _u_DirectSpecularScale;
            float _u_FracPower;
            float4 _u_GiColor;
            float _u_Glossiness;
            // 间接光
            float _u_InDirectLightIntensity;
            float _Mask;
            float _Power1;
            float _Power2;
            // 旋转的一个频率
            float _u_RotateRate;
            float _u_ShineIntensity;
            float _u_ShineIntensity2;
            float _u_ShineSpeed;
            float _u_UVFrequency;
            //
            float3 _u_RimVector;
            float4 _u_RimColor;
            float _u_RimIntensity;
            float _u_RimPower;

            CBUFFER_END
            sampler2D _Albedo;
            sampler2D _ShineTex;
            sampler2D _Bump;


            VertexOutput VertexFunction(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                o.uv.xy = v.texcoord.xy;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);
                o.positionWS = positionWS;
                o.worldView = normalize(positionWS - _WorldSpaceCameraPos);

                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

                o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);


                half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);

                o.vertexLight = half4(vertexLight, 0);


                float3 rimVector = normalize(_u_RimVector);
                o.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

                o.clipPos = positionCS;

                return o;
            }


            VertexOutput vert(VertexInput v)
            {
                return VertexFunction(v);
            }

            float4 frag(VertexOutput IN) : SV_Target
            {
                float3 WorldNormal = normalize(IN.tSpace0.xyz);
                float3 WorldTangent = IN.tSpace1.xyz;
                float3 WorldBiTangent = IN.tSpace2.xyz;

                // cut off
                float2 uv_BaseMap = IN.uv.xy * _Albedo_ST.xy + _Albedo_ST.zw;
                float4 albedoColor = tex2D(_Albedo, uv_BaseMap);
                float Alpha = albedoColor.a;
                float3 Albedo = albedoColor.rgb * _u_Color.rgb;

                float3 ShineColor = tex2D(_ShineTex, IN.uv.xy * _u_UVFrequency).rgb;

                float2 uv_NormalMap = IN.uv.xy * _Bump_ST.xy + _Bump_ST.zw;
                float3 Normal = UnpackNormalScale(tex2D(_Bump, uv_NormalMap), 1.0f);
                // 算法线
                float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                // 计算PBR相关数据
                float3 lightDir = _MainLightPosition; // 平行光就是方向了
                float3 WorldviewDir = IN.worldView;

                float NoL = saturate(dot(normalWS, lightDir));
                float3 hDir = normalize((lightDir + WorldviewDir));
                float NoH = saturate(dot(normalWS, hDir));
                float NoV = saturate(dot(normalWS, WorldviewDir));
                float HoL = saturate(dot(lightDir, hDir));
                float LoV = saturate(dot(lightDir, WorldviewDir));

                float perceptualRoughness = (1 - _u_Glossiness);
                float roughness = perceptualRoughness * perceptualRoughness;
                float roughness2 = roughness * roughness;
                float diffuseTerm = NoL * 0.5f + 0.5f; // lanbert  方案
                //  直接高光部分
                float V = Vis_SmithJointApprox_Plus(roughness, NoV, NoL);
                float D = D_GGX_UE4(roughness2, NoH);
                float F = Pow5(1 - HoL);
                // PBR 直接高光计算
                float3  frenel = lerp(saturate(Albedo * 0.8453586f), 1.0f, F);
                float SpecXXXXXXX = max(0, frenel * NoL * D * V * PI * _u_DirectSpecularScale);
                // shine
                // 用来计算 Shiness的Deon关系
                float rotateshine = (WorldviewDir.y - WorldviewDir.x - WorldviewDir.z) * _u_RotateRate + ShineColor.x;
                rotateshine = rotateshine + (_Time.x * _u_ShineSpeed);
                float tmpvar_56;
                tmpvar_56 = (ShineColor.y * 2);
                float _tmp_dvx_56 = saturate(tmpvar_56 - 1);
                float _tmp_dvx_57 = saturate(tmpvar_56);
                float3 lerp12 = lerp(_u_DiamondCol.rgb, _u_DiamondCol2.rgb, _tmp_dvx_57);
                float3 lerp123 = lerp(lerp12, _u_DiamondCol3.rgb, _tmp_dvx_56);
                float3 ShineSpec1 = pow(((frac((rotateshine + ShineColor.x)) * ShineColor.z) - _Mask), 3) * _u_ShineIntensity;
                float3 ShineSpec2 = pow(saturate(ShineSpec1), _u_FracPower) * ShineColor.z * _u_ShineIntensity2;

                float3 shineColor = lerp123 * ShineSpec2;

                float lerpP1P2 = lerp(_Power1, _Power2, LoV);
                shineColor = SpecXXXXXXX * pow(NoH, lerpP1P2) * shineColor;

                // 边缘光
                float3 rimLightDirection = IN.rimDirView;

                float3 giDiffuse = _u_GiColor.rgb * _u_InDirectLightIntensity + diffuseTerm * _u_DirectLightIntensity;
                float NoRim = saturate(dot(normalWS, rimLightDirection));
                float rimXXX = saturate(pow((1 - NoL) * NoRim, _u_RimPower));
                float3 rimResult = saturate(_u_RimColor.rgb * rimXXX * _u_RimIntensity);
                float3 resultColor = saturate(Albedo) * giDiffuse + SpecXXXXXXX + rimResult;
                resultColor = resultColor + shineColor;

                resultColor = resultColor * Alpha * _MainLightColor.xyz;
                return float4(resultColor, Alpha);
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS


            #pragma vertex vert
            #pragma fragment frag

            #define SHADERPASS_FORWARD

            #include "ColorCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct VertexInput
            {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float4 texcoord : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                float4 lightmapUVOrVertexSH : TEXCOORD0;
                half4 vertexLight : TEXCOORD1;
                float4 tSpace0 : TEXCOORD2;
                float4 tSpace1 : TEXCOORD3;
                float4 tSpace2 : TEXCOORD4;
                float2 uv : TEXCOORD5;
                //
                float3 positionWS :TEXCOORD6;
                float3 worldView :TEXCOORD7;
                float3 rimDirView :TEXCOORD8;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _Albedo_ST;
            float4 _ShineTex_ST;
            float4 _Bump_ST;

            float _CutOff;
            float4 _u_Color;
            float4 _u_DiamondCol;
            float4 _u_DiamondCol2;
            float4 _u_DiamondCol3;
            // 直接光
            float _u_DirectLightIntensity;
            float _u_DirectSpecularScale;
            float _u_FracPower;
            float4 _u_GiColor;
            float _u_Glossiness;
            // 间接光
            float _u_InDirectLightIntensity;
            float _Mask;
            float _Power1;
            float _Power2;
            // 旋转的一个频率
            float _u_RotateRate;
            float _u_ShineIntensity;
            float _u_ShineIntensity2;
            float _u_ShineSpeed;
            float _u_UVFrequency;
            //
            float3 _u_RimVector;
            float4 _u_RimColor;
            float _u_RimIntensity;
            float _u_RimPower;

            CBUFFER_END
            sampler2D _Albedo;
            sampler2D _ShineTex;
            sampler2D _Bump;


            VertexOutput VertexFunction(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                o.uv.xy = v.texcoord.xy;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);
                o.positionWS = positionWS;
                o.worldView = normalize(positionWS - _WorldSpaceCameraPos);

                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

                o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);


                half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);

                o.vertexLight = half4(vertexLight, 0);


                float3 rimVector = normalize(_u_RimVector);
                o.rimDirView = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

                o.clipPos = positionCS;

                return o;
            }


            VertexOutput vert(VertexInput v)
            {
                return VertexFunction(v);
            }

            float4 frag(VertexOutput IN) : SV_Target
            {
                float3 WorldNormal = normalize(IN.tSpace0.xyz);
                float3 WorldTangent = IN.tSpace1.xyz;
                float3 WorldBiTangent = IN.tSpace2.xyz;

                // cut off
                float2 uv_BaseMap = IN.uv.xy * _Albedo_ST.xy + _Albedo_ST.zw;
                float4 albedoColor = tex2D(_Albedo, uv_BaseMap);
                float Alpha = albedoColor.a;
                float3 Albedo = albedoColor.rgb * _u_Color.rgb;

                float3 ShineColor = tex2D(_ShineTex, IN.uv.xy * _u_UVFrequency).rgb;

                float2 uv_NormalMap = IN.uv.xy * _Bump_ST.xy + _Bump_ST.zw;
                float3 Normal = UnpackNormalScale(tex2D(_Bump, uv_NormalMap), 1.0f);
                // 算法线
                float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                // 计算PBR相关数据
                float3 lightDir = _MainLightPosition; // 平行光就是方向了
                float3 WorldviewDir = IN.worldView;

                float NoL = saturate(dot(normalWS, lightDir));
                float3 hDir = normalize((lightDir + WorldviewDir));
                float NoH = saturate(dot(normalWS, hDir));
                float NoV = saturate(dot(normalWS, WorldviewDir));
                float HoL = saturate(dot(lightDir, hDir));
                float LoV = saturate(dot(lightDir, WorldviewDir));

                float perceptualRoughness = (1 - _u_Glossiness);
                float roughness = perceptualRoughness * perceptualRoughness;
                float roughness2 = roughness * roughness;
                float diffuseTerm = NoL * 0.5f + 0.5f; // lanbert  方案
                //  直接高光部分
                float V = Vis_SmithJointApprox_Plus(roughness, NoV, NoL);
                float D = D_GGX_UE4(roughness2, NoH);
                float F = Pow5(1 - HoL);
                // PBR 直接高光计算
                float3  frenel = lerp(saturate(Albedo * 0.8453586f), 1.0f, F);
                float SpecXXXXXXX = max(0, frenel * NoL * D * V * PI * _u_DirectSpecularScale);
                // shine
                // 用来计算 Shiness的Deon关系
                float rotateshine = (WorldviewDir.y - WorldviewDir.x - WorldviewDir.z) * _u_RotateRate + ShineColor.x;
                rotateshine = rotateshine + (_Time.x * _u_ShineSpeed);
                float tmpvar_56;
                tmpvar_56 = (ShineColor.y * 2);
                float _tmp_dvx_56 = saturate(tmpvar_56 - 1);
                float _tmp_dvx_57 = saturate(tmpvar_56);
                float3 lerp12 = lerp(_u_DiamondCol.rgb, _u_DiamondCol2.rgb, _tmp_dvx_57);
                float3 lerp123 = lerp(lerp12, _u_DiamondCol3.rgb, _tmp_dvx_56);
                float3 ShineSpec1 = pow(((frac((rotateshine + ShineColor.x)) * ShineColor.z) - _Mask), 3) * _u_ShineIntensity;
                float3 ShineSpec2 = pow(saturate(ShineSpec1), _u_FracPower) * ShineColor.z * _u_ShineIntensity2;

                float3 shineColor = lerp123 * ShineSpec2;

                float lerpP1P2 = lerp(_Power1, _Power2, LoV);
                shineColor = SpecXXXXXXX * pow(NoH, lerpP1P2) * shineColor;

                // 边缘光
                float3 rimLightDirection = IN.rimDirView;

                float3 giDiffuse = _u_GiColor.rgb * _u_InDirectLightIntensity + diffuseTerm * _u_DirectLightIntensity;
                float NoRim = saturate(dot(normalWS, rimLightDirection));
                float rimXXX = saturate(pow((1 - NoL) * NoRim, _u_RimPower));
                float3 rimResult = saturate(_u_RimColor.rgb * rimXXX * _u_RimIntensity);
                float3 resultColor = saturate(Albedo) * giDiffuse + SpecXXXXXXX + rimResult;
                resultColor = resultColor + shineColor;

                resultColor = resultColor * Alpha * _MainLightColor.xyz;
                return float4(resultColor, Alpha);
            }
            ENDHLSL
        }
    }
    CustomEditor "FoldoutShaderGUI"
}
