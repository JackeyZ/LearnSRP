// 该脚本负责计算表面片源所受到的灯光
#ifndef CUSTOM_LIGHTING_INCLUDE
#define CUSTOM_LIGHTING_INCLUDE

// 获取给定表面的光的入射量
float3 IncomingLight(Surface surface, Light light){
	return saturate(dot(surface.normal, light.direction)) * light.color;
}

float3 GetLighting(Surface surface, BRDF brdf, Light light){
	// BRDF = 反射光线强度 / 入射光线强度 。
	// 所以反射光线强度 = 入射光线强度 * BRDF
	return IncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
}

float3 GetLighting(Surface surface, BRDF brdf){
	float3 color = 0.0;
	for(int i = 0; i < GetDirectionalLightCount(); i++){
		color += GetLighting(surface, brdf, GetDirectionalLight(i));
	}
	return color;
}
#endif