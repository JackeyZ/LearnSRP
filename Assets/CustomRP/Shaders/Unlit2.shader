Shader "Custom RP/Unlit2"
{
	Properties{
		_BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader {
		Pass {
			HLSLPROGRAM

			// 让shader支持GUIInstancing 
			// 一次对具有相同网格物体的多个对象发出一次绘图调用。
			// CPU收集所有每个对象的变换和材质属性，并将它们放入数组中，然后发送给GPU(SetPassCall)。
			// 最后，GPU遍历所有条目，并按提供顺序对其进行渲染。
			#pragma multi_compile_instancing

			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment
			#include "UnlitPass.hlsl"					// 里面定义了顶点着色器以及片元着色器
			ENDHLSL
		}
	}
}