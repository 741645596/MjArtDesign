using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System;
using System.IO;

public class LitePostUtils
{
    public static LitePostFeature LitePostFeature;

    /// <summary>
    /// 判断相机是否需要开启LitPost
    /// </summary>
    /// <param name="cam"></param>
    /// <param name="isUICamera">UI相机</param>
    /// <param name="isCameraCapRT">相机缓存截取相机</param>
    /// <param name="isSceneViewCamera"></param>
    /// <returns></returns>
    public static bool CameraIsLitPost(Camera cam, CameraData cameraData,ref bool isUICamera,ref bool isCameraCapRT,ref bool isSceneViewCamera)
    {
        isSceneViewCamera = cameraData.isSceneViewCamera;
        isUICamera = cam.CompareTag("UICamera");
        isCameraCapRT = cam.CompareTag("CameraCapRT");
        if (
            (isUICamera && (WrapAndBlurUtils.UICameraEffect || LitePostFeature.OpenGaussionBlurUI || LitePostFeature.OpenScreenDirectionBlurUI || LitePostFeature.OpenFinishColorUI)) 
            || cameraData.isSceneViewCamera || cam.CompareTag("MainCamera") || isCameraCapRT
            )
        {
            return true;
        }
        return false;
    }

    #region//管线

    /// <summary>
    /// 获得下一步目标
    /// </summary>
    /// <param name="cameraData"></param>
    /// <param name="needBlitToCameraColorTarget"></param>
    /// <returns></returns>
    public static LitePostFeature.LitPostPassEnum NextPostStep(CameraData cameraData, ref bool needBlitToCameraColorTarget)
    {
        needBlitToCameraColorTarget = false;
        if (TemporalAntiAliasingUtils.TemporalAntiAliasingFeature.isActive && TemporalAntiAliasingUtils.IsTemporalAntiAliasingCamera(cameraData))
        {
            return LitePostFeature.LitPostPassEnum.TemporalAntiAliasingPass;
        }
        else
        {
            needBlitToCameraColorTarget = true;
            return LitePostFeature.LitPostPassEnum.None;
        }
    }

    #endregion

    #region//Volume

    /// <summary>
    /// 效果是否开放
    /// </summary>
    public static bool EffectOpen
    {
        get
        {
            if (VolumeNotLUTEffectOpen || VolumeLUTEffectOpen)
            {
                return true;
            }
            return false;
        }
    }

    /// <summary>
    /// 判断是否需要开启后期 不参与 LUT
    /// </summary>
    public static bool VolumeNotLUTEffectOpen
    {
        get
        {
            if (LitePostUtils.OpenBloom || LitePostUtils.OpenVignette || LitePostUtils.OpenChromaticAberration)
            {
                return true;
            }
            return false;
        }
    }

    /// <summary>
    /// 判断是否需要开启后期 参与 LUT
    /// </summary>
    public static bool VolumeLUTEffectOpen
    {
        get
        {
            if (LitePostFeature.LUT && (LitePostUtils.OpenWhiteBalance || LitePostUtils.OpenToneMapping
                || LitePostUtils.OpenColorGrading || LitePostUtils.OpenLiftGammaGain
                || LitePostUtils.OpenSplitToning || LitePostUtils.OpenShadowsMidtonesHighlights))
            {
                return true;
            }
            return false;
        }
    }

    #region//Bloom 辉光

    /// <summary>
    /// 低配与中配的时候使用
    /// </summary>
    public static LitBloom Bloom;

    /// <summary>
    /// 高配的时候使用
    /// </summary>
    public static Bloom LitBloomHight;

    /// <summary>
    /// 判断Bloom是否开启
    /// </summary>
    public static bool OpenBloom
    {
        get
        {
            if (LitePostFeature.BloomSelect == LitePostFeature.BloomType.None)
            {
                return false;
            }
            bool res = LitePostFeature.BloomSelect == LitePostFeature.BloomType.Low ? (Bloom.IsActive()) : (LitBloomHight.IsActive() || Bloom.IsActive());
            return res;
        }
    }

    public static bool BloomHightActive
    {
        get
        {
            return LitBloomHight.IsActive();
        }
    }

    public static bool BloomActive
    {
        get
        {
            return Bloom.IsActive();
        }
    }

    #endregion

