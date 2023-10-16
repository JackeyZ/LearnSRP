// ��������ɫ��
Shader "Custom RP/Lit"
{
	Properties{
		_BaseColor("Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5									// ͸���Ȳü�
		[Toggle(_CLIPPING)] _Clipping("Alpha Clipping", Float) = 0						// �����л�_CLIPPING�ؼ���
		_BaseMap("Texture", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend", Float) = 0
		[Enum(Off, 0, On, 1)] _ZWrite("Z Write", Float) = 1
	}
	SubShader {
		Pass {
			// Pass������ù���tags�ĵ�https://docs.unity.cn/cn/2020.3/Manual/shader-predefined-pass-tags-built-in.html
			// SubShader��tags�ĵ�https://docs.unity.cn/cn/2020.3/Manual/SL-SubShaderTags.html
			Tags{
				"LightMode" = "CustomLit"				// �Զ���Ĺ��շ���������ɫ��������ģʽ����ΪCustomLit������unity�Դ��ģ�
			}
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			HLSLPROGRAM

			// �Զ���Ĺؼ��֣����������Ƿ�����͸���Ȳü�
			#pragma shader_feature _CLIPPING
			// ��shader֧��GUIInstancing 
			// һ�ζԾ�����ͬ��������Ķ�����󷢳�һ�λ�ͼ���á�
			// CPU�ռ�����ÿ������ı任�Ͳ������ԣ��������Ƿ��������У�Ȼ���͸�GPU(SetPassCall)��
			// ���GPU����������Ŀ�������ṩ˳����������Ⱦ��
			#pragma multi_compile_instancing

			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment
			#include "LitPass.hlsl"					// ���涨���˶�����ɫ���Լ�ƬԪ��ɫ��
			ENDHLSL
		}
	}
}