// ��������ɫ����pass
#ifndef CUSTOM_LIT_PASS_INCLUDE
#define CUSTOM_LIT_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/Surface.hlsl"			// �������ݽṹ��
#include "../ShaderLibrary/Light.hlsl"				// ���ռ�����ؽṹ��
#include "../ShaderLibrary/BRDF.hlsl"				// ˫�����ʷֲ�������ؼ���
#include "../ShaderLibrary/Lighting.hlsl"			// ���ռ�����غ���

// ����Ͳ�����״̬������ɫ����Դ��������PerMaterial���ݣ��������ԣ������ܰ�ʵ���ṩ(���ܰ�����UnityPerMaterial����)��������ȫ�ַ�Χ��������
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

// ʹ�ú���RP���е�CBUFFER_START�궨�壬��Ϊ��Щƽ̨�ǲ�֧�ֳ����������ġ����ﲻ��ֱ����cbuffer UnityPerMaterial{ float4 _BaseColor };
// Properties�����������������б��������Ҫ֧��SRP����������Ҫ��UnityPerMaterial��CBUFFER���������в������ԣ��������������ǲ������ԣ�
// ��GPU�����������˻�����������Ҫÿһ֡��CPU�������ݵ�GPU�������ڱ䶯ʱ�����Ҫ���ݣ��ܹ���Ч����set pass call
//CBUFFER_START(UnityPerMaterial)
//float4 _BaseColor;															// ��_BaseColor�����ض��ĳ����ڴ滺����������ȫ�ּ����壬�����޷�֧��SRP����
//CBUFFER_END
// Ϊ��֧��GUIInstancing������CBUFFER_START�ĳ���UNITY_INSTANCING_BUFFER_START��
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)							// _BaseMap�����ƽ�̺�ƫ��
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)								// ������ʵ����_BaseColor���������ʽ�����������ڴ滺����
	UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)									// ������ʵ����_Cutoff���������ʽ�����������ڴ滺����
	UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)								
	UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)							
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// ������ɫ������
struct Attributes{
	float3 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float2 baseUV : TEXCOORD0;													
	UNITY_VERTEX_INPUT_INSTANCE_ID												// ����GUIInstancing��ʱ���ô˺꣬�����ö��㴫��ʵ����id
};

// ������ɫ�����
struct Varyings {
	float4 positionCS : SV_POSITION;
	float3 positionWS : VAR_POSITION;											// ������������
	float3 normalWS : VAR_NORMAL;
	float2 baseUV : VAR_BASE_UV;												// �����VAR_BASE_UV��û�õģ���Ϊ�﷨��Ҫ������Ҫ��ôд�� ��������
	UNITY_VERTEX_INPUT_INSTANCE_ID												// ����GUIInstancing��ʱ���ô˺꣬�ö�����ɫ�����ʵ����id
};

Varyings LitPassVertex(Attributes input){
	Varyings output;
	UNITY_SETUP_INSTANCE_ID(input);												// ��input����ȡ����������������洢������GUIInstancing��غ���������ȫ�־�̬������
	UNITY_TRANSFER_INSTANCE_ID(input, output);									// ��input�е�ʵ����idת����ƬԪ��ɫ�����õ�ʵ����id
	output.positionWS = TransformObjectToWorld(input.positionOS);				// ��Object Space�µ�����ת����world space��
	output.positionCS = TransformWorldToHClip(output.positionWS);				// ����ת����Camera Space��
	output.normalWS = TransformObjectToWorldNormal(input.normalOS);				// ����ת��������ռ���
	float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);	// ����ʵ��id��ȡ��UnityPerMaterial��������ȡ��Ӧ���������ź�ƫ��
	output.baseUV = input.baseUV * baseST.xy + baseST.zw;						// Ӧ�������������ƫ��
	return output;
}

float4 LitPassFragment(Varyings input) : SV_TARGET{
	UNITY_SETUP_INSTANCE_ID(input);													// ��input����ȡ����������������洢������GUIInstancing��غ���������ȫ�־�̬������
	float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);		// ���������Լ�����������uv�����ض�Ӧλ�õ�������ɫ
	float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);	// ����ʵ��id��UnityPerMaterial��������_BaseColor������ȡ����Ӧ��_BaseColor
	float4 base = baseMap * baseColor;
	#if defined(_CLIPPING)
		clip(base.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));
	#endif

	Surface surface;
	surface.normal = normalize(input.normalWS);
	surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS); 
	surface.color = base.rgb;
	surface.alpha = base.a;
	surface.metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
	surface.smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);

	// ����ģʽ���������Ƿ�Ԥ��alpha
	#if defined(_PREMULTIPLY_ALPHA)
		BRDF brdf = GetBRDF(surface, true);
	#else 
		BRDF brdf = GetBRDF(surface);
	#endif

	float3 color = GetLighting(surface, brdf);
	return float4(color, surface.alpha);
}


#endif