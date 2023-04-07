using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System;
using System.IO;
using System.Collections.Generic;

public class WrapAndBlurUtils
{
    public static LitePostFeature LitePostFeature;

    /// <summary>
    /// "FB/PostProcessing/WrapAndBlur"
    /// </summary>
    public static Material m_material;

    static RenderQualityEnum _renderQuality= RenderQualityEnum.Low;

    /// <summary>
    /// 渲染质量
    /// </summary>
    public static RenderQualityEnum WrapAndBlurRenderQuality
    {
        get
        {
            return _renderQuality;
        }
    }

    /// <summary>
    /// 设置渲染质量
    /// </summary>
    public static void SetRenderQualityEnum(RenderQualityEnum renderQualityEnum)
    {
        RenderQualityData data = RenderQualityDatas[renderQualityEnum];
        ScreenDirectionBlurForCount = data.ScreenDirectionBlurForCount;
        GaussioQuality = data.GaussioQuality;
        GaussioSampl = data.GaussioSampl;
        GaussionForCount = data.GaussionForCount;
    }

    static Dictionary<RenderQualityEnum, RenderQualityData> _renderQualityDatas;

    /// <summary>
    /// 品质设置数据
    /// </summary>
    public static Dictionary<RenderQualityEnum, RenderQualityData> RenderQualityDatas
    {
        get
        {
            if (_renderQualityDatas==null)
            {
                _renderQualityDatas = new Dictionary<RenderQualityEnum, RenderQualityData>();
                _renderQualityDatas.Add(RenderQualityEnum.Low,new RenderQualityData (8, GaussioQualityEnum.Simplify, GaussioSamplEnum.Samp5,4));
                _renderQualityDatas.Add(RenderQualityEnum.High, new RenderQualityData(12, GaussioQualityEnum.Normal, GaussioSamplEnum.Samp9, 6));
            }
            return _renderQualityDatas;
        }
    }

    /// <summary>
    /// 品质设置数据
    /// </summary>
    public class RenderQualityData
    {
        public RenderQualityData(int screenDirectionBlurForCount, GaussioQualityEnum gaussioQuality, GaussioSamplEnum gaussioSampl, int gaussionForCount)
        {
            ScreenDirectionBlurForCount = screenDirectionBlurForCount;
            GaussioQuality = gaussioQuality;
            GaussioSampl = gaussioSampl;
            GaussionForCount = gaussionForCount;
        }

        /// <summary>
        /// 径向模糊For循环次数
        /// </summary>
        public int ScreenDirectionBlurForCount = 8;

        /// <summary>
        /// 高斯模糊的质量
        /// 简化版高斯模糊不会有for循环，效果也会差一些
        /// </summary>
        public GaussioQualityEnum GaussioQuality = GaussioQualityEnum.Simplify;

        /// <summary>
        /// 高斯模糊采样次数控制
        /// </summary>
        public GaussioSamplEnum GaussioSampl = GaussioSamplEnum.Samp5;

        /// <summary>
        /// 高斯模糊循环次数 值越大，功耗越大 
        /// 此数值只有在使用非简化高斯模糊的情况下才会被用到
        /// </summary>
        public int GaussionForCount = 4;
    }

    /// <summary>
    /// 渲染质量
    /// </summary>
    public enum RenderQualityEnum
    {
        /// <summary>
        /// 简化版，适用于中配，高配
        /// </summary>
        Low,
        /// <summary>
        /// 适用于高配
        /// </summary>
        High,
    }

    /// <summary>
    /// 渲染层级
    /// </summary>
    public enum RenderEventEnum
    {
        /// <summary>
        /// PostPass之前
        /// </summary>
        BeforePostPass,

        /// <summary>
        /// PostPass
        /// </summary>
        PostPass,

        /// <summary>
        /// UI之后
        /// </summary>
        AfterUI,
    }

