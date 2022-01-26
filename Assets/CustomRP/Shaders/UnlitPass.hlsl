#ifndef CUSTOM_UNLIT_PASS_INCLUDE
#define CUSTOM_UNLIT_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"

// ʹ�ú���RP���е�CBUFFER_START�궨�壬��Ϊ��Щƽ̨�ǲ�֧�ֳ����������ġ����ﲻ��ֱ����cbuffer UnityPerMaterial{ float4 _BaseColor };
// Properties�����������������б��������Ҫ֧�ֺ���������Ҫ��UnityPerMaterial��CBUFFER���������в�������
// ��GPU�����������˻�����������Ҫÿһ֡��CPU�������ݵ�GPU�������ڱ䶯ʱ�����Ҫ���ݣ��ܹ���Ч����set pass call
//CBUFFER_START(UnityPerMaterial)
//float4 _BaseColor;															// ��_BaseColor�����ض��ĳ����ڴ滺����
//CBUFFER_END
// Ϊ��֧��GUIInstancing������CBUFFER_START�ĳ���UNITY_INSTANCING_BUFFER_START��
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)								// ������ʵ����_BaseColor���������ʽ�����������ڴ滺����
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// ������ɫ������
struct Attributes{
	float3 positionOS : POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID												// ����GUIInstancing��ʱ���ô˺꣬�����ö��㴫��ʵ����id
};

// ������ɫ�����
struct Varyings {
	float4 positionCS : SV_POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID												// ����GUIInstancing��ʱ���ô˺꣬�ö�����ɫ�����ʵ����id
};

Varyings UnlitPassVertex(Attributes input){
	Varyings output;
	UNITY_SETUP_INSTANCE_ID(input);												// ��input����ȡ����������������洢������GUIInstancing��غ���������ȫ�־�̬������
	UNITY_TRANSFER_INSTANCE_ID(input, output);									// ��input�е�ʵ����idת����ƬԪ��ɫ�����õ�ʵ����id
	float3 positionWS = TransformObjectToWorld(input.positionOS);
	output.positionCS = TransformWorldToHClip(positionWS);
	return output;
}

float4 UnlitPassFragment(Varyings input) : SV_TARGET{
	UNITY_SETUP_INSTANCE_ID(input);												// ��input����ȡ����������������洢������GUIInstancing��غ���������ȫ�־�̬������
	return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);			// ����ʵ��id��_BaseColor������ȡ����Ӧ��_BaseColor
}


#endif