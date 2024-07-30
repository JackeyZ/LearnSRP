// 带光照着色器的pass
#ifndef CUSTOM_LIT_PASS_INCLUDE
#define CUSTOM_LIT_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/Surface.hlsl"			// 表面数据结构体
#include "../ShaderLibrary/Light.hlsl"				// 光照计算相关结构体
#include "../ShaderLibrary/BRDF.hlsl"				// 双向反射率分布函数相关计算
#include "../ShaderLibrary/Lighting.hlsl"			// 光照计算相关函数

// 纹理和采样器状态都是着色器资源，不属于PerMaterial数据（材质属性）。不能按实例提供(不能包含在UnityPerMaterial里面)，必须在全局范围内声明。
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

// 使用核心RP库中的CBUFFER_START宏定义，因为有些平台是不支持常量缓冲区的。这里不能直接用cbuffer UnityPerMaterial{ float4 _BaseColor };
// Properties大括号里声明的所有变量如果需要支持SRP合批，都需要在UnityPerMaterial的CBUFFER中声明所有材质属性（纹理、采样器不是材质属性）
// 在GPU给变量设置了缓冲区，则不需要每一帧从CPU传递数据到GPU，仅仅在变动时候才需要传递，能够有效降低set pass call
//CBUFFER_START(UnityPerMaterial)
//float4 _BaseColor;															// 将_BaseColor放入特定的常量内存缓冲区，不能全局级别定义，否则无法支持SRP合批
//CBUFFER_END
// 为了支持GUIInstancing，这里CBUFFER_START改成用UNITY_INSTANCING_BUFFER_START宏
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)							// _BaseMap纹理的平铺和偏移
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)								// 把所有实例的_BaseColor以数组的形式声明并放入内存缓冲区
	UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)									// 把所有实例的_Cutoff以数组的形式声明并放入内存缓冲区
	UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)								
	UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)							
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// 顶点着色器输入
struct Attributes{
	float3 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float2 baseUV : TEXCOORD0;													
	UNITY_VERTEX_INPUT_INSTANCE_ID												// 启用GUIInstancing的时候，用此宏，可以让顶点传入实例化id
};

// 顶点着色器输出
struct Varyings {
	float4 positionCS : SV_POSITION;
	float3 positionWS : VAR_POSITION;											// 顶点世界坐标
	float3 normalWS : VAR_NORMAL;
	float2 baseUV : VAR_BASE_UV;												// 这里的VAR_BASE_UV是没用的，因为语法的要求，这里要这么写， 命名随意
	UNITY_VERTEX_INPUT_INSTANCE_ID												// 启用GUIInstancing的时候，用此宏，让顶点着色器输出实例化id
};

Varyings LitPassVertex(Attributes input){
	Varyings output;
	UNITY_SETUP_INSTANCE_ID(input);												// 从input中提取对象索引，并将其存储在其他GUIInstancing相关宏所依赖的全局静态变量中
	UNITY_TRANSFER_INSTANCE_ID(input, output);									// 把input中的实例化id转换到片元着色器中用的实例化id
	output.positionWS = TransformObjectToWorld(input.positionOS);				// 把Object Space下的坐标转换到world space下
	output.positionCS = TransformWorldToHClip(output.positionWS);				// 坐标转换到Camera Space下
	output.normalWS = TransformObjectToWorldNormal(input.normalOS);				// 法线转换到世界空间下
	float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);	// 根据实例id获取从UnityPerMaterial缓冲区读取对应的纹理缩放和偏移
	output.baseUV = input.baseUV * baseST.xy + baseST.zw;						// 应用纹理的缩放与偏移
	return output;
}

float4 LitPassFragment(Varyings input) : SV_TARGET{
	UNITY_SETUP_INSTANCE_ID(input);													// 从input中提取对象索引，并将其存储在其他GUIInstancing相关宏所依赖的全局静态变量中
	float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);		// 传入纹理以及采样器还有uv，返回对应位置的纹理颜色
	float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);	// 根据实例id从UnityPerMaterial缓冲区的_BaseColor数组中取出对应的_BaseColor
	float4 base = baseMap * baseColor;
	#if defined(_CLIPPING)
		clip(base.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));
	#endif

	Surface surface;
	surface.normal = normalize(input.normalWS);
	surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS); 
	surface.color = base.rgb;
	surface.alpha = base.a;
	surface.metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
	surface.smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);

	// 玻璃模式，漫反射是否预乘alpha
	#if defined(_PREMULTIPLY_ALPHA)
		BRDF brdf = GetBRDF(surface, true);
	#else 
		BRDF brdf = GetBRDF(surface);
	#endif

	float3 color = GetLighting(surface, brdf);
	return float4(color, surface.alpha);
}


#endif