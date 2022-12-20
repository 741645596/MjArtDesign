using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System;
using System.IO;
using UnityEngine.XR;

public class RenderPassUtils
{
    /// <summary>
    /// 设置PostProcess.hlsl中的 VP 矩阵，用于计算世界到屏幕坐标
    /// </summary>
    /// <param name="context"></param>
    /// <param name="renderingData"></param>
    public static void SetShaderWorldToScreenPosition(CommandBuffer cmd,ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CameraData cameraData = renderingData.cameraData;
        Camera camera = cameraData.camera;
        if (camera == null) { return; }
        //if (XRSettings.enabled)
        //{
        //    context.StartMultiEye(camera);
        //}
        #if ENABLE_VR && ENABLE_XR_MODULE
            int eyeCount = renderingData.cameraData.xr.enabled && renderingData.cameraData.xr.singlePassEnabled ? 2 : 1;
        #else
            int eyeCount = 1;
        #endif
        Matrix4x4[] cameraMatrices = new Matrix4x4[2];
        for (int eyeIndex = 0; eyeIndex < eyeCount; eyeIndex++)
        {
            Matrix4x4 view = renderingData.cameraData.GetViewMatrix(eyeIndex);
            Matrix4x4 proj = renderingData.cameraData.GetProjectionMatrix(eyeIndex);
            cameraMatrices[eyeIndex] = proj * view;
        }
        cmd.SetGlobalMatrixArray(ShaderParams._RenderPassCameraVP, cameraMatrices);
    }

    public static class ShaderParams
    {

        public static readonly int _RenderPassCameraVP = Shader.PropertyToID(string.Intern("_RenderPassCameraVP"));

    }


}
