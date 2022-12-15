Shader "Standard/SGameFur"
{
	Properties
	{	
		_BaseColor("颜色",Color) = (1.0 ,1.0 ,1.0 ,1.0)
		//_Color("ShadowColor",Color) = (1.0 ,0.85 ,0.7 ,1.0)
		_MainTex ("颜色贴图", 2D) = "white" {} 
		_FlowTex("毛发长度图",2D) = "white" {}
		//	_SubTex("SubTex",2D) = "white" {}   
		_SubTexUV("毛发缩放", Vector) = (4.0 ,8.0 ,1.0 ,1.0)

		[Space(10)]
		[Header(_______________________LIGHT______________________________________________)]
		[Space(10)]
		_EnvironmentLightInt("AO",  Range(0,1)) = 1
		_FresnelLV("边缘光强度", Range(1,10)) = 5

		[Space(10)]
		[Header(_______________________SHAPE______________________________________________)]
		[Space(10)]
		_FarSpacing("长度", Range(0,16)) = 1
		_FurTickness("浓密程度", Range(0,1)) = 1 
		_FurGravity("毛发重力", Range(0,1)) = 0.5

	}

	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 300
		Blend SrcAlpha OneMinusSrcAlpha//, One OneMinusSrcAlpha


		//2
		Pass
		{
			Tags { "LightMode" = "MultiPass0" }
			ZWrite On

			HLSLPROGRAM
			#pragma vertex vertFirst
			#pragma fragment fragFirst
			#define FUROFFSETVX 0.0
		
		
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		//3
		Pass
		{
			Tags { "LightMode" = "MultiPass1" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.1
	
		
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		//4
		Pass
		{
			Tags { "LightMode" = "MultiPass2" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.2
	
		
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		//5
		Pass
		{
			Tags { "LightMode" = "MultiPass3" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.3
	
	
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		//6
		Pass
		{
			Tags { "LightMode" = "MultiPass4" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.4
	
		
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		//7
		Pass
		{
			Tags { "LightMode" = "MultiPass5" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.5
		
			
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		Pass
		{
			Tags { "LightMode" = "MultiPass6" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.6
		
			
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		Pass
		{
			Tags { "LightMode" = "MultiPass7" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.7
		
			
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		Pass
		{
			Tags { "LightMode" = "MultiPass8" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.8
			
			
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}

		Pass
		{
			Tags { "LightMode" = "MultiPass9" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 0.9
			
			
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}


		Pass
		{
			Tags { "LightMode" = "MultiPass10" }
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FUROFFSETVX 1.0
			
			
			#include "MultiPassFurCore.hlsl"
			ENDHLSL
		}
	}

	
}
