// ���ļ����ڱ�д��ȡ���ֵƹ����͵ĺ���
#ifndef CUSTOM_LIGHT_INCLUDE
#define CUSTOM_LIGHT_INCLUDE

#define MAX_DIRECTIONAL_LIGHT_COUNT 4

// �Զ���һ�����С�_CustomLight����Cbuffer��C#�Ǳ߻��ֵ���ù���
CBUFFER_START(_CustomLight)
	int _DirectionalLightCount;													// ���ƽ�й���Ŀ
	float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];				// ƽ�й���ɫ����
	float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];			// ƽ�йⷽ������
CBUFFER_END

struct Light {
	float3 color;
	float3 direction;
};

int GetDirectionalLightCount(){
	return _DirectionalLightCount;
}

// ��ȡ�����ṹ��
Light GetDirectionalLight(int index){
	Light light;
	light.color = _DirectionalLightColors[index];
	light.direction = _DirectionalLightDirections[index].xyz;
	return light;
}

#endif