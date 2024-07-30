using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    const string bufferName = "Lighting";
    const int maxDirLightCount = 4;                     // ƽ�й����֧����Ŀ
    static int dirLightCountId = Shader.PropertyToID("_DirectionalLightCount");
    static int dirLightColorId = Shader.PropertyToID("_DirectionalLightColors");
    static int dirLightDirectionId = Shader.PropertyToID("_DirectionalLightDirections");
    static Vector4[] dirLightColors = new Vector4[maxDirLightCount];
    static Vector4[] dirLightDirections = new Vector4[maxDirLightCount];
    CullingResults cullingResults;
    

    CommandBuffer buffer = new CommandBuffer {
        name = bufferName
    };

    public void SetUp(ScriptableRenderContext context, CullingResults cullingResults) {
        this.cullingResults = cullingResults;                                               // ȡ�òü����ݣ�������ȡ��Щ�ƹ�Ե�ǰ�����������Ӱ��
        buffer.BeginSample(bufferName);
        SetupLights();
        buffer.EndSample(bufferName);
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    /// <summary>
    /// ���ù�����Ϣ����������
    /// </summary>
    void SetupLights() {
        NativeArray<VisibleLight> visibleLights = cullingResults.visibleLights;             // ��ȡ���жԵ�ǰ�������׶��������Ӱ��ĵƹ�
        int dirLightCount = 0;
        for (int i = 0; i < visibleLights.Length; i++)
        {
            VisibleLight visibleLight = visibleLights[i];
            if(visibleLight.lightType == LightType.Directional)
            {
                SetupDirectionalLight(dirLightCount++, ref visibleLight);
                if (dirLightCount >= maxDirLightCount)
                {
                    break;
                }
            }
        }
        buffer.SetGlobalInt(dirLightCountId, visibleLights.Length);                         // ����ƽ�й���Ŀ
        buffer.SetGlobalVectorArray(dirLightColorId, dirLightColors);                       // ����ƽ�й���ɫ����
        buffer.SetGlobalVectorArray(dirLightDirectionId, dirLightDirections);               // ����ƽ�йⷽ������

    }

    /// <summary>
    /// ����һ��ƽ�й����Ϣ
    /// </summary>
    /// <param name="index"></param>
    /// <param name="visibleLight">ƽ�й�Ľṹ�壬ʹ��ref�ؼ����Ǳ���VisibleLight����ṹ���ڴ��ݲ�����ʱ���ƣ���Ϊ����ṹ��ǳ���</param>
    void SetupDirectionalLight(int index, ref VisibleLight visibleLight) {
        dirLightColors[index] = visibleLight.finalColor;
        dirLightDirections[index] = -visibleLight.localToWorldMatrix.GetColumn(2);          // ͨ����ģ�Ϳռ�->����ռ䡱ת������ĵ����л�ȡ�ƹ��transform.forward������Ȼ��ȡ���õ����շ���(ָ���Դ������)
    }
}
