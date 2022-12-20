using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System.Collections.Generic;

public class RayAndScreenVolumeLightPass : ScriptableRenderPass
{
    ProfilingSampler mProfilingSampler;

    Material material;

    RenderTargetIdentifier cameraColorTarget;

    RenderTargetHandle rayVolumeLightTexture;

    /// <summary>
    /// 高斯模糊循环缓存
    /// </summary>
    int[] gaussionBlurs;

    int gaussionForCountMax = 8;

    int gaussionBlurCount = 0;

    GraphicsFormat m_DefaultHDRFormat;

    bool m_UseRGBM;

    GodLightType lightType;

    public void Setup(LitePostFeature litePostFeature,RenderTargetIdentifier cameraColorTarget, GodLightType lightType)
    {
        this.lightType = lightType;
        this.cameraColorTarget = cameraColorTarget;
    }

    public RayAndScreenVolumeLightPass(RenderPassEvent passEvent, Material material)
    {
        this.material = material;
        renderPassEvent = passEvent;//RenderPassEvent.AfterRenderingTransparents
        mProfilingSampler = new ProfilingSampler("RayVolumeLightPass");
        rayVolumeLightTexture.Init("RayVolumeLightTexture");

        gaussionBlurs = new int[gaussionForCountMax];
        for (int i = 0; i < gaussionBlurs.Length; i++)
        {
            gaussionBlurs[i] = Shader.PropertyToID("RayVolumeLightPass_GaussionBlur" + i);
        }

        if (SystemInfo.IsFormatSupported(GraphicsFormat.B10G11R11_UFloatPack32, FormatUsage.Linear | FormatUsage.Render))
        {
            m_DefaultHDRFormat = GraphicsFormat.B10G11R11_UFloatPack32;
            m_UseRGBM = false;
        }
        else
        {
            m_DefaultHDRFormat = QualitySettings.activeColorSpace == ColorSpace.Linear
                ? GraphicsFormat.R8G8B8A8_SRGB
                : GraphicsFormat.R8G8B8A8_UNorm;
            m_UseRGBM = true;
        }
    }

    RenderTextureDescriptor textureDescriptor;

