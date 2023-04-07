using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System.Collections.Generic;
using UnityEngine.Rendering.RendererUtils;
using RendererList = UnityEngine.Rendering.RendererUtils.RendererList;
using UnityEngine.Profiling;

public class WrapPass : ScriptableRenderPass
{
    #region//game 相机

    /// <summary>
    /// rg:扭曲 ba:色散  输出序号=0
    /// </summary>
    RenderTargetHandle tempWrapTexture;

    /// <summary>
    /// 径向扭曲  输出序号=1
    /// </summary>
    RenderTargetHandle tempScreenDirectionBlurTexture;

    /// <summary>
    /// 高斯模糊
    /// </summary>
    RenderTargetHandle tempGaussianBlurTexture;

    ///// <summary>
    ///// r>0 -- 开启了扭曲 g>0 -- 开启了色散 b>0 -- 开启了径向模糊  
    ///// 输出序号=2
    ///// </summary>
    //RenderTargetHandle tempResultTextureA;
    //RenderTargetHandle tempResultTextureB;
    //RenderTargetHandle lastTempResultTexture;

    #endregion

    #region//scene 相机

    /// <summary>
    /// rg:扭曲 ba:色散  输出序号=0
    /// </summary>
    RenderTargetHandle tempWrapTexture_View;

    /// <summary>
    /// 径向扭曲  输出序号=1
    /// </summary>
    RenderTargetHandle tempScreenDirectionBlurTexture_View;

    /// <summary>
    /// 高斯模糊
    /// </summary>
    RenderTargetHandle tempGaussianBlurTexture_View;

    ///// <summary>
    ///// r>0 -- 开启了扭曲 g>0 -- 开启了色散 b>0 -- 开启了径向模糊  
    ///// 输出序号=2
    ///// </summary>
    //RenderTargetHandle tempResultTextureA_View;
    //RenderTargetHandle tempResultTextureB_View;
    //RenderTargetHandle lastTempResultTexture_View;

    RenderTargetHandle tempCameraColorTarget;

    #endregion

    /// <summary>
    /// 开关检测
    /// </summary>
    RenderTexture tempResultCopyTexture;

    RenderTargetHandle tempColorTexture;

    bool FindEffect
    {
        get
        {
            if ((WrapAndBlurUtils.OpenScreenDirectionBlur && WrapAndBlurUtils.ScreenDirectionBlurRenderEvent== WrapAndBlurUtils.RenderEventEnum.BeforePostPass) || 
                (WrapAndBlurUtils.OpenGaussionBlur && WrapAndBlurUtils.GaussioRenderEvent== WrapAndBlurUtils.RenderEventEnum.BeforePostPass) || 
                (WrapAndBlurUtils.OpenWrap && WrapAndBlurUtils.WrapRenderEvent == WrapAndBlurUtils.RenderEventEnum.BeforePostPass) || 
                (WrapAndBlurUtils.OpenChromatic && WrapAndBlurUtils.WrapRenderEvent == WrapAndBlurUtils.RenderEventEnum.BeforePostPass))
            {
                return true;
            }
            return false;
        }
    }

    Texture2D tex2d;

    LitePostFeature litePostFeature;

    Camera camera;

    RenderTargetHandle cameraDepthTarget;

    RenderTargetIdentifier cameraColorTarget;

    RenderTargetIdentifier[] runarData = new RenderTargetIdentifier[3];

    /// <summary>
    /// 扭曲RT
    /// </summary>
    RenderTargetIdentifier[] wrapRts = new RenderTargetIdentifier[2];

    /// <summary>
    /// 径向模糊RT
    /// </summary>
    RenderTargetIdentifier[] screenDirectionBlurRts = new RenderTargetIdentifier[2];

    /// <summary>
    /// 高斯模糊RT
    /// </summary>
    RenderTargetIdentifier[] gaussianBlurRts = new RenderTargetIdentifier[2];

    /// <summary>
    /// 清理目标
    /// </summary>
    RenderTargetIdentifier[] clearRTs = new RenderTargetIdentifier[4];

    RenderTargetIdentifier[] clearRTs1 = new RenderTargetIdentifier[1];

    RenderTargetIdentifier[] clearRTs2 = new RenderTargetIdentifier[2];

    RenderTargetIdentifier[] clearRTs3 = new RenderTargetIdentifier[3];

