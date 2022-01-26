using UnityEngine;

[DisallowMultipleComponent] // 单个对象不允许添加多个本组件
public class PerObjectMaterialProperties : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");
    static MaterialPropertyBlock block;                                                 // 材质球属性块
    [SerializeField]
    Color baseColor = Color.white;

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
        GetComponent<Renderer>().SetPropertyBlock(block);                               // 把属性块设置到渲染器里,这样就可以实现多个renderer用同一个材质球时可以出现不同效果，但是会打断合批
    }
}
