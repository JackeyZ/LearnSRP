using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;

/// <summary>
/// CameraRenderer类在编辑器下的代码
/// partial关键字表示本文件只是这个类的部分代码
/// </summary>
partial class CameraRenderer
{
#if UNITY_EDITOR
    static ShaderTagId[] legacyShaderTagIds = {                                     // unity默认着色器里的pass
        new ShaderTagId("Always"),
        new ShaderTagId("ForwardBase"),
        new ShaderTagId("PrepassBase"),
        new ShaderTagId("Vertex"),
        new ShaderTagId("VertexLMRGBM"),
        new ShaderTagId("VertexLM")
    };
    static Material errorMaterial;                                                  // 渲染不支持的shader的时候用的材质球
    string SampleName { get; set; }

    /// <summary>
    /// 绘制scene窗口下的小部件（Gizmos）
    /// </summary>
    partial void DrawGizmos()
    {
        // unity的开关，检查是否需要在Scene窗口绘制Gizmos
        if (Handles.ShouldRenderGizmos())
        {
            context.DrawGizmos(camera, GizmoSubset.PreImageEffects);                // 后处理之前绘制
            context.DrawGizmos(camera, GizmoSubset.PostImageEffects);               // 后处理之后绘制
        }
    }

    /// <summary>
    /// 绘制本RP不支持的shader
    /// </summary>
    partial void DrawUnsupportedShaders()
    {
        if (errorMaterial == null)
        {
            errorMaterial = new Material(Shader.Find("Hidden/InternalErrorShader"));                // 查找unity自带的错误shader，并创建材质球
        }

        // 渲染设置
        var drawingSettings = new DrawingSettings(legacyShaderTagIds[0], new SortingSettings(camera))
        {
            overrideMaterial = errorMaterial                                                        // 把unity自带的错误材质球设置到渲染设置里
                                                                                                    // 本RP不支持的shader渲染成紫色
        };
        // 遍历所有pass，设置进去
        for (int i = 1; i < legacyShaderTagIds.Length; i++)
        {
            drawingSettings.SetShaderPassName(i, legacyShaderTagIds[i]);
        }
        // 过滤设置
        var filteringSettings = FilteringSettings.defaultValue;

        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }

    /// <summary>
    /// Editer下对缓冲区的提前准备操作
    /// </summary>
    partial void PrepareBuffer()
    {
        buffer.name = SampleName = camera.name;          // 把摄像机名称赋值进去，这样editor下profiler和frame debugger中就会显示对应摄像机的名称,同时用SampleName记录下来
    }

    /// <summary>
    /// scene窗口下的绘制
    /// </summary>
    partial void PrepareForSceneWindow()
    {
        // 如果是scene窗口下的摄像机
        if (camera.cameraType == CameraType.SceneView)
        {
            // UI显式添加到世界几何体中,这样Scene窗口才能把UI渲染出来
            ScriptableRenderContext.EmitWorldGeometryForSceneView(camera);
        }
    }
#else 
    const string SampleName = bufferName;               // 非编辑器下profiler和frame debugger中的渲染名称直接用缓冲区名称,
                                                        // 之所以不和Editor下一样用摄像机名称，是因为频繁检索摄像机名称会引起GC
#endif
}
