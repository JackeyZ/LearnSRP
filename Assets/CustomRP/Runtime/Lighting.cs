using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    const string bufferName = "Lighting";
    const int maxDirLightCount = 4;                     // 平行光最大支持数目
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
        this.cullingResults = cullingResults;                                               // 取得裁剪数据，用来获取哪些灯光对当前摄像机物体有影响
        buffer.BeginSample(bufferName);
        SetupLights();
        buffer.EndSample(bufferName);
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    /// <summary>
    /// 设置光照信息到缓冲区里
    /// </summary>
    void SetupLights() {
        NativeArray<VisibleLight> visibleLights = cullingResults.visibleLights;             // 获取所有对当前摄像机视锥体区域有影响的灯光
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
        buffer.SetGlobalInt(dirLightCountId, visibleLights.Length);                         // 设置平行光数目
        buffer.SetGlobalVectorArray(dirLightColorId, dirLightColors);                       // 设置平行光颜色数组
        buffer.SetGlobalVectorArray(dirLightDirectionId, dirLightDirections);               // 设置平行光方向数组

    }

    /// <summary>
    /// 设置一个平行光的信息
    /// </summary>
    /// <param name="index"></param>
    /// <param name="visibleLight">平行光的结构体，使用ref关键字是避免VisibleLight这个结构体在传递参数的时候复制，因为这个结构体非常大</param>
    void SetupDirectionalLight(int index, ref VisibleLight visibleLight) {
        dirLightColors[index] = visibleLight.finalColor;
        dirLightDirections[index] = -visibleLight.localToWorldMatrix.GetColumn(2);          // 通过“模型空间->世界空间”转化矩阵的第三列获取灯光的transform.forward向量，然后取负得到光照方向(指向光源的向量)
    }
}
