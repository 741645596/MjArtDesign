using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.IO;
using UnityEngine.SceneManagement;

public class LitePostFeature : ScriptableRendererFeature
{
    #region//体积光 两种: 1-光追体积光(高配) 2-屏幕容积光(中配)

    [Header("开启体积光")]
    public bool UseVolumeLight = false;

    [Header("允许使用的体积光类型: RayVolumeLight-光追 ScreenDirectionGodLight-容积")]
    public RayAndScreenVolumeLightPass.GodLightType VolumeLightType = RayAndScreenVolumeLightPass.GodLightType.RayVolumeLight;

    public Shader RayVolumeLight;

    RayAndScreenVolumeLightPass rayVolumeLightPass;

    #endregion

    #region//体积云

    [Header("开启体积云")]
    public bool UseVolumeCloud = false;

    public Shader VolumeCloudLight;

    VolumeCloudPass volumeCloudPass;

    #endregion

    #region LUT BAKER

    public Shader LutBakerShader;

    /// <summary>
    /// 在低配的时候可以选择不去计算LUT，而是使用一张LUT纹理
    /// </summary>
    [Header("Bilinear,RGBA32Bit,not sRGB")]
    public Texture2D CustemLUT;

    Material m_LutBakerMaterial;

    LutBakerPass m_LutBakerPass;

    static Texture2D lastCustemLUT;

    #endregion

    #region UBER POST

    public Shader PostShader;

    LitePostPass m_LitePostPass;

    Material m_LitePostMaterial;

    #endregion

    #region//Fur 毛发

    FurPass furPass;

    [Space(20)]
    [Header("是否启用毛发")]
    public bool UseFur=false;

    [Range(0.01f,0.2f)]
    [Header("毛发最大长度限定 <= 0.2")]
    public float FurMaxLenght=0.1f; 

    #endregion

    #region//UI 渲染相机RT

    CameraCapRTPass cameraCapRTPass;

    #endregion

    #region//UI

    public Shader UICameraColorCopyShader;

    bool IsUICameara;

    UICameraColorCopy uiCameraColorCopy;

    /// <summary>
    /// 控制UI尺寸
    /// </summary>
    public enum UIQualityType
    {
        Low,
        Hight,
    }

    #endregion

    #region Wrap 屏幕扭曲 屏幕径向模糊  适用于粒子特效 会有一帧延迟

    [Space(20)]

    public Shader WrapAndBlurShader;

    WrapPass m_WrapPass;

    [HideInInspector] //此选项需要在PC端才可以开启，移动端可能会产生 "_CameraDepthAttachment" 丢失的BUG
    //看Unity升级版本后会不会解决
    [Header("屏幕扭曲模糊开启ZTest遮挡")]
    public bool UseWrapAndBlurZtest = false;

    /// <summary>
    /// Low:流程经过了优化  在同一个阶段渲染的扭曲，高斯模糊，径向模糊会在同一个ShaderPass渲染完成，但是效果会有所减弱
    /// Hight:扭曲，高斯模糊，径向模糊会在三个Shader Pass渲染，效果没有削弱，比较吃带宽
    /// </summary>
    [Header("显示质量")]
    public WrapAndBlurQualityEnum WrapAndBlurQuality = WrapAndBlurQualityEnum.Low;

    [HideInInspector]
    public bool OpenLitWrapAndBlur
    {
        get
        {
            if (OpenLitWrap ||
                OpenLitGaussioBlur ||
                OpenLitScreenDirectionBlur)
            {
                return true;
            }
            return false;
        }
    }

    //------------------------------扭曲

    [Header("使用-屏幕扭曲(粒子)")]
    public bool UseLitWrap = true;

    [Header("屏幕扭曲层级")]
    public LayerMask WrapLayerMask;

    [HideInInspector]
    [Header("屏幕扭曲阶段")]
    public static WrapAndBlurUtils.RenderEventEnum WrapRenderEvent = WrapAndBlurUtils.RenderEventEnum.BeforePostPass;

    [HideInInspector]
    public bool OpenLitWrap
    {
        get
        {
            return UseLitWrap && WrapLayerMask.value != 0;
        }
    }

    //------------------------------高斯模糊

    [Header("使用-屏幕高斯模糊(粒子)")]
    public bool UseLitGaussioBlur = true;

    [Header("屏幕高斯模糊层级")]
    public LayerMask GaussioBlurLayerMask;

