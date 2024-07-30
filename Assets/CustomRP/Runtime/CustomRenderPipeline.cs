using UnityEngine;
using UnityEngine.Rendering;

public class CustomRenderPipeline : RenderPipeline {
    CameraRenderer renderer = new CameraRenderer();
    bool useDynamicBatching, useGPUInstancing;

    public CustomRenderPipeline(bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatcher)
    {
        this.useDynamicBatching = useDynamicBatching;
        this.useGPUInstancing = useGPUInstancing;
        GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;   // 启用SRP批处理
        GraphicsSettings.lightsUseLinearIntensity = true;                       // 光照强度使用线性空间
    }

    /// <summary>
    /// Unity在每帧都会调用RP实例上的Render函数。
    /// 通过传入一个环境结构体变量来与本地引擎进行交流，
    /// 我们可以用这个变量来进行渲染。还会传入一个相机数组，
    /// 因为场景中可能会有多个相机被激活了。
    /// RP的职责是要按照确定的顺序将这些相机渲染出来。
    /// </summary>
    /// <param name="context">上下文结构体</param>
    /// <param name="cameras">场景中所有激活的相机</param>
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        // 遍历所有激活的相机进行渲染
        foreach (Camera camera in cameras)
        {
            renderer.Render(context, camera, useDynamicBatching, useGPUInstancing);
        }
    }
}
