// �޹�����ɫ����pass
#ifndef CUSTOM_UNLIT_PASS_INCLUDE
#define CUSTOM_UNLIT_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"

// ����Ͳ�����״̬������ɫ����Դ��������PerMaterial���ݣ��������ԣ������ܰ�ʵ���ṩ(���ܰ�����UnityPerMaterial����)��������ȫ�ַ�Χ��������
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap); // ������ζ�������в���

// ʹ�ú���RP���е�CBUFFER_START�궨�壬��Ϊ��Щƽ̨�ǲ�֧�ֳ����������ġ����ﲻ��ֱ����cbuffer UnityPerMaterial{ float4 _BaseColor };
// Properties�����������������б��������Ҫ֧��SRP����������Ҫ����ΪUnityPerMaterial��CBUFFER�����������в������ԣ��������������ǲ������ԣ�
// ��GPU�����������˻�����������Ҫÿһ֡��CPU�������ݵ�GPU�������ڱ䶯ʱ�����Ҫ���ݣ��ܹ���Ч����set pass call
//CBUFFER_START(UnityPerMaterial)
//float4 _BaseColor;															// ��_BaseColor�����ض��ĳ����ڴ滺����������ȫ�ּ����壬�����޷�֧��SRP����
//CBUFFER_END
// Ϊ��֧��GUIInstancing������CBUFFER_START�ĳ���UNITY_INSTANCING_BUFFER_START��
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)							// _BaseMap�����ƽ�̺�ƫ��
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)								// ������ʵ����_BaseColor���������ʽ�����������ڴ滺����
	UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)									// ������ʵ����_Cutoff���������ʽ�����������ڴ滺����
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// ������ɫ������
struct Attributes{
	float3 positionOS : POSITION;
	float2 baseUV : TEXCOORD0;													
	UNITY_VERTEX_INPUT_INSTANCE_ID												// ����GUIInstancing��ʱ���ô˺꣬�����ö��㴫��ʵ����id
};

// ������ɫ�����
struct Varyings {
	float4 positionCS : SV_POSITION;
	float2 baseUV : VAR_BASE_UV;												// �����VAR_BASE_UV��û�õģ���Ϊ�﷨��Ҫ������Ҫ��ôд�� ��������
	UNITY_VERTEX_INPUT_INSTANCE_ID												// ����GUIInstancing��ʱ���ô˺꣬�ö�����ɫ�����ʵ����id
};

Varyings UnlitPassVertex(Attributes input){
	Varyings output;
	UNITY_SETUP_INSTANCE_ID(input);												// ��input����ȡ����������������洢������GUIInstancing��غ���������ȫ�־�̬������
	UNITY_TRANSFER_INSTANCE_ID(input, output);									// ��input�е�ʵ����idת����ƬԪ��ɫ�����õ�ʵ����id
	float3 positionWS = TransformObjectToWorld(input.positionOS);				// ��Object Space�µ�����ת����world space��
	output.positionCS = TransformWorldToHClip(positionWS);						// ����ת����Camera Space��
	float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);	// ����ʵ��id��ȡ��UnityPerMaterial��������ȡ��Ӧ���������ź�ƫ��
	output.baseUV = input.baseUV * baseST.xy + baseST.zw;						// Ӧ�������������ƫ��
	return output;
}

float4 UnlitPassFragment(Varyings input) : SV_TARGET{
	UNITY_SETUP_INSTANCE_ID(input);													// ��input����ȡ����������������洢������GUIInstancing��غ���������ȫ�־�̬������
	float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);		// ���������Լ�����������uv�����ض�Ӧλ�õ�������ɫ
	float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);	// ����ʵ��id��UnityPerMaterial��������_BaseColor������ȡ����Ӧ��_BaseColor
	float4 base = baseMap * baseColor;
	#if defined(_CLIPPING)
		clip(base.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));
	#endif
	return base;
}


#endif