    [HideInInspector]
    [Header("屏幕高斯模糊阶段")]
    public static WrapAndBlurUtils.RenderEventEnum GaussioRenderEvent = WrapAndBlurUtils.RenderEventEnum.BeforePostPass;

    [HideInInspector]
    public bool OpenLitGaussioBlur
    {
        get
        {
            return UseLitGaussioBlur && GaussioBlurLayerMask.value != 0;
        }
    }

    //------------------------------径向模糊

    [Header("使用-屏幕径向模糊(粒子)")]
    public bool UseLitScreenDirectionBlur = true;

    [Header("屏幕高斯模糊层级")]
    public LayerMask ScreenDirectionBlurLayerMask;

    [HideInInspector]
    [Header("屏幕径向模糊阶段")]
    public static WrapAndBlurUtils.RenderEventEnum ScreenDirectionBlurRenderEvent = WrapAndBlurUtils.RenderEventEnum.BeforePostPass;

    [HideInInspector]
    public bool OpenLitScreenDirectionBlur
    {
        get
        {
            return UseLitScreenDirectionBlur && ScreenDirectionBlurLayerMask.value != 0;
        }
    }

    /// <summary>
    /// 扭曲模糊显示质量
    /// </summary>
    public enum WrapAndBlurQualityEnum
    {
        /// <summary>
        /// 低质量显示 同一个阶段中的的扭曲与模糊会在一个Shader中处理
        /// </summary>
        Low,
        /// <summary>
        /// 高质量显示 扭曲，高斯模糊，径向扭曲会在不同的Shader中处理
        /// </summary>
        Hight,
    }

    #endregion

    #region//Bloom 辉光

    [Header("Bloom - Low:(Lit Bloom) Mid/Hight:(Lit Bloom Hight)")]
    public BloomType BloomSelect = BloomType.Low;

    #endregion

    #region//chromaticAberration 色散

    [Header("使用-ChromaticAberration色散")]
    public bool UseChromaticAberration = true;

    #endregion

    #region//LitVignette 暗角

    [Header("使用-Vignette暗角")]
    public bool UseVignette = true;

    #endregion

    [Space(20)]
    [Header("LUT开关")]
    public bool LUT = true;

    #region//LitToneMapping ACES

    [Header("(LUT)使用-ToneMappingACES")]
    public bool UseToneMapping = true;

    #endregion

    #region//WhiteBalance 白平衡

    [Header("(LUT)使用-WhiteBalance白平衡")]
    public bool UseWhiteBalance = true;

    #endregion

    #region//ColorAdjustments 校色

    [Header("(LUT)使用-ColorGrading校色")]
    public bool UseColorGrading = true;

    #endregion

    #region//LiftGammaGain

    [Header("(LUT)使用-LiftGammaGain黑白灰校色")]
    public bool UseLiftGammaGain = true;

    #endregion

    #region//ShadowsMidtonesHighlights

    [Header("(LUT)使用-ShadowsMidtonesHighlights黑白灰校色")]
    public bool UseShadowsMidtonesHighlights = true;

    #endregion

    #region//SplitToning

    [Header("(LUT)使用-SplitToning色调分离")]
    public bool UseSplitToning = true;

    #endregion

    //转场控制

    //转场控制 颜色
    #region

    [HideInInspector]
    [Header("开启转场颜色控制UI")]
    public static bool OpenFinishColorUI = false;

    #endregion

    //转场控制 高斯模糊
    #region

    [HideInInspector]
    [Header("开启高斯模糊转场控制UI")]
    public static bool OpenGaussionBlurUI = false;

    [HideInInspector]
    [Header("开启高斯模糊转场控制")]
    public static bool OpenGaussionTurnBlur = false;

    [HideInInspector]
    public static int OpenGaussionTurnBlurMaxCount = 4;

    [HideInInspector]
    public static float GaussionTurnBlurLerp = 0;

    public static float PixOffsetSize = 1;

    #endregion

    //转场控制 屏幕径向模糊
    #region

    [HideInInspector]
    [Header("开启屏幕径向模糊转场控制UI")]
    public static bool OpenScreenDirectionBlurUI = false;

    [HideInInspector]
    [Header("开启屏幕径向模糊转场控制")]
    public static bool OpenScreenDirectionTurnBlur = false;

    [HideInInspector]
    public static float ScreenDirectionTurnBlurRange = 0.5f; //Range(0.01, 1)

    [HideInInspector]
    public static float ScreenDirectionTurnBlurPower = 3f; //Range(1, 6)

