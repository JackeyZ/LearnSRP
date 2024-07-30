// 该文件用于编写获取各种灯光类型的函数
#ifndef CUSTOM_LIGHT_INCLUDE
#define CUSTOM_LIGHT_INCLUDE

#define MAX_DIRECTIONAL_LIGHT_COUNT 4

// 自定义一个名叫“_CustomLight”的Cbuffer，C#那边会把值设置过来
CBUFFER_START(_CustomLight)
	int _DirectionalLightCount;													// 最大平行光数目
	float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];				// 平行光颜色数组
	float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];			// 平行光方向数组
CBUFFER_END

struct Light {
	float3 color;
	float3 direction;
};

int GetDirectionalLightCount(){
	return _DirectionalLightCount;
}

// 获取方向光结构体
Light GetDirectionalLight(int index){
	Light light;
	light.color = _DirectionalLightColors[index];
	light.direction = _DirectionalLightDirections[index].xyz;
	return light;
}

#endif