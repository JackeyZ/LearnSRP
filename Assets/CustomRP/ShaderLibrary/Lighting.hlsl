// �ƹ������ؽű�
#ifndef CUSTOM_LIGHTING_INCLUDE
#define CUSTOM_LIGHTING_INCLUDE

// ��ȡ��������Ĺ��������
float3 IncomingLight(Surface surface, Light light){
	return dot(surface.normal, light.direction) * light.color;
}

float3 GetLighting(Surface surface, Light light){
	return IncomingLight(surface, light) * surface.color;
}

float3 GetLighting(Surface surface){
	return IncomingLight(surface, GetDirectionalLight());
}
#endif