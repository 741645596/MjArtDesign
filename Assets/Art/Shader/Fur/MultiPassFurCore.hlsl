#include "../Common/CommonFunction.hlsl"

struct VertexInput
{
    float4 vertex : POSITION;
    float3 normal   : NORMAL;
    float2 uv : TEXCOORD0;//UV
};

struct VertexOutput
{
    float4 gl_Position  : SV_POSITION;
    float4 uv : TEXCOORD0;//WorldPos
    float4 BlendLightColor : TEXCOORD1;//Diffuse
};

CBUFFER_START(UnityPerMaterial)
    float4 _SubTexUV;
    half _EnvironmentLightInt;
    half _FresnelLV;
    half _FurGravity;
    float4 _BaseColor;
    float _FarSpacing;
    float _FurTickness;
    float4  _MainTex_ST;
CBUFFER_END
sampler2D _FlowTex;
sampler2D _MainTex;


//顶点着色
VertexOutput vert(VertexInput v)
{   
    VertexOutput o = (VertexOutput)0;

    // 计算毛发收重力影响的位置
    float spacing = _FarSpacing * 0.1;
    half4 positionLS;
    positionLS.xyz = normalize(mul(unity_WorldToObject, float3(0,-FUROFFSETVX*2*_FurGravity,0)) + v.normal.xyz) * FUROFFSETVX; //添加简单重力
    positionLS.xyz = positionLS.xyz * spacing * 0.1 + v.vertex.xyz;
    positionLS.w = 1.0;

    float4 posWorld = mul(unity_ObjectToWorld, positionLS);
    o.gl_Position = mul(UNITY_MATRIX_VP, posWorld);
    // uv
    half2 uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.uv.xy = uv;
    o.uv.zw = v.uv * _SubTexUV.xy;

    // 毛发diffuse 的处理
    half3 normalWorld = TransformObjectToWorldNormal(v.normal);
    float3 eyeVec = normalize(posWorld.xyz - _WorldSpaceCameraPos); 
    float nv = saturate(dot(normalWorld, -eyeVec));  

    float3 lightDir = _MainLightPosition.xyz;
    float3 nl = dot(normalWorld, lightDir);
    nl = nl - (0.2 - FUROFFSETVX * 0.1)* (1 - _EnvironmentLightInt); //模拟光穿过毛发

    Light mainLight = GetMainLight();
    half3 sh = SampleSHVertex(normalWorld);
    half FurSSS = sh * pow(1 - nv,4) * (FUROFFSETVX * FUROFFSETVX * FUROFFSETVX * FUROFFSETVX) * 10 * _FresnelLV;
    half3 ambient =  sh  * lerp((FUROFFSETVX * 2 + 0.3), 1.3,  _EnvironmentLightInt);
    half shadowAtten = max(0.1, nl) * mainLight.color;
    o.BlendLightColor.rgb = shadowAtten  + ambient + FurSSS;
    o.BlendLightColor.a = 1.0;

    return o;
} 

half4 frag(VertexOutput v) : SV_Target
{
    half4 Color;
    Color.rgb = tex2D(_MainTex, v.uv.xy).rgb * _BaseColor.rgb * v.BlendLightColor.rgb;
    half flowTex = tex2D(_FlowTex, v.uv.zw).r;
    half furAlphaOffset = pow(FUROFFSETVX , 0.8 + _FurTickness); 
    Color.a = saturate(flowTex.r - pow(furAlphaOffset ,  1 + _FurTickness * 3)) * _BaseColor.a;
    return Color;
}



//顶点着色
VertexOutput vertFirst(VertexInput v)
{   
    VertexOutput o = (VertexOutput)0;

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    o.gl_Position = mul(UNITY_MATRIX_VP, posWorld);

    half2 uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.uv.xy = uv;

    half3 normalWorld = TransformObjectToWorldNormal(v.normal);  //normalWorld
    float3 lightDir = _MainLightPosition.xyz;
    float3 nl = saturate(dot(normalWorld, lightDir));
    nl = nl  - 0.2 * (1 - _EnvironmentLightInt); //模拟光穿过毛发

    half3 sh = SampleSHVertex(normalWorld);
    Light mainLight = GetMainLight();
    half3 ambient =  sh  * lerp(0.3, 1.3, _EnvironmentLightInt);

    o.BlendLightColor.rgb = max(0, nl) * mainLight.color  + ambient;
    o.BlendLightColor.a = 1.0;

    return o;
}

half4 fragFirst(VertexOutput v) : SV_Target
{
    half4 Color;
    Color.rgb = tex2D(_MainTex, v.uv.xy).xyz * _BaseColor.rgb * v.BlendLightColor.rgb;
    Color.a = 1;
    return Color;
}