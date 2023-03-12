Shader "HappyMJ/SkinStock"
{
    Properties
    {
        [Foldout] _CtrlName("控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_Albedo("_u_Albedo", 2D) = "white" {}
        [FoldoutItem] _u_BSSRDFTex("_u_BSSRDFTex", 2D) = "white" {}
        [FoldoutItem] _u_Bump("_u_Bump", 2D) = "white" {}
        [FoldoutItem] _u_GST("_u_GST", 2D) = "white" {}

        [FoldoutItem] _u_AttenColor("_u_AttenColor", Color) = (1.0, 0.92941, 0.85882, 1.00)
        [FoldoutItem] _u_Color("_u_Color", Color) = (1.0, 1.0, 1.0, 1.00)
        [FoldoutItem] _u_DiffuseIntensity("_u_DiffuseIntensity", Float) = 0.32
        [FoldoutItem] _u_DirectSpecularScale("_u_DirectSpecularScale", Float) = 2.0
        [FoldoutItem] _u_FresnalExp_1("_u_FresnalExp_1", Float) = 2.0
        [FoldoutItem] _u_GiColor("_u_GiColor", Color) = (1.0, 1.0, 1.00, 1.00)
        [FoldoutItem] _u_IndirectDiffuseIntensity("_u_IndirectDiffuseIntensity", Float) = 0.70
        [FoldoutItem] _u_MaxOpacity("_u_MaxOpacity", Float) = 0.988
        [FoldoutItem] _u_MaxSpecScale("_u_MaxSpecScale", Float) = 3.20
        [FoldoutItem] _u_MinOpacity("_u_MinOpacity", Float) = 0.988
        [FoldoutItem] _u_ScatteringMapScale("_u_ScatteringMapScale", Float) = 0.60
        [FoldoutItem] _u_TranslucencyColor("_u_TranslucencyColor", Color) = (1.00, 0.00, 0.00, 1.00)

        [Foldout] _RimName("RIM边缘光控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_RimVector("_u_RimVector", Vector) = (0.00, 0.30, -1.00, 1.00)
        [FoldoutItem] _u_RimColor("_u_RimColor", Color) = (1.00, 1.00, 1.00, 1.00)
        [FoldoutItem] _u_RimIntensity("_u_RimIntensity", Range(0 , 50)) = 1
        [FoldoutItem] _u_RimPower("_u_RimPower", Range(0 , 50)) = 0.40
        [FoldoutItem] _u_RimVecto2("_u_RimVecto2", Vector) = (0.00, 0.00, 0.00, 0.00)
        [FoldoutItem] _u_RimVector3("_u_RimVecto3", Vector) = (-0.34, 0.19, 0.33, 1.00)
        [FoldoutItem] _u_RimColor3("_u_RimColor3", Color) = (1.00, 0.49804, 0.31765, 1.00)
        [FoldoutItem] _u_RimIntensity3("_u_RimIntensity3", Float) = 1
        [FoldoutItem] _u_RimPower3("_u_RimPower3", Range(0 , 50)) = 1.0
        //_u_LightShadowData 0.60, 20.00, 0.50, -4.00    float4
        //_u_ShadowColor 1.00, 0.48627, 0.37647, 1.00    float4
        [Foldout] _StockName("Stock控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_SpecularFresnelMult("_u_SpecularFresnelMult", Float) = 0.082
        [FoldoutItem] _u_StockColor("_u_StockColor", Color) = (1.00, 0.49804, 0.31765, 1.00)
        [FoldoutItem] _u_StockFresnelExp("_u_StockFresnelExp", Range(0 , 50)) = 1.60
        [FoldoutItem] _u_StockFresnelMult("_u_StockFresnelMult", Range(0 , 50)) = 1.13
        [FoldoutItem] _u_StockSpecular("_u_StockSpecular", Color) = (1.00, 1.00, 1.00, 1.00)
    }

    SubShader
    {
        Tags {"RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent"}
        LOD 100

        Cull Off
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "../PBR/ColorCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
        //half4 _MainTex_TexelSize;
        float4 _u_Albedo_ST;
        float4 _u_Bump_ST;
        float4 _u_BSSRDFTex_ST;
        float4 _u_GST_ST;

        float4 _u_AttenColor;
        float4 _u_Color;
        float4 _u_GiColor;
        //
        float _u_FresnalExp_1;
        float _u_DiffuseIntensity;
        float _u_DirectSpecularScale;
        float _u_IndirectDiffuseIntensity;
        float _u_MaxSpecScale;
        float _u_ScatteringMapScale;
        float4 _u_TranslucencyColor;
        float _u_MaxOpacity;
        float _u_MinOpacity;
        // 边缘光
        float3 _u_RimVector;
        float4 _u_RimColor;
        float _u_RimIntensity;
        float _u_RimPower;
        float3 _u_RimVector2;
        float3 _u_RimVector3;
        float4 _u_RimColor3;
        float _u_RimIntensity3;
        float _u_RimPower3;
        //
        float _u_SpecularFresnelMult;
        float4 _u_StockColor;
        float _u_StockFresnelExp;
        float _u_StockFresnelMult;
        float4 _u_StockSpecular;

        CBUFFER_END
        sampler2D _u_Albedo;
        sampler2D _u_Bump;
        sampler2D _u_BSSRDFTex;
        sampler2D _u_GST;

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
            float4 tSpace0      : TEXCOORD2;
            float4 tSpace1      : TEXCOORD3;
            float4 tSpace2      : TEXCOORD4;
            float3 positionWS   : TEXCOORD5;
            float3 worldView    :TEXCOORD6;
            float3 rimDirView1   :TEXCOORD7;
            float3 rimDirView2   :TEXCOORD8;
            float3 rimDirView3   :TEXCOORD9;
        };


        Varyings vert(Attributes input)
        {
            Varyings output = (Varyings)0;

            output.vertex = TransformObjectToHClip(input.positionOS.xyz);
            output.uv = input.uv;

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
            output.rimDirView1 = normalize(mul(rimVector, UNITY_MATRIX_V).xyz);

            float3 rimVector2 = normalize(_u_RimVector2);
            output.rimDirView2 = normalize(mul(rimVector2, UNITY_MATRIX_V).xyz);

            float3 rimVector3 = normalize(_u_RimVector3);
            output.rimDirView3 = rimVector3;

            return output;
        }

        float4 frag(Varyings input, float facing : VFACE) : SV_Target
        {
            
            float3 WorldNormal = normalize(input.tSpace0.xyz);
            float3 WorldTangent = input.tSpace1.xyz;
            float3 WorldBiTangent = input.tSpace2.xyz;

            float3 WorldPosition = float3(input.tSpace0.w, input.tSpace1.w, input.tSpace2.w);
            float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
            float3 Normal = UnpackNormalScale(tex2D(_u_Bump, input.uv), 1.0f);
            bool backface = facing < 0.0f;
            if (backface)
            {
                Normal = -Normal;
            }
            float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
            float3 worldView = -normalize(input.worldView);
            float3 lightDir = normalize(_MainLightPosition.xyz);
            float3 hDir = normalize(worldView + lightDir);
            float HoL = saturate(dot(hDir, lightDir));
            float NoL = saturate(dot(normalWS, lightDir));
            float NdotH = saturate(dot(normalWS, hDir));
            //
            float3 albedoColor = tex2D(_u_Albedo, input.uv).rgb * _u_Color.rgb;
            float halfLanbert = HoL * 0.5 + 0.5;
            float3 diffuse = lerp(_u_AttenColor.rgb, 1.0f, halfLanbert);
            //
            float4 gstColor = tex2D(_u_Albedo, input.uv);
            float2 BssrdfUV;
            BssrdfUV.y = gstColor.r;// 存储的是曲率
            BssrdfUV.x = NoL * 0.5 + 0.5; 
            // 叠加透光
            float3 bssrdfTexColor = tex2D(_u_BSSRDFTex, BssrdfUV).rgb;
            float3 translucencyColor = gstColor.z * _u_ScatteringMapScale * _u_TranslucencyColor.rgb;
            translucencyColor = _u_GiColor.xyz * _u_IndirectDiffuseIntensity + translucencyColor;
            float3 upDiffuse = _u_DiffuseIntensity * (diffuse + bssrdfTexColor) + translucencyColor;
            upDiffuse = upDiffuse * albedoColor;

            //
            float F = lerp(0.1546414, 1.0f, Pow5(1.0f - HoL));
            float spec = pow(NdotH, 10.0f) * gstColor.g * _u_MaxSpecScale * F * _u_DirectSpecularScale;

            float3 ResultdiffuseColor = upDiffuse + spec;
            //
            float NdotRim = saturate(dot(normalWS, input.rimDirView1));
            float3 rimColor = saturate(pow(NdotRim * (1 - NoL), _u_RimPower)) * _u_RimColor.rgb * _u_RimIntensity;
            rimColor = rimColor * clamp(gstColor.a, 0, 0.5) * 2;
            ResultdiffuseColor = ResultdiffuseColor + rimColor;
            //
            float3 objRimVector3 = TransformObjectToWorld(input.rimDirView3);
            float3 objNormal = TransformObjectToWorld(normalWS);
            float3 objLightDir = TransformObjectToWorld(lightDir);

            float NdotRim3 = saturate(dot(objNormal, objRimVector3));
            NoL = saturate(dot(objNormal, objLightDir));
            float rim3 = pow((1 - NoL) * NdotRim3, _u_RimPower3) * _u_RimIntensity3;
            rim3 = saturate(rim3);
            rim3 = rim3 * saturate(0.5 - (gstColor.b * _u_ScatteringMapScale));

            ResultdiffuseColor = lerp(ResultdiffuseColor, albedoColor * _u_RimColor3.xyz, rim3);
            ResultdiffuseColor = ResultdiffuseColor * _MainLightColor.rgb;
            // stock了。
            float NoV = saturate(dot(normalWS, worldView));
            float3 stockSpeColor = pow(saturate(NoV), _u_FresnalExp_1)* _u_SpecularFresnelMult * _u_StockSpecular.rgb;
            float stockFresnel= pow(saturate(1 - NoV), _u_StockFresnelExp)* _u_StockFresnelMult;
            stockFresnel = clamp(stockFresnel, _u_MinOpacity, _u_MaxOpacity) * gstColor.a;
            ResultdiffuseColor  = lerp(ResultdiffuseColor, _u_StockColor.rgb, stockFresnel) + stockSpeColor;
            ResultdiffuseColor = saturate(ResultdiffuseColor);
            return float4(ResultdiffuseColor,1.0f);
            }
            ENDHLSL
        }
    }
    CustomEditor "FoldoutShaderGUI"
}


