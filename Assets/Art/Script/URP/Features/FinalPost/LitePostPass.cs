using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System;
using System.IO;

public class LitePostPass : ScriptableRenderPass
{
    ProfilingSampler mProfilingSampler;

    string litePostTextureName = "_LitePostTexture";

    RenderTargetHandle litePostTexture;

    RenderTexture staticCapTexture;

    Material material;

    RenderTextureDescriptor m_Descriptor;

    #region//编辑器工具-屏幕截图

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

    int capW;

    int capH;

    CameraClearFlags cameraClearFlags;

    Color backgroundColor;

    #endregion

    #region//转场 模糊

    int blurWidth;

    int blurHeight;

    #endregion

    public LitePostPass(Material material, RenderPassEvent passEvent)
    {
        litePostTexture.Init(litePostTextureName);
        LitePostUtils.InitUICapRt();
        renderPassEvent = passEvent;
        this.material = material;
        mProfilingSampler = new ProfilingSampler("Lite Post-Processing Pass");

        LitePostUtils.ShaderParams._BloomMipDown = new int[LitePostUtils.BloomExecuteData.bloomMaxStepNum];
        for (int i = 0; i < LitePostUtils.BloomExecuteData.bloomMaxStepNum; i++)
        {
            LitePostUtils.ShaderParams._BloomMipDown[i] = Shader.PropertyToID("_BlurMipDown" + i);
        }

        LitePostUtils.ShaderParams._BloomMipUp = new int[LitePostUtils.BloomExecuteData.bloomMaxStepNum];
        for (int i = 0; i < LitePostUtils.BloomExecuteData.bloomMaxStepNum; i++)
        {
            LitePostUtils.ShaderParams._BloomMipUp[i] = Shader.PropertyToID("_BlurMipUp" + i);
        }

        LitePostUtils.ShaderParams._GaussionBlur = new int[LitePostUtils.BloomExecuteData.bloomMaxStepNum];
        for (int i = 0; i < LitePostUtils.BloomExecuteData.bloomMaxStepNum; i++)
        {
            LitePostUtils.ShaderParams._GaussionBlur[i] = Shader.PropertyToID("_GaussionBlur" + i);
        }

        if (SystemInfo.IsFormatSupported(GraphicsFormat.B10G11R11_UFloatPack32, FormatUsage.Linear | FormatUsage.Render))
        {
            LitePostUtils.BloomExecuteData.m_DefaultHDRFormat = GraphicsFormat.B10G11R11_UFloatPack32;
            LitePostUtils.BloomExecuteData.m_UseRGBM = false;
        }
        else
        {
            LitePostUtils.BloomExecuteData.m_DefaultHDRFormat = QualitySettings.activeColorSpace == ColorSpace.Linear
                ? GraphicsFormat.R8G8B8A8_SRGB
                : GraphicsFormat.R8G8B8A8_UNorm;
            LitePostUtils.BloomExecuteData.m_UseRGBM = true;
        }

    }

    GF.GetRendertextEvent getRendertextEvent;

    public void Setup()
    {
        this.getRendertextEvent = GF.FeaturesSingleton<GF.LitePostFeatureEvent>.Instance.GetRendertex(GF.LitePostFeatureRTGetType.CapRTMainCamera);
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        m_Descriptor = cameraTextureDescriptor;
        // Disable MSAA and depth
        cameraTextureDescriptor.msaaSamples = 1;
        cameraTextureDescriptor.depthBufferBits = 0;
        cameraTextureDescriptor.useMipMap = false;
        cameraTextureDescriptor.autoGenerateMips = false;
        if (CapTest)
        {
            int maxCapSize = 4096;
            capW = cameraTextureDescriptor.width;
            capH = cameraTextureDescriptor.height;
            int maxSize = (int)MathF.Max(capW, capH);
            float n = ((float)maxCapSize / maxSize);
            capW = (int)(capW * n);
            capH = (int)(capH * n);
            cameraTextureDescriptor.width = capW;
            cameraTextureDescriptor.height = capH;
            cameraTextureDescriptor.colorFormat = RenderTextureFormat.ARGB32;
            // We need final postprocess texture to maintain the same size.
            cmd.GetTemporaryRT(litePostTexture.id, cameraTextureDescriptor);
            cameraTextureDescriptor.vrUsage = VRTextureUsage.None;
            capRenderTexture = RenderTexture.GetTemporary(cameraTextureDescriptor);
        }
        else
        {
            // We need final postprocess texture to maintain the same size.
            cmd.GetTemporaryRT(litePostTexture.id, cameraTextureDescriptor);
        }

        if (LitePostFeature.OpenGaussionTurnBlur || LitePostFeature.OpenScreenDirectionTurnBlur)
        {
            blurWidth = cameraTextureDescriptor.width >> 2;
            blurHeight = cameraTextureDescriptor.height >> 2;
        }

        if (LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Hight)
        {
            LitePostUtils.BloomExecuteData.bloomWidth = cameraTextureDescriptor.width >> 2;
            LitePostUtils.BloomExecuteData.bloomHeight = cameraTextureDescriptor.height >> 2;
        }else if (LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Mid)
        {
            LitePostUtils.BloomExecuteData.bloomWidth = cameraTextureDescriptor.width >> 1;
            LitePostUtils.BloomExecuteData.bloomHeight = cameraTextureDescriptor.height >> 1;
        }
        else if (LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.None)
        {

        }
        else
        {
            LitePostUtils.BloomExecuteData.bloomWidth = cameraTextureDescriptor.width;
            LitePostUtils.BloomExecuteData.bloomHeight = cameraTextureDescriptor.height;
        }

        if (GF.FeaturesSingleton<GF.LitePostFeatureEvent>.Instance.StaticCapRT && staticCapTexture == null)
        {
            RenderTextureDescriptor descriptor = cameraTextureDescriptor;
            descriptor.graphicsFormat = GraphicsFormat.R8G8B8A8_UNorm;
            descriptor.width = cameraTextureDescriptor.width;
            descriptor.height = cameraTextureDescriptor.height;
            staticCapTexture = RenderTexture.GetTemporary(descriptor);
        }
        if (this.getRendertextEvent!=null)
        {
            this.getRendertextEvent.Invoke(staticCapTexture);
            this.getRendertextEvent = null;
            GF.FeaturesSingleton<GF.LitePostFeatureEvent>.Instance.RemoveRendertexEvent(GF.LitePostFeatureRTGetType.CapRTMainCamera);
        }
    }

