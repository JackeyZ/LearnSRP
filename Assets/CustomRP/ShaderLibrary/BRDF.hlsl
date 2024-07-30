// �ýű����ڱ�д��BRDF��صĺ���
// �����Է����ʷֲ�����(BRDF)�����Ա��Ŀ����Ķ����Է���������
// ��������������߾���ĳ�����淴�������ڸ������䷽���Ϸֲ���Ҳ�����Ϊ�����ߴ�ĳ���������䵽������������ñ������գ�Ȼ���ٳ��Ÿ����������ȥ��
// ���������� BRDF = �������ǿ�� / �������ǿ�� �����������ǿ�� = �������ǿ�� * BRDF
#ifndef CUSTOM_BRDF_INCLUDE
#define CUSTOM_BRDF_INCLUDE

struct BRDF{
	float3 diffuse;			// ������
	float3 specular;		// �߹ⷴ��
	float roughness;		// �ֲڶ�
};

// ��С������(��������ȫ�ķǽ���ҲӦ����΢���ľ��淴��)
#define MIN_REFLECTIVITY 0.04	

// ���ݽ����ȼ���1 - ���淴����
float OneMinusReflectivity(float metallic){
	// ������Խ�ߣ����淴����Խ��
	float range = 1.0 - MIN_REFLECTIVITY;
	return range - metallic * range;			// �޶� 1-�����ʵķ�Χ��0~0.96(�����淴���ʷ�Χ��0.04~1)
}

// ����������ƬԪ�������ݼ����BRDF
BRDF GetBRDF(Surface surface, bool applyAlphaToDiffuse = false){
	BRDF brdf;
	float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);		// 1 - ���淴����
	brdf.diffuse = surface.color * oneMinusReflectivity;						// ���淴��ԽС��������ǿ��Խ��
	// ����ģʽ
	if(applyAlphaToDiffuse){
		// �������������Ԥ�ȳ���͸���ȣ����������ں����GPU͸���Ȼ�ϣ����ڽ��ȫ͸���Ĳ����ĸ߹ⷴ��Ҳ�ᱻ͸�����ںϵ��¸߹ⷴ�䶪ʧ�����⣬��ȫ͸���Ĳ���Ҫ�����߹ⷴ�䣩
		brdf.diffuse *= surface.alpha;											
	}
	brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);	// �ٶ�����������ŷ����ķ��򣬼���߹ⷴ����գ��õ��������ֵ
																				// �Ա�����ɫ����ֵ����ȫ�������淴���ʱ��߹ⷴ�����ɫ����ȫ���ڱ�����ɫ
																				// (���ǽ���������ɫ����Ӱ��߹ⷴ����ɫ��������������ɫ��Ӱ��߹ⷴ����ɫ)
	float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);		// �⻬��ת���ɴֲڶ�
	brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);		// ��0~1��Χ�ڵĴֲڶ�ת���������ʿ������ģ��ƥ��Ĵֲڶȣ�ʵ������ȡ�˸�ƽ��ֵ
	return brdf;
}

// ����������������߹ⷴ��ǿ�ȣ�ǿ�������������;��淴�䷽���йأ�����������������Ź��߷��䷽���ʱ��ǿ�����
float SpecularStrength(Surface surface, BRDF brdf, Light light){
	float3 h = SafeNormalize(light.direction + surface.viewDirection);			// ����õ����ߣ������ƬԪָ���Դ�������ߣ������ƬԪָ���������֮����м�����
	float nh2 = Square(saturate(dot(surface.normal, h)));
	float lh2 = Square(saturate(dot(light.direction, h)));
	float r2 = Square(brdf.roughness);
	float d2 = Square(nh2 * (r2 - 1.0) + 1.00001);
	float normalization = brdf.roughness * 4.0 + 2.0;
	return r2 / (d2 * max(0.1, lh2) * normalization);
}

// ����ƽ�й����䵽��������ʱ���BRDF
float3 DirectBRDF(Surface surface, BRDF brdf, Light light){
	return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;	// �߹ⷴ��ǿ�� * �߹ⷴ��������ֵ + ���������
}
#endif