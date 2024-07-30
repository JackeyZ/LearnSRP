// 该脚本用于编写与BRDF相关的函数
// 二向性反射率分布函数(BRDF)是用以表达目标物的二向性反射特征。
// 它描述了入射光线经过某个表面反射后如何在各个出射方向上分布。也可理解为：光线从某个方向入射到表面后，能量被该表面吸收，然后再朝着各个方向发射出去。
// 简单来讲就是 BRDF = 反射光线强度 / 入射光线强度 。即反射光线强度 = 入射光线强度 * BRDF
#ifndef CUSTOM_BRDF_INCLUDE
#define CUSTOM_BRDF_INCLUDE

struct BRDF{
	float3 diffuse;			// 漫反射
	float3 specular;		// 高光反射
	float roughness;		// 粗糙度
};

// 最小反射率(就算是完全的非金属也应该有微弱的镜面反射)
#define MIN_REFLECTIVITY 0.04	

// 根据金属度计算1 - 镜面反射率
float OneMinusReflectivity(float metallic){
	// 金属度越高，镜面反射率越高
	float range = 1.0 - MIN_REFLECTIVITY;
	return range - metallic * range;			// 限定 1-反射率的范围是0~0.96(即镜面反射率范围是0.04~1)
}

// 根据所给的片元表面数据计算出BRDF
BRDF GetBRDF(Surface surface, bool applyAlphaToDiffuse = false){
	BRDF brdf;
	float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);		// 1 - 镜面反射率
	brdf.diffuse = surface.color * oneMinusReflectivity;						// 镜面反射越小，漫反射强度越大
	// 玻璃模式
	if(applyAlphaToDiffuse){
		// 漫反射在这里就预先乘以透明度，不再依赖于后面的GPU透明度混合（用于解决全透明的玻璃的高光反射也会被透明度融合导致高光反射丢失的问题，即全透明的玻璃要保留高光反射）
		brdf.diffuse *= surface.alpha;											
	}
	brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);	// 假定摄像机正对着反射光的方向，计算高光反射光照，得到的是最大值
																				// 对表面颜色做插值，完全金属表面反射的时候高光反射的颜色就完全等于表面颜色
																				// (即非金属表面颜色不会影响高光反射颜色，而金属表面颜色会影响高光反射颜色)
	float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);		// 光滑度转换成粗糙度
	brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);		// 让0~1范围内的粗糙度转换成这与迪士尼照明模型匹配的粗糙度，实际上是取了个平方值
	return brdf;
}

// 根据摄像机方向计算高光反射强度（强度与摄像机方向和镜面反射方向有关，若摄像机方向正对着光线反射方向的时候，强度最大）
float SpecularStrength(Surface surface, BRDF brdf, Light light){
	float3 h = SafeNormalize(light.direction + surface.viewDirection);			// 计算得到光线（起点是片元指向光源）与视线（起点是片元指向摄像机）之间的中间向量
	float nh2 = Square(saturate(dot(surface.normal, h)));
	float lh2 = Square(saturate(dot(light.direction, h)));
	float r2 = Square(brdf.roughness);
	float d2 = Square(nh2 * (r2 - 1.0) + 1.00001);
	float normalization = brdf.roughness * 4.0 + 2.0;
	return r2 / (d2 * max(0.1, lh2) * normalization);
}

// 计算平行光照射到给定表面时候的BRDF
float3 DirectBRDF(Surface surface, BRDF brdf, Light light){
	return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;	// 高光反射强度 * 高光反射光照最大值 + 漫反射光照
}
#endif