    [HideInInspector]
    public static float ScreenDirectionTurnBlurStep = 0.01f; //Range(0.005,0.015)

    [HideInInspector]
    public static Vector2 ScreenDirectionTurnBlurCenter = new Vector2(0.5f,0.5f);

    [HideInInspector]
    public static int ScreenDirectionTurnBlurMaxCount = 10;

    #endregion

    #region//截屏

    ///// <summary>
    ///// 单帧主相机截取
    ///// </summary>
    //public static bool StaticCapRT = false;

    ///// <summary>
    ///// 单帧UI相机截取
    ///// </summary>
    //public static bool StaticUICapRT = false;


    #endregion

    #region//粒子编辑器工具

    public static bool EditorTextureChromaticOpen = false;

    EditorTextureChromaticPass editorTextureChromaticPass;

    #endregion

    public static void OnSceneSave()
    {
        lastCustemLUT = null;
    }

    public override void Create()
    {
        LitePostUtils.LitePostFeature = this;
        WrapAndBlurUtils.LitePostFeature = this;
#if UNITY_EDITOR
        InitShaders();
#endif
        lastCustemLUT = null;
        if (LutBakerShader != null)
        {
            m_LutBakerMaterial = CoreUtils.CreateEngineMaterial(LutBakerShader);
            if (m_LutBakerMaterial != null)
            {
                m_LutBakerPass = new LutBakerPass(RenderPassEvent.AfterRenderingShadows, m_LutBakerMaterial);
            }
        }

        //volumeCloudPass = new VolumeCloudPass(RenderPassEvent.AfterRenderingSkybox + 2, CoreUtils.CreateEngineMaterial(VolumeCloudLight));
        //rayVolumeLightPass = new RayAndScreenVolumeLightPass(RenderPassEvent.AfterRenderingSkybox+1, CoreUtils.CreateEngineMaterial(RayVolumeLight));

        furPass = new FurPass(RenderPassEvent.BeforeRenderingTransparents + 25);
        if (PostShader != null) 
        {
            m_LitePostMaterial = CoreUtils.CreateEngineMaterial(PostShader);
            if (m_LitePostMaterial != null)
            {
                m_LitePostPass = new LitePostPass(m_LitePostMaterial, RenderPassEvent.AfterRenderingPostProcessing + 10);
            }
            m_WrapPass = new WrapPass(RenderPassEvent.AfterRenderingPostProcessing, CoreUtils.CreateEngineMaterial(WrapAndBlurShader));
            if (UICameraColorCopyShader!=null)
            {
                uiCameraColorCopy = new UICameraColorCopy(CoreUtils.CreateEngineMaterial(UICameraColorCopyShader), RenderPassEvent.AfterRenderingSkybox+2);
            }
        }
        cameraCapRTPass = new CameraCapRTPass(RenderPassEvent.AfterRenderingPostProcessing+10);
        editorTextureChromaticPass = new EditorTextureChromaticPass(RenderPassEvent.BeforeRenderingOpaques);
    }

    public enum LitPostPassEnum
    {
        None,
        WrapAndBlurPass, //600
        UICameraColorCopyPass, //400
        CameraCapRTPass, //610
        LitePostPass, //610
        TemporalAntiAliasingPass, //611
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        GF.FeaturesSingleton<GF.LitePostFeatureEvent>.Instance.Update();
        //if (UseVolumeLight && renderingData.cameraData.camera.CompareTag("MainCamera"))
        //{

        //    rayVolumeLightPass.Setup(this, renderer.cameraColorTarget, VolumeLightType);
        //    renderer.EnqueuePass(rayVolumeLightPass);
        //}

        //if (UseVolumeLight && (renderingData.cameraData.camera.CompareTag("MainCamera") || renderingData.cameraData.isSceneViewCamera))
        //{

        //    volumeCloudPass.Setup(this, renderer.cameraColorTarget);
        //    renderer.EnqueuePass(volumeCloudPass);

        //}

        switch (WrapAndBlurQuality)
        {
            case WrapAndBlurQualityEnum.Low:
                {
                    WrapAndBlurUtils.SetRenderQualityEnum(WrapAndBlurUtils.RenderQualityEnum.Low);
                }
                break;
            case WrapAndBlurQualityEnum.Hight:
                {
                    WrapAndBlurUtils.SetRenderQualityEnum(WrapAndBlurUtils.RenderQualityEnum.High);
                }
                break;
        }
        WrapAndBlurUtils.WrapRenderEvent = WrapRenderEvent;
        WrapAndBlurUtils.GaussioRenderEvent = GaussioRenderEvent;
        WrapAndBlurUtils.ScreenDirectionBlurRenderEvent = ScreenDirectionBlurRenderEvent;
        if (EditorTextureChromaticOpen)
        {
            renderer.EnqueuePass(editorTextureChromaticPass);
        }

