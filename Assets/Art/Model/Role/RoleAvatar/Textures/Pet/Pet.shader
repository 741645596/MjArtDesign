Shader "Unlit/Pet"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        

        Pass
        {
            Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
            LOD 100

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = normalize(UnityObjectToClipPos(v.vertex));
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float distToCamera = dot(_uvs_TEXCOORD1.xyz, _uvs_TEXCOORD1.xyz);
                 distToCamera = inversesqrt(distToCamera);
                 
                 // 将像素表面点到摄像机距离乘以光源位置转换到世界空间后的向量，得到视角方向的光照强度
                 vec3 viewSpaceLightDir = vec3(distToCamera) * _u_WorldSpaceLightPos0.xyz;
                 
                 // 计算表面法线与光源方向的点积，并将结果限制在[0,1]范围内
                 float ndotl = dot(_uvs_TEXCOORD1.xyz, viewSpaceLightDir);
                 ndotl = clamp(ndotl, 0.0, 1.0);
                 
                 // 获取主纹理贴图的像素颜色，并将其乘以当前材质的颜色以及光源颜色，得到最终颜色
                 vec3 baseColor = texture(_u_MainTex, _uvs_TEXCOORD0.xy).xyz;
                 vec3 finalColor = baseColor * _u_Color.xyz * _u_LightColor0.xyz;
                 
                 // 将视角方向的光照强度乘以最终颜色，并加上全局环境光颜色，得到最终像素颜色
                 finalColor = vec3(ndotl) * finalColor + _uglstate_lightmodel_ambient.xyz * 2.0;
                 
                 // 输出最终颜色到渲染目标
                 _uSV_Target0.xyz = finalColor;
                 _uSV_Target0.w = 1.0;
            }

            ENDCG
        }
    }
}
