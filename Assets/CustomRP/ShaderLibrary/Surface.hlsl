#ifndef CUSTOM_SURFACCE_INCLUDE
#define CUSTOM_SURFACCE_INCLUDE

struct Surface{
	float3 normal;
	float3 viewDirection;		// 视角方向，即片元指向摄像机的向量
	float3 color;
	float alpha;
	float metallic;
	float smoothness;
};

#endif