    List<RenderTargetIdentifier> clearRTList = new List<RenderTargetIdentifier>();

    //bool isFirst = false;


    public void Setup(LitePostFeature litePostFeature, Camera camera, RenderTargetIdentifier cameraColorTarget)
    {
        this.cameraColorTarget = cameraColorTarget;
        this.litePostFeature = litePostFeature;
        this.camera = camera;
    }

    public WrapPass(RenderPassEvent passEvent, Material material)
    {
        WrapAndBlurUtils.m_material = material;
        renderPassEvent = passEvent;
        tempWrapTexture.Init("_TempDistortionTexture");
        tempScreenDirectionBlurTexture.Init("_TempScreenDirectionBlurTexture");
        tempGaussianBlurTexture.Init("_TempGaussianBlurTexture");
        //tempResultTextureA.Init("_TempOnePixTextureA");
        //tempResultTextureB.Init("_TempOnePixTextureB");
        //lastTempResultTexture = tempResultTextureA;

        tempWrapTexture_View.Init("_TempDistortionTexture_View");
        tempScreenDirectionBlurTexture_View.Init("_TempScreenDirectionBlurTexture_View");
        tempGaussianBlurTexture_View.Init("_TempGaussianBlurTexture_View");
        

        cameraDepthTarget.Init("_CameraDepthAttachment");

        tempCameraColorTarget.Init("_TempCameraColorTarget");

        tempColorTexture.Init("_TempColorTexture");

        WrapAndBlurUtils.GaussionBlurs = new int[WrapAndBlurUtils.GaussionForCountMax];
        for (int i = 0; i < WrapAndBlurUtils.GaussionForCountMax; i++)
        {
            WrapAndBlurUtils.GaussionBlurs[i] = Shader.PropertyToID("WrapPass_GaussionBlur" + i);
        }

        RenderPipelineManager.beginContextRendering -= OnBeginContextRendering;
        RenderPipelineManager.beginContextRendering += OnBeginContextRendering;
    }

    List<Camera> tempCameraStack = new List<Camera>();

    //Dictionary<Camera, RenderTexture> cameRTS = new Dictionary<Camera, RenderTexture>();

    //Dictionary<Camera, RenderTexture> cameTempRTS = new Dictionary<Camera, RenderTexture>();


    WrapAndBlurUtils.WrapAndBlurCameraData lastWrapAndBlurCameraData;
    List<WrapAndBlurUtils.WrapAndBlurCameraData> tempNotUIList = new List<WrapAndBlurUtils.WrapAndBlurCameraData>();
    void SetCameraCustemData(Camera camera, UniversalAdditionalCameraData universalAdditionalCameraData)
    {
        WrapAndBlurUtils.WrapAndBlurCameraData baseCustemData = WrapAndBlurUtils.GetOneCameraData();
        lastWrapAndBlurCameraData = baseCustemData;
        WrapAndBlurUtils.AddCameraCustemDatas(camera, baseCustemData);
        tempNotUIList.Clear();
        tempNotUIList.Add(baseCustemData);
        List<Camera> cameraStack = universalAdditionalCameraData.cameraStack;
        for (int i=0,listCount= cameraStack.Count;i< listCount;++i)
        {
            if (cameraStack[i]!=null && cameraStack[i].GetUniversalAdditionalCameraData().renderType!=CameraRenderType.Base)
            {
                WrapAndBlurUtils.WrapAndBlurCameraData childCustemData = WrapAndBlurUtils.GetOneCameraData();
                WrapAndBlurUtils.AddCameraCustemDatas(cameraStack[i], childCustemData);
                if (cameraStack[i].CompareTag("UICamera"))
                {
                    for (int j = 0, listCount2 = tempNotUIList.Count; j < listCount2; ++j)
                    {
                        tempNotUIList[j].BackUICamera = cameraStack[i];
                    }
                    childCustemData.BackUICamera= cameraStack[i];
                    tempNotUIList.Clear();
                }
                else
                {
                    tempNotUIList.Add(childCustemData);
                }
                lastWrapAndBlurCameraData.NextCamera = cameraStack[i];
                lastWrapAndBlurCameraData = baseCustemData;
            }
            else
            {
                cameraStack.RemoveAt(i);
                i--;
                listCount--;
            }
        }
    }

