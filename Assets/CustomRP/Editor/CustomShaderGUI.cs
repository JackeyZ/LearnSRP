using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class CustomShaderGUI : ShaderGUI
{
    MaterialEditor editor;
    Object[] materials;
    MaterialProperty[] properties;

    bool showPresets;

    bool Clipping
    {
        set => SetProperty("_Clipping", "_CLIPPING", value);
    }

    /// <summary>
    /// 漫反射是否预乘透明度(玻璃模式)
    /// </summary>
    bool PremultiplyAlpha
    {
        set => SetProperty("_PremulAlpha", "_PREMULTIPLY_ALPHA", value);
    }

    BlendMode SrcBlend
    {
        set => SetProperty("_SrcBlend", (float)value);
    }

    BlendMode DstBlend
    {
        set => SetProperty("_DstBlend", (float)value);
    }

    bool ZWrite
    {
        set => SetProperty("_ZWrite", value ? 1f : 0f);
    }

    RenderQueue RenderQueue {
        set {
            foreach (Material m in materials)
            {
                m.renderQueue = (int)value;
            }
        }
    }

    /// <summary>
    /// 材质属性是否存在
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    bool HasProperty(string name) => FindProperty(name, properties, false) != null;

    /// <summary>
    /// 是否有预乘透明度属性
    /// </summary>
    bool HasPremultiplyAlpha => HasProperty("_PremulAlpha");

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
        base.OnGUI(materialEditor, properties);
        editor = materialEditor;
        materials = materialEditor.targets;
        this.properties = properties;

        EditorGUILayout.Space();
        showPresets = EditorGUILayout.Foldout(showPresets, "Presets", true);
        if (showPresets)
        {
            OpaquePreset();
            ClipPreset();
            FadePreset();
            TransparentPreset();
        }
    }


    /// <summary>
    /// 设置材质属性
    /// </summary>
    /// <param name="name">属性名</param>
    /// <param name="value">属性值</param>
    bool SetProperty(string name, float value) {
        MaterialProperty property = FindProperty(name, properties, false);
        if (property != null)
        {
            property.floatValue = value;
            return true;
        }
        return false;
    }

    /// <summary>
    /// 设置材质属性和keyword
    /// </summary>
    /// <param name="name">属性名</param>
    /// <param name="keyword">keyword名称</param>
    /// <param name="value">是否激活</param>
    void SetProperty(string name, string keyword, bool value) {
        if (SetProperty(name, value ? 1f : 0f))
        {
            SetKeyword(keyword, value);
        }
    }

    /// <summary>
    /// 设置材质keyword是否激活
    /// </summary>
    /// <param name="keyword">keyword名称</param>
    /// <param name="enabled">是否激活</param>
    void SetKeyword(string keyword, bool enabled) {
        if (enabled)
        {
            foreach (Material m in materials)
            {
                m.EnableKeyword(keyword);
            }
        }
        else
        {
            foreach (Material m in materials)
            {
                m.DisableKeyword(keyword);
            }
        }
    }

    bool PresetButton(string name) {
        if (GUILayout.Button(name)) {
            editor.RegisterPropertyChangeUndo(name);
            return true;
        }
        return false;
    }

    /// <summary>
    /// 不透明模式
    /// </summary>
    void OpaquePreset() {
        if (PresetButton("Opaque")) {
            Clipping = false;
            PremultiplyAlpha = false;
            SrcBlend = BlendMode.One;
            DstBlend = BlendMode.Zero;
            ZWrite = true;
            RenderQueue = RenderQueue.Geometry;
        }
    }

    /// <summary>
    /// 裁剪半透明模式
    /// </summary>
    void ClipPreset() {
        if (PresetButton("Clip")) {
            Clipping = true;
            PremultiplyAlpha = false;
            SrcBlend = BlendMode.One;
            DstBlend = BlendMode.Zero;
            ZWrite = true;
            RenderQueue = RenderQueue.AlphaTest;
        }
    }
    /// <summary>
    /// 透明模式
    /// </summary>
    void FadePreset()
    {
        if (PresetButton("Fade"))
        {
            Clipping = false;
            PremultiplyAlpha = false;
            SrcBlend = BlendMode.SrcAlpha;
            DstBlend = BlendMode.OneMinusSrcAlpha;
            ZWrite = false;
            RenderQueue = RenderQueue.Transparent;
        }
    }

    /// <summary>
    /// 漫反射半透明模式（玻璃模式）
    /// </summary>
    void TransparentPreset() {
        if (HasPremultiplyAlpha && PresetButton("Transparent")) {
            Clipping = false;
            PremultiplyAlpha = true;
            SrcBlend = BlendMode.One;
            DstBlend = BlendMode.OneMinusSrcAlpha;
            ZWrite = false;
            RenderQueue = RenderQueue.Transparent;
        }
    }
}
