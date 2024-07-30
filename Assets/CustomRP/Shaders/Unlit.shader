// 无光照着色器
Shader "Custom RP/Unlit"
{
	Properties{
		_BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5									// 透明度裁剪
		[Toggle(_CLIPPING)] _Clipping("Alpha Clipping", Float) = 0						// 用来切换_CLIPPING关键字
		_BaseMap("Texture", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend", Float) = 0
		[Enum(Off, 0, On, 1)] _ZWrite("Z Write", Float) = 1
	}
	SubShader {
		Pass {
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			HLSLPROGRAM
			#pragma target 3.5						// 由于使用了可变长度的循环，而WebGL1.0和OpenGL ES 2.0不支持，因此这里提高编译目标，不支持旧的GPU

			// 自定义的关键字，用来控制是否启用透明度裁剪
			#pragma shader_feature _CLIPPING
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

	CustomEditor "CustomShaderGUI"
}