    Camera curCamera;

    int gaussionBlurCount;

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        curCamera = renderingData.cameraData.camera;
        if (!LitePostUtils.EffectOpen && !WrapAndBlurUtils.NeedLitPost(renderingData.cameraData))
        {
            LitePostUtils.BloomExecuteData.bloomIterations = 0;
            return;
        }
        //
        CommandBuffer cmd = CommandBufferPool.Get();
        for (int i = 0; i < gaussionBlurCount; ++i)
        {
            cmd.ReleaseTemporaryRT(WrapAndBlurUtils.GaussionBlurs[i]);
        }
        gaussionBlurCount = 0;
        using (new ProfilingScope(cmd, mProfilingSampler))
        {
            if (curCamera.CompareTag("UICamera"))
            {
                RenderTargetIdentifier lastTexture = -1;
                if (WrapAndBlurUtils.UICameraEffect)
                {
                    WrapAndBlurUtils.FreskMaterialKeys(WrapAndBlurUtils.RenderEventEnum.AfterUI,cmd);

                    if (WrapAndBlurUtils.GaussioQuality == WrapAndBlurUtils.GaussioQualityEnum.Simplify)
                    {
                        int screenDirectionBlurForCount = Mathf.Clamp(WrapAndBlurUtils.ScreenDirectionBlurForCount, 1, 6);
                        WrapAndBlurUtils.m_material.SetInt(WrapAndBlurUtils.ShaderParams._ScreenDirectionBlurForCount, screenDirectionBlurForCount);
                        if (LitePostUtils.GetExecuteSrcColorTarget() == LitePostUtils.GetExecuteDesColorTarget())
                        {
                            cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), litePostTexture.id, WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.WrapAndBlurSimplified);
                            lastTexture = litePostTexture.id;
                        }
                        else
                        {
                            cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget(), WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.WrapAndBlurSimplified);
                            lastTexture = LitePostUtils.GetExecuteDesColorTarget();
                        }
                    }
                    else
                    {
                        if (WrapAndBlurUtils.OpenWrap || WrapAndBlurUtils.OpenChromatic && WrapAndBlurUtils.WrapRenderEvent == WrapAndBlurUtils.RenderEventEnum.AfterUI)
                        {
                            if (LitePostUtils.GetExecuteSrcColorTarget() == LitePostUtils.GetExecuteDesColorTarget())
                            {
                                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), litePostTexture.id, WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.WrapPass);
                                lastTexture = litePostTexture.id;
                            }
                            else
                            {
                                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget(), WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.WrapPass);
                                lastTexture = LitePostUtils.GetExecuteDesColorTarget();
                            }
                        }
                        if (WrapAndBlurUtils.OpenGaussionBlur && WrapAndBlurUtils.GaussioRenderEvent == WrapAndBlurUtils.RenderEventEnum.AfterUI)
                        {
                            gaussionBlurCount = Mathf.Clamp(WrapAndBlurUtils.GaussionForCount, 1, WrapAndBlurUtils.GaussionForCountMax);
                            for (int i = 0; i < gaussionBlurCount; ++i)
                            {
                                cmd.GetTemporaryRT(WrapAndBlurUtils.GaussionBlurs[i], m_Descriptor.width, m_Descriptor.height, 0, FilterMode.Bilinear, LitePostUtils.BloomExecuteData.m_DefaultHDRFormat);
                                if (lastTexture == -1)
                                {
                                    cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), WrapAndBlurUtils.GaussionBlurs[i], WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.GaussionBlurPass);
                                }
                                else
                                {
                                    cmd.Blit(lastTexture, WrapAndBlurUtils.GaussionBlurs[i], WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.GaussionBlurPass);
                                }
                                lastTexture = WrapAndBlurUtils.GaussionBlurs[i];
                            }
                        }
                        if (WrapAndBlurUtils.OpenScreenDirectionBlur && WrapAndBlurUtils.ScreenDirectionBlurRenderEvent == WrapAndBlurUtils.RenderEventEnum.AfterUI)
                        {
                            int screenDirectionBlurForCount = Mathf.Clamp(WrapAndBlurUtils.ScreenDirectionBlurForCount, 1, 16);
                            WrapAndBlurUtils.m_material.SetInt(WrapAndBlurUtils.ShaderParams._ScreenDirectionBlurForCount, screenDirectionBlurForCount);
                            if (lastTexture == -1)
                            {
                                if (LitePostUtils.GetExecuteSrcColorTarget() == LitePostUtils.GetExecuteDesColorTarget())
                                {
                                    cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), litePostTexture.id, WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.ScreenDirectionBlurPass);
                                    lastTexture = litePostTexture.id;
                                }
                                else
                                {
                                    cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget(), WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.ScreenDirectionBlurPass);
                                    lastTexture = LitePostUtils.GetExecuteDesColorTarget();
                                }
                            }
                            else if (lastTexture == litePostTexture.id)
                            {
                                cmd.Blit(lastTexture, LitePostUtils.GetExecuteDesColorTarget(), WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.ScreenDirectionBlurPass);
                                lastTexture = LitePostUtils.GetExecuteDesColorTarget();
                            }
                            else
                            {
                                if (lastTexture == LitePostUtils.GetExecuteDesColorTarget())
                                {
                                    cmd.Blit(lastTexture, litePostTexture.id, WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.ScreenDirectionBlurPass);
                                    lastTexture = litePostTexture.id;
                                }
                                else
                                {
                                    cmd.Blit(lastTexture, LitePostUtils.GetExecuteDesColorTarget(), WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.ScreenDirectionBlurPass);
                                    lastTexture = LitePostUtils.GetExecuteDesColorTarget();
                                }
                            }
                        }
                    }
                    LitePostUtils.SetExecuteSrcColorTarget(lastTexture);
                    WrapAndBlurUtils.ClearMaterialKeys(cmd);
                }
                if (LitePostFeature.OpenGaussionBlurUI || LitePostFeature.OpenScreenDirectionBlurUI)
                {
                    TurnSceneBlur(renderingData.cameraData.camera, context, cmd, material);
                }
                if (LitePostFeature.OpenFinishColorUI)
                {
                    if (LitePostUtils.GetExecuteSrcColorTarget() == LitePostUtils.GetExecuteDesColorTarget())
                    {
                        cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), litePostTexture.id, material, LitePostUtils.ShaderPassIndex.FinishColorPass);
                        LitePostUtils.SetExecuteSrcColorTarget(litePostTexture.id);
                    }
                    else
                    {
                        cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget(), material, LitePostUtils.ShaderPassIndex.FinishColorPass);
                        LitePostUtils.ClearExecuteSrcColorTarget();
                    }
                }
                if (LitePostUtils.GetExecuteSrcColorTarget()!= LitePostUtils.GetExecuteDesColorTarget())
                {
                    bool needBlitToCameraColorTarget = false;
                    LitePostFeature.LitPostPassEnum nextLitPostPassEnum = LitePostUtils.NextPostStep(renderingData.cameraData, ref needBlitToCameraColorTarget);
                    if (nextLitPostPassEnum== LitePostFeature.LitPostPassEnum.TemporalAntiAliasingPass)
                    {
                        TemporalAntiAliasingUtils.SetExecuteSrcColorTarget(LitePostUtils.GetExecuteSrcColorTarget());
                        LitePostUtils.ClearExecuteSrcColorTarget();
                    }
                    else
                    {
                        cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget());
                        LitePostUtils.ClearExecuteSrcColorTarget();
                    }
                }
            }
            else
            {
                if (LitePostUtils.VolumeLUTEffectOpen)
                {
                    cmd.EnableShaderKeyword(string.Intern("NEED_LUT"));
                }
                else
                {
                    cmd.DisableShaderKeyword(string.Intern("NEED_LUT"));
                }

#if UNITY_EDITOR
                if (CapTestNext)
                {
                    cmd.DisableShaderKeyword(string.Intern("ENABLE_CAP"));
                    CapTestNext = false;
                    string dir = "E:/Capture";
                    if (!Directory.Exists(dir))
                    {
                        Directory.CreateDirectory(dir);
                    }
                    LitePostFeature.SaveRenderToPng(capRenderTexture, dir, "CaptureTexture");
                    RenderTexture.ReleaseTemporary(capRenderTexture);
                    Debug.LogError("截屏存储路径:E:/Capture");
                }
#endif

#if UNITY_EDITOR
                if (CapTest)
                {
                    Camera cam = renderingData.cameraData.camera;
                    cameraClearFlags = cam.clearFlags;
                    backgroundColor = cam.backgroundColor;
                    cam.clearFlags = CameraClearFlags.SolidColor;
                    cam.backgroundColor = new Color(0, 0, 0, 0);
                    cmd.EnableShaderKeyword(string.Intern("ENABLE_CAP"));
                }
#endif
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                //
                DoBloom(cmd, material);
                //
                if (!LitePostUtils.OpenColorGrading)
                {
                    DoFinalPost(context, cmd, material, 0, LitePostUtils.Vignette, LitePostUtils.ChromaticAberration.intensity.value);
                }
                else
                {
                    DoFinalPost(context, cmd, material, LitePostUtils.ColorGrading.postExposure.value, LitePostUtils.Vignette, LitePostUtils.ChromaticAberration.intensity.value);
                }
                if (LitePostFeature.OpenGaussionTurnBlur || LitePostFeature.OpenScreenDirectionTurnBlur)
                {
                    TurnSceneBlur(renderingData.cameraData.camera, context, cmd, material);
                }
#if UNITY_EDITOR
                if (CapTest)
                {
                    cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), capRenderTexture);
                }
                else
                {
                    if (LitePostUtils.GetExecuteDesColorTarget()!= LitePostUtils.GetExecuteSrcColorTarget())
                    {
                        bool needBlitToCameraColorTarget = false;
                        LitePostFeature.LitPostPassEnum nextLitPostPassEnum = LitePostUtils.NextPostStep(renderingData.cameraData, ref needBlitToCameraColorTarget);
                        if (nextLitPostPassEnum == LitePostFeature.LitPostPassEnum.TemporalAntiAliasingPass)
                        {
                            TemporalAntiAliasingUtils.SetExecuteSrcColorTarget(LitePostUtils.GetExecuteSrcColorTarget());
                            StaticCap(cmd, LitePostUtils.GetExecuteSrcColorTarget());
                            LitePostUtils.ClearExecuteSrcColorTarget();
                        }
                        else
                        {
                            cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget());
                            StaticCap(cmd, LitePostUtils.GetExecuteDesColorTarget());
                            LitePostUtils.ClearExecuteSrcColorTarget();
                        }
                    }
                    else
                    {
                        StaticCap(cmd, LitePostUtils.GetExecuteDesColorTarget());
                    }
                }
