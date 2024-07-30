#ifndef CUSTOM_UNITY_INPUT_INCLUDE
#define CUSTOM_UNITY_INPUT_INCLUDE

// �����Ҫ֧��SRP�����������������Ա��������cBuffer�ġ�UnityPerDraw����������
CBUFFER_START(UnityPerDraw)
float4x4 unity_ObjectToWorld;			// ģ�Ϳռ�->����ռ䣬ת������(uniform ֵ������GPUÿ�λ���ʱ���ã����ڸû����ڼ����ж����Ƭ�κ����ĵ��ö������ֲ���)
float4x4 unity_WorldToObject;			// ����ռ�->ģ�Ϳռ�
float4 unity_LODFade;
float3 _WorldSpaceCameraPos;			// ������������꣬Unity�Դ��Ĳ���
real4 unity_WorldTransformParams;		// ����һЩ���ǲ�����Ҫ��ת����Ϣ��real4����������������Ч�����ͣ�����ȡ����Ŀ��ƽ̨��float4��half4�ı���������Ҫ����unityURP�����"Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"����ʹ��real4��
CBUFFER_END

float4x4 unity_MatrixV;					// ����ռ�->�ӿڿռ䣬ת������
float4x4 unity_MatrixVP;				// ����ռ�->�ü��ռ䣬ת������
float4x4 glstate_matrix_projection;		// �ӿڿռ�->�ü��ռ䣬ת������
#endif