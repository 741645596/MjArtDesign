Shader "Charactor/SGameSkin2U"
{
    Properties
    {
        _BaseColor("RGB:颜色 A:透明度", Color) = (1.0,1.0,1.0,1.0)
        [NoScaleOffset]_BaseMap("颜色贴图", 2D) = "white" {}
        [NoScaleOffset]_NormalMap("法线贴图", 2D) = "bump" {}
        [NoScaleOffset]_SkinMap("RGB: 曲率 AO 光滑度", 2D) = "white" {}
    

        // _BlushArea("腮红位置", 2D) = "black"{}
        // _BlushColor("腮红颜色", Color) = (1,0,0,0)
        // _BlushInt("腮红强度", Range(0, 2)) = 1

        _SSSRange("3S额外强度", Range( -1 , 1)) = 0
        _Occlusion("AO强度", Range( 0 , 1)) = .5

        [Space(15)]
        _lobe0Smoothness("皮肤光滑度", Range( 0.0 , 1.0)) = 1.0
       
      

        _EnvDiffInt("环境补光强度", Range(1.0, 3.0)) = 1.0
   

        _SSSLUT("3S查找表", 2D) = "black" {}

        _ThickMap("厚度贴图",2D) = "white" {}
        _BackLightIntensity("透光强度",Range(0.0, 1.0)) = 1.0
        _BackLightColor("透光颜色", Color) = (1.0,1.0,1.0,1.0)
        
        [Toggle]_Open2UDecal("2U贴图", Range(0,1)) = 0
        _BaseMap_2U("RGB:颜色 A:Mask", 2D) = "white"{}
        _BaseColor_2U("2U Color", Color) =  (1.0,1.0,1.0,1.0)
        _Metallic_2U("M_2U", Range(0, 1)) = 0.0
        _Smoothness_2U("S_2U", Range(0, 1)) = 0.5
        _Normal_2U("N_2U", Range(0, 1)) = 0.5


        [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _BlendOp("__blendop", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
        [HideInInspector] _ReceiveShadows("Receive Shadows", Float) = 1.0

    }

    HLSLINCLUDE
    #include "../Common/CommonFunction.hlsl"
    #include "../Charactor/SkinFunction.hlsl"
    #include "../Common/GlobalIllumination.hlsl"

    
    
    CBUFFER_START(UnityPerMaterial)
        half4 _BaseColor;

        float4 _BaseMap_ST;

        half  _SSSRange;
        float  _lobe0Smoothness;
        float _lobe1Smoothness;
        float _LobeMix;
        half  _Occlusion;
        half _EnvDiffInt;
        half _PBRToDiffuse;
        half _DiffusePower;
        half _BlushInt;
        half4 _BlushColor;
        half4 _BaseColor_2U;
        half3 _BackLightColor;
        

        half  _BackLightIntensity;

        half _Cutoff;

        // shadow
        //阴影颜色 目前由外部脚本设定 UpdateShadowPlane.cs
        half4 _ShadowColor;
        //阴影平面的高度 目前由外部脚本设定 UpdateShadowPlane.cs
        float _ShadowHeight;
        //XZ平面的偏移
        float _ShadowOffsetX;
        float _ShadowOffsetZ;

        //模型高度 由外部脚本设定 UpdateShadowPlane.cs
        float _MeshHight;
        //模型位置 由外部脚本设定 UpdateShadowPlane.cs
        float4 _WorldPos;
        //影子透明度
        half _AlphaVal;

        half3 _ProGameOutDir;
        half _ShadowStr=1;
        half _Metallic_2U;
        half _Smoothness_2U;
        half _Normal_2U;
    

    CBUFFER_END
    TEXTURE2D(_BaseMap_2U);   SAMPLER(sampler_BaseMap_2U);
    TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
    TEXTURE2D(_SkinMap);        SAMPLER(sampler_SkinMap);
    TEXTURE2D(_NormalMap);      SAMPLER(sampler_NormalMap);
    TEXTURE2D(_BlushArea);      SAMPLER(sampler_BlushArea);
    TEXTURE2D_HALF(_SSSLUT);    SAMPLER(sampler_SSSLUT);
    TEXTURE2D_HALF(_ThickMap);  SAMPLER(sampler_ThickMap);
    ENDHLSL

    SubShader
    {
        Tags { 
            "RenderPipeline"="UniversalRenderPipline"
            "RenderType"="Opaque" 
        }
        
        Pass{

            Name "SGameSkin"
            Tags{ "LightMode" = "UniversalForward" }

            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend]

            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM

            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _RECEIVE_SHADOWS_OFF
            #pragma shader_feature _ ENABLE_HQ_SHADOW ENABLE_HQ_AND_UNITY_SHADOW

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _SHADOWS_SOFT
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_instancing
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile _ _OPEN2UDECAL

            #pragma instancing_options renderinglayer
  

            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 vertex           : POSITION;
                float3 normal           : NORMAL;
                float4 tangent          : TANGENT;
                float2 uv               : TEXCOORD0;
                float2 uv1              : TEXCOORD1;
           
            };
            
            struct Varyings
            {
                float4 vertex           : SV_POSITION;
                float2 uv               : TEXCOORD0;
                float2 uv1              : TEXCOORD1;
                float4 world_normal     : TEXCOORD2;
                float4 world_tangent    : TEXCOORD3;
                float4 world_binormal   : TEXCOORD4;

                #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
                    float4 shadowCoord  : TEXCOORD5;
                #endif

                DECLARE_LIGHTMAP_OR_SH(uv1, vertexSH, 6);
            };

            struct SurfaceDataSkin
            {
                // 为了传参方便
                // pbr参数
                half3   diffuseColor;
                half3   specularColor;
                half    metallic;
                half    roughness;
                half    occlusion;
                float3  emission;
                half    clearCoat;
                half    clearCoatRoughness;
                
                // 3s参数
                half    skinArea;
                half    sssCurve;
                half    lobe0Smoothness;
                half    lobe1Smoothness;

                half    lobe0Roughness;
                half    lobe1Roughness;

                half    lobeMix;

                half    alpha;
                float   alpha2u;
            };

            struct CommonData
            {
                half3 lightColor;
                
                half4 shadowCoord;
                half shadow;

                float3 pos_world;

                half3 dir_normal;
                half3 dir_normal_blur;

                half3 dir_light;
                half3 dir_half;
                half3 dir_view;

                half NdotL;
                half NdotL_blur;
                half NdotV;
                half NdotH;
                half VdotH;
            };

            void InitData(Varyings i,out SurfaceDataSkin surfaceData,out CommonData commonData)
            {
                surfaceData                     = (SurfaceDataSkin)0;
                commonData                      = (CommonData)0;

                // half3 var_BlushArea = SAMPLE_TEXTURE2D(_BlushArea,sampler_LinearClamp,i.uv).rgb;

                half4 base_color                = SAMPLE_TEXTURE2D(_BaseMap , sampler_BaseMap,i.uv) * _BaseColor;
                #if _OPEN2UDECAL
                float4 base_color_2u            = SAMPLE_TEXTURE2D(_BaseMap_2U , sampler_BaseMap_2U,i.uv1).rgba * _BaseColor_2U.rgba;
                surfaceData.alpha2u             =  (base_color_2u.a);
                base_color.rgb                  = lerp(base_color.rgb, base_color_2u.rgb, base_color_2u.a);
                
                #endif
                
                half3 skin_map                  = SAMPLE_TEXTURE2D(_SkinMap , sampler_SkinMap,i.uv).xyz;

                
                surfaceData.alpha               = base_color.a;

                #if _ALPHATEST_ON
                    clip(surfaceData.alpha - _Cutoff);
                #endif


                surfaceData.sssCurve            = saturate(skin_map.r * 2 - 0.7) + _SSSRange;  // or GetCurvature(_SSSRange,_SSSPower,dir_normal,i.pos_world);
                // surfaceData.sssCurve            = saturate(skin_map.r * 2 - (1.2 - _SSSRange * 2));  

                surfaceData.occlusion           = lerp(1,skin_map.g,_Occlusion);

                half smoothness                 = skin_map.b ;
                #if _OPEN2UDECAL 
                surfaceData.metallic            =  _Metallic_2U * surfaceData.alpha2u;
                #else 
                surfaceData.metallic            = 0;
                #endif
                
                #if _OPEN2UDECAL
                float3 F0Default                 = lerp(0.028,0.04,surfaceData.alpha2u);
                #else
                float3 F0Default                 = 0.028;
                #endif
                surfaceData.specularColor       = lerp(F0Default, base_color, surfaceData.metallic);
                surfaceData.diffuseColor        = lerp(base_color * (1 - F0Default) , 0,  surfaceData.metallic);

                surfaceData.lobe0Roughness      = 1 - smoothness * _lobe0Smoothness;
                surfaceData.lobe1Roughness      = 1 - smoothness * _lobe0Smoothness * 0.5;

                #if _OPEN2UDECAL 
                surfaceData.lobe0Roughness      = lerp(surfaceData.lobe0Roughness, 1-_Smoothness_2U,  surfaceData.alpha2u);
                surfaceData.lobe1Roughness      = lerp(surfaceData.lobe1Roughness, 1-_Smoothness_2U,  surfaceData.alpha2u);
                #endif


                surfaceData.roughness          = lerp(surfaceData.lobe0Roughness, surfaceData.lobe1Roughness, 0.5);

                //-----
                half3 normal_data               = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,i.uv));
                // half3 nromal_data_blur          = normal_data; /// UnpackNormal(SAMPLE_TEXTURE2D_LOD(_NormalMap,sampler_LinearClamp,i.uv,1));    //4

                half3 dir_normal                = normalize(i.world_normal.xyz);
                half3 dir_tangent               = normalize(i.world_tangent.xyz);
                half3 dir_binormal              = normalize(i.world_binormal.xyz);
                float3x3 TBN                    = float3x3(dir_tangent,dir_binormal,dir_normal);

                commonData.pos_world            = half3(i.world_normal.w,i.world_tangent.w,i.world_binormal.w);

                commonData.dir_normal           = normalize(mul(normal_data,TBN));
                #if _OPEN2UDECAL 
                commonData.dir_normal           = lerp(commonData.dir_normal, dir_normal.xyz,surfaceData.alpha2u * (_Normal_2U)); 
                #endif
                // commonData.dir_normal_blur      = normalize(mul(nromal_data_blur,TBN));
                commonData.dir_view             = normalize(_WorldSpaceCameraPos.xyz - commonData.pos_world);

                commonData.NdotV                = saturate(abs(dot(commonData.dir_normal,commonData.dir_view)) + 1e-5);


                #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
                    #if defined(ENABLE_HQ_SHADOW) || defined(ENABLE_HQ_AND_UNITY_SHADOW) 
                        commonData.shadowCoord.x = HighQualityRealtimeShadow(commonData.pos_world);
                    #else
                        commonData.shadowCoord = i.shadowCoord;
                    #endif
                #endif

            }

            void UpdateLightData(inout CommonData commonData,Light light)
            {
                half3 dir_half          = SafeNormalize(light.direction + commonData.dir_view);

                commonData.lightColor   = light.color;
                
                commonData.dir_light    = light.direction;
                commonData.dir_half     = dir_half;

                commonData.NdotH        = saturate(dot(commonData.dir_normal , dir_half));
                commonData.NdotL        = dot(commonData.dir_normal , light.direction);
                // commonData.NdotL_blur   = dot(commonData.dir_normal_blur , light.direction);

                commonData.VdotH        = saturate(dot(commonData.dir_view , dir_half));
                
                
                commonData.shadow       =  light.shadowAttenuation * light.distanceAttenuation;
            }

            float3 SkinBRDF( SurfaceDataSkin surfaceData,CommonData commonData)
            {
        
                float halfLambert       = commonData.NdotL * 0.5 + 0.5;

                float2 uv_sss           = float2(saturate(max(0.0, halfLambert) - ( 1 - commonData.shadow) * ( halfLambert * 0.5)) , surfaceData.sssCurve);

                float3 sss_color        = SAMPLE_TEXTURE2D(_SSSLUT, sampler_SSSLUT,uv_sss).rgb;
                
                
             
                float3 radiance         = saturate(commonData.NdotL)  * commonData.lightColor ;
                

             

                // skin diffuse
                float3 skinDiffuse      = surfaceData.diffuseColor * sss_color * commonData.lightColor;

                half perceptualRoughness = surfaceData.lobe0Roughness;
                half roughness = max(perceptualRoughness* perceptualRoughness, M_HALF_MIN_SQRT);
                half roughness2 = max( roughness *  roughness, M_HALF_MIN);
                half roughness2MinusOne =  roughness2 - 1.0h;
                half normalizationTerm =  roughness * 4.0h + 2.0h;

                half perceptualRoughness1 = surfaceData.lobe1Roughness;
                half roughness1 = max(perceptualRoughness1* perceptualRoughness1, M_HALF_MIN_SQRT);
                half roughness21 = max( roughness1 *  roughness1, M_HALF_MIN);
                half roughness2MinusOne1 =  roughness21 - 1.0h;
                half normalizationTerm1 =  roughness1 * 4.0h + 2.0h;
                

                
                // Dual GGX
            
                float F = lerp(surfaceData.specularColor, 1  ,pow(1-saturate(dot(commonData.dir_half, commonData.dir_view)),5));
                half D1 =  UnitySpecular(commonData.dir_normal, commonData.dir_light, commonData.dir_view, roughness2MinusOne, roughness2, normalizationTerm);
                half D2 =  UnitySpecular(commonData.dir_normal, commonData.dir_light, commonData.dir_view, roughness2MinusOne1, roughness21, normalizationTerm1);
                float3 SpecularBRDF = surfaceData.specularColor * lerp(D1, D2, _LobeMix);// * F ;

                float3 skinSpecular = SpecularBRDF * radiance *  commonData.shadow;// * surfaceData.specularColor;

               
                // return (F);
                return (skinDiffuse + (skinSpecular));
            }

            half3 GI(half3 V,half3 N,half occlusion,half roughness,half metallic,half3 bakedGI,half3 diffuseColor,half3 specularColor, half3 posWS)
            {
              
                half3 reflectVector = reflect(-V,N);

                half NdotV = saturate(dot(N, V));
                half fresnelTerm = Pow5(1.0 - NdotV);

                half3 indirectDiffuse = occlusion * bakedGI;

      
        
                half3 irradiance = UEIBL(reflectVector, posWS, roughness, specularColor, NdotV, occlusion) ;                                                                                              

                
                half3 indirectSpecular = irradiance ;

                float CustomF = 1 - pow(1-NdotV, 2.42);
                float3 CustomFColor = lerp(float3(0.3,0.2, 0.1), 0.972, CustomF);
                half3 c = indirectDiffuse * diffuseColor * CustomFColor;
                
                c += indirectSpecular;

                return c;
            }

            half4 SkinColor(SurfaceDataSkin surfaceData,CommonData commonData,Varyings i,Light mainLight, uint meshRenderingLayers)
            {
              
                half3 DirectLighting_MainLight = 0;
                half3 backLightColor = 0;

                float VoL = clamp(dot(commonData.dir_view, -commonData.dir_light) ,0, 1);
                backLightColor += VoL  * commonData.lightColor ;

                half thicknessBackLight = SAMPLE_TEXTURE2D(_ThickMap,sampler_ThickMap,i.uv).r;


                if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
                {
                    DirectLighting_MainLight = SkinBRDF(surfaceData,commonData);
                }
                float4 ShadowMask = float4(1.0,1.0,1.0,1.0);
                half3 DirectLighting_AddLight = half3(0,0,0);

                #ifdef _ADDITIONAL_LIGHTS
                    uint pixelLightCount = GetAdditionalLightsCount();
                    for(uint lightIndex = 0; lightIndex < pixelLightCount ; ++lightIndex)
                    {
                        
                        Light light = GetAdditionalLight(lightIndex,commonData.pos_world,ShadowMask);
                        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
                        {
                            UpdateLightData(commonData,light);

                            DirectLighting_AddLight += SkinBRDF(surfaceData,commonData);
                        
                       
                            float VoL = clamp(dot(commonData.dir_view, -commonData.dir_light) ,0, 1);
                            backLightColor += VoL  * commonData.lightColor ;

                        }
                    }
                #endif
                backLightColor *= surfaceData.diffuseColor  * (1 - thicknessBackLight) * surfaceData.occlusion * (_BackLightIntensity * _BackLightColor) ;
                
                #if _OPEN2UDECAL 
                backLightColor = lerp(backLightColor, 0, surfaceData.alpha2u);
                #endif

                float3 skin_color = DirectLighting_MainLight + DirectLighting_AddLight;


                // indirect color
                half3 bakedGI = SAMPLE_GI(i.uv1, i.vertexSH, commonData.dir_normal) * _EnvDiffInt;
                float3 indirect_color = GI(commonData.dir_view,commonData.dir_normal,surfaceData.occlusion, surfaceData.roughness,surfaceData.metallic,bakedGI,surfaceData.diffuseColor,surfaceData.specularColor, commonData.pos_world);

             
                // return half4(skin_color , surfaceData.alpha);
                return half4(skin_color + indirect_color + backLightColor, surfaceData.alpha);
            }

            Varyings vert( Attributes v)
            {
                Varyings o= (Varyings)0;

                o.vertex                = TransformObjectToHClip(v.vertex.xyz);
                o.uv                    = v.uv;
                o.uv1                   = v.uv1;
                o.world_normal.xyz      = TransformObjectToWorldNormal(v.normal);
                o.world_tangent.xyz     = TransformObjectToWorldDir(v.tangent.xyz);
                o.world_binormal.xyz    = cross(o.world_normal,o.world_tangent) * v.tangent.w;

                half3 pos_world         = TransformObjectToWorld(v.vertex.xyz);
                o.world_normal.w        = pos_world.x;
                o.world_tangent.w       = pos_world.y;
                o.world_binormal.w      = pos_world.z;
                
                
                #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
                    #if !defined(ENABLE_HQ_SHADOW) && !defined(ENABLE_HQ_AND_UNITY_SHADOW)
                        o.shadowCoord           = TransformWorldToShadowCoord(pos_world);
                    #endif
                #endif
                
               
                OUTPUT_SH(o.world_normal, o.vertexSH);

                return o;
            }
            
            float4 frag(Varyings i):SV_TARGET
            {
                SurfaceDataSkin surfaceData;
                CommonData commonData;

                InitData(i,surfaceData,commonData);

                
                uint meshRenderingLayers = GetMeshRenderingLightLayer();
                Light light = GetMainLight_SGame(commonData.pos_world,commonData.shadowCoord);

                UpdateLightData(commonData,light);
                // commonData.NdotL += var_BlushArea.g;
                
                float4 skin_color = SkinColor(surfaceData,commonData,i,light,meshRenderingLayers );

                return skin_color;

            }
            ENDHLSL 
        }

    }
}
