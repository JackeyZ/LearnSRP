#ifndef CUSTOM_SURFACCE_INCLUDE
#define CUSTOM_SURFACCE_INCLUDE

struct Surface{
	float3 normal;
	float3 viewDirection;		// �ӽǷ��򣬼�ƬԪָ�������������
	float3 color;
	float alpha;
	float metallic;
	float smoothness;
};

#endif