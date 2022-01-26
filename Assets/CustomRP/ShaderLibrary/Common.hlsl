#ifndef CUSTOM_UNITY_COMMON_INCLUDE
#define CUSTOM_UNITY_COMMON_INCLUDE
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"				// ����unity�Դ��Ĺ����⣨��Ҫ��PackageManager�����°�װUniversal RP�İ��ſ����룩
#include "UnityInput.hlsl"																	// ���������Լ�д��UnityInput

// SpaceTransforms.hlsl�����õ�������ĺ궨�壬�������ܸ�
#define UNITY_MATRIX_M unity_ObjectToWorld
#define UNITY_MATRIX_I_M unity_WorldToObject
#define UNITY_MATRIX_V unity_MatrixV
#define UNITY_MATRIX_VP unity_MatrixVP
#define UNITY_MATRIX_P glstate_matrix_projection
 
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"		// ����SRP����GUIInstancing��صĿ⣬����һϵ�п��õķ����ͺ궨��
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"		// ����unity�ĺ��Ŀ⣨���а���һЩ�ռ�ת���ķ���������Ҫ��PackageManager�����°�װUniversal RP�İ��ſ����룩

#endif