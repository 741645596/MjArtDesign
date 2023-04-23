Shader "HappyMJ/Glass"
{
    Properties
    {
        [Foldout] _MainName("主内容控制面板",Range(0,1)) = 0
        [FoldoutItem] _u_MainTex("_u_MainTex", 2D) = "white" {}
        [FoldoutItem] _u_BumpMap("_u_BumpMap", 2D) = "white" {}
        [FoldoutItem] _u_CubeMap("_u_CubeMap   (HDR)", Cube) = "grey" {}
        [FoldoutItem] _u_Distortion("_u_Distortion", Float) = 66.60
        [FoldoutItem] _u_RefractAmount("_u_RefractAmount", Range(0,1)) = 0.80
    }

    SubShader
    {
        Tags {"RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent+200"}
        LOD 100
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            ZTest LEqual
            ZWrite 	On
            Cull Back
    //        Blend SrcAlpha OneMinusSrcAlpha
        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
        float4 _u_MainTex_ST;
        float4 _u_BumpMap_ST;
        float4 _CameraOpaqueTexture_ST;
        float4 _CameraOpaqueTexture_TexelSize;
        float4 _u_CubeMap_HDR;
        float _u_Distortion;
        float _u_RefractAmount;
        CBUFFER_END
        sampler2D _u_MainTex;
        sampler2D _u_BumpMap;
        samplerCUBE _u_CubeMap;
        sampler2D _CameraOpaqueTexture;

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
        float4 uv      : TEXCOORD4;
        float4 screenPos : TEXCOORD5;
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
        output.uv.xy = input.uv.xy * _u_MainTex_ST.xy + _u_MainTex_ST.zw;
        output.uv.zw = input.uv.xy * _u_BumpMap_ST.xy + _u_BumpMap_ST.zw;
        output.screenPos = ComputeScreenPos(output.vertex);

        return output;
    }

    float4 frag(Varyings input) : SV_Target
    {
        float3 Normal = UnpackNormalScale(tex2D(_u_BumpMap, input.uv.zw), 1.0f);
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
        float3 envColor = texCUBE(_u_CubeMap, reflectVector).rgb ;
        //
        float3 mainColor = tex2D(_u_MainTex, input.uv.xy).rgb ;
        float3 resultColor = envColor * envColor;
        // 屏幕
        float2 screenUV = (Normal.xy * _u_Distortion * _CameraOpaqueTexture_TexelSize.xy + input.screenPos.xy) / input.screenPos.w;
        float3 screenColor = tex2D(_CameraOpaqueTexture, screenUV).rgb;

        resultColor = resultColor * (1.0f - _u_RefractAmount) + screenColor * _u_RefractAmount;
        return float4(resultColor, 1.0f);
    }
    ENDHLSL
    }
    }
    CustomEditor "FoldoutShaderGUI"
}