    #region//LitVignette 暗角

    public static LitVignette Vignette;

    public static bool OpenVignette
    {
        get
        {
            return LitePostFeature.UseVignette && Vignette.IsActive();
        }
    }

    #endregion

    #region//chromaticAberration 色散

    public static ChromaticAberration ChromaticAberration;

    public static bool OpenChromaticAberration
    {
        get
        {
            return LitePostFeature.UseChromaticAberration && ChromaticAberration.IsActive();
        }
    }

    #endregion

    #region//LitToneMapping ACES

    public static LitToneMapping ToneMapping;

    public static bool OpenToneMapping
    {
        get
        {
            return LitePostFeature.UseToneMapping && ToneMapping.IsActive();
        }
    }

    #endregion

    #region//WhiteBalance 白平衡

    public static WhiteBalance WhiteBalance;

    public static bool OpenWhiteBalance
    {
        get
        {
            return LitePostFeature.UseWhiteBalance && WhiteBalance.IsActive();
        }
    }

    #endregion

    #region//ColorAdjustments 校色

    public static ColorAdjustments ColorGrading;

    public static bool OpenColorGrading
    {
        get
        {
            return LitePostFeature.UseColorGrading && ColorGrading.IsActive();
        }
    }

    #endregion

    #region//LiftGammaGain

    public static LiftGammaGain LiftGammaGain;

    public static bool OpenLiftGammaGain
    {
        get
        {
            return LitePostFeature.UseLiftGammaGain && LiftGammaGain.IsActive();
        }
    }

    #endregion

    #region//ShadowsMidtonesHighlights

    public static ShadowsMidtonesHighlights ShadowsMidtonesHighlights;

    public static bool OpenShadowsMidtonesHighlights
    {
        get
        {
            return LitePostFeature.UseShadowsMidtonesHighlights && ShadowsMidtonesHighlights.IsActive();
        }
    }

    #endregion

    #region//SplitToning

    public static SplitToning SplitToning;

    public static bool OpenSplitToning
    {
        get
        {
            return LitePostFeature.UseSplitToning && SplitToning.IsActive();
        }
    }

    #endregion

    /// <summary>
    /// 刷新Volume组件
    /// </summary>
    public static void FreshEffectVolume()
    {
        VolumeStack stack = VolumeManager.instance.stack;
        ColorGrading = stack.GetComponent<ColorAdjustments>();
        Bloom = stack.GetComponent<LitBloom>();
        LitBloomHight = stack.GetComponent<Bloom>();
        Vignette = stack.GetComponent<LitVignette>();
        ChromaticAberration = stack.GetComponent<ChromaticAberration>();
        ToneMapping = stack.GetComponent<LitToneMapping>();
        WhiteBalance = stack.GetComponent<WhiteBalance>();

        LiftGammaGain = stack.GetComponent<LiftGammaGain>();
        SplitToning = stack.GetComponent<SplitToning>();
        ShadowsMidtonesHighlights = stack.GetComponent<ShadowsMidtonesHighlights>();
    }

    #endregion

    #region//当前的 ColorTarget 仅针对于 LitePostPass

    /// <summary>
    /// 流程最先颜色目标 作为ScriptableRenderPass的目标RT
    /// </summary>
    static RenderTargetIdentifier cameraColorTarget;

    public static void InitColorTarget(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        cameraColorTarget = renderer.cameraColorTarget;
        executeColorTarget = -1;
    }

    /// <summary>
    /// 执行起始目标 作为ScriptableRenderPass的源RT
    /// </summary>
    static RenderTargetIdentifier executeColorTarget;

    /// <summary>
    /// 设置源RT为CameraColorTarget之外的其他RT
    /// </summary>
    /// <param name="identifier"></param>
    public static void SetExecuteSrcColorTarget(RenderTargetIdentifier identifier)
    {
        executeColorTarget = identifier;
    }

    /// <summary>
    /// 设置源RT为CameraColorTarget
    /// </summary>
    public static void ClearExecuteSrcColorTarget()
    {
        executeColorTarget = -1;
    }

    /// <summary>
    /// 获得源RT
    /// </summary>
    /// <returns></returns>
    public static RenderTargetIdentifier GetExecuteSrcColorTarget()
    {
        if (executeColorTarget==-1)
        {
            return cameraColorTarget;
        }
        else
        {
            return executeColorTarget;
        }
    }