    /// <summary>
    /// 是否需要处理UI相机
    /// </summary>
    public static bool UICameraEffect
    {
        get
        {
            if (
                ((OpenWrap || OpenChromatic) && WrapRenderEvent == RenderEventEnum.AfterUI) ||
                (OpenScreenDirectionBlur && ScreenDirectionBlurRenderEvent == RenderEventEnum.AfterUI) ||
                (OpenGaussionBlur && GaussioRenderEvent ==RenderEventEnum.AfterUI)
                )
            {
                return true;
            }
            return false;
        }
    }

    /// <summary>
    /// 刷新材质key
    /// </summary>
    /// <param name="renderEventEnum"></param>
    public static void FreskMaterialKeys(RenderEventEnum renderEventEnum, CommandBuffer cmd)
    {
        if ((WrapAndBlurUtils.OpenWrap || WrapAndBlurUtils.OpenChromatic) && WrapAndBlurUtils.WrapRenderEvent == renderEventEnum)
        {
            if (WrapAndBlurUtils.OpenWrap)
            {
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_WRAP"));
            }
            else
            {
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_WRAP"));
            }
            if (WrapAndBlurUtils.OpenChromatic)
            {
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_CHROMATIC"));
            }
            else
            {
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_CHROMATIC"));
            }
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_WRAP"));
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_CHROMATIC"));
        }
        if (WrapAndBlurUtils.OpenScreenDirectionBlur && WrapAndBlurUtils.ScreenDirectionBlurRenderEvent == renderEventEnum)
        {
            cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_SCREENDIRECTIONBLUR"));
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_SCREENDIRECTIONBLUR"));
        }
        if (WrapAndBlurUtils.OpenGaussionBlur && WrapAndBlurUtils.GaussioRenderEvent == renderEventEnum)
        {
            if (WrapAndBlurUtils.GaussioSampl == WrapAndBlurUtils.GaussioSamplEnum.Samp5)
            {
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP5"));
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP9"));
            }
            else
            {
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP5"));
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP9"));
            }
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP5"));
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP9"));
        }
    }

    public static void FreskMaterialKeys(RenderEventEnum renderEventEnum, CommandBuffer cmd, Camera cam)
    {
        WrapAndBlurCameraData data;
        CameraCustemDatas.TryGetValue(cam, out data);
        if (data != null && (data.BackUICamera != null && (!data.NextIsBaseCamera || (data.NextIsBaseCamera && (data.NextCamera != data.BackUICamera)))))
        {
            FreskMaterialKeys(renderEventEnum, cmd);
            return;
        }
        if ((WrapAndBlurUtils.OpenWrap || WrapAndBlurUtils.OpenChromatic) && (WrapAndBlurUtils.WrapRenderEvent == RenderEventEnum.AfterUI || WrapAndBlurUtils.WrapRenderEvent == renderEventEnum))
        {
            if (WrapAndBlurUtils.OpenWrap)
            {
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_WRAP"));
            }
            else
            {
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_WRAP"));
            }
            if (WrapAndBlurUtils.OpenChromatic)
            {
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_CHROMATIC"));
            }
            else
            {
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_CHROMATIC"));
            }
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_WRAP"));
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_CHROMATIC"));
        }
        if (WrapAndBlurUtils.OpenScreenDirectionBlur && (WrapAndBlurUtils.ScreenDirectionBlurRenderEvent == RenderEventEnum.AfterUI || WrapAndBlurUtils.ScreenDirectionBlurRenderEvent == renderEventEnum))
        {
            cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_SCREENDIRECTIONBLUR"));
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_SCREENDIRECTIONBLUR"));
        }
        if (WrapAndBlurUtils.OpenGaussionBlur && (WrapAndBlurUtils.GaussioRenderEvent == RenderEventEnum.AfterUI || WrapAndBlurUtils.GaussioRenderEvent == renderEventEnum))
        {
            if (WrapAndBlurUtils.GaussioSampl == WrapAndBlurUtils.GaussioSamplEnum.Samp5)
            {
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP5"));
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP9"));
            }
            else
            {
                cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP5"));
                cmd.EnableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP9"));
            }
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP5"));
            cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP9"));
        }
    }

