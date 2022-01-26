using UnityEngine;

[DisallowMultipleComponent] // ��������������Ӷ�������
public class PerObjectMaterialProperties : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");
    static MaterialPropertyBlock block;                                                 // ���������Կ�
    [SerializeField]
    Color baseColor = Color.white;

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
        GetComponent<Renderer>().SetPropertyBlock(block);                               // �����Կ����õ���Ⱦ����,�����Ϳ���ʵ�ֶ��renderer��ͬһ��������ʱ���Գ��ֲ�ͬЧ�������ǻ��Ϻ���
    }
}
