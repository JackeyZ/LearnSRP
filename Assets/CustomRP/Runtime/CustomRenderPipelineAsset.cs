using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 自定义渲染管线资产脚本
/// 用于创建一个渲染管线
/// </summary>
[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")] // 让我们可以从菜单中创建这个资产
public class CustomRenderPipelineAsset : RenderPipelineAsset
{
    [SerializeField]
    bool useDynamicBatching, useGPUInstancing, useSRPBatcher;

    /// <summary>
    /// 创建一个渲染管线
    /// </summary>
    /// <returns></returns>
    protected override RenderPipeline CreatePipeline()
    {
        return new CustomRenderPipeline(useDynamicBatching, useGPUInstancing, useSRPBatcher);          // 返回自定义渲染管线
    }
}