    public static void ClearMaterialKeys(CommandBuffer cmd)
    {
        cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_WRAP"));
        cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_CHROMATIC"));
        cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_SCREENDIRECTIONBLUR"));
        cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP5"));
        cmd.DisableShaderKeyword(string.Intern("ENABLE_SCREEN_GAUSSIANBLUR_SAMP9"));
    }

    #region//当前的 ColorTarget 仅针对于 TemporalAntiAliasingPass

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
        if (executeColorTarget == -1)
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

    #region//管线

    public static bool NeedLitPost(CameraData cameraData)
    {
        if ((OpenWrap || OpenChromatic) && WrapRenderEvent == RenderEventEnum.PostPass)
        {
            return true;
        }
        if (OpenGaussionBlur && GaussioRenderEvent == RenderEventEnum.PostPass)
        {
            return true;
        }
        if (OpenScreenDirectionBlur && ScreenDirectionBlurRenderEvent == RenderEventEnum.PostPass)
        {
            return true;
        }
        bool isUICamera = cameraData.camera.CompareTag("UICamera");
        if (isUICamera)
        {
            if ((OpenWrap || OpenChromatic) && WrapRenderEvent == RenderEventEnum.AfterUI)
            {
                return true;
            }
            if (OpenGaussionBlur && GaussioRenderEvent == RenderEventEnum.AfterUI)
            {
                return true;
            }
            if (OpenScreenDirectionBlur && ScreenDirectionBlurRenderEvent == RenderEventEnum.AfterUI)
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// 获得下一步目标
    /// </summary>
    public static LitePostFeature.LitPostPassEnum NextPostStep(CameraData cameraData,ref bool needBlitToCameraColorTarget)
    {
        needBlitToCameraColorTarget = false;
        bool isGameCamera = false;
        bool isSceneViewCamera = cameraData.isSceneViewCamera;
        bool isUICamera = cameraData.camera.CompareTag("UICamera");
        bool isCameraCapRT = cameraData.camera.CompareTag("CameraCapRT");

        if (UniversalRenderPipeline.IsGameCamera(cameraData.camera))
        {
            isGameCamera = true;
        }
        if (isGameCamera)
        {
            if (isUICamera)
            {
                if (LitePostUtils.EffectOpen || NeedLitPost(cameraData))
                {
                    return LitePostFeature.LitPostPassEnum.LitePostPass;
                }
                if (TemporalAntiAliasingUtils.TemporalAntiAliasingFeature.isActive && TemporalAntiAliasingUtils.IsTemporalAntiAliasingCamera(cameraData))
                {
                    return LitePostFeature.LitPostPassEnum.TemporalAntiAliasingPass;
                }
                bool nextIsUICamera = false;
                WrapAndBlurCameraData data;
                CameraCustemDatas.TryGetValue(cameraData.camera, out data);
                if (data != null && (data.BackUICamera != null && (!data.NextIsBaseCamera || (data.NextIsBaseCamera && (data.NextCamera != data.BackUICamera)))))
                {
                    nextIsUICamera = true;
                }
                if (nextIsUICamera)
                {
                    needBlitToCameraColorTarget = true;
                    return LitePostFeature.LitPostPassEnum.UICameraColorCopyPass;
                }
                else
                {
                    WrapAndBlurCameraData nextData;
                    CameraCustemDatas.TryGetValue(cameraData.camera, out nextData);
                    if (nextData == null || nextData.NextCamera==null || nextData.NextIsBaseCamera)
                    {
                        needBlitToCameraColorTarget = true;
                        return LitePostFeature.LitPostPassEnum.None;
                    }
                    else
                    {
                        if (nextData.NextCamera.CompareTag("CameraCapRT"))
                        {
                            if (!LitePostUtils.EffectOpen && !WrapAndBlurUtils.NeedLitPost(cameraData))
                            {
                                needBlitToCameraColorTarget = true;
                                return LitePostFeature.LitPostPassEnum.CameraCapRTPass;
                            }
                            else
                            {
                                needBlitToCameraColorTarget = true;
                                return LitePostFeature.LitPostPassEnum.LitePostPass;
                            }
                        }
                        else
                        {
                            needBlitToCameraColorTarget = true;
                            return LitePostFeature.LitPostPassEnum.WrapAndBlurPass;
                        }
                    }
                }
            }
            else
            {
                if (isCameraCapRT)
                {
                    if (!LitePostUtils.EffectOpen && !WrapAndBlurUtils.NeedLitPost(cameraData))
                    {
                        return LitePostFeature.LitPostPassEnum.CameraCapRTPass;
                    }
                }
                if (LitePostUtils.EffectOpen || NeedLitPost(cameraData))
                {
                    return LitePostFeature.LitPostPassEnum.LitePostPass;
                }
                if (TemporalAntiAliasingUtils.TemporalAntiAliasingFeature.isActive && TemporalAntiAliasingUtils.IsTemporalAntiAliasingCamera(cameraData))
                {
                    return LitePostFeature.LitPostPassEnum.TemporalAntiAliasingPass;
                }
                bool nextIsUICamera = false;
                WrapAndBlurCameraData data;
                CameraCustemDatas.TryGetValue(cameraData.camera, out data);
                if (data != null && (data.BackUICamera != null && (!data.NextIsBaseCamera || (data.NextIsBaseCamera && (data.NextCamera != data.BackUICamera)))))
                {
                    nextIsUICamera = true;
                }
                if (nextIsUICamera)
                {
                    needBlitToCameraColorTarget = true;
                    return LitePostFeature.LitPostPassEnum.UICameraColorCopyPass;
                }
                else
                {
                    WrapAndBlurCameraData nextData;
                    CameraCustemDatas.TryGetValue(cameraData.camera, out nextData);
                    if (nextData == null || nextData.NextCamera==null || nextData.NextIsBaseCamera)
                    {
                        needBlitToCameraColorTarget = true;
                        return LitePostFeature.LitPostPassEnum.None;
                    }
                    else
                    {
                        if (nextData.NextCamera.CompareTag("CameraCapRT"))
                        {
                            if (!LitePostUtils.EffectOpen && !WrapAndBlurUtils.NeedLitPost(cameraData))
                            {
                                needBlitToCameraColorTarget = true;
                                return LitePostFeature.LitPostPassEnum.CameraCapRTPass;
                            }
                            else
                            {
                                needBlitToCameraColorTarget = true;
                                return LitePostFeature.LitPostPassEnum.LitePostPass;
                            }
                        }
                        else
                        {
                            needBlitToCameraColorTarget = true;
                            return LitePostFeature.LitPostPassEnum.WrapAndBlurPass;
                        }
                    }
                }
            }
        }
        else
        {
            if (isCameraCapRT)
            {
                if (!LitePostUtils.VolumeNotLUTEffectOpen && !LitePostUtils.VolumeLUTEffectOpen)
                {
                    return LitePostFeature.LitPostPassEnum.CameraCapRTPass;
                }
            }
            if (LitePostUtils.EffectOpen || NeedLitPost(cameraData))
            {
                return LitePostFeature.LitPostPassEnum.LitePostPass;
            }
            if (TemporalAntiAliasingUtils.TemporalAntiAliasingFeature.isActive && TemporalAntiAliasingUtils.IsTemporalAntiAliasingCamera(cameraData))
            {
                return LitePostFeature.LitPostPassEnum.TemporalAntiAliasingPass;
            }
            return LitePostFeature.LitPostPassEnum.None;
        }
    }

    #endregion

    #region//相机数据

    public static Dictionary<Camera, WrapAndBlurCameraData> CameraCustemDatas = new Dictionary<Camera, WrapAndBlurCameraData>();

    public static void ClearCameraCustemDatas()
    {
        Dictionary<Camera, WrapAndBlurCameraData>.Enumerator enumerator = CameraCustemDatas.GetEnumerator();
        while (enumerator.MoveNext())
        {
            PutBackOneCameraData(enumerator.Current.Value);
        }
        CameraCustemDatas.Clear();
    }

    public static void AddCameraCustemDatas(Camera cam, WrapAndBlurCameraData data)
    {
        CameraCustemDatas.Add(cam, data);
    }


    public static bool RTNeedFlagClear(Camera came, RenderEventEnum eventEnum)
    {
        switch (eventEnum)
        {
            case RenderEventEnum.BeforePostPass:
            case RenderEventEnum.PostPass:
                {
                    return true;
                }
            case RenderEventEnum.AfterUI:
                {
                    WrapAndBlurCameraData data;
                    CameraCustemDatas.TryGetValue(came, out data);

                    //if (data != null && (data.BackUICamera != null && (!data.NextIsBaseCamera || (data.NextIsBaseCamera && (data.NextCamera != cameraData.camera)))))
                    if (data == null || data.BackUICamera==null || (data.NextIsBaseCamera&& data.NextCamera == data.BackUICamera))
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
        }
        return true;
    }

    /// <summary>
    /// 判断当前相机缓存是否需要被清空
    /// </summary>
    /// <param name="came"></param>
    /// <returns></returns>
    public static void RTNeedFlagClear(Camera came, RenderEventEnum eventEnumWrap, RenderEventEnum eventEnumGaussion, RenderEventEnum eventEnumScreenDirection,
        ref bool clearWrap,ref bool clearGaussion,ref bool clearScreenDirection)
    {
        if (came.GetUniversalAdditionalCameraData().renderType == CameraRenderType.Base)
        {
            clearWrap = true;
            clearGaussion = true;
            clearScreenDirection = true;
        }
        else
        {
            clearWrap = RTNeedFlagClear(came, eventEnumWrap);
            clearGaussion = RTNeedFlagClear(came, eventEnumGaussion);
            clearScreenDirection = RTNeedFlagClear(came, eventEnumScreenDirection);
        }
    }

    public class WrapAndBlurCameraData
    {
        public bool IsPutBack = false;

        /// <summary>
        /// 排在后面的第一个UI相机
        /// </summary>
        public Camera BackUICamera;

        /// <summary>
        /// 下一个相机
        /// </summary>
        public Camera NextCamera;

        /// <summary>
        /// 下一个相机是否为Base
        /// </summary>
        public bool NextIsBaseCamera = false;
    }

    static Queue<WrapAndBlurCameraData> wrapAndBlurCameraDataPool = new Queue<WrapAndBlurCameraData>();

    public static WrapAndBlurCameraData GetOneCameraData()
    {
        WrapAndBlurCameraData res = null;
        while (res == null && wrapAndBlurCameraDataPool.Count > 0)
        {
            res = wrapAndBlurCameraDataPool.Dequeue();
        }
        if (res==null)
        {
            res = new WrapAndBlurCameraData();
        }
        res.IsPutBack = false;
        return res;
    }

    public static void PutBackOneCameraData(WrapAndBlurCameraData data)
    {
        if (data==null || data.IsPutBack) return;
        data.IsPutBack = true;
        data.BackUICamera = null;
        data.NextCamera = null;
        data.NextIsBaseCamera = false;
        wrapAndBlurCameraDataPool.Enqueue(data);
    }

    #endregion

    #region//颜色转场

    /// <summary>
    /// 是否开启颜色转场
    /// </summary>
    //public static bool ColorCutTo = false;

    /// <summary>
    /// 颜色转场渲染顺序
    /// </summary>
    //public static RenderEventEnum ColorCutToRenderEvent = RenderEventEnum.BeforePostPass;

    #endregion

    #region//扭曲

    /// <summary>
    /// 是否启动扭曲
    /// </summary>
    public static bool OpenWrap = false;

    /// <summary>
    /// 是否启动色散
    /// </summary>
    public static bool OpenChromatic = false;

    /// <summary>
    /// 扭曲渲染顺序
    /// </summary>
    public static RenderEventEnum WrapRenderEvent = RenderEventEnum.BeforePostPass;

    #endregion

    #region//径向模糊

    /// <summary>
    /// 是否启动径向模糊
    /// </summary>
    public static bool OpenScreenDirectionBlur = false;

    /// <summary>
    /// 径向模糊渲染顺序
    /// </summary>
    public static RenderEventEnum ScreenDirectionBlurRenderEvent = RenderEventEnum.BeforePostPass;

    /// <summary>
    /// 径向模糊For循环次数
    /// </summary>
    public static int ScreenDirectionBlurForCount = 8;

    #endregion

    #region//高斯模糊

    /// <summary>
    /// 是否启动高斯模糊
    /// </summary>
    public static bool OpenGaussionBlur = false;

    /// <summary>
    /// 高斯模糊渲染顺序
    /// </summary>
    public static RenderEventEnum GaussioRenderEvent = RenderEventEnum.PostPass;

    /// <summary>
    /// 高斯模糊的质量
    /// 简化版高斯模糊不会有for循环，效果也会差一些
    /// </summary>
    public static GaussioQualityEnum GaussioQuality = GaussioQualityEnum.Simplify;

    /// <summary>
    /// 高斯模糊采样次数控制
    /// </summary>
    public static GaussioSamplEnum GaussioSampl= GaussioSamplEnum.Samp5;

    /// <summary>
    /// 高斯模糊循环次数 值越大，功耗越大 
    /// 此数值只有在使用非简化高斯模糊的情况下才会被用到
    /// </summary>
    public static int GaussionForCount = 4;

    /// <summary>
    /// 高斯模糊循环次数限制
    /// </summary>
    public static int GaussionForCountMax = 8;

    /// <summary>
    /// 高斯模糊循环缓存
    /// </summary>
    public static int[] GaussionBlurs;

    /// <summary>
    /// 采样精度 值越大，功耗越大
    /// </summary>
    public enum GaussioSamplEnum
    {
        /// <summary>
        /// 5个像素平均
        /// </summary>
        Samp5,
        /// <summary>
        /// 9个像素平均
        /// </summary>
        Samp9,
    }

    public enum GaussioQualityEnum
    {
        Simplify,
        Normal,
    }

    #endregion

    public static class ShaderParams
    {
        public static readonly int _ScreenDirectionBlurForCount = Shader.PropertyToID(string.Intern("_ScreenDirectionBlurForCount"));
        public static readonly int _DistortionTexture = Shader.PropertyToID(string.Intern("_DistortionTexture"));
        public static readonly int _ScreenDirectionBlurTexture = Shader.PropertyToID(string.Intern("_ScreenDirectionBlurTexture"));
        public static readonly int _GaussionBlurTexture = Shader.PropertyToID(string.Intern("_GaussionBlurTexture"));
    }

    public class ShaderPassIndex
    {
        /// <summary>
        /// 整合简化
        /// </summary>
        public static int WrapAndBlurSimplified = 0;

        /// <summary>
        /// 扭曲Pass
        /// </summary>
        public static int WrapPass = 1;

        /// <summary>
        /// 高斯模糊Pass
        /// </summary>
        public static int GaussionBlurPass = 2;

        /// <summary>
        /// 径向模糊Pass
        /// </summary>
        public static int ScreenDirectionBlurPass = 3;
    }
}
