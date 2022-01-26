#ifndef CUSTOM_UNLIT_PASS_INCLUDE
#define CUSTOM_UNLIT_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"

// 使用核心RP库中的CBUFFER_START宏定义，因为有些平台是不支持常量缓冲区的。这里不能直接用cbuffer UnityPerMaterial{ float4 _BaseColor };
// Properties大括号里声明的所有变量如果需要支持合批，都需要在UnityPerMaterial的CBUFFER中声明所有材质属性
// 在GPU给变量设置了缓冲区，则不需要每一帧从CPU传递数据到GPU，仅仅在变动时候才需要传递，能够有效降低set pass call
//CBUFFER_START(UnityPerMaterial)
//float4 _BaseColor;															// 将_BaseColor放入特定的常量内存缓冲区
//CBUFFER_END
// 为了支持GUIInstancing，这里CBUFFER_START改成用UNITY_INSTANCING_BUFFER_START宏
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)								// 把所有实例的_BaseColor以数组的形式声明并放入内存缓冲区
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// 顶点着色器输入
struct Attributes{
	float3 positionOS : POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID												// 启用GUIInstancing的时候，用此宏，可以让顶点传入实例化id
};

// 顶点着色器输出
struct Varyings {
	float4 positionCS : SV_POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID												// 启用GUIInstancing的时候，用此宏，让顶点着色器输出实例化id
};

Varyings UnlitPassVertex(Attributes input){
	Varyings output;
	UNITY_SETUP_INSTANCE_ID(input);												// 从input中提取对象索引，并将其存储在其他GUIInstancing相关宏所依赖的全局静态变量中
	UNITY_TRANSFER_INSTANCE_ID(input, output);									// 把input中的实例化id转换到片元着色器中用的实例化id
	float3 positionWS = TransformObjectToWorld(input.positionOS);
	output.positionCS = TransformWorldToHClip(positionWS);
	return output;
}

float4 UnlitPassFragment(Varyings input) : SV_TARGET{
	UNITY_SETUP_INSTANCE_ID(input);												// 从input中提取对象索引，并将其存储在其他GUIInstancing相关宏所依赖的全局静态变量中
	return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);			// 根据实例id从_BaseColor数组中取出对应的_BaseColor
}


#endif