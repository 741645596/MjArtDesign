using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering.Universal.Internal;

public class LutBakerPass : ScriptableRenderPass
{
    private const string k_ProfilerTag = "Color Grading LUT";
    private readonly Material m_LutBakerMaterial;

    private const string m_ColorLutName = "_ColorLut";
    private RenderTargetHandle m_ColorLut;

    private GraphicsFormat m_LutFormat;
    public static int m_LutSize = 32;
    LitePostFeature litePostFeature;

    #region//编辑器工具-Lut截图

#if UNITY_EDITOR
    /// <summary>
    /// 截图开始帧
    /// </summary>
    public static bool CapTest = false;

    /// <summary>
    /// 截图执行帧
    /// </summary>
    public static bool CapTestNext = false;

    /// <summary>
    /// 临时存储
    /// </summary>
    RenderTexture capRenderTexture = null;

    public static string CapLevelPNGName = null;

    string capLevelDir = Application.dataPath + "/Renders/Texture/VolumeLutTextures/";

#endif

    int capW;

    int capH;

    #endregion

    public LutBakerPass(UnityEngine.Rendering.Universal.RenderPassEvent evt, Material material)
    {
        renderPassEvent = evt;
        m_LutBakerMaterial = material;

        FormatUsage kFlags = FormatUsage.Linear | FormatUsage.Render;
        if (SystemInfo.IsFormatSupported(GraphicsFormat.B10G11R11_UFloatPack32, kFlags))
            m_LutFormat = GraphicsFormat.B10G11R11_UFloatPack32;
        else
            m_LutFormat = GraphicsFormat.R8G8B8A8_UNorm;
    }

    public void Set(LitePostFeature litePostFeature)
    {
        this.litePostFeature = litePostFeature;
    }

    RenderTargetHandle[] ACES_Array = new RenderTargetHandle[1];

