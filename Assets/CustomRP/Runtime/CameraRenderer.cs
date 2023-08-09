using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 负责单个摄像机的渲染
/// </summary>
public partial class CameraRenderer
{
    ScriptableRenderContext context;                                                // 上下文
    Camera camera;                                                                  // 当前渲染的摄像机
    CullingResults cullingResults;                                                  // 用于储存剔除结果
    static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");       // 用于渲染的着色器
    static ShaderTagId LitShaderTagId = new ShaderTagId("CustomLit");               // 光照着色器LightMode的tag

    const string bufferName = "Render Camera";
    CommandBuffer buffer = new CommandBuffer            // 调用CommandBuffer的无参构造函数，并执行大括号内的方法，对CommandBuffer里面的属性赋值
    {
        name = bufferName                               // 给缓冲区命名，方便后续显示在profiler和frame debugger中
    };

    /// <summary>
    /// 渲染单个相机
    /// </summary>
    /// <param name="context">上下文</param>
    /// <param name="camera">所需渲染的相机</param>
    public void Render(ScriptableRenderContext context, Camera camera, bool useDynamicBatching, bool useGPUInstancing)
    {
        this.context = context;
        this.camera = camera;

        // 缓冲区准备设置
        PrepareBuffer();
        // 在Scene窗口的摄像机绘制几何体，因为可能会给场景新添几何体，所以要在Cull之前调用
        PrepareForSceneWindow();

        // 剔除摄像机视锥体外部的renderer
        if (!Cull())
        {
            return; // 剔除失败
        }

        SetUp();
        DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);                                  // 绘制可见几何体
        DrawUnsupportedShaders();                               // 绘制用了不支持shader材质的几何体
        DrawGizmos();                                           // 绘制小控件
        Submit();                                               // 根据上下文，执行渲染
    }

    public void SetUp()
    {
        context.SetupCameraProperties(camera);                  // 摄像机的属性(位置/方向/fov等，设置unity_MatrixVP矩阵)应用到context
        CameraClearFlags flags = camera.clearFlags;             // 获取当前摄像机的清理标志
        // 给buffer添加命令：清理渲染目标的数据（深度缓冲/颜色缓冲/背景颜色等）
        buffer.ClearRenderTarget(
            flags <= CameraClearFlags.Depth,                    // 标记小于等于CameraClearFlags.Depth的，都清掉深度缓冲
            flags == CameraClearFlags.Color,                    // 清除颜色缓冲
            flags == CameraClearFlags.Color ? camera.backgroundColor.linear : Color.clear   // 如果需要清理颜色缓冲，则该参数决定用什么颜色写入颜色缓冲区 
        );  
        buffer.BeginSample(SampleName);                         // 给buffer添加命令：显示在profiler和frame debugger中
        ExecuteBuffer();                                        // 将buffer中的命令复制到上下文中
    }

    /// <summary>
    /// 把所需渲染的几何体写入上下文
    /// </summary>
    void DrawVisibleGeometry(bool useDynamicBatching, bool useGPUInstancing)
    {
        var sortingSettings = new SortingSettings(camera)                                           // 创建排序设置
        {
            criteria = SortingCriteria.CommonOpaque                                                 // 指定为通用渲染顺序（从前往后）
        };
        var drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings)                // 创建绘图设置，参数传入着色器和顺序设置
        {
            enableDynamicBatching = useDynamicBatching,                                             // 是否开启动态合批
            enableInstancing = useGPUInstancing                                                     // 是否开启GPUInstancing
        };
        drawingSettings.SetShaderPassName(1, LitShaderTagId);                                       // 把LightMode的Tag是CustomLit的pass设置到1的位置（0的位置在构造函数里设置了），让这次draw call可以用这个pass渲染
        var filteringSetting = new FilteringSettings(RenderQueueRange.opaque);                      // 创建过滤设置，参数指定渲染不透明物体

        // 绘制不透明物体。传入剔除结果，绘图设置，过滤设置从而绘制可视的renderer
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSetting);

        context.DrawSkybox(camera);         // 绘制天空盒

        // 绘制半透明物体。
        sortingSettings.criteria = SortingCriteria.CommonTransparent;                               // 渲染顺序改成半透明的顺序（从后往前）
        drawingSettings.sortingSettings = sortingSettings;
        filteringSetting.renderQueueRange = RenderQueueRange.transparent;                           // 目标渲染队列改成半透明的队列
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSetting);           // 渲染半透明躯体
    }

    /// <summary>
    /// 绘制scene窗口下小部件的方法（这里仅仅是空方法，在CameraRenderer.Editor.cs里会重写该方法）
    /// </summary>
    partial void DrawGizmos();

    /// <summary>
    /// Editor下绘制本RP不支持的shader（这里仅仅是空方法，在CameraRenderer.Editor.cs里会重写该方法）
    /// </summary>
    partial void DrawUnsupportedShaders();

    /// <summary>
    /// Editor下缓冲区准备
    /// </summary>
    partial void PrepareBuffer();

    /// <summary>
    /// Editor下scene窗口下的绘制
    /// </summary>
    partial void PrepareForSceneWindow();

    /// <summary>
    /// 根据缓存的上下文，执行渲染
    /// </summary>
    void Submit()
    {
        buffer.EndSample(SampleName);           // 给buffer添加命令：显示在profiler和frame debugger中
        ExecuteBuffer();                        // 将buffer中的命令复制到上下文中
        context.Submit();                       // 根据上下文真正执行渲染
    }

    /// <summary>
    /// 把buffer中的命令复制到上下文中
    /// </summary>
    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);   // 把命令从缓冲区复制到上下文中
        buffer.Clear();                         // 清理缓冲区中的命令
    }


    bool Cull()
    {
        // 获得执行剔除所需要的信息
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            cullingResults = context.Cull(ref p);        // 执行剔除,并得到剔除结果
            return true;
        }
        return false;
    }
}