    RenderTextureDescriptor cameraDescriptor;

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        cameraDescriptor = cameraTextureDescriptor;
        //
        textureDescriptor = cameraTextureDescriptor;
        textureDescriptor.width= cameraTextureDescriptor.width >> 1;
        textureDescriptor.height = cameraTextureDescriptor.height >> 1;
        textureDescriptor.depthBufferBits = 0;
        cmd.GetTemporaryRT(rayVolumeLightTexture.id, textureDescriptor);
    }

    Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 mat = Matrix4x4.identity;
        float fov = Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);
        //得到向上向右的位移偏亮 进而推出屏幕面片四个点的发射方向 
        Vector3 up = Vector3.up * fov;
        Vector3 right = Vector3.right * cam.aspect * fov;
        Vector3 TL = (-Vector3.forward + up - right);
        Vector3 TR = (-Vector3.forward + up + right);
        Vector3 BL = (-Vector3.forward - up - right);
        Vector3 BR = (-Vector3.forward - up + right);
        //顺序为左下，右下，左上，右上 不要乱
        mat.SetRow(0, BL);
        mat.SetRow(1, BR);
        mat.SetRow(2, TL);
        mat.SetRow(3, TR);
        return mat;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        VolumeStack stack = VolumeManager.instance.stack;
        RayAndScreenVolumeLight rayVolumeLight = stack.GetComponent<RayAndScreenVolumeLight>();
        if (!rayVolumeLight.IsActive())
        {
            return;
        }
        if (lightType == GodLightType.None)
        {
            return;
        }
        //
        CommandBuffer cmd = CommandBufferPool.Get();
        for (int i = 0; i < gaussionBlurCount; ++i)
        {
            cmd.ReleaseTemporaryRT(gaussionBlurs[i]);
        }
        gaussionBlurCount = 0;
        //
        using (new ProfilingScope(cmd, mProfilingSampler))
        {
            switch (lightType)
            {
                case GodLightType.RayVolumeLight:
                    {
                        ExecuteRayVolumeLight(rayVolumeLight, cmd, context, ref renderingData);
                    }
                    break;
                case GodLightType.ScreenDirectionGodLight:
                    {
                        ExecuteScreenDirectionGodLight(rayVolumeLight, cmd, context, ref renderingData);
                    }
                    break;
            }
        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    void ExecuteRayVolumeLight(RayAndScreenVolumeLight rayVolumeLight, CommandBuffer cmd,ScriptableRenderContext context, ref RenderingData renderingData)
    {
        Matrix4x4 rayArray = CamFrustum(renderingData.cameraData.camera);

        cmd.SetGlobalInt(ShaderParams._RayVolumeLightLength, (int)rayVolumeLight.RayLength.value);
        cmd.SetGlobalInt(ShaderParams._RayVolumeLightStepCount, (int)rayVolumeLight.StepCount.value);
        cmd.SetGlobalFloat(ShaderParams._RayVolumeLightAttenStrength, (float)rayVolumeLight.AttenStrength.value);
        cmd.SetGlobalFloat(ShaderParams._RayVolumeLightMieScatteringG, (float)rayVolumeLight.MieScatteringG.value);
        cmd.SetGlobalFloat(ShaderParams._RayVolumeLightExtingction, (float)rayVolumeLight.Extingction.value);
        if ((bool)rayVolumeLight.RandomNoise.value)
        {

            cmd.EnableShaderKeyword(string.Intern("ENABLE_CREATENOISE_TEX"));
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_CREATENOISE_TEX"));
        }
        if ((bool)rayVolumeLight.AddLights.value)
        {
            cmd.EnableShaderKeyword(string.Intern("ENABLE_ADDLIGHTRAYLIGHT"));
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_ADDLIGHTRAYLIGHT"));
        }
        cmd.SetGlobalMatrix(ShaderParams._RayVolumeLightArray, rayArray);
        cmd.SetGlobalMatrix(ShaderParams._RayVolumeLightCamToWorldMatr, renderingData.cameraData.camera.cameraToWorldMatrix);
        if ((bool)rayVolumeLight.GaussionBlur.value)
        {
            //开启高斯模糊
            cmd.SetGlobalFloat(ShaderParams._RayVolumeLightGaussionBlurSize, (float)rayVolumeLight.GaussionBlurSize.value);
            cmd.EnableShaderKeyword(string.Intern("ENABLE_GAUSSIONBLUR"));
            cmd.Blit(cameraColorTarget, rayVolumeLightTexture.id, material, 0);
            RenderTargetIdentifier lastTexture = rayVolumeLightTexture.id;
            gaussionBlurCount = Mathf.Clamp((int)rayVolumeLight.GaussionBlurCount.value, 1, gaussionForCountMax);
            for (int i = 0; i < gaussionBlurCount; ++i)
            {
                cmd.GetTemporaryRT(gaussionBlurs[i], textureDescriptor.width, textureDescriptor.height, 0, FilterMode.Bilinear, m_DefaultHDRFormat);
                cmd.Blit(lastTexture, gaussionBlurs[i], material, 1);
                lastTexture = gaussionBlurs[i];
            }
            cmd.SetGlobalTexture(ShaderParams._RayVolumeLightBlurTexture, lastTexture);
            cmd.Blit(cameraColorTarget, rayVolumeLightTexture.id, material, 2);
            cmd.Blit(rayVolumeLightTexture.id, cameraColorTarget);
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("ENABLE_GAUSSIONBLUR"));
            cmd.Blit(cameraColorTarget, rayVolumeLightTexture.id, material, 0);
            cmd.Blit(rayVolumeLightTexture.id, cameraColorTarget);
        }
    }

    void ExecuteScreenDirectionGodLight(RayAndScreenVolumeLight rayVolumeLight, CommandBuffer cmd, ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (RenderSettings.sun==null) return;
        RenderPassUtils.SetShaderWorldToScreenPosition(cmd,context, ref renderingData);
        if (m_UseRGBM)
        {
            cmd.EnableShaderKeyword(string.Intern("_USE_RGBM"));
        }
        else
        {
            cmd.DisableShaderKeyword(string.Intern("_USE_RGBM"));
        }

        cmd.SetGlobalFloat(ShaderParams._SunShafeLenght, (float)rayVolumeLight.SunShafeLenght.value);
        cmd.SetGlobalColor(ShaderParams._SunShafeThreshold, (Color)rayVolumeLight.SunShafeThreshold.value);
        cmd.SetGlobalFloat(ShaderParams._SunShafeDepthThreshold, (float)rayVolumeLight.SunShafeDepthThreshold.value);
        cmd.Blit(cameraColorTarget, rayVolumeLightTexture.id, material, 3);
        RenderTargetIdentifier lastTexture = rayVolumeLightTexture.id;

        float ofs = (float)rayVolumeLight.SunShafeBlurRadius.value * 0.00130f;
        int count = (int)rayVolumeLight.SunShafeBlurIterations.value;
        gaussionBlurCount = count * 2;
        int index = 0;
        for (int i = 0; i < count; i++)
        {
            cmd.SetGlobalVector(ShaderParams._SunShafeBlurRadius, Vector2.one * ofs * (i * 2 + 1) * 6);
            
            cmd.GetTemporaryRT(gaussionBlurs[index], textureDescriptor);
            cmd.Blit(lastTexture, gaussionBlurs[index], material, 4);
            lastTexture = gaussionBlurs[index];
            index++;


            cmd.SetGlobalVector(ShaderParams._SunShafeBlurRadius, Vector2.one * ofs * (i * 2 + 2) * 6);
            cmd.GetTemporaryRT(gaussionBlurs[index], textureDescriptor);
            cmd.Blit(lastTexture, gaussionBlurs[index], material, 4);
            lastTexture = gaussionBlurs[index];
            index++;

        }
        cmd.SetGlobalFloat(ShaderParams._SunShaftBlurStrength, (float)rayVolumeLight.SunShaftBlurStrength.value);
        cmd.SetGlobalTexture(ShaderParams._SunShaftBlurTex, lastTexture);
        cmd.Blit(cameraColorTarget, rayVolumeLightTexture.id, material, 5);
        cmd.Blit(rayVolumeLightTexture.id, cameraColorTarget);


        //material.SetFloat(ShaderParams._SunShafeLenght, (float)rayVolumeLight.SunShafeLenght.value);
        //material.SetColor(ShaderParams._SunShafeThreshold, (Color)rayVolumeLight.SunShafeThreshold.value);
        //material.SetFloat(ShaderParams._SunShafeDepthThreshold, (float)rayVolumeLight.SunShafeDepthThreshold.value);

        //gaussionBlurCount = 2;
        //cmd.GetTemporaryRT(gaussionBlurs[0], textureDescriptor);
        //cmd.Blit(lastTexture, gaussionBlurs[0], material, 4);
        //lastTexture = gaussionBlurs[0];

        //cmd.GetTemporaryRT(gaussionBlurs[1], textureDescriptor);
        //cmd.Blit(lastTexture, gaussionBlurs[1], material, 4);
        //lastTexture = gaussionBlurs[1];

        //cmd.GetTemporaryRT(gaussionBlurs[2], textureDescriptor);
        //cmd.Blit(lastTexture, gaussionBlurs[2], material, 4);
        //lastTexture = gaussionBlurs[2];


        //cmd.SetGlobalTexture(ShaderParams._RayVolumeLightBlurTexture, lastTexture);
        //cmd.Blit(cameraColorTarget, rayVolumeLightTexture.id, material, 2);
        //cmd.Blit(rayVolumeLightTexture.id, cameraColorTarget);

        //cmd.Blit(gaussionBlurs[0], cameraColorTarget);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(rayVolumeLightTexture.id);
    }

    public static class ShaderParams
    {
        public static readonly int _RayVolumeLightArray = Shader.PropertyToID(string.Intern("_RayVolumeLightArray"));

        public static readonly int _RayVolumeLightCamToWorldMatr = Shader.PropertyToID(string.Intern("_RayVolumeLightCamToWorldMatr"));

        public static readonly int _RayVolumeLightLength = Shader.PropertyToID(string.Intern("_RayVolumeLightLength"));

        public static readonly int _RayVolumeLightAttenStrength = Shader.PropertyToID(string.Intern("_RayVolumeLightAttenStrength"));

        public static readonly int _RayVolumeLightStepCount = Shader.PropertyToID(string.Intern("_RayVolumeLightStepCount"));

        public static readonly int _RayVolumeLightMieScatteringG = Shader.PropertyToID(string.Intern("_RayVolumeLightMieScatteringG"));

        public static readonly int _RayVolumeLightExtingction = Shader.PropertyToID(string.Intern("_RayVolumeLightExtingction"));

        public static readonly int _RayVolumeLightBlurTexture = Shader.PropertyToID(string.Intern("_RayVolumeLightBlurTexture"));

        public static readonly int _RayVolumeLightGaussionBlurSize = Shader.PropertyToID(string.Intern("_RayVolumeLightGaussionBlurSize"));

        public static readonly int _SunShafeLenght = Shader.PropertyToID(string.Intern("_SunShafeLenght"));

        public static readonly int _SunShafeThreshold = Shader.PropertyToID(string.Intern("_SunShafeThreshold"));

        public static readonly int _SunShafeDepthThreshold = Shader.PropertyToID(string.Intern("_SunShafeDepthThreshold"));

        public static readonly int _SunShafeBlurRadius = Shader.PropertyToID(string.Intern("_SunShafeBlurRadius"));

        public static readonly int _SunShaftBlurTex = Shader.PropertyToID(string.Intern("_SunShaftBlurTex"));

        public static readonly int _SunShaftBlurStrength = Shader.PropertyToID(string.Intern("_SunShaftBlurStrength"));
    }

    public enum GodLightType
    {
        /// <summary>
        /// 关闭体积光
        /// </summary>
        None,
        /// <summary>
        /// 光追体积光，比较耗性能，高配
        /// </summary>
        RayVolumeLight,
        /// <summary>
        /// 后期径向体积光，中配
        /// </summary>
        ScreenDirectionGodLight,
    }

}
