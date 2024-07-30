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
    /// �������Ƿ�Ԥ��͸����(����ģʽ)
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
    /// ���������Ƿ����
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    bool HasProperty(string name) => FindProperty(name, properties, false) != null;

    /// <summary>
    /// �Ƿ���Ԥ��͸��������
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
    /// ���ò�������
    /// </summary>
    /// <param name="name">������</param>
    /// <param name="value">����ֵ</param>
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
    /// ���ò������Ժ�keyword
    /// </summary>
    /// <param name="name">������</param>
    /// <param name="keyword">keyword����</param>
    /// <param name="value">�Ƿ񼤻�</param>
    void SetProperty(string name, string keyword, bool value) {
        if (SetProperty(name, value ? 1f : 0f))
        {
            SetKeyword(keyword, value);
        }
    }

    /// <summary>
    /// ���ò���keyword�Ƿ񼤻�
    /// </summary>
    /// <param name="keyword">keyword����</param>
    /// <param name="enabled">�Ƿ񼤻�</param>
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
    /// ��͸��ģʽ
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
    /// �ü���͸��ģʽ
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
    /// ͸��ģʽ
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
    /// �������͸��ģʽ������ģʽ��
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
