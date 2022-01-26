#ifndef CUSTOM_UNITY_INPUT_INCLUDE
#define CUSTOM_UNITY_INPUT_INCLUDE

// 如果需要支持SRP合批，内置引擎属性必须在“UnityPerDraw”的 CBUFFER 中声明
CBUFFER_START(UnityPerDraw)
float4x4 unity_ObjectToWorld;			// 模型空间->世界空间，转换矩阵(uniform 值。它由GPU每次绘制时设置，对于该绘制期间所有顶点和片段函数的调用都将保持不变)
float4x4 unity_WorldToObject;			// 世界空间->模型空间
float4 unity_LODFade;
real4 unity_WorldTransformParams;		// 包含一些我们不再需要的转换信息，real4向量，它本身不是有效的类型，而是取决于目标平台的float4或half4的别名。（需要引入unityURP库里的"Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"才能使用real4）
CBUFFER_END

float4x4 unity_MatrixV;					// 世界空间->视口空间，转换矩阵
float4x4 unity_MatrixVP;				// 世界空间->裁剪空间，转换矩阵
float4x4 glstate_matrix_projection;		// 视口空间->裁剪空间，转换矩阵
#endif