#else
                if (LitePostUtils.GetExecuteDesColorTarget()!= LitePostUtils.GetExecuteSrcColorTarget())
                {
                    bool needBlitToCameraColorTarget = false;
                    LitePostFeature.LitPostPassEnum nextLitPostPassEnum = LitePostUtils.NextPostStep(renderingData.cameraData, ref needBlitToCameraColorTarget);
                    if (nextLitPostPassEnum == LitePostFeature.LitPostPassEnum.TemporalAntiAliasingPass)
                    {
                        TemporalAntiAliasingUtils.SetExecuteSrcColorTarget(LitePostUtils.GetExecuteSrcColorTarget());
                        StaticCap(cmd, LitePostUtils.GetExecuteSrcColorTarget());
                        LitePostUtils.ClearExecuteSrcColorTarget();
                    }
                    else
                    {
                        cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget());
                        StaticCap(cmd, LitePostUtils.GetExecuteDesColorTarget());
                        LitePostUtils.ClearExecuteSrcColorTarget();
                    }
                }else
                {
                    StaticCap(cmd, LitePostUtils.GetExecuteDesColorTarget());
                }
#endif

            }
        }

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);

#if UNITY_EDITOR
        if (CapTest)
        {
            Camera cam = renderingData.cameraData.camera;
            cam.clearFlags = cameraClearFlags;
            cam.backgroundColor = backgroundColor;
            CapTest = false;
            CapTestNext = true;
        }