    void OnBeginContextRendering(ScriptableRenderContext context, List<Camera> cameras)
    {
        if (!WrapAndBlurUtils.LitePostFeature.isActive || !WrapAndBlurUtils.LitePostFeature.OpenLitWrapAndBlur)
        {
            return;
        }
        tempCameraStack.Clear();
        WrapAndBlurUtils.ClearCameraCustemDatas();
        lastWrapAndBlurCameraData = null;
        for (int i = 0; i < cameras.Count; ++i)
        {
            Camera camera = cameras[i];
            //if (!cameRTS.ContainsKey(camera))
            //{
            //    cameTempRTS.Add(camera, RenderTexture.GetTemporary(w, h, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear));
            //}
            //else
            //{
            //    cameTempRTS.Add(camera, cameRTS[camera]);
            //    cameRTS.Remove(camera);
            //}
            UniversalAdditionalCameraData universalAdditionalCameraData = camera.GetUniversalAdditionalCameraData();
            if (universalAdditionalCameraData.renderType == CameraRenderType.Base)
            {
                if (lastWrapAndBlurCameraData != null)
                {
                    lastWrapAndBlurCameraData.NextCamera = camera;
                    lastWrapAndBlurCameraData.NextIsBaseCamera = true;
                    if (camera.CompareTag("UICamera"))
                    {
                        lastWrapAndBlurCameraData.BackUICamera = camera;
                    }
                }
                SetCameraCustemData(camera, universalAdditionalCameraData);
            }
        }

        //Dictionary<Camera, RenderTexture>.Enumerator enumerator = cameRTS.GetEnumerator();
        //while (enumerator.MoveNext())
        //{
        //    RenderTexture.ReleaseTemporary(enumerator.Current.Value);
        //}
        //cameRTS.Clear();
        //Dictionary<Camera, RenderTexture> tempDIC = cameRTS;
        //cameRTS = cameTempRTS;
        //cameTempRTS = tempDIC;
    }

    RenderTextureDescriptor cameraTextureDescriptor;

    RenderTextureDescriptor opaqueDesc;

    bool useLitWrapZtest;

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {

        if (litePostFeature.UseWrapAndBlurZtest && Application.platform != RuntimePlatform.WindowsPlayer && Application.platform != RuntimePlatform.WindowsEditor)
        {
            useLitWrapZtest = false;
        }

        this.cameraTextureDescriptor = cameraTextureDescriptor;
        this.opaqueDesc = cameraTextureDescriptor;
        opaqueDesc.vrUsage = cameraTextureDescriptor.vrUsage;
        opaqueDesc.useMipMap = false;
        opaqueDesc.autoGenerateMips = false;
        opaqueDesc.depthBufferBits = cameraTextureDescriptor.depthBufferBits;

        if (useLitWrapZtest)
        {
            opaqueDesc.width = Screen.width;
            opaqueDesc.height = Screen.height;
        }
        else
        {
            opaqueDesc.width = Screen.width >> 2;
            opaqueDesc.height = Screen.height >> 2;
        }
        opaqueDesc.graphicsFormat = GraphicsFormat.R8G8B8A8_UNorm;
    }