        Camera camera = renderingData.cameraData.camera;
        bool isCameraCapRT = false;
        bool isSceneViewCamera = false;
        bool cameraIsLitPost = LitePostUtils.CameraIsLitPost(camera, renderingData.cameraData, ref IsUICameara, ref isCameraCapRT,ref isSceneViewCamera);

        if (UseFur && !IsUICameara)
        {
            furPass.Setup(this, FurMaxLenght);
            renderer.EnqueuePass(furPass);
        }

        if (IsUICameara || isSceneViewCamera)
        {
            UICamera3DBufferLinerToSRGB(renderer,ref renderingData);
        }
        if (cameraIsLitPost && PostShader!=null)
        {
            LitePostUtils.FreshEffectVolume();
            if (m_LitePostPass != null)
            {
                if (OpenLitWrapAndBlur && !IsUICameara)// && !OverdrawForURP.OverdrawRendererFeature.Open)
                {
                    m_WrapPass.Setup(this, camera, renderer.cameraColorTarget);
                    renderer.EnqueuePass(m_WrapPass);
                }
            }
            if (!LitePostUtils.EffectOpen && !WrapAndBlurUtils.NeedLitPost(renderingData.cameraData))
            {
                if (isCameraCapRT)
                {
                    CameraCapRTUtils.InitColorTarget(renderer, ref renderingData);
                    cameraCapRTPass.Setup(this);
                    renderer.EnqueuePass(cameraCapRTPass);
                }
            }
            //LUT
            if (CustemLUT==null && m_LutBakerPass != null && LitePostUtils.VolumeLUTEffectOpen)// && !OverdrawForURP.OverdrawRendererFeature.Open)
            {
                m_LutBakerPass.Set(this);
                renderer.EnqueuePass(m_LutBakerPass);
            }
            //
            if (m_LitePostPass != null)// && !OverdrawForURP.OverdrawRendererFeature.Open)
            {
                LitePostUtils.InitColorTarget(renderer,ref renderingData);
                if (lastCustemLUT!= CustemLUT)
                {
                    lastCustemLUT = CustemLUT;
                    LitePostUtils.CustemLUT = CustemLUT;
                    m_LitePostPass.Setup();
                }
                else
                {
                    LitePostUtils.CustemLUT = null;
                    m_LitePostPass.Setup();
                }
                renderer.EnqueuePass(m_LitePostPass);
            }
        }
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
    }

    /// <summary>
    /// 对UI空间的3D相机缓存进行线性到SRGB转换
    /// </summary>
    void UICamera3DBufferLinerToSRGB(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (UICameraColorCopyShader==null) return;

        UICameraColorCopyUtils.InitColorTarget(renderer, ref renderingData);
        uiCameraColorCopy.Setup(this);
        renderer.EnqueuePass(uiCameraColorCopy);
    }

    public enum BloomType
    {
        None,
        Low,
        Mid,
        Hight,
    }

#if UNITY_EDITOR

    public static Texture2D SaveRenderToPng(RenderTexture renderT, string folderName, string name,bool useTime=true)
    {
        int width = renderT.width;
        int height = renderT.height;
        Texture2D tex2d = new Texture2D(width, height, TextureFormat.ARGB32, false);
        RenderTexture.active = renderT;
        tex2d.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        tex2d.Apply();

        byte[] b = tex2d.EncodeToPNG();
        if (!Directory.Exists(folderName))
            Directory.CreateDirectory(folderName);
        FileStream file=null;
        if (useTime)
        {
            file = File.Open(folderName + "/" + name + GetTimeName() + ".png", FileMode.Create);
        }
        else
        {
            file = File.Open(folderName + "/" + name + ".png", FileMode.Create);
        }
        BinaryWriter writer = new BinaryWriter(file);
        writer.Write(b);
        file.Close();

        return tex2d;
    }

    public static string GetTimeName()
    {
        return System.DateTime.Now.Year.ToString() + System.DateTime.Now.Month.ToString() +
            System.DateTime.Now.Day.ToString() + System.DateTime.Now.Hour.ToString() +
            System.DateTime.Now.Minute.ToString() + System.DateTime.Now.Second.ToString() +
            System.DateTime.Now.Millisecond.ToString();
    }

