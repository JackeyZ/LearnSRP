using UnityEngine;

/// <summary>
/// 该脚本用于替换游戏对象里材质球的个别属性，可以让同一个材质球在不同游戏对象里有不同的属性
/// </summary>
[DisallowMultipleComponent] // 单个对象不允许添加多个本组件
public class PerObjectMaterialProperties : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");                         // 把shader里的属性名转换成id
    static int cutoffId = Shader.PropertyToID("_Cutoff");
    static MaterialPropertyBlock block;                                                 // 材质球属性块
    [SerializeField]
    Color baseColor = Color.white;

    [SerializeField, Range(0, 1)]
    float cutoff = 0.5f;

    private void Awake()
    {
        OnValidate();       // 初始化后直接给renderer设置属性块
    }

    /// <summary>
    /// 加载或更改组件后，将在Unity编辑器中调用OnValidate。因此，每次加载场景时以及编辑组件时。因此，各个颜色会立即显示并响应编辑。
    /// </summary>
    private void OnValidate()
    {
        if(block == null)
        {
            block = new MaterialPropertyBlock();
        }
        block.SetColor(baseColorId, baseColor);                                         // 给属性块赋值
        block.SetFloat(cutoffId, cutoff);
        GetComponent<Renderer>().SetPropertyBlock(block);                               // 把属性块设置到渲染器里,这样就可以实现多个renderer用同一个材质球时可以出现不同效果，但是会打断合批
    }
}