#endif
        LitePostUtils.ClearExecuteSrcColorTarget();
    }

    void StaticCap(CommandBuffer cmd,  RenderTargetIdentifier src)
    {
        if (GF.FeaturesSingleton<GF.LitePostFeatureEvent>.Instance.StaticCapRT)
        {
            GF.FeaturesSingleton<GF.LitePostFeatureEvent>.Instance.AddEvent(GF.LitePostFeatureEventType.CapRTMainCameraClose);
            cmd.Blit(src, staticCapTexture);
            cmd.SetGlobalTexture(LitePostUtils.ShaderParams._StaticCapRenderTextureCamTex, staticCapTexture);
            cmd.Blit(staticCapTexture, src);

        }
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        LitePostUtils.ReleaseUICapRt(cmd);
        cmd.ReleaseTemporaryRT(litePostTexture.id);
       if (curCamera.CompareTag("UICamera"))
       {
            ClearTurnSceneBlurArrayRT(cmd);
        }
        else
        {
            if ((LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Hight || LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Mid) && 
                LitePostUtils.BloomHightActive)
            {
                cmd.ReleaseTemporaryRT(LitePostUtils.ShaderParams._BloomMipUp[0]);
            }
            if (LitePostUtils.BloomActive && LitePostUtils.LitePostFeature.BloomSelect != LitePostFeature.BloomType.None)
            {
                for (int i = 0; i < LitePostUtils.BloomExecuteData.bloomIterations; i++)
                {
                    cmd.ReleaseTemporaryRT(LitePostUtils.ShaderParams._BloomMipDown[i]);
                }
            }
        }
    }

    RenderTextureDescriptor GetCompatibleDescriptor(int width, int height, GraphicsFormat format, int depthBufferBits = 0)
    {
        var desc = m_Descriptor;
        desc.depthBufferBits = depthBufferBits;
        desc.msaaSamples = 1;
        desc.width = width;
        desc.height = height;
        desc.graphicsFormat = format;
        return desc;
    }

    private BuiltinRenderTextureType BlitDstDiscardContent(CommandBuffer cmd, RenderTargetIdentifier rt)
    {
        // We set depth to DontCare because rt might be the source of PostProcessing used as a temporary target
        // Source typically comes with a depth buffer and right now we don't have a way to only bind the color attachment of a RenderTargetIdentifier
        cmd.SetRenderTarget(new RenderTargetIdentifier(rt, 0, CubemapFace.Unknown, -1),
            RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store,
            RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
        return BuiltinRenderTextureType.CurrentActive;
    }

    void DoBloom(CommandBuffer cmd, Material material)
    {
        if ((LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Hight || LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Mid) && LitePostUtils.BloomHightActive)
        {
            // Start at half-res
            int tw = LitePostUtils.BloomExecuteData.bloomWidth;
            int th = LitePostUtils.BloomExecuteData.bloomHeight;

            // Determine the iteration count
            int maxSize = Mathf.Max(tw, th);
            int iterations = Mathf.FloorToInt(Mathf.Log(maxSize, 2f) - 1);
            int skipIterationsValue= LitePostUtils.LitBloomHight.skipIterations.value;
            if (LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Mid)
            {
                skipIterationsValue = Mathf.Max(4, skipIterationsValue);
            }
            iterations -= skipIterationsValue;
            int mipCount = Mathf.Clamp(iterations, 1, LitePostUtils.BloomExecuteData.bloomMaxStepNum);

            // Pre-filtering parameters
            float clamp = LitePostUtils.LitBloomHight.clamp.value;
            float threshold = Mathf.GammaToLinearSpace(LitePostUtils.LitBloomHight.threshold.value);
            float thresholdKnee = threshold * 0.5f; // Hardcoded soft knee

            // Material setup
            float scatter = Mathf.Lerp(0.05f, 0.95f, LitePostUtils.LitBloomHight.scatter.value);
            material.SetVector(LitePostUtils.ShaderParams._Params, new Vector4(scatter, clamp, threshold, thresholdKnee));
            CoreUtils.SetKeyword(material, ShaderKeywordStrings.BloomHQ, LitePostUtils.LitBloomHight.highQualityFiltering.value);
            CoreUtils.SetKeyword(material, ShaderKeywordStrings.UseRGBM, LitePostUtils.BloomExecuteData.m_UseRGBM);

            // Prefilter
            var desc = GetCompatibleDescriptor(tw, th, LitePostUtils.BloomExecuteData.m_DefaultHDRFormat);
            cmd.GetTemporaryRT(LitePostUtils.ShaderParams._BloomMipDown[0], desc, FilterMode.Bilinear);
            cmd.GetTemporaryRT(LitePostUtils.ShaderParams._BloomMipUp[0], desc, FilterMode.Bilinear);

            Blit(cmd, LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.ShaderParams._BloomMipDown[0], material, LitePostUtils.ShaderPassIndex.UnityBloomPrefilter);

            // Downsample - gaussian pyramid
            int lastDown = LitePostUtils.ShaderParams._BloomMipDown[0];
            for (int i = 1; i < mipCount; i++)
            {
                tw = Mathf.Max(1, tw >> 1);
                th = Mathf.Max(1, th >> 1);
                int mipDown = LitePostUtils.ShaderParams._BloomMipDown[i];
                int mipUp = LitePostUtils.ShaderParams._BloomMipUp[i];

                desc.width = tw;
                desc.height = th;

                cmd.GetTemporaryRT(mipDown, desc, FilterMode.Bilinear);
                cmd.GetTemporaryRT(mipUp, desc, FilterMode.Bilinear);

                // Classic two pass gaussian blur - use mipUp as a temporary target
                //   First pass does 2x downsampling + 9-tap gaussian
                //   Second pass does 9-tap gaussian using a 5-tap filter + bilinear filtering
                Blit(cmd, lastDown, mipUp, material, LitePostUtils.ShaderPassIndex.UnityBloomBlurHorizontal);
                Blit(cmd, mipUp, mipDown, material, LitePostUtils.ShaderPassIndex.UnityBloomBlurVertical);

                lastDown = mipDown;
            }

            // Upsample (bilinear by default, HQ filtering does bicubic instead
            for (int i = mipCount - 2; i >= 0; i--)
            {
                int lowMip = (i == mipCount - 2) ? LitePostUtils.ShaderParams._BloomMipDown[i + 1] : LitePostUtils.ShaderParams._BloomMipUp[i + 1];
                int highMip = LitePostUtils.ShaderParams._BloomMipDown[i];
                int dst = LitePostUtils.ShaderParams._BloomMipUp[i];

                cmd.SetGlobalTexture(LitePostUtils.ShaderParams._SourceTexLowMip, lowMip);
                Blit(cmd, highMip, BlitDstDiscardContent(cmd, dst), material, LitePostUtils.ShaderPassIndex.UnityBloomUpsample);
            }

            // Cleanup
            for (int i = 0; i < mipCount; i++)
            {
                cmd.ReleaseTemporaryRT(LitePostUtils.ShaderParams._BloomMipDown[i]);
                if (i > 0) cmd.ReleaseTemporaryRT(LitePostUtils.ShaderParams._BloomMipUp[i]);
            }

            // Setup bloom on uber
            var tint = LitePostUtils.LitBloomHight.tint.value.linear;
            var luma = ColorUtils.Luminance(tint);
            tint = luma > 0f ? tint * (1f / luma) : Color.white;

            var bloomParams = new Vector4(LitePostUtils.LitBloomHight.intensity.value, tint.r, tint.g, tint.b);
            material.SetVector(LitePostUtils.ShaderParams._Bloom_Params, bloomParams);
            material.SetFloat(LitePostUtils.ShaderParams._Bloom_RGBM, LitePostUtils.BloomExecuteData.m_UseRGBM ? 1f : 0f);

            // Setup lens dirtiness on uber
            // Keep the aspect ratio correct & center the dirt texture, we don't want it to be
            // stretched or squashed
            var dirtTexture = LitePostUtils.LitBloomHight.dirtTexture.value == null ? Texture2D.blackTexture : LitePostUtils.LitBloomHight.dirtTexture.value;
            float dirtRatio = dirtTexture.width / (float)dirtTexture.height;
            float screenRatio = m_Descriptor.width / (float)m_Descriptor.height;
            var dirtScaleOffset = new Vector4(1f, 1f, 0f, 0f);
            float dirtIntensity = LitePostUtils.LitBloomHight.dirtIntensity.value;

            if (dirtRatio > screenRatio)
            {
                dirtScaleOffset.x = screenRatio / dirtRatio;
                dirtScaleOffset.z = (1f - dirtScaleOffset.x) * 0.5f;
            }
            else if (screenRatio > dirtRatio)
            {
                dirtScaleOffset.y = dirtRatio / screenRatio;
                dirtScaleOffset.w = (1f - dirtScaleOffset.y) * 0.5f;
            }

            material.SetVector(LitePostUtils.ShaderParams._LensDirt_Params, dirtScaleOffset);
            material.SetFloat(LitePostUtils.ShaderParams._LensDirt_Intensity, dirtIntensity);
            material.SetTexture(LitePostUtils.ShaderParams._LensDirt_Texture, dirtTexture);

            material.EnableKeyword(dirtIntensity > 0f ? "ENABLE_BLOOM_HIGHT_DIRT" : "ENABLE_BLOOM_HIGHT");

        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_BLOOM_HIGHT"));
            cmd.DisableShaderKeyword(string.Intern("ENABLE_BLOOM_HIGHT_DIRT"));
            LitePostUtils.BloomExecuteData.bloomIterations = LitePostUtils.BloomActive ? Mathf.Clamp(LitePostUtils.Bloom.m_BloomIterations.value, 1, LitePostUtils.BloomExecuteData.bloomMaxStepNum) : 1;
            material.SetFloat(LitePostUtils.ShaderParams._BloomIntensity, LitePostUtils.Bloom.m_BloomIntensity.value);
            material.SetColor(LitePostUtils.ShaderParams._BloomTintColor, LitePostUtils.Bloom.m_BloomTintColor.value);
            material.SetFloat(LitePostUtils.ShaderParams._BloomIterations, LitePostUtils.BloomExecuteData.bloomIterations);
            if (LitePostUtils.BloomActive && LitePostUtils.LitePostFeature.BloomSelect != LitePostFeature.BloomType.None)
            {
                material.SetFloat(LitePostUtils.ShaderParams._BloomThreshold, Mathf.GammaToLinearSpace(LitePostUtils.Bloom.m_BloomThreshold.value));

                cmd.GetTemporaryRT(LitePostUtils.ShaderParams._BloomMipDown[0], LitePostUtils.BloomExecuteData.bloomWidth, LitePostUtils.BloomExecuteData.bloomHeight, 0, FilterMode.Bilinear, LitePostUtils.BloomExecuteData.m_DefaultHDRFormat);

                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.ShaderParams._BloomMipDown[0], material, LitePostUtils.ShaderPassIndex.LitePostFirst);

                RenderTargetIdentifier lastDown = LitePostUtils.ShaderParams._BloomMipDown[0];
                int i = 1;
                for (; i < LitePostUtils.BloomExecuteData.bloomIterations; i++)
                {
                    if (LitePostUtils.BloomExecuteData.bloomWidth <= 2 || LitePostUtils.BloomExecuteData.bloomHeight <= 2) break;
                    LitePostUtils.BloomExecuteData.bloomWidth = Mathf.Max(LitePostUtils.BloomExecuteData.bloomWidth >> 1, 2);
                    LitePostUtils.BloomExecuteData.bloomHeight = Mathf.Max(LitePostUtils.BloomExecuteData.bloomHeight >> 1, 2);
                    int mipDown = LitePostUtils.ShaderParams._BloomMipDown[i];
                    cmd.GetTemporaryRT(mipDown, LitePostUtils.BloomExecuteData.bloomWidth, LitePostUtils.BloomExecuteData.bloomHeight, 0, FilterMode.Bilinear, LitePostUtils.BloomExecuteData.m_DefaultHDRFormat);
                    cmd.Blit(lastDown, mipDown, material, LitePostUtils.ShaderPassIndex.BloomDownSamplePass);
                    lastDown = mipDown;
                }
                LitePostUtils.BloomExecuteData.bloomIterations = i;

                int lastUp = LitePostUtils.ShaderParams._BloomMipDown[i - 1];
                for (i -= 2; i >= 0; i--)
                {
                    int mipDown = LitePostUtils.ShaderParams._BloomMipDown[i];
                    cmd.Blit(lastUp, mipDown, material, LitePostUtils.ShaderPassIndex.BloomUpSamplePass);
                    lastUp = mipDown;
                }
            }
        }
    }

    #region//WrapAndBlur

    void WrapAndBlurGameCameraRenderBlur(CommandBuffer cmd, RenderTargetIdentifier srcId)
    {
        bool openWrap = false;
        bool openScreenDirectionBlur = false;
        bool openGaussionBlur = false;
        if ((WrapAndBlurUtils.OpenWrap || WrapAndBlurUtils.OpenChromatic) && WrapAndBlurUtils.WrapRenderEvent == WrapAndBlurUtils.RenderEventEnum.PostPass)
        {
            openWrap = true;
        }
        if (WrapAndBlurUtils.OpenScreenDirectionBlur && WrapAndBlurUtils.ScreenDirectionBlurRenderEvent == WrapAndBlurUtils.RenderEventEnum.PostPass)
        {
            openScreenDirectionBlur = true;
        }
        if (WrapAndBlurUtils.OpenGaussionBlur && WrapAndBlurUtils.GaussioRenderEvent == WrapAndBlurUtils.RenderEventEnum.PostPass)
        {
            openGaussionBlur = true;
        }

        if (openGaussionBlur || openScreenDirectionBlur || openWrap)
        {
            int screenDirectionBlurForCount = Mathf.Clamp(WrapAndBlurUtils.ScreenDirectionBlurForCount, 1, 6);
            WrapAndBlurUtils.m_material.SetInt(WrapAndBlurUtils.ShaderParams._ScreenDirectionBlurForCount, screenDirectionBlurForCount);
            RenderTargetIdentifier finId;
            //
            if (srcId == LitePostUtils.GetExecuteDesColorTarget())
            {
                finId = litePostTexture.id;
            }
            else
            {
                finId = LitePostUtils.GetExecuteDesColorTarget();
            }
            WrapAndBlurUtils.FreskMaterialKeys(WrapAndBlurUtils.RenderEventEnum.PostPass, cmd);
            if (WrapAndBlurUtils.GaussioQuality != WrapAndBlurUtils.GaussioQualityEnum.Simplify)
            {
                //复杂版
                if (openWrap)
                {
                    if (!openGaussionBlur && !openScreenDirectionBlur)
                    {
                        if (LitePostUtils.OpenVignette)
                        {
                            material.SetFloat(LitePostUtils.ShaderParams._VignetteIntensity, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteIntensity.value : 0.1f);
                            material.SetFloat(LitePostUtils.ShaderParams._VignetteRoughness, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteRoughness.value : 1.5f);
                            material.SetFloat(LitePostUtils.ShaderParams._VignetteSmothness, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteSmothness.value : 1.5f);
                            cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                        }
                        else
                        {
                            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                        }
                    }
                    else
                    {
                        cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                    }
                    cmd.Blit(srcId, finId, WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.WrapPass);
                    if (finId == LitePostUtils.GetExecuteDesColorTarget())
                    {
                        LitePostUtils.ClearExecuteSrcColorTarget();
                        srcId = LitePostUtils.GetExecuteDesColorTarget();
                        finId = litePostTexture.id;
                    }
                    else
                    {
                        LitePostUtils.SetExecuteSrcColorTarget(finId);
                        srcId= litePostTexture.id;
                        finId = LitePostUtils.GetExecuteDesColorTarget();
                    }
                }
                if (openGaussionBlur)
                {
                    if (!openScreenDirectionBlur)
                    {
                        if (LitePostUtils.OpenVignette)
                        {
                            material.SetFloat(LitePostUtils.ShaderParams._VignetteIntensity, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteIntensity.value : 0.1f);
                            material.SetFloat(LitePostUtils.ShaderParams._VignetteRoughness, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteRoughness.value : 1.5f);
                            material.SetFloat(LitePostUtils.ShaderParams._VignetteSmothness, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteSmothness.value : 1.5f);
                            cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                        }
                        else
                        {
                            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                        }
                    }
                    else
                    {
                        cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                    }

                    gaussionBlurCount = Mathf.Clamp(WrapAndBlurUtils.GaussionForCount, 1, WrapAndBlurUtils.GaussionForCountMax);
                    for (int i = 0; i < gaussionBlurCount; ++i)
                    {
                        cmd.GetTemporaryRT(WrapAndBlurUtils.GaussionBlurs[i], m_Descriptor.width, m_Descriptor.height, 0, FilterMode.Bilinear, LitePostUtils.BloomExecuteData.m_DefaultHDRFormat);
                        if (i == (gaussionBlurCount - 1))
                        {
                            cmd.Blit(srcId, finId, WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.GaussionBlurPass);
                        }
                        else
                        {
                            cmd.Blit(srcId, WrapAndBlurUtils.GaussionBlurs[i], WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.GaussionBlurPass);
                            srcId = WrapAndBlurUtils.GaussionBlurs[i];
                        }
                    }

                    if (finId == LitePostUtils.GetExecuteDesColorTarget())
                    {
                        LitePostUtils.ClearExecuteSrcColorTarget();
                        srcId = LitePostUtils.GetExecuteDesColorTarget();
                        finId = litePostTexture.id;
                    }
                    else
                    {
                        LitePostUtils.SetExecuteSrcColorTarget(finId);
                        srcId = litePostTexture.id;
                        finId = LitePostUtils.GetExecuteDesColorTarget();
                    }
                }
                if (openScreenDirectionBlur)
                {
                    if (LitePostUtils.OpenVignette)
                    {
                        material.SetFloat(LitePostUtils.ShaderParams._VignetteIntensity, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteIntensity.value : 0.1f);
                        material.SetFloat(LitePostUtils.ShaderParams._VignetteRoughness, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteRoughness.value : 1.5f);
                        material.SetFloat(LitePostUtils.ShaderParams._VignetteSmothness, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteSmothness.value : 1.5f);
                        cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                    }
                    else
                    {
                        cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                    }
                    cmd.Blit(srcId, finId, WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.ScreenDirectionBlurPass);
                    if (finId == LitePostUtils.GetExecuteDesColorTarget())
                    {
                        LitePostUtils.ClearExecuteSrcColorTarget();
                        srcId = LitePostUtils.GetExecuteDesColorTarget();
                        finId = litePostTexture.id;
                    }
                    else
                    {
                        LitePostUtils.SetExecuteSrcColorTarget(finId);
                        srcId = litePostTexture.id;
                        finId = LitePostUtils.GetExecuteDesColorTarget();
                    }
                }
            }
            else
            {
                //简化版
                if (LitePostUtils.OpenVignette)
                {
                    material.SetFloat(LitePostUtils.ShaderParams._VignetteIntensity, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteIntensity.value : 0.1f);
                    material.SetFloat(LitePostUtils.ShaderParams._VignetteRoughness, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteRoughness.value : 1.5f);
                    material.SetFloat(LitePostUtils.ShaderParams._VignetteSmothness, LitePostUtils.OpenVignette ? LitePostUtils.Vignette.vignetteSmothness.value : 1.5f);
                    cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                }
                else
                {
                    cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
                }
                //
                cmd.Blit(srcId, finId, WrapAndBlurUtils.m_material, WrapAndBlurUtils.ShaderPassIndex.WrapAndBlurSimplified);
                if (finId== LitePostUtils.GetExecuteDesColorTarget())
                {
                    LitePostUtils.ClearExecuteSrcColorTarget();
                }
                else
                {
                    LitePostUtils.SetExecuteSrcColorTarget(finId);
                }
            }
            
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
            LitePostUtils.SetExecuteSrcColorTarget(srcId);
        }
    }