    /// <summary>
    /// 初始化 Shader 赋值
    /// </summary>
    void InitShaders()
    {
        FindShader(ref LutBakerShader, "FB/PostProcessing/LutBuilderHdr");
        FindShader(ref PostShader, "FB/PostProcessing/LitePostProcess");
        FindShader(ref WrapAndBlurShader, "FB/PostProcessing/WrapAndBlur");
        FindShader(ref UICameraColorCopyShader, "FB/PostProcessing/UICameraColorCopy");
        FindShader(ref RayVolumeLight, "FB/PostProcessing/RayAndScreenVolumeLight");
        FindShader(ref VolumeCloudLight, "FB/PostProcessing/RayVolumeCloud");
    }

    void FindShader(ref Shader findShader,string shaderName)
    {
        if (findShader==null)
        {
            findShader = Shader.Find(shaderName);
        }
    }

#endif

}

#if UNITY_EDITOR

public class LitePostFeatureSaveScene : UnityEditor.AssetModificationProcessor
{
    //场景保存监听
    static public void OnWillSaveAssets(string[] names)
    {
        LitePostFeature.OnSceneSave();
    }

    //编译监听
    [InitializeOnLoadMethod]
    static void OnProjectLoadedInEditor()
    {
        LitePostFeature.OnSceneSave();
        ProjectChanged_Listener(() => {
            LitePostFeature.OnSceneSave();
        }, true);
        PlayModeStateChanged_Listener((obj) => {
            PlayModeChange(obj);
        },true);
        SelectionChanged_Listener(()=> {
            LitePostFeature.OnSceneSave();
        }, true);
        HierarchyChanged_Listener(() => {
            LitePostFeature.OnSceneSave();
        }, true);
        PauseStateChanged_Listener((obj) => {
            PlayModeChange(obj);
        }, true);
        EditorApplication.CallbackFunction fun= LitePostFeature.OnSceneSave;
        DelayCall_Update(fun,true);
    }

    //模式变动监听
    static void PlayModeChange(PlayModeStateChange obj)
    {
        LitePostFeature.OnSceneSave();
    }

    static void PlayModeChange(PauseState obj)
    {
        LitePostFeature.OnSceneSave();
    }

    static void ProjectChanged_Listener(Action fun, bool add = true)
    {
        EditorApplication.projectChanged -= fun;
        if (add)
        {
            EditorApplication.projectChanged += fun;
        }
    }

    /// <summary>
    /// 选中物体发生变化
    /// </summary>
    /// <param name="fun"></param>
    /// <param name="add"></param>
    static void SelectionChanged_Listener(Action fun, bool add = true)
    {
        UnityEditor.Selection.selectionChanged -= fun;
        if (add)
        {
            UnityEditor.Selection.selectionChanged += fun;
        }
    }

    /// <summary>
    /// Hierarchy面板变动回调
    /// </summary>
    /// <param name="fun"></param>
    static void HierarchyChanged_Listener(Action fun, bool add = true)
    {
        EditorApplication.hierarchyChanged -= fun;
        if (add)
        {
            EditorApplication.hierarchyChanged += fun;
        }
    }

    /// <summary>
    /// 模式变化回调，编辑器模式/游戏模式
    /// </summary>
    /// <param name="fun"></param>
    static void PlayModeStateChanged_Listener(Action<PlayModeStateChange> fun, bool add = true)
    {
        EditorApplication.playModeStateChanged -= fun;
        if (add)
        {
            EditorApplication.playModeStateChanged += fun;
        }
    }

    /// <summary>
    /// 暂停模式变化回调，暂停/取消暂停
    /// </summary>
    /// <param name="fun"></param>
    static void PauseStateChanged_Listener(Action<PauseState> fun, bool add = true)
    {
        EditorApplication.pauseStateChanged -= fun;
        if (add)
        {
            EditorApplication.pauseStateChanged += fun;
        }
    }

    /// <summary>
    /// 编辑器所有检视面板更新完之后执行一次，只会执行一次的函数
    /// </summary>
    /// <param name="fun"></param>
    /// <param name="add"></param>
    static void DelayCall_Update(EditorApplication.CallbackFunction fun, bool add = true)
    {
        EditorApplication.delayCall -= fun;
        if (add)
        {
            EditorApplication.delayCall += fun;
        }
    }

}

#endif