    RenderTargetHandle[] NotACES_Array = new RenderTargetHandle[2];


    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        m_ColorLut.Init(m_ColorLutName);
        capW = m_LutSize * m_LutSize;
        capH = m_LutSize;
        cmd.GetTemporaryRT(m_ColorLut.id, capW, capH, 0, FilterMode.Bilinear, m_LutFormat, 1);
#if UNITY_EDITOR
        if (CapTest)
        {
            RenderTextureDescriptor opaqueDesc = cameraTextureDescriptor;
            opaqueDesc.vrUsage = VRTextureUsage.None;
            opaqueDesc.depthBufferBits = 0;
            opaqueDesc.colorFormat = RenderTextureFormat.ARGB32;
            opaqueDesc.width = capW;
            opaqueDesc.height = capH;
            capRenderTexture = RenderTexture.GetTemporary(opaqueDesc);
        }
#endif
    }

    Vector4 defaultSplitShadows = new Vector4(0.5f,0.5f,0.5f,0);

    Vector4 defaultSplitHighlights = new Vector4(0.5f, 0.5f, 0.5f, 0);

    Vector4 defaultShadowsHighlightsLimits = new Vector4(0, 0.3f, 0.55f,1f);

    Vector4 defaultShadows = new Vector4(1f, 1f, 1f, 0);

    Vector4 defaultMidtones = new Vector4(1f, 1f, 1f, 0);

    Vector4 defaultHighlights = new Vector4(1f, 1f, 1f, 0);

    Vector4 defaultHueSatCon = new Vector4(0f, 1f, 1f, 0);

    Vector4 lutParameters = new Vector4(32, 0.00048828125f, 0.015625f, 1.0322580645f);

    /// <inheritdoc/>
    public override void Execute(ScriptableRenderContext context, ref UnityEngine.Rendering.Universal.RenderingData renderingData)
    {
#if UNITY_EDITOR
        if (CapTestNext)
        {
            CapTestNext = false;
            string dir = "E:/Capture";
            if (CapLevelPNGName != null)
            {
                dir = capLevelDir;
            }
            if (!System.IO.Directory.Exists(dir))
            {
                System.IO.Directory.CreateDirectory(dir);
            }
            if (CapLevelPNGName!=null)
            {
                LitePostFeature.SaveRenderToPng(capRenderTexture, dir, CapLevelPNGName, false);
            }
            else
            {
                LitePostFeature.SaveRenderToPng(capRenderTexture, dir, "LutCaptureTexture");
            }
            RenderTexture.ReleaseTemporary(capRenderTexture);
            Debug.LogError("截屏存储路径:"+ dir);
        }
#endif
        var cmd = CommandBufferPool.Get(k_ProfilerTag);
        cmd.BeginSample(string.Intern("Lite LutBaker Pass"));
        if (LitePostUtils.OpenToneMapping)
        {
            switch (LitePostUtils.ToneMapping.tonemappingMode.value)
            {
                case TonemappingMode.Unity:
                    {
                        cmd.EnableShaderKeyword(string.Intern("TONEMAPPING_UNITY"));
                        cmd.DisableShaderKeyword(string.Intern("TONEMAPPING_GT"));
                        cmd.DisableShaderKeyword(string.Intern("TONEMAPPING_UNREAL"));
                    }
                    break;
                case TonemappingMode.GT:
                    {
                        cmd.DisableShaderKeyword(string.Intern("TONEMAPPING_UNITY"));
                        cmd.EnableShaderKeyword(string.Intern("TONEMAPPING_GT"));
                        cmd.DisableShaderKeyword(string.Intern("TONEMAPPING_UNREAL"));
                    }
                    break;
                case TonemappingMode.Unreal:
                    {
                        cmd.DisableShaderKeyword(string.Intern("TONEMAPPING_UNITY"));
                        cmd.DisableShaderKeyword(string.Intern("TONEMAPPING_GT"));
                        cmd.EnableShaderKeyword(string.Intern("TONEMAPPING_UNREAL"));
                        m_LutBakerMaterial.SetFloat(ShaderConstants.Tonemap_FilmSlope, LitePostUtils.ToneMapping.Unreal_FilmSlope.value);
                        m_LutBakerMaterial.SetFloat(ShaderConstants.Tonemap_FilmToe, LitePostUtils.ToneMapping.Unreal_FilmToe.value);
                        m_LutBakerMaterial.SetFloat(ShaderConstants.Tonemap_FilmShoulder, LitePostUtils.ToneMapping.Unreal_FilmShoulder.value);
                        m_LutBakerMaterial.SetFloat(ShaderConstants.Tonemap_FilmBlackClip, LitePostUtils.ToneMapping.Unreal_FilmBlackClip.value);
                        m_LutBakerMaterial.SetFloat(ShaderConstants.Tonemap_FilmWhiteClip, LitePostUtils.ToneMapping.Unreal_FilmWhiteClip.value);
                    }
                    break;
            }
        }

        //Vector4 lutParameters = new Vector4(m_LutSize, 0.5f / (m_LutSize * m_LutSize), 0.5f / m_LutSize, m_LutSize / (m_LutSize - 1f));

        m_LutBakerMaterial.SetVector(ShaderConstants._Lut_Params, lutParameters);
        if (LitePostUtils.OpenWhiteBalance) {
            Vector3 lmsColorBalance = ColorUtils.ColorBalanceToLMSCoeffs(LitePostUtils.WhiteBalance.temperature.value, LitePostUtils.WhiteBalance.tint.value);
            m_LutBakerMaterial.SetVector(ShaderConstants._ColorBalance, lmsColorBalance);
        }
        else
        {
            m_LutBakerMaterial.SetVector(ShaderConstants._ColorBalance, Vector3.one);
        }
        m_LutBakerMaterial.SetVector(ShaderConstants._ColorFilter, LitePostUtils.ColorGrading.colorFilter.value.linear);
        if (LitePostUtils.OpenColorGrading)
        {
            Vector4 hueSatCon = new Vector4(LitePostUtils.ColorGrading.hueShift.value / 360f,
                LitePostUtils.ColorGrading.saturation.value / 100f + 1f, LitePostUtils.ColorGrading.contrast.value / 100f + 1f, 0f);
            m_LutBakerMaterial.SetVector(ShaderConstants._HueSatCon, hueSatCon);
        }
        else
        {
            m_LutBakerMaterial.SetVector(ShaderConstants._HueSatCon, defaultHueSatCon);
        }

        if (LitePostUtils.OpenLiftGammaGain)
        {
            (Vector4 lift, Vector4 gamma, Vector4 gain) = ColorUtils.PrepareLiftGammaGain(
                LitePostUtils.LiftGammaGain.lift.value,
                LitePostUtils.LiftGammaGain.gamma.value,
                LitePostUtils.LiftGammaGain.gain.value
            );
            m_LutBakerMaterial.SetVector(ShaderConstants._Lift, lift);
            m_LutBakerMaterial.SetVector(ShaderConstants._Gamma, gamma);
            m_LutBakerMaterial.SetVector(ShaderConstants._Gain, gain);
        }
        else
        {
            m_LutBakerMaterial.SetVector(ShaderConstants._Lift, Vector4.zero);
            m_LutBakerMaterial.SetVector(ShaderConstants._Gamma, Vector4.one);
            m_LutBakerMaterial.SetVector(ShaderConstants._Gain, Vector4.one);
        }
        if (LitePostUtils.OpenShadowsMidtonesHighlights)
        {
            Vector4 shadowsHighlightsLimits = new Vector4(
                LitePostUtils.ShadowsMidtonesHighlights.shadowsStart.value,
                LitePostUtils.ShadowsMidtonesHighlights.shadowsEnd.value,
                LitePostUtils.ShadowsMidtonesHighlights.highlightsStart.value,
                LitePostUtils.ShadowsMidtonesHighlights.highlightsEnd.value
            );
            (Vector4 shadows, Vector4 midtones, Vector4 highlights) = ColorUtils.PrepareShadowsMidtonesHighlights(
                LitePostUtils.ShadowsMidtonesHighlights.shadows.value,
                LitePostUtils.ShadowsMidtonesHighlights.midtones.value,
                LitePostUtils.ShadowsMidtonesHighlights.highlights.value
            );
            m_LutBakerMaterial.SetVector(ShaderConstants._Shadows, shadows);
            m_LutBakerMaterial.SetVector(ShaderConstants._Midtones, midtones);
            m_LutBakerMaterial.SetVector(ShaderConstants._Highlights, highlights);
            m_LutBakerMaterial.SetVector(ShaderConstants._ShaHiLimits, shadowsHighlightsLimits);
        }
        else
        {
            m_LutBakerMaterial.SetVector(ShaderConstants._Shadows, defaultShadows);
            m_LutBakerMaterial.SetVector(ShaderConstants._Midtones, defaultMidtones);
            m_LutBakerMaterial.SetVector(ShaderConstants._Highlights, defaultHighlights);
            m_LutBakerMaterial.SetVector(ShaderConstants._ShaHiLimits, defaultShadowsHighlightsLimits);
        }
        if (LitePostUtils.OpenSplitToning)
        {
            (Vector4 splitShadows, Vector4 splitHighlights) = ColorUtils.PrepareSplitToning(
                LitePostUtils.SplitToning.shadows.value,
                LitePostUtils.SplitToning.highlights.value,
                LitePostUtils.SplitToning.balance.value
            );
            m_LutBakerMaterial.SetVector(ShaderConstants._SplitShadows, splitShadows);
            m_LutBakerMaterial.SetVector(ShaderConstants._SplitHighlights, splitHighlights);
        }
        else
        {
            m_LutBakerMaterial.SetVector(ShaderConstants._SplitShadows, defaultSplitShadows);
            m_LutBakerMaterial.SetVector(ShaderConstants._SplitHighlights, defaultSplitHighlights);
        }
        if (LitePostUtils.OpenToneMapping)
        {
            cmd.Blit(m_ColorLut.id, m_ColorLut.id, m_LutBakerMaterial, 0);
        }
        else
        {
            cmd.Blit(m_ColorLut.id, m_ColorLut.id, m_LutBakerMaterial, 2);
        }
#if UNITY_EDITOR
        if (CapTest)
        {
            cmd.Blit(m_ColorLut.id, capRenderTexture);
            CapTest = false;
            CapTestNext = true;
        }
#endif
        cmd.EndSample(string.Intern("Lite LutBaker Pass"));
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }


    /// <inheritdoc/>
    public override void FrameCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(m_ColorLut.id);
    }

    // Precomputed shader ids to same some CPU cycles (mostly affects mobile)
    static class ShaderConstants
    {
        public static readonly int _Lut_Params        = Shader.PropertyToID("_Lut_Params");
        public static readonly int _ColorBalance      = Shader.PropertyToID("_ColorBalance");
        public static readonly int _ColorFilter       = Shader.PropertyToID("_ColorFilter");
        public static readonly int _HueSatCon         = Shader.PropertyToID("_HueSatCon");
        public static readonly int _Lift              = Shader.PropertyToID("_Lift");
        public static readonly int _Gamma             = Shader.PropertyToID("_Gamma");
        public static readonly int _Gain              = Shader.PropertyToID("_Gain");
        public static readonly int _Shadows           = Shader.PropertyToID("_Shadows");
        public static readonly int _Midtones          = Shader.PropertyToID("_Midtones");
        public static readonly int _Highlights        = Shader.PropertyToID("_Highlights");
        public static readonly int _ShaHiLimits       = Shader.PropertyToID("_ShaHiLimits");
        public static readonly int _SplitShadows      = Shader.PropertyToID("_SplitShadows");
        public static readonly int _SplitHighlights   = Shader.PropertyToID("_SplitHighlights");
        //
        public static readonly int Tonemap_FilmSlope = Shader.PropertyToID("Tonemap_FilmSlope");
        public static readonly int Tonemap_FilmToe = Shader.PropertyToID("Tonemap_FilmToe");
        public static readonly int Tonemap_FilmShoulder = Shader.PropertyToID("Tonemap_FilmShoulder");
        public static readonly int Tonemap_FilmBlackClip = Shader.PropertyToID("Tonemap_FilmBlackClip");
        public static readonly int Tonemap_FilmWhiteClip = Shader.PropertyToID("Tonemap_FilmWhiteClip");
    }
}