#endregion

    void DoFinalPost(ScriptableRenderContext context,CommandBuffer cmd, Material material, float postExposure, LitVignette vignette, float chromaticAberrationIntensity)
    {
        if (postExposure == 0)
        {
            material.SetVector(LitePostUtils.ShaderParams._LutParams, new Vector4(1f / (LutBakerPass.m_LutSize * LutBakerPass.m_LutSize), 1f / LutBakerPass.m_LutSize, LutBakerPass.m_LutSize - 1f, 1));
        }
        else
        {
            material.SetVector(LitePostUtils.ShaderParams._LutParams, new Vector4(1f / (LutBakerPass.m_LutSize * LutBakerPass.m_LutSize), 1f / LutBakerPass.m_LutSize, LutBakerPass.m_LutSize - 1f, Mathf.Pow(2f, postExposure)));
        }

        // Vignette
        if (LitePostUtils.OpenVignette)
        {
            material.SetFloat(LitePostUtils.ShaderParams._VignetteIntensity, LitePostUtils.OpenVignette ? vignette.vignetteIntensity.value : 0.1f);
            material.SetFloat(LitePostUtils.ShaderParams._VignetteRoughness, LitePostUtils.OpenVignette ? vignette.vignetteRoughness.value : 1.5f);
            material.SetFloat(LitePostUtils.ShaderParams._VignetteSmothness, LitePostUtils.OpenVignette ? vignette.vignetteSmothness.value : 1.5f);
            if ((WrapAndBlurUtils.OpenScreenDirectionBlur && WrapAndBlurUtils.ScreenDirectionBlurRenderEvent == WrapAndBlurUtils.RenderEventEnum.PostPass) ||
                (WrapAndBlurUtils.OpenGaussionBlur && WrapAndBlurUtils.GaussioRenderEvent == WrapAndBlurUtils.RenderEventEnum.PostPass))
            {
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
            }
            else
            {
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
            }
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_VIGNETTE"));
        }

        // Chromatic Aberration
        material.SetFloat(LitePostUtils.ShaderParams._ChromaticAberration, LitePostUtils.OpenChromaticAberration ? chromaticAberrationIntensity : 0);

        //
        if (LitePostUtils.CustemLUT != null)
        {
            material.SetTexture(LitePostUtils.ShaderParams._ColorLut, LitePostUtils.CustemLUT);
        }
       
#if UNITY_EDITOR
        if (CapTest)
        {
            if ( (LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Hight || LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Mid) &&
                LitePostUtils.BloomHightActive)
            {
                cmd.Blit(LitePostUtils.ShaderParams._BloomMipUp[0], litePostTexture.id, material, LitePostUtils.ShaderPassIndex.LitePostFinal);
            }
            else if (LitePostUtils.BloomActive && LitePostUtils.LitePostFeature.BloomSelect != LitePostFeature.BloomType.None)
            {
                cmd.Blit(LitePostUtils.ShaderParams._BloomMipDown[0], litePostTexture.id, material, LitePostUtils.ShaderPassIndex.LitePostFinal);
            }
            else
            {
                cmd.Blit(Texture2D.blackTexture, litePostTexture.id, material, LitePostUtils.ShaderPassIndex.LitePostFinal);
            }
            WrapAndBlurGameCameraRenderBlur(cmd, litePostTexture.id);
            if (curCamera.CompareTag("CameraCapRT"))
            {
                LitePostUtils.GetUICapRt(cmd, m_Descriptor);
                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.CapRenderTextureCamTex.id);
                cmd.SetGlobalTexture(LitePostUtils.ShaderParams._CapRenderTextureCamTex, LitePostUtils.CapRenderTextureCamTex.id);
            }
            WrapAndBlurUtils.ClearMaterialKeys(cmd);
        }
        else
        {
            cmd.EnableShaderKeyword(string.Intern("ENABLE_UNITYEDITOR"));
            cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), litePostTexture.id);
            cmd.SetGlobalTexture(LitePostUtils.ShaderParams._MainTexEditor, litePostTexture.id);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            if ((LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Hight || LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Mid) &&
                LitePostUtils.BloomHightActive)
            {
                cmd.Blit(LitePostUtils.ShaderParams._BloomMipUp[0], LitePostUtils.GetExecuteDesColorTarget(), material, LitePostUtils.ShaderPassIndex.LitePostFinal);
            }
            else if (LitePostUtils.BloomActive && LitePostUtils.LitePostFeature.BloomSelect != LitePostFeature.BloomType.None)
            {
                cmd.Blit(LitePostUtils.ShaderParams._BloomMipDown[0], LitePostUtils.GetExecuteDesColorTarget(), material, LitePostUtils.ShaderPassIndex.LitePostFinal);
            }
            else
            {
                cmd.Blit(Texture2D.blackTexture, LitePostUtils.GetExecuteDesColorTarget(), material, LitePostUtils.ShaderPassIndex.LitePostFinal);
            }
            WrapAndBlurGameCameraRenderBlur(cmd, LitePostUtils.GetExecuteDesColorTarget());
            if (curCamera.CompareTag("CameraCapRT"))
            {
                LitePostUtils.GetUICapRt(cmd, m_Descriptor);
                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.CapRenderTextureCamTex.id);
                cmd.SetGlobalTexture(LitePostUtils.ShaderParams._CapRenderTextureCamTex, LitePostUtils.CapRenderTextureCamTex.id);
            }
            cmd.DisableShaderKeyword(string.Intern("ENABLE_UNITYEDITOR"));
            WrapAndBlurUtils.ClearMaterialKeys(cmd);
        }

#else
        cmd.SetGlobalTexture(LitePostUtils.ShaderParams._CameraColorTextureST, LitePostUtils.GetExecuteSrcColorTarget());
        if ((LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Hight || LitePostUtils.LitePostFeature.BloomSelect == LitePostFeature.BloomType.Mid) && 
            LitePostUtils.BloomHightActive)
        {
            cmd.Blit(LitePostUtils.ShaderParams._BloomMipUp[0], litePostTexture.id, material, LitePostUtils.ShaderPassIndex.LitePostFinal);
        }
        else if (LitePostUtils.BloomActive && LitePostUtils.LitePostFeature.BloomSelect != LitePostFeature.BloomType.None)
        {
            cmd.Blit(LitePostUtils.ShaderParams._BloomMipDown[0], litePostTexture.id, material, LitePostUtils.ShaderPassIndex.LitePostFinal);
        }
        else
        {
            cmd.Blit(Texture2D.blackTexture, litePostTexture.id, material, LitePostUtils.ShaderPassIndex.LitePostFinal);
        }
        WrapAndBlurGameCameraRenderBlur(cmd,litePostTexture.id);
        if (curCamera.CompareTag("CameraCapRT"))
        {
            LitePostUtils.GetUICapRt(cmd, m_Descriptor);
            cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.CapRenderTextureCamTex.id);
            cmd.SetGlobalTexture(LitePostUtils.ShaderParams._CapRenderTextureCamTex, LitePostUtils.CapRenderTextureCamTex.id);
        }
        WrapAndBlurUtils.ClearMaterialKeys(cmd);
#endif

    }

    int turnSceneBlurArrayRTCount = 0;

    void ClearTurnSceneBlurArrayRT(CommandBuffer cmd)
    {
        for (int i=0;i< turnSceneBlurArrayRTCount;++i)
        {
            cmd.ReleaseTemporaryRT(LitePostUtils.ShaderParams._GaussionBlur[i]);
        }
        turnSceneBlurArrayRTCount = 0;
    }

    /// <summary>
    /// 转场模糊
    /// </summary>
    /// <param name="context"></param>
    /// <param name="cmd"></param>
    /// <param name="material"></param>
    void TurnSceneBlur(Camera cam, ScriptableRenderContext context, CommandBuffer cmd, Material material)
    {
        //高斯模糊
        if (LitePostFeature.OpenGaussionTurnBlur && LitePostFeature.OpenGaussionTurnBlurMaxCount>0)
        {
            turnSceneBlurArrayRTCount = LitePostFeature.OpenGaussionTurnBlurMaxCount;
            cmd.DisableShaderKeyword(string.Intern("GAUSSION_LITPOSTFINAL_LERP"));
            RenderTargetIdentifier lastTexture = LitePostUtils.GetExecuteSrcColorTarget();
            for (int i = 0; i < turnSceneBlurArrayRTCount; ++i)
            {
                cmd.GetTemporaryRT(LitePostUtils.ShaderParams._GaussionBlur[i], blurWidth, blurHeight, 0, FilterMode.Bilinear, LitePostUtils.BloomExecuteData.m_DefaultHDRFormat);
                cmd.Blit(lastTexture, LitePostUtils.ShaderParams._GaussionBlur[i], material, LitePostUtils.ShaderPassIndex.LitePostGaussionBlur);
                lastTexture = LitePostUtils.ShaderParams._GaussionBlur[i];
            }
            cmd.SetGlobalTexture(LitePostUtils.ShaderParams._TurnBlurTex, lastTexture);

            cmd.SetGlobalFloat(LitePostUtils.ShaderParams._PixOffsetSize, LitePostFeature.PixOffsetSize);
            //

            material.SetFloat(LitePostUtils.ShaderParams._BlurLerp, LitePostFeature.GaussionTurnBlurLerp);
            cmd.EnableShaderKeyword(string.Intern("GAUSSION_LITPOSTFINAL_LERP"));
            if (LitePostUtils.GetExecuteSrcColorTarget() == LitePostUtils.GetExecuteDesColorTarget())
            {
                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), litePostTexture.id, material, LitePostUtils.ShaderPassIndex.LitePostGaussionBlur);
                LitePostUtils.SetExecuteSrcColorTarget(litePostTexture.id);
            }
            else
            {
                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget(), material, LitePostUtils.ShaderPassIndex.LitePostGaussionBlur);
                LitePostUtils.ClearExecuteSrcColorTarget();
            }
        }

        //径向模糊
        if (LitePostFeature.OpenScreenDirectionTurnBlur && LitePostFeature.ScreenDirectionTurnBlurMaxCount>0)
        {
            material.SetInt(LitePostUtils.ShaderParams._ScreenDirectionTurnBlurMaxCount, LitePostFeature.ScreenDirectionTurnBlurMaxCount);
            material.SetFloat(LitePostUtils.ShaderParams._BlurRange, LitePostFeature.ScreenDirectionTurnBlurRange);
            material.SetFloat(LitePostUtils.ShaderParams._BlurPower, LitePostFeature.ScreenDirectionTurnBlurPower);
            material.SetFloat(LitePostUtils.ShaderParams._Step, LitePostFeature.ScreenDirectionTurnBlurStep);
            material.SetVector(LitePostUtils.ShaderParams._Center, LitePostFeature.ScreenDirectionTurnBlurCenter);

            if (LitePostUtils.GetExecuteSrcColorTarget() == LitePostUtils.GetExecuteDesColorTarget())
            {
                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), litePostTexture.id, material, LitePostUtils.ShaderPassIndex.LitePostScreenDirectionBlur);
                LitePostUtils.SetExecuteSrcColorTarget(litePostTexture.id);
            }
            else
            {
                cmd.Blit(LitePostUtils.GetExecuteSrcColorTarget(), LitePostUtils.GetExecuteDesColorTarget(), material, LitePostUtils.ShaderPassIndex.LitePostScreenDirectionBlur);
                LitePostUtils.ClearExecuteSrcColorTarget();
            }
        }
    }

}
