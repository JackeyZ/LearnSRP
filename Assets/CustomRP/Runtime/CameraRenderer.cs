using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// ���𵥸����������Ⱦ
/// </summary>
public partial class CameraRenderer
{
    ScriptableRenderContext context;                                                // ������
    Camera camera;                                                                  // ��ǰ��Ⱦ�������
    CullingResults cullingResults;                                                  // ���ڴ����޳����
    static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");       // ������Ⱦ����ɫ��
    static ShaderTagId LitShaderTagId = new ShaderTagId("CustomLit");               // ������ɫ��LightMode��tag

    const string bufferName = "Render Camera";
    CommandBuffer buffer = new CommandBuffer            // ����CommandBuffer���޲ι��캯������ִ�д������ڵķ�������CommandBuffer��������Ը�ֵ
    {
        name = bufferName                               // �����������������������ʾ��profiler��frame debugger��
    };

    /// <summary>
    /// ��Ⱦ�������
    /// </summary>
    /// <param name="context">������</param>
    /// <param name="camera">������Ⱦ�����</param>
    public void Render(ScriptableRenderContext context, Camera camera, bool useDynamicBatching, bool useGPUInstancing)
    {
        this.context = context;
        this.camera = camera;

        // ������׼������
        PrepareBuffer();
        // ��Scene���ڵ���������Ƽ����壬��Ϊ���ܻ�������������壬����Ҫ��Cull֮ǰ����
        PrepareForSceneWindow();

        // �޳��������׶���ⲿ��renderer
        if (!Cull())
        {
            return; // �޳�ʧ��
        }

        SetUp();
        DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);                                  // ���ƿɼ�������
        DrawUnsupportedShaders();                               // �������˲�֧��shader���ʵļ�����
        DrawGizmos();                                           // ����С�ؼ�
        Submit();                                               // ���������ģ�ִ����Ⱦ
    }

    public void SetUp()
    {
        context.SetupCameraProperties(camera);                  // �����������(λ��/����/fov�ȣ�����unity_MatrixVP����)Ӧ�õ�context
        CameraClearFlags flags = camera.clearFlags;             // ��ȡ��ǰ������������־
        // ��buffer������������ȾĿ������ݣ���Ȼ���/��ɫ����/������ɫ�ȣ�
        buffer.ClearRenderTarget(
            flags <= CameraClearFlags.Depth,                    // ���С�ڵ���CameraClearFlags.Depth�ģ��������Ȼ���
            flags == CameraClearFlags.Color,                    // �����ɫ����
            flags == CameraClearFlags.Color ? camera.backgroundColor.linear : Color.clear   // �����Ҫ������ɫ���壬��ò���������ʲô��ɫд����ɫ������ 
        );  
        buffer.BeginSample(SampleName);                         // ��buffer��������ʾ��profiler��frame debugger��
        ExecuteBuffer();                                        // ��buffer�е�����Ƶ���������
    }

    /// <summary>
    /// ��������Ⱦ�ļ�����д��������
    /// </summary>
    void DrawVisibleGeometry(bool useDynamicBatching, bool useGPUInstancing)
    {
        var sortingSettings = new SortingSettings(camera)                                           // ������������
        {
            criteria = SortingCriteria.CommonOpaque                                                 // ָ��Ϊͨ����Ⱦ˳�򣨴�ǰ����
        };
        var drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings)                // ������ͼ���ã�����������ɫ����˳������
        {
            enableDynamicBatching = useDynamicBatching,                                             // �Ƿ�����̬����
            enableInstancing = useGPUInstancing                                                     // �Ƿ���GPUInstancing
        };
        drawingSettings.SetShaderPassName(1, LitShaderTagId);                                       // ��LightMode��Tag��CustomLit��pass���õ�1��λ�ã�0��λ���ڹ��캯���������ˣ��������draw call���������pass��Ⱦ
        var filteringSetting = new FilteringSettings(RenderQueueRange.opaque);                      // �����������ã�����ָ����Ⱦ��͸������

        // ���Ʋ�͸�����塣�����޳��������ͼ���ã��������ôӶ����ƿ��ӵ�renderer
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSetting);

        context.DrawSkybox(camera);         // ������պ�

        // ���ư�͸�����塣
        sortingSettings.criteria = SortingCriteria.CommonTransparent;                               // ��Ⱦ˳��ĳɰ�͸����˳�򣨴Ӻ���ǰ��
        drawingSettings.sortingSettings = sortingSettings;
        filteringSetting.renderQueueRange = RenderQueueRange.transparent;                           // Ŀ����Ⱦ���иĳɰ�͸���Ķ���
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSetting);           // ��Ⱦ��͸������
    }

    /// <summary>
    /// ����scene������С�����ķ�������������ǿշ�������CameraRenderer.Editor.cs�����д�÷�����
    /// </summary>
    partial void DrawGizmos();

    /// <summary>
    /// Editor�»��Ʊ�RP��֧�ֵ�shader����������ǿշ�������CameraRenderer.Editor.cs�����д�÷�����
    /// </summary>
    partial void DrawUnsupportedShaders();

    /// <summary>
    /// Editor�»�����׼��
    /// </summary>
    partial void PrepareBuffer();

    /// <summary>
    /// Editor��scene�����µĻ���
    /// </summary>
    partial void PrepareForSceneWindow();

    /// <summary>
    /// ���ݻ���������ģ�ִ����Ⱦ
    /// </summary>
    void Submit()
    {
        buffer.EndSample(SampleName);           // ��buffer��������ʾ��profiler��frame debugger��
        ExecuteBuffer();                        // ��buffer�е�����Ƶ���������
        context.Submit();                       // ��������������ִ����Ⱦ
    }

    /// <summary>
    /// ��buffer�е�����Ƶ���������
    /// </summary>
    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);   // ������ӻ��������Ƶ���������
        buffer.Clear();                         // ���������е�����
    }


    bool Cull()
    {
        // ���ִ���޳�����Ҫ����Ϣ
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            cullingResults = context.Cull(ref p);        // ִ���޳�,���õ��޳����
            return true;
        }
        return false;
    }
}
