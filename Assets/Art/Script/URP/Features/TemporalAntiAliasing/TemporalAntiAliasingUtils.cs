using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System;
using System.IO;

public class TemporalAntiAliasingUtils
{
    public static TemporalAntiAliasingFeature TemporalAntiAliasingFeature;

    public static bool IsTemporalAntiAliasingCamera(CameraData cameraData)
    {
        if (!cameraData.isSceneViewCamera && (cameraData.camera.CompareTag("MainCamera")))
        {
            return true;
        }
        return false;
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

    public static class ShaderParams
    {
        public static readonly int _TAAParams = Shader.PropertyToID(string.Intern("_TAAParams"));
        public static readonly int _PrevTex = Shader.PropertyToID(string.Intern("_PrevTex"));
    }
}
