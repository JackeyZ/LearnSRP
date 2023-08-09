using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;

/// <summary>
/// CameraRenderer���ڱ༭���µĴ���
/// partial�ؼ��ֱ�ʾ���ļ�ֻ�������Ĳ��ִ���
/// </summary>
partial class CameraRenderer
{
#if UNITY_EDITOR
    static ShaderTagId[] legacyShaderTagIds = {                                     // unityĬ����ɫ�����pass
        new ShaderTagId("Always"),
        new ShaderTagId("ForwardBase"),
        new ShaderTagId("PrepassBase"),
        new ShaderTagId("Vertex"),
        new ShaderTagId("VertexLMRGBM"),
        new ShaderTagId("VertexLM")
    };
    static Material errorMaterial;                                                  // ��Ⱦ��֧�ֵ�shader��ʱ���õĲ�����
    string SampleName { get; set; }

    /// <summary>
    /// ����scene�����µ�С������Gizmos��
    /// </summary>
    partial void DrawGizmos()
    {
        // unity�Ŀ��أ�����Ƿ���Ҫ��Scene���ڻ���Gizmos
        if (Handles.ShouldRenderGizmos())
        {
            context.DrawGizmos(camera, GizmoSubset.PreImageEffects);                // ����֮ǰ����
            context.DrawGizmos(camera, GizmoSubset.PostImageEffects);               // ����֮�����
        }
    }

    /// <summary>
    /// ���Ʊ�RP��֧�ֵ�shader
    /// </summary>
    partial void DrawUnsupportedShaders()
    {
        if (errorMaterial == null)
        {
            errorMaterial = new Material(Shader.Find("Hidden/InternalErrorShader"));                // ����unity�Դ��Ĵ���shader��������������
        }

        // ��Ⱦ����
        var drawingSettings = new DrawingSettings(legacyShaderTagIds[0], new SortingSettings(camera))
        {
            overrideMaterial = errorMaterial                                                        // ��unity�Դ��Ĵ�����������õ���Ⱦ������
                                                                                                    // ��RP��֧�ֵ�shader��Ⱦ����ɫ
        };
        // ��������pass�����ý�ȥ
        for (int i = 1; i < legacyShaderTagIds.Length; i++)
        {
            drawingSettings.SetShaderPassName(i, legacyShaderTagIds[i]);
        }
        // ��������
        var filteringSettings = FilteringSettings.defaultValue;

        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }

    /// <summary>
    /// Editer�¶Ի���������ǰ׼������
    /// </summary>
    partial void PrepareBuffer()
    {
        buffer.name = SampleName = camera.name;          // ����������Ƹ�ֵ��ȥ������editor��profiler��frame debugger�оͻ���ʾ��Ӧ�����������,ͬʱ��SampleName��¼����
    }

    /// <summary>
    /// scene�����µĻ���
    /// </summary>
    partial void PrepareForSceneWindow()
    {
        // �����scene�����µ������
        if (camera.cameraType == CameraType.SceneView)
        {
            // UI��ʽ��ӵ����缸������,����Scene���ڲ��ܰ�UI��Ⱦ����
            ScriptableRenderContext.EmitWorldGeometryForSceneView(camera);
        }
    }
#else 
    const string SampleName = bufferName;               // �Ǳ༭����profiler��frame debugger�е���Ⱦ����ֱ���û���������,
                                                        // ֮���Բ���Editor��һ������������ƣ�����ΪƵ��������������ƻ�����GC
#endif
}
