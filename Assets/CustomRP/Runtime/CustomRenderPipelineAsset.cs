using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// �Զ�����Ⱦ�����ʲ��ű�
/// ���ڴ���һ����Ⱦ����
/// </summary>
[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")] // �����ǿ��ԴӲ˵��д�������ʲ�
public class CustomRenderPipelineAsset : RenderPipelineAsset
{

    /// <summary>
    /// ����һ����Ⱦ����
    /// </summary>
    /// <returns></returns>
    protected override RenderPipeline CreatePipeline()
    {
        return new CustomRenderPipeline();          // �����Զ�����Ⱦ����
    }
}