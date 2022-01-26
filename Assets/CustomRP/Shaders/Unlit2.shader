Shader "Custom RP/Unlit2"
{
	Properties{
		_BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader {
		Pass {
			HLSLPROGRAM

			// ��shader֧��GUIInstancing 
			// һ�ζԾ�����ͬ��������Ķ�����󷢳�һ�λ�ͼ���á�
			// CPU�ռ�����ÿ������ı任�Ͳ������ԣ��������Ƿ��������У�Ȼ���͸�GPU(SetPassCall)��
			// ���GPU����������Ŀ�������ṩ˳����������Ⱦ��
			#pragma multi_compile_instancing

			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment
			#include "UnlitPass.hlsl"					// ���涨���˶�����ɫ���Լ�ƬԪ��ɫ��
			ENDHLSL
		}
	}
}