    /// <summary>
    /// 获得目标RT
    /// </summary>
    /// <returns></returns>
    public static RenderTargetIdentifier GetExecuteDesColorTarget()
    {
        return cameraColorTarget;
    }

    #endregion

    /// <summary>
    /// 自定义LUT 
    /// 如果此项部位Null，则在后期中不会进行动态计算Lut，会直接采样此项
    /// </summary>
    public static Texture2D CustemLUT;

    #region//RT相机 将相机渲染到RT，并设置为Shader中的纹理名为 "_CapRenderTextureCamTex" 的属性，材质球客服与给Image 

    public static RenderTargetHandle CapRenderTextureCamTex;

    static bool capRenderTextureCamTexGet = false;

    public static void InitUICapRt()
    {
        CapRenderTextureCamTex.Init("_CapRenderTextureCamTex");
    }

    public static void GetUICapRt(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        capRenderTextureCamTexGet = true;
        cmd.GetTemporaryRT(CapRenderTextureCamTex.id, cameraTextureDescriptor);
    }

    public static void ReleaseUICapRt(CommandBuffer cmd)
    {
        if (capRenderTextureCamTexGet)
        {
            capRenderTextureCamTexGet = false;
            cmd.ReleaseTemporaryRT(CapRenderTextureCamTex.id);
        }
    }

    #endregion

    #region Bloom

    /// <summary>
    /// Bloom运行数据
    /// </summary>
    public static BloomExecuteclass BloomExecuteData = new BloomExecuteclass ();

    /// <summary>
    /// Bloom运行数据
    /// </summary>
    public class BloomExecuteclass
    {
        /// <summary>
        /// Bloom步进次数
        /// </summary>
        public int bloomMaxStepNum = 16;

        /// <summary>
        /// 记录RT数组长度
        /// </summary>
        public int bloomIterations;

        /// <summary>
        /// Bloom RT 宽度
        /// </summary>
        public int bloomWidth;

        /// <summary>
        /// Bloom RT 高度 //        CoreUtils
        /// </summary>
        public int bloomHeight;

        /// <summary>
        /// key:RT Id value:RT宽高 
        /// </summary>
        public System.Collections.Generic.Dictionary<int, Vector2> bloomHightWHs = new System.Collections.Generic.Dictionary<int, Vector2>();

        public GraphicsFormat m_DefaultHDRFormat;

        public bool m_UseRGBM;
    }

    #endregion

    public static class ShaderParams
    {
        // Bloom
        public static readonly int _BloomIntensity = Shader.PropertyToID(string.Intern("_BloomIntensity"));
        public static readonly int _BloomThreshold = Shader.PropertyToID(string.Intern("_BloomThreshold"));
        public static readonly int _BloomTintColor = Shader.PropertyToID(string.Intern("_BloomTintColor"));
        public static readonly int _BloomIterations = Shader.PropertyToID(string.Intern("_BloomIterations"));
        public static readonly int _Offset = Shader.PropertyToID(string.Intern("_Offset"));
        public static int[] _BloomMipDown;

        public static int[] _BloomMipUp;

        public static int[] _GaussionBlur;

        public static readonly int _PixOffsetSize = Shader.PropertyToID(string.Intern("_PixOffsetSize"));

        public static readonly int _StaticCapRenderTextureCamTex = Shader.PropertyToID(string.Intern("_StaticCapRenderTextureCamTex"));

        // Color grading
        public static readonly int _LutParams = Shader.PropertyToID(string.Intern("_LutParams"));

        // lut
        public static readonly int _ColorLut = Shader.PropertyToID(string.Intern("_ColorLut"));

        // Vignette
        public static readonly int _VignetteIntensity = Shader.PropertyToID(string.Intern("_VignetteIntensity"));
        public static readonly int _VignetteRoughness = Shader.PropertyToID(string.Intern("_VignetteRoughness"));
        public static readonly int _VignetteSmothness = Shader.PropertyToID(string.Intern("_VignetteSmothness"));

        // Chromatic Aberration
        public static readonly int _ChromaticAberration = Shader.PropertyToID(string.Intern("_ChromaticAberration"));

