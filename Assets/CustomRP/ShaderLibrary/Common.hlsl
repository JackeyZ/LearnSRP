#ifndef CUSTOM_UNITY_COMMON_INCLUDE
#define CUSTOM_UNITY_COMMON_INCLUDE
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"				// 引入unity自带的公共库（需要在PackageManager窗口下安装Universal RP的包才可引入）
#include "UnityInput.hlsl"																	// 引入我们自己写的UnityInput

// SpaceTransforms.hlsl库里用到了下面的宏定义，命名不能改
#define UNITY_MATRIX_M unity_ObjectToWorld
#define UNITY_MATRIX_I_M unity_WorldToObject
#define UNITY_MATRIX_V unity_MatrixV
#define UNITY_MATRIX_VP unity_MatrixVP
#define UNITY_MATRIX_P glstate_matrix_projection
 
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"		// 引入SRP里与GUIInstancing相关的库，里面一系列可用的方法和宏定义
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"		// 引入unity的核心库（其中包括一些空间转换的方法）（需要在PackageManager窗口下安装Universal RP的包才可引入）

#endif