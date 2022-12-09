Shader "mj/mj_tuyoo"
{
    // https://zhuanlan.zhihu.com/p/478462422
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _SubTex("SubTex", 2D) = "white" {}
        _MatCapDiffuse("MatCapDiffuse", 2D) = "white" {}
        _SubMatCapDiffuse("SubMatCapDiffuse", 2D) = "white" {}

        _FirstLight("_FirstLight", Vector) = (0.10, -0.47, 0.74, 0)
        _SecondLight("_SecondLight", Vector) = (0, 2.92, -10.95, 0)
        _LightRadius("_LightRadius", Float) = 80.0
        _SubLightRadius("_SubLightRadius", Float) = 80.0
        _MatCapRotation("_MatCapRotation", Int) = 125
        _SubMatCapRotation("_SubMatCapRotation", Int) = 125
        //
        _MainColor("MainColor", Color) = (0.50289, 0.50289, 0.50289, 1)
        _SecondColor("_SecondColor", Color) = (1.0, 1.0, 1.0, 1)
        _SpecularColor("_SpecularColor", Color) = (0.5972, 0.69387, 0.47353, 1)
        _Shininess("_Shininess", Float) = 24.0

        _SubSecondColor("_SubSecondColor", Color) = (1.0, 1.0, 1.0, 1)
        _SubSpecularColor("_SubSpecularColor", Color) = (0.5972, 0.69387, 0.47353, 1)
        _SubShininess("_SubShininess", Float) = 24.0
    }
        SubShader
        {
            Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"  }
            LOD 300

            Pass
            {
                Name "ForwardLit"
                Tags{"LightMode" = "UniversalForward"}


                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normalOS	: NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float4 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float3 lightDir	: TEXCOORD1;
                    float3 normal  : TEXCOORD2;
                    float3 viewDirWS : TEXCOORD3;
                    float3 cumsTomData	: TEXCOORD4;

                };
                CBUFFER_START(UnityPerMaterial)
                    float4 _MainTex_ST;
                    float4 _MatCapDiffuse_ST;
                    float3 _FirstLight;
                    float _LightRadius;
                    int _MatCapRotation;
                    float4 _MainColor;
                    float4 _SecondColor;
                    float4 _SpecularColor;
                    float _Shininess;
                    //
                    float4 _SubTex_ST;
                    float4 _SubMatCapDiffuse_ST;
                    float3 _SecondLight;
                    float _SubLightRadius;
                    int _SubMatCapRotation;
                    float4 _SubSecondColor;
                    float4 _SubSpecularColor;
                    float _SubShininess;
                CBUFFER_END
                sampler2D _MainTex;
                sampler2D _SubTex;
                sampler2D _MatCapDiffuse;
                sampler2D _SubMatCapDiffuse;


                v2f vert(appdata v)
                {
                    v2f o;
                    // matcap 需法向量采样。
                    float3 normalOS = normalize(v.normalOS);
                    float3 normalWS = TransformObjectToWorldNormal(normalOS);
                    float3 normalVS = TransformWorldToViewDir(normalWS, true);
                    // 计算uv
                    float2 Mainuv;
                    Mainuv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                    //float3 u_xlatb1 = greaterThanEqual(float4(0.0908203125, 0.185546875, 0.45703125, 0.0), Mainuv.yyxy).xyz;
                    float3 u_xlatb1 = step(float4(0.0908203125, 0.185546875, 0.45703125, 0.0), Mainuv.yyxy).xyz;
                    float3 u_xlat1 = saturate(u_xlatb1);
                    u_xlat1.x = u_xlat1.y * u_xlat1.z + u_xlat1.x;
                    u_xlat1.x = min(u_xlat1.x, 1.0);
                    //float u_xlatb7 = Mainuv.x >= 0.3125;
                    //float u_xlatb7 = Mainuv.x >= 0.1125;
                    float u_xlatb7 = Mainuv.x >= 0;
                    o.uv.xy = Mainuv.xy;
                    // 确定是否正面
                    Mainuv.x = u_xlatb7 ? 1.0 : float(0.0);
                    Mainuv.y = Mainuv.x * u_xlat1.x;
                    Mainuv.x = (-u_xlat1.x) * Mainuv.x + 1.0;
                    // 法向量采样uv，这里采取进行旋转。
                    float Deg2Rad = 0.0174532924f;  // 角度转弧度
                    float2 Rotation = float2(_MatCapRotation, _SubMatCapRotation) * Mainuv.xy;
                    float RotationAngle = Rotation.x * Deg2Rad + Rotation.y * Deg2Rad;
                    float u_xlat16_2 = sin(RotationAngle);
                    float u_xlat16_3 = cos(RotationAngle);
                    float3 u_xlat16_4;
                    u_xlat16_4.x = (-u_xlat16_2);
                    u_xlat16_4.y = u_xlat16_3;
                    u_xlat16_4.z = u_xlat16_2;
                    float2 u_xlat13;
                    u_xlat13.y = dot(u_xlat16_4.zy, normalVS.xy);
                    u_xlat13.x = dot(u_xlat16_4.yx, normalVS.xy);
                    o.uv.zw = u_xlat13.xy * float2(0.5, 0.5) + float2(0.5, 0.5);
                    // 灯光方向
                    o.lightDir = (-_FirstLight.xyz);
                    o.normal = TransformObjectToWorldNormal(v.normalOS);
                    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                    o.viewDirWS = (-positionWS) + _WorldSpaceCameraPos.xyz;
                    o.vertex = TransformWorldToHClip(positionWS);
                    // secondlight 入射方向
                    float3 secondLightDir = (-positionWS) + _SecondLight;
                    float lenght = length(secondLightDir);
                    secondLightDir = normalize(secondLightDir);
                    float NdotL = saturate(dot(secondLightDir, o.normal));

                    float r2 = saturate(lenght / _SubLightRadius);
                    r2 = 1.0 - r2 * r2;
                    float r1 = saturate(lenght / _LightRadius);
                    r1 = 1.0 - r1 * r1;
                    float controlValue = Mainuv.x * r1 + Mainuv.y * r2;
                    // 灯光方向相关
                    o.cumsTomData = NdotL * controlValue;
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    /*******************采样diffuse mainTex*************/
                    float3 mainColor = tex2D(_MainTex, i.uv.xy).rgb;
                    float3 subColor = tex2D(_SubTex, i.uv.xy * float2(1.0, 4.0)).rgb;
                    // 采样次纹理
                    //float4 u_xlatb2 = greaterThanEqual(float4(0.0322265625, 0.185546875, 0.45703125, 0.189999998), i.uv.yyxy);
                    float4 u_xlatb2 = step(float4(0.0322265625, 0.185546875, 0.45703125, 0.189999998), i.uv.yyxy);
                    float4 u_xlat2 = saturate(u_xlatb2);
                    // 通过uv判断是否麻将正面了, 先通过uv 判断，采样到正确的主次纹理
                    //float u_xlat18 = step(0.3125, i.uv.x);// x >= 0.3125 ? 1: 0;
                    float u_xlat18 = step(0, i.uv.x);
                    float3 mainDiffuseColor = lerp(subColor, mainColor, u_xlat18 * u_xlat2.w);// 混合主次纹理
                    // 加入控制颜色。
                    u_xlat2.x = u_xlat2.y * u_xlat2.z + u_xlat2.x;
                    u_xlat2.x = min(u_xlat2.x, 1.0);
                    float isSub = u_xlat18 * u_xlat2.x;// 1 :Sub 0: no Sub
                    float isMain = (-u_xlat2.x) * u_xlat18 + 1.0; // 1 :main 0: no main
                    float3 controlMainColor = isSub * _SubSecondColor.xyz + isMain * _SecondColor.xyz;
                    mainDiffuseColor = mainDiffuseColor * controlMainColor;
                    /*******************采样diffuse matCap*******************/
                    // 采样submatcap
                    float3 capDiffuse = tex2D(_SubMatCapDiffuse, i.uv.zw).xyz * isSub + tex2D(_MatCapDiffuse, i.uv.zw).xyz * isMain;
                    float3 subSpecularColorControl = isSub * _SubSpecularColor.xyz;
                    float3 SpecularColorControl = isMain * _SpecularColor.xyz;
                    // 得到diffuse了
                    float3 diffuse = mainDiffuseColor * capDiffuse * _MainColor.xyz + mainDiffuseColor * i.cumsTomData.xyz; 
                    // spec
                    float3 lightDir = normalize(i.lightDir);
                    float3 normalWS = normalize(i.normal);
                    float3 reflectDir = 2 * dot(lightDir, normalWS) * normalWS - lightDir;
                    float3 viewDirWS = normalize(i.viewDirWS);
                    //  高光phone 模型，计算高光。
                    float RdotV = saturate(dot(reflectDir, viewDirWS));
                    float3 spec = pow(RdotV, _Shininess) * SpecularColorControl;
                    float3 subSpec = pow(RdotV, _SubShininess) * subSpecularColorControl;
                    // diffuse + spec
                    float4 color;
                    color.rgb = diffuse + spec + subSpec;
                    color.a = 1.0f;
                    return color;
                  }
                  ENDHLSL
              }
        }
}