        //Hight
        public static readonly int _downSampleBlurSize = Shader.PropertyToID(string.Intern("_downSampleBlurSize"));
        public static readonly int _downSampleBlurSigma = Shader.PropertyToID(string.Intern("_downSampleBlurSigma"));
        public static readonly int _upSampleBlurSize = Shader.PropertyToID(string.Intern("_upSampleBlurSize"));
        public static readonly int _upSampleBlurSigma = Shader.PropertyToID(string.Intern("_upSampleBlurSigma"));
        public static readonly int _luminanceThreshole = Shader.PropertyToID(string.Intern("_luminanceThreshole"));
        public static readonly int _bloomIntensity = Shader.PropertyToID(string.Intern("_bloomIntensity"));
        public static readonly int _PrevMip = Shader.PropertyToID(string.Intern("_PrevMip"));

        //Unity Bloom
        public static readonly int _Params = Shader.PropertyToID(string.Intern("_Params"));
        public static readonly int _SourceTexLowMip = Shader.PropertyToID(string.Intern("_SourceTexLowMip"));
        public static readonly int _Bloom_Params = Shader.PropertyToID(string.Intern("_Bloom_Params"));
        public static readonly int _Bloom_RGBM = Shader.PropertyToID(string.Intern("_Bloom_RGBM"));
        public static readonly int _LensDirt_Params = Shader.PropertyToID(string.Intern("_LensDirt_Params"));
        public static readonly int _LensDirt_Intensity = Shader.PropertyToID(string.Intern("_LensDirt_Intensity"));
        public static readonly int _LensDirt_Texture = Shader.PropertyToID(string.Intern("_LensDirt_Texture"));

        //CameraCap
        public static readonly int _CapRenderTextureCamTex = Shader.PropertyToID(string.Intern("_CapRenderTextureCamTex"));

        public static readonly int _MainTexEditor = Shader.PropertyToID(string.Intern("_MainTexEditor"));
        public static readonly int _CameraColorTextureST = Shader.PropertyToID(string.Intern("_CameraColorTextureST"));

        public static readonly int _TurnBlurTex = Shader.PropertyToID(string.Intern("_TurnBlurTex"));
        public static readonly int _BlurLerp = Shader.PropertyToID(string.Intern("_BlurLerp"));
        public static readonly int _ScreenDirectionTurnBlurMaxCount = Shader.PropertyToID(string.Intern("_ScreenDirectionTurnBlurMaxCount"));
        public static readonly int _BlurRange = Shader.PropertyToID(string.Intern("_BlurRange"));
        public static readonly int _BlurPower = Shader.PropertyToID(string.Intern("_BlurPower"));
        public static readonly int _Step = Shader.PropertyToID(string.Intern("_Step"));
        public static readonly int _Center = Shader.PropertyToID(string.Intern("_Center"));
    }

    public class ShaderPassIndex
    {

        public static int LitePostFirst = 0;

        /// <summary>
        /// Lit Bloom 适合低配机
        /// </summary>
        public static int BloomDownSamplePass = 1;

        /// <summary>
        /// Lit Bloom 适合低配机
        /// </summary>
        public static int BloomUpSamplePass = 2;

        /// <summary>
        /// 最终阶段
        /// </summary>
        public static int LitePostFinal = 3;


        /// <summary>
        /// Unity Bloom 适合中高配机
        /// </summary>
        public static int UnityBloomPrefilter = 4;

        /// <summary>
        /// /// <summary>
        /// Unity Bloom 适合中高配机
        /// </summary>
        /// </summary>
        public static int UnityBloomBlurHorizontal = 5;

        /// <summary>
        /// /// <summary>
        /// Unity Bloom 适合中高配机
        /// </summary>
        /// </summary>
        public static int UnityBloomBlurVertical = 6;

        /// <summary>
        /// Unity Bloom 适合中高配机
        /// </summary>
        public static int UnityBloomUpsample = 7;

        /// <summary>
        /// 场景 高斯模糊
        /// </summary>
        public static int LitePostGaussionBlur = 8;

        /// <summary>
        /// 场景 径向模糊
        /// </summary>
        public static int LitePostScreenDirectionBlur = 9;

        /// <summary>
        /// 场景 UI颜色混合
        /// </summary>
        public static int FinishColorPass = 10;
    }

}