    void DrawTargetRenderers(int layerMask,RenderTargetIdentifier rt, ShaderTagId tagId, CommandBuffer cmd,ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.cameraType == CameraType.SceneView)
        {
            if (useLitWrapZtest)
            {
                cmd.SetRenderTarget(rt, new RenderTargetIdentifier(cameraDepthTarget.id));
            }
            else
            {
                cmd.SetRenderTarget(rt, new RenderTargetIdentifier(cameraDepthTarget.id));
            }
        }
        else
        {
            if (useLitWrapZtest)
            {
                cmd.SetRenderTarget(rt, new RenderTargetIdentifier(cameraDepthTarget.id));
            }
            else
            {
                cmd.SetRenderTarget(rt, new RenderTargetIdentifier(-1));
            }
        }
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
        //
        SortingCriteria sortingCriteria = SortingCriteria.CommonTransparent;
        DrawingSettings drawingSettings = CreateDrawingSettings(tagId, ref renderingData, sortingCriteria);
        int overrideMaterialPassIndex = 0;
        drawingSettings.overrideMaterial = null;
        drawingSettings.overrideMaterialPassIndex = overrideMaterialPassIndex;
        FilteringSettings m_FilteringSettings;
        RenderQueueRange renderQueueRange = RenderQueueRange.all;
        //int layerMask = litePostFeature.WrapLayerMask.value;
        m_FilteringSettings = new FilteringSettings(renderQueueRange, layerMask);
        context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
    }

    int gaussionBlurCount;

    //控制扭曲，模糊的检测精度，数值越大，检测的间隔像素距离越小，精度越高，在屏幕中占比越小的效果越容易检测到
    int w = 32;

    int h = 8;

    RenderTargetIdentifier[] clearTargetArray;

    ShaderTagId shaderTagIdWrap = new ShaderTagId(string.Intern("WrapPass"));

    ShaderTagId shaderTagIdScreenDirectionBlur = new ShaderTagId(string.Intern("ScreenDirectionBlurPass"));

    ShaderTagId shaderTagIdGaussianBlur = new ShaderTagId(string.Intern("GaussianBlurPass"));
    

    List<RendererList> _activeRendererLists = new List<RendererList>();
    


    void DrawTargetRenderersList(in RendererList rendererList, RenderTargetIdentifier rt, CommandBuffer cmd, ScriptableRenderContext context, ref RenderingData renderingData)
    {

        RenderTargetIdentifier renderTargetId;
        if (renderingData.cameraData.cameraType != CameraType.SceneView && !useLitWrapZtest)
        {
            renderTargetId = new RenderTargetIdentifier(-1);
        }
        else
        {
            renderTargetId = new RenderTargetIdentifier(cameraDepthTarget.id);
        }
        cmd.SetRenderTarget(rt, renderTargetId);

        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();


        cmd.DrawRendererList(rendererList);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
    }

    RendererList PrepareRendererList(int layerMask, ShaderTagId tagId, ScriptableRenderContext context, ref RenderingData renderingData)
    {
        var rendererListDesc = new UnityEngine.Rendering.RendererUtils.RendererListDesc(tagId, renderingData.cullResults, renderingData.cameraData.camera);
        rendererListDesc.renderQueueRange = RenderQueueRange.all;
        rendererListDesc.sortingCriteria = SortingCriteria.CommonTransparent;
        rendererListDesc.rendererConfiguration = PerObjectData.None;
        rendererListDesc.layerMask = layerMask;
        rendererListDesc.overrideMaterialPassIndex = 0;

        var rendererList = context.CreateRendererList(rendererListDesc);
        return rendererList;
    }

    bool isCallled(ScriptableRenderContext context, in RendererList rendererList)
    {
        var rendererListStatus = context.QueryRendererListStatus(rendererList);
        return !(rendererListStatus == RendererListStatus.kRendererListEmpty || rendererListStatus == RendererListStatus.kRendererListInvalid);




    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (!WrapAndBlurUtils.LitePostFeature.isActive || !WrapAndBlurUtils.LitePostFeature.OpenLitWrapAndBlur)
        {
            return;
        }


        Profiler.BeginSample("test wrapPass");
        _activeRendererLists.Clear();
        RendererList wrapRendererList = new RendererList();
        RendererList screenDirectionRendererList = new RendererList();
        RendererList gaussianRendererList = new RendererList();

        if (WrapAndBlurUtils.LitePostFeature.OpenLitWrap)
        {
            wrapRendererList = PrepareRendererList(litePostFeature.WrapLayerMask.value, shaderTagIdWrap, context, ref renderingData);
            _activeRendererLists.Add(wrapRendererList);
            
        }

        if (WrapAndBlurUtils.LitePostFeature.OpenLitScreenDirectionBlur)
        {
            screenDirectionRendererList = PrepareRendererList(litePostFeature.ScreenDirectionBlurLayerMask.value, shaderTagIdScreenDirectionBlur, context, ref renderingData);
            _activeRendererLists.Add(screenDirectionRendererList);
        }

        if (WrapAndBlurUtils.LitePostFeature.OpenLitGaussioBlur)
        {
            gaussianRendererList = PrepareRendererList(litePostFeature.GaussioBlurLayerMask.value, shaderTagIdGaussianBlur, context, ref renderingData);
            _activeRendererLists.Add(gaussianRendererList);
        }

        context.PrepareRendererListsAsync(_activeRendererLists);
        WrapAndBlurUtils.OpenWrap = false;
        WrapAndBlurUtils.OpenChromatic = false;
        WrapAndBlurUtils.OpenScreenDirectionBlur = false;
        WrapAndBlurUtils.OpenGaussionBlur = false;

        if(WrapAndBlurUtils.LitePostFeature.OpenLitWrap && isCallled(context, in wrapRendererList))
        {
            WrapAndBlurUtils.OpenWrap = true;
        }

        if (WrapAndBlurUtils.LitePostFeature.OpenLitScreenDirectionBlur && isCallled(context, in screenDirectionRendererList))
        {
            WrapAndBlurUtils.OpenScreenDirectionBlur = true;
        }

        if (WrapAndBlurUtils.LitePostFeature.OpenLitGaussioBlur && isCallled(context, in gaussianRendererList))
        {
            WrapAndBlurUtils.OpenGaussionBlur = true;
        }
        Profiler.EndSample();
        if (WrapAndBlurUtils.OpenWrap == false && WrapAndBlurUtils.OpenScreenDirectionBlur == false && WrapAndBlurUtils.OpenGaussionBlur == false)
        {
            return;
        }

        

        CommandBuffer cmd = CommandBufferPool.Get(string.Intern("Wrap And Blur Pass"));
        cmd.ReleaseTemporaryRT(tempColorTexture.id);
        cmd.GetTemporaryRT(tempColorTexture.id, cameraTextureDescriptor, FilterMode.Bilinear);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
        clearRTList.Clear();

        for (int i = 0; i < gaussionBlurCount; ++i)
        {
            cmd.ReleaseTemporaryRT(WrapAndBlurUtils.GaussionBlurs[i]);
        }
        gaussionBlurCount = 0;

        bool clearWrap = false;
        bool clearGaussion = false;
        bool clearScreenDirection = false;
        WrapAndBlurUtils.RTNeedFlagClear(renderingData.cameraData.camera, WrapAndBlurUtils.WrapRenderEvent, WrapAndBlurUtils.GaussioRenderEvent, WrapAndBlurUtils.ScreenDirectionBlurRenderEvent,
            ref clearWrap, ref clearGaussion, ref clearScreenDirection);

        if (renderingData.cameraData.cameraType == CameraType.SceneView)
        {
            cmd.ReleaseTemporaryRT(tempCameraColorTarget.id);
            cmd.GetTemporaryRT(tempCameraColorTarget.id, cameraTextureDescriptor, FilterMode.Bilinear);

            cmd.BeginSample(string.Intern("Scenes Lite Post-Wrap Pass"));
            cmd.Blit(cameraColorTarget, tempCameraColorTarget.id);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            cmd.Blit(tempCameraColorTarget.id, cameraColorTarget);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            //


            if (clearWrap)
            {
                cmd.ReleaseTemporaryRT(tempWrapTexture_View.id);
                cmd.GetTemporaryRT(tempWrapTexture_View.id, opaqueDesc, FilterMode.Bilinear);
                clearRTList.Add(tempWrapTexture_View.id);
            }
            wrapRts[0] = tempWrapTexture_View.id;
            

            if (clearScreenDirection)
            {
                cmd.ReleaseTemporaryRT(tempScreenDirectionBlurTexture_View.id);
                cmd.GetTemporaryRT(tempScreenDirectionBlurTexture_View.id, opaqueDesc, FilterMode.Bilinear);
                clearRTList.Add(tempScreenDirectionBlurTexture_View.id);
            }
            screenDirectionBlurRts[0] = tempScreenDirectionBlurTexture_View.id;
            

            if (clearGaussion)
            {
                cmd.ReleaseTemporaryRT(tempGaussianBlurTexture_View.id);
                cmd.GetTemporaryRT(tempGaussianBlurTexture_View.id, opaqueDesc, FilterMode.Bilinear);
                clearRTList.Add(tempGaussianBlurTexture_View.id);
            }
            gaussianBlurRts[0] = tempGaussianBlurTexture_View.id;
            

            clearTargetArray = null;
            switch (clearRTList.Count)
            {
                case 1:
                    {
                        clearTargetArray = clearRTs1;
                    }
                    break;
                case 2:
                    {
                        clearTargetArray = clearRTs2;
                    }
                    break;
                case 3:
                    {
                        clearTargetArray = clearRTs3;
                    }
                    break;
                case 4:
                    {
                        clearTargetArray = clearRTs;
                    }
                    break;
            }
            for (int i = 0, listCount = clearRTList.Count; i < listCount; ++i)
            {
                clearTargetArray[i] = clearRTList[i];
            }

            if (clearTargetArray != null)
            {
                if (useLitWrapZtest)
                {
                    cmd.SetRenderTarget(clearTargetArray, cameraDepthTarget.id);
                    cmd.ClearRenderTarget(false, true, Color.clear);
                }
                else
                {
                    cmd.SetRenderTarget(clearTargetArray, cameraDepthTarget.id);
                    cmd.ClearRenderTarget(true, true, Color.clear);
                }
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
            }

            if (WrapAndBlurUtils.LitePostFeature.OpenLitWrap)
            {
                DrawTargetRenderersList(wrapRendererList, tempWrapTexture_View.id, cmd, context, ref renderingData);
            }
            if (WrapAndBlurUtils.LitePostFeature.OpenLitScreenDirectionBlur)
            {
                DrawTargetRenderersList(screenDirectionRendererList, tempScreenDirectionBlurTexture_View.id, cmd, context, ref renderingData);
            }
            if (WrapAndBlurUtils.LitePostFeature.OpenLitGaussioBlur)
            {
                DrawTargetRenderersList(gaussianRendererList, tempGaussianBlurTexture_View.id, cmd, context, ref renderingData);
            }

            cmd.Blit(cameraColorTarget, tempWrapTexture_View.id);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            cmd.Blit(tempCameraColorTarget.id, cameraColorTarget);
            cmd.EndSample(string.Intern("Scenes Lite Post-Wrap Pass"));
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            cmd.SetGlobalTexture(WrapAndBlurUtils.ShaderParams._DistortionTexture, tempWrapTexture_View.id);
            cmd.SetGlobalTexture(WrapAndBlurUtils.ShaderParams._ScreenDirectionBlurTexture, tempScreenDirectionBlurTexture_View.id);
            cmd.SetGlobalTexture(WrapAndBlurUtils.ShaderParams._GaussionBlurTexture, tempGaussianBlurTexture_View.id);

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            if (FindEffect)
            {
                WrapAndBlurUtils.FreskMaterialKeys(WrapAndBlurUtils.RenderEventEnum.BeforePostPass, cmd);
                cmd.BeginSample(string.Intern("WrapAndBlur Wrap Pass"));
                cmd.Blit(cameraColorTarget, tempColorTexture.id, WrapAndBlurUtils.m_material, 0);
                cmd.Blit(tempColorTexture.id, cameraColorTarget);
                cmd.EndSample(string.Intern("WrapAndBlur Wrap Pass"));
                WrapAndBlurUtils.ClearMaterialKeys(cmd);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
            }

            CommandBufferPool.Release(cmd);

        }
        else
        {

            if (clearWrap)
            {
                cmd.ReleaseTemporaryRT(tempWrapTexture.id);
                cmd.GetTemporaryRT(tempWrapTexture.id, opaqueDesc, FilterMode.Bilinear);
                clearRTList.Add(tempWrapTexture.id);
            }
            wrapRts[0] = tempWrapTexture.id;
            //wrapRts[1] = lastTempResultTexture.id;

            if (clearScreenDirection)
            {
                RenderTextureDescriptor dd = opaqueDesc;
                dd.graphicsFormat = GraphicsFormat.R8G8B8A8_SRGB;
                cmd.ReleaseTemporaryRT(tempScreenDirectionBlurTexture.id);
                cmd.GetTemporaryRT(tempScreenDirectionBlurTexture.id, dd, FilterMode.Bilinear);
                clearRTList.Add(tempScreenDirectionBlurTexture.id);
            }
            screenDirectionBlurRts[0] = tempScreenDirectionBlurTexture.id;
            //screenDirectionBlurRts[1] = lastTempResultTexture.id;

            if (clearGaussion)
            {
                cmd.ReleaseTemporaryRT(tempGaussianBlurTexture.id);
                cmd.GetTemporaryRT(tempGaussianBlurTexture.id, opaqueDesc, FilterMode.Bilinear);
                clearRTList.Add(tempGaussianBlurTexture.id);
            }
            gaussianBlurRts[0] = tempGaussianBlurTexture.id;
            //gaussianBlurRts[1] = lastTempResultTexture.id;

            clearTargetArray = null;
            switch (clearRTList.Count)
            {
                case 1:
                    {
                        clearTargetArray = clearRTs1;
                    }
                    break;
                case 2:
                    {
                        clearTargetArray = clearRTs2;
                    }
                    break;
                case 3:
                    {
                        clearTargetArray = clearRTs3;
                    }
                    break;
                case 4:
                    {
                        clearTargetArray = clearRTs;
                    }
                    break;
            }
            for (int i = 0, listCount = clearRTList.Count; i < listCount; ++i)
            {
                clearTargetArray[i] = clearRTList[i];
            }

            if (clearTargetArray != null)
            {
                if (useLitWrapZtest)
                {
                    cmd.SetRenderTarget(clearTargetArray, cameraDepthTarget.id);
                    cmd.ClearRenderTarget(false, true, Color.clear);
                }
                else
                {
                    cmd.SetRenderTarget(clearTargetArray, -1);
                    cmd.ClearRenderTarget(true, true, Color.clear);
                }
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
            }

            if (WrapAndBlurUtils.LitePostFeature.OpenLitWrap)
            {
                //DrawTargetRenderers(litePostFeature.WrapLayerMask.value, tempWrapTexture.id, shaderTagIdWrap, cmd, context, ref renderingData);
                DrawTargetRenderersList(wrapRendererList, tempWrapTexture.id, cmd, context, ref renderingData);
            }
            if (WrapAndBlurUtils.LitePostFeature.OpenLitScreenDirectionBlur)
            {
                //DrawTargetRenderers(litePostFeature.GaussioBlurLayerMask.value, tempScreenDirectionBlurTexture.id, shaderTagIdScreenDirectionBlur, cmd, context, ref renderingData);
                DrawTargetRenderersList(screenDirectionRendererList, tempScreenDirectionBlurTexture.id, cmd, context, ref renderingData);
            }
            if (WrapAndBlurUtils.LitePostFeature.OpenLitGaussioBlur)
            {
                //DrawTargetRenderers(litePostFeature.ScreenDirectionBlurLayerMask.value, tempGaussianBlurTexture.id, shaderTagIdGaussianBlur, cmd, context, ref renderingData);
                DrawTargetRenderersList(gaussianRendererList, tempGaussianBlurTexture.id, cmd, context, ref renderingData);
            }

            //RenderTexture writeTarget = null;
            //cameRTS.TryGetValue(renderingData.cameraData.camera, out writeTarget);
            //if (writeTarget != null)
            //{
            //    cmd.Blit(lastTempResultTexture.id, writeTarget);
            //}

            //
            //cmd.EndSample(string.Intern("LitePostWrapPass"));
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            //
            cmd.SetGlobalTexture(WrapAndBlurUtils.ShaderParams._DistortionTexture, tempWrapTexture.id);
            cmd.SetGlobalTexture(WrapAndBlurUtils.ShaderParams._ScreenDirectionBlurTexture, tempScreenDirectionBlurTexture.id);
            cmd.SetGlobalTexture(WrapAndBlurUtils.ShaderParams._GaussionBlurTexture, tempGaussianBlurTexture.id);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();


            bool needBlitToCameraColorTarget = false;
            LitePostFeature.LitPostPassEnum nextStep = WrapAndBlurUtils.NextPostStep(renderingData.cameraData, ref needBlitToCameraColorTarget);

            if (FindEffect)
            {
                WrapAndBlurUtils.FreskMaterialKeys(WrapAndBlurUtils.RenderEventEnum.BeforePostPass, cmd, renderingData.cameraData.camera);
                cmd.BeginSample(string.Intern("WrapAndBlur Wrap Pass"));
                if (WrapAndBlurUtils.GaussioQuality == WrapAndBlurUtils.GaussioQualityEnum.Simplify)
                {
                    int screenDirectionBlurForCount = Mathf.Clamp(WrapAndBlurUtils.ScreenDirectionBlurForCount, 1, 6);
                    WrapAndBlurUtils.m_material.SetInt(WrapAndBlurUtils.ShaderParams._ScreenDirectionBlurForCount, screenDirectionBlurForCount);
                    cmd.Blit(cameraColorTarget, tempColorTexture.id, WrapAndBlurUtils.m_material, 0);
                    SetColorTarget(cmd, nextStep, tempColorTexture.id, cameraColorTarget, needBlitToCameraColorTarget);
                }
                else
                {
                    RenderTargetIdentifier lastId = cameraColorTarget;
                    if (WrapAndBlurUtils.OpenWrap || WrapAndBlurUtils.OpenChromatic && WrapAndBlurUtils.WrapRenderEvent == WrapAndBlurUtils.RenderEventEnum.BeforePostPass)
                    {
                        cmd.Blit(cameraColorTarget, tempColorTexture.id, WrapAndBlurUtils.m_material, 1);
                        lastId = tempColorTexture.id;
                    }
                    if (WrapAndBlurUtils.OpenGaussionBlur && WrapAndBlurUtils.GaussioRenderEvent == WrapAndBlurUtils.RenderEventEnum.BeforePostPass)
                    {
                        gaussionBlurCount = Mathf.Clamp(WrapAndBlurUtils.GaussionForCount, 1, WrapAndBlurUtils.GaussionForCountMax);
                        for (int i = 0; i < gaussionBlurCount; ++i)
                        {
                            cmd.GetTemporaryRT(WrapAndBlurUtils.GaussionBlurs[i], cameraTextureDescriptor.width, cameraTextureDescriptor.height, 0, FilterMode.Bilinear, LitePostUtils.BloomExecuteData.m_DefaultHDRFormat);
                            cmd.Blit(lastId, WrapAndBlurUtils.GaussionBlurs[i], WrapAndBlurUtils.m_material, 2);
                            lastId = WrapAndBlurUtils.GaussionBlurs[i];
                        }
                    }
                    if (WrapAndBlurUtils.OpenScreenDirectionBlur && WrapAndBlurUtils.ScreenDirectionBlurRenderEvent == WrapAndBlurUtils.RenderEventEnum.BeforePostPass)
                    {
                        int screenDirectionBlurForCount = Mathf.Clamp(WrapAndBlurUtils.ScreenDirectionBlurForCount, 1, 16);
                        WrapAndBlurUtils.m_material.SetInt(WrapAndBlurUtils.ShaderParams._ScreenDirectionBlurForCount, screenDirectionBlurForCount);
                        if (lastId == cameraColorTarget)
                        {
                            cmd.Blit(lastId, tempColorTexture.id, WrapAndBlurUtils.m_material, 3);
                            lastId = tempColorTexture.id;
                        }
                        else
                        {
                            cmd.Blit(lastId, cameraColorTarget, WrapAndBlurUtils.m_material, 3);
                            lastId = cameraColorTarget;
                        }
                    }
                    if (lastId != cameraColorTarget)
                    {
                        SetColorTarget(cmd, nextStep, lastId, cameraColorTarget, needBlitToCameraColorTarget);
                    }
                }
                cmd.EndSample(string.Intern("WrapAndBlur Wrap Pass"));
                WrapAndBlurUtils.ClearMaterialKeys(cmd);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
            }

            CommandBufferPool.Release(cmd);
        }
        WrapAndBlurUtils.ClearExecuteSrcColorTarget();
    }

    void SetColorTarget(CommandBuffer cmd ,LitePostFeature.LitPostPassEnum nextStep, RenderTargetIdentifier id, RenderTargetIdentifier cameraColorTarget, bool needBlitToCameraColorTarget)
    {
        if (cameraColorTarget==id)
        {
            return;
        }
        if (needBlitToCameraColorTarget)
        {
            cmd.Blit(id, cameraColorTarget);
            return;
        }
        switch (nextStep)
        {
            case LitePostFeature.LitPostPassEnum.None:
                {
                    cmd.Blit(id, cameraColorTarget);
                }
                break;
            case LitePostFeature.LitPostPassEnum.WrapAndBlurPass:
                {
                    WrapAndBlurUtils.SetExecuteSrcColorTarget(id);
                }
                break;
            case LitePostFeature.LitPostPassEnum.UICameraColorCopyPass:
                {
                    UICameraColorCopyUtils.SetExecuteSrcColorTarget(id);
                }
                break;
            case LitePostFeature.LitPostPassEnum.CameraCapRTPass:
                {
                    CameraCapRTUtils.SetExecuteSrcColorTarget(id);
                }
                break;
            case LitePostFeature.LitPostPassEnum.LitePostPass:
                {
                    LitePostUtils.SetExecuteSrcColorTarget(id);
                }
                break;
            case LitePostFeature.LitPostPassEnum.TemporalAntiAliasingPass:
                {
                   TemporalAntiAliasingUtils.SetExecuteSrcColorTarget(id);
                }
                break;
        }
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {

    }

}
