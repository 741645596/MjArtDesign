#ifndef HAIR_CORE_INCLUDED
#define HAIR_CORE_INCLUDED

#include "Assets/Art/shader/Core/ColorCore.hlsl"
#include "Assets/Art/shader/Core/RoleCore.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
float  _Cutoff;
float4 _Albedo_ST;
float4 _Bump_ST;

float4 _Color;
float4 _GiColor;
float  _Blend;
float _BumpScale;
float _IndirectDiffuseIntensity;
// 各向异性高光
float _Shift;
float _MPrimaryShift;
float _ThirdShift;
float4 _SpecColor1;
float _SpecPower1;
float _SpecStrength;
float4 _SpecColor3;
float _SpecPower3;
float _SpecStrength3;
// 边缘光
float3 _RimVector;
float4 _RimColor;
float _RimIntensity;
float _RimPower;
CBUFFER_END
sampler2D _Albedo;
sampler2D _Bump;
sampler2D _UV2Tex;

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

    float3 rimVector = normalize(_RimVector);
    output.rimDirView = normalize(mul(float4(rimVector, 1), UNITY_MATRIX_V).xyz);

    return output;
}

float4 frag(Varyings input, float facing : VFACE) : SV_Target
{
    float4 albedoColor = tex2D(_Albedo, input.uv);
    float Alpha = albedoColor.a * _Color.a;
    clip(Alpha - _Cutoff);
    float3 WorldNormal = normalize(input.tSpace0.xyz);
    float3 WorldTangent = input.tSpace1.xyz;
    float3 WorldBiTangent = input.tSpace2.xyz;

    float3 WorldPosition = float3(input.tSpace0.w, input.tSpace1.w, input.tSpace2.w);
    float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
    float3 Normal = UnpackNormalScale(tex2D(_Bump, input.uv), _BumpScale);
    float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
    // kk  算法的核心，使用副切并用法线进行偏正
    float3 n1DirWS = normalize(WorldBiTangent + normalWS * (_Shift + _ThirdShift));
    float3 worldView = -normalize(input.worldView);
    float3 lightDir = normalize(_MainLightPosition.xyz);
    float3 hDir = normalize(worldView + lightDir);
    float HoL = saturate(dot(hDir, lightDir));
    float NoL = saturate(dot(normalWS, lightDir));

    float3 specCol3 = HairSpecular(hDir, n1DirWS, _SpecPower3) * _SpecColor3.rgb * _SpecStrength3;
    //
    float3 n2DirWS = normalize(WorldBiTangent + normalWS * (_Shift + _MPrimaryShift));
    float3 specCol1 = HairSpecular(hDir, n2DirWS, _SpecPower1) * _SpecColor1.rgb * _SpecStrength;
    float3 specColor = specCol1 + specCol3;

    // 菲尼尔项
    float F = Pow5(1 - HoL);

    float3 uv2TexColor = tex2D(_UV2Tex, input.uv1).rgb;
    float3 BaseColor = lerp(albedoColor.rgb * _Color.rgb, uv2TexColor.rgb, _Blend);
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
    float3 RimColor = min(pow(NoRim * (1 - NoL), _RimPower), 1.0f) * _RimColor.rgb * _RimIntensity;
    RimColor = isFront * RimColor;

    float3 diffuse = _GiColor.rgb * _IndirectDiffuseIntensity + max(NoL, 0.3f) * _MainLightColor.rgb;

    float3 result = diffuse * BaseColor + specColor + RimColor;

    return float4(result, Alpha);
}

float4 frag1(Varyings input, float facing : VFACE) : SV_Target
{
    float4 albedoColor = tex2D(_Albedo, input.uv);
    float Alpha = albedoColor.a * _Color.a;
    float3 WorldNormal = normalize(input.tSpace0.xyz);
    float3 WorldTangent = input.tSpace1.xyz;
    float3 WorldBiTangent = input.tSpace2.xyz;

    float3 WorldPosition = float3(input.tSpace0.w, input.tSpace1.w, input.tSpace2.w);
    float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
    float3 Normal = UnpackNormalScale(tex2D(_Bump, input.uv), _BumpScale);
    float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
    // kk  算法的核心，使用副切并用法线进行偏正
    float3 n1DirWS = normalize(WorldBiTangent + normalWS * (_Shift + _ThirdShift));
    float3 worldView = -normalize(input.worldView);
    float3 lightDir = normalize(_MainLightPosition.xyz);
    float3 hDir = normalize(worldView + lightDir);
    float HoL = saturate(dot(hDir, lightDir));
    float NoL = saturate(dot(normalWS, lightDir));

    float3 specCol3 = HairSpecular(hDir, n1DirWS, _SpecPower3) * _SpecColor3.rgb * _SpecStrength3;
    //
    float3 n2DirWS = normalize(WorldBiTangent + normalWS * (_Shift + _MPrimaryShift));
    float3 specCol1 = HairSpecular(hDir, n2DirWS, _SpecPower1) * _SpecColor1.rgb * _SpecStrength;
    float3 specColor = specCol1 + specCol3;

    // 菲尼尔项
    float F = Pow5(1 - HoL);

    float3 uv2TexColor = tex2D(_UV2Tex, input.uv1).rgb;
    float3 BaseColor = lerp(albedoColor.rgb * _Color.rgb, uv2TexColor.rgb, _Blend);
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
    float3 RimColor = min(pow(NoRim * (1 - NoL), _RimPower), 1.0f) * _RimColor.rgb * _RimIntensity;
    RimColor = isFront * RimColor;

    float3 diffuse = _GiColor.rgb * _IndirectDiffuseIntensity + max(NoL, 0.3f) * _MainLightColor.rgb;

    float3 result = diffuse * BaseColor + specColor + RimColor;

    return float4(result, Alpha);
}

#endif