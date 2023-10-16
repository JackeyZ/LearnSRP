using UnityEngine;

/// <summary>
/// �ýű������滻��Ϸ�����������ĸ������ԣ�������ͬһ���������ڲ�ͬ��Ϸ�������в�ͬ������
/// </summary>
[DisallowMultipleComponent] // ��������������Ӷ�������
public class PerObjectMaterialProperties : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");                         // ��shader���������ת����id
    static int cutoffId = Shader.PropertyToID("_Cutoff");
    static MaterialPropertyBlock block;                                                 // ���������Կ�
    [SerializeField]
    Color baseColor = Color.white;

    [SerializeField, Range(0, 1)]
    float cutoff = 0.5f;

    private void Awake()
    {
        OnValidate();       // ��ʼ����ֱ�Ӹ�renderer�������Կ�
    }

    /// <summary>
    /// ���ػ��������󣬽���Unity�༭���е���OnValidate����ˣ�ÿ�μ��س���ʱ�Լ��༭���ʱ����ˣ�������ɫ��������ʾ����Ӧ�༭��
    /// </summary>
    private void OnValidate()
    {
        if(block == null)
        {
            block = new MaterialPropertyBlock();
        }
        block.SetColor(baseColorId, baseColor);                                         // �����Կ鸳ֵ
        block.SetFloat(cutoffId, cutoff);
        GetComponent<Renderer>().SetPropertyBlock(block);                               // �����Կ����õ���Ⱦ����,�����Ϳ���ʵ�ֶ��renderer��ͬһ��������ʱ���Գ��ֲ�ͬЧ�������ǻ��Ϻ���
    }
}
