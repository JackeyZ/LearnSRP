using UnityEngine;
using UnityEngine.Rendering;

public class CustomRenderPipeline : RenderPipeline {
    CameraRenderer renderer = new CameraRenderer();
    bool useDynamicBatching, useGPUInstancing;

    public CustomRenderPipeline(bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatcher)
    {
        this.useDynamicBatching = useDynamicBatching;
        this.useGPUInstancing = useGPUInstancing;
        GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;   // ����SRP������
        GraphicsSettings.lightsUseLinearIntensity = true;                       // ����ǿ��ʹ�����Կռ�
    }

    /// <summary>
    /// Unity��ÿ֡�������RPʵ���ϵ�Render������
    /// ͨ������һ�������ṹ��������뱾��������н�����
    /// ���ǿ��������������������Ⱦ�����ᴫ��һ��������飬
    /// ��Ϊ�����п��ܻ��ж������������ˡ�
    /// RP��ְ����Ҫ����ȷ����˳����Щ�����Ⱦ������
    /// </summary>
    /// <param name="context">�����Ľṹ��</param>
    /// <param name="cameras">���������м�������</param>
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        // �������м�������������Ⱦ
        foreach (Camera camera in cameras)
        {
            renderer.Render(context, camera, useDynamicBatching, useGPUInstancing);
        }
    }
}
