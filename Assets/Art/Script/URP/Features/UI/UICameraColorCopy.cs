using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System.Collections.Generic;
using UnityEngine.Rendering.Universal.Internal;

public class UICameraColorCopy : ScriptableRenderPass
{
    ProfilingSampler mProfilingSampler;

    RenderTargetHandle tempOpaqueTexture;

    Material material;

    LitePostFeature litePostFeature;

    RenderTargetHandle cameraDepthTarget;

    

    public UICameraColorCopy(Material material, RenderPassEvent passEvent)
    {
        this.material = material;
        mProfilingSampler = new ProfilingSampler("UICamera3DBufferLinerToSRGB");
        renderPassEvent = passEvent;
        tempOpaqueTexture.Init("_TempOpaqueColorTextureA");
        cameraDepthTarget.Init("_CameraDepthAttachment");
    }

    public void Setup(LitePostFeature litePostFeature)
    {
        
        this.litePostFeature = litePostFeature;
    }

    RenderTextureDescriptor cameraTextureDescriptor;
    RenderTextureDescriptor uiDescriptor;

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        
        this.cameraTextureDescriptor = cameraTextureDescriptor;
        uiDescriptor = cameraTextureDescriptor;
        uiDescriptor.useMipMap = false;
        uiDescriptor.autoGenerateMips = false;
        uiDescriptor.depthBufferBits = 0;

        uiDescriptor.width = Screen.width;
        uiDescriptor.height = Screen.height;

        uiDescriptor.graphicsFormat = GraphicsFormat.R8G8B8A8_UNorm;
        cmd.GetTemporaryRT(tempOpaqueTexture.id, uiDescriptor, FilterMode.Bilinear);
        
    }

    ShaderTagId m_ShaderTagId = new ShaderTagId(string.Intern("Default UI RP"));

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, mProfilingSampler))
        {
            //Liner to SRGB
            cmd.Blit(UICameraColorCopyUtils.GetExecuteSrcColorTarget(), tempOpaqueTexture.id, material, UICameraColorCopyUtils.ShaderPassIndex.LinerToSRGBPass);
            if (renderingData.cameraData.isSceneViewCamera)
            {
                cmd.SetRenderTarget(tempOpaqueTexture.id, RenderBufferLoadAction.Load, RenderBufferStoreAction.Store, cameraDepthTarget.id, RenderBufferLoadAction.Load, RenderBufferStoreAction.DontCare);
            }
            else
            {
                cmd.SetRenderTarget(tempOpaqueTexture.id, RenderBufferLoadAction.Load, RenderBufferStoreAction.Store, -1, RenderBufferLoadAction.Load, RenderBufferStoreAction.DontCare);
            }
            cmd.ClearRenderTarget(true, false, Color.clear);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            //UI渲染
            SortingCriteria sortingCriteria = SortingCriteria.CommonTransparent;
            DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagId, ref renderingData, sortingCriteria);

            int overrideMaterialPassIndex = 0;
            drawingSettings.overrideMaterial = null;
            drawingSettings.overrideMaterialPassIndex = overrideMaterialPassIndex;

            FilteringSettings m_FilteringSettings;
            RenderQueueRange renderQueueRange = RenderQueueRange.all;
            m_FilteringSettings = new FilteringSettings(renderQueueRange);
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);

            //SRGB to Liner
            cmd.Blit(tempOpaqueTexture.id, UICameraColorCopyUtils.GetExecuteDesColorTarget(), material, UICameraColorCopyUtils.ShaderPassIndex.SRGBToLinerPass);
            
            
        }
        
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
        UICameraColorCopyUtils.ClearExecuteSrcColorTarget();
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(tempOpaqueTexture.id);
    }

    public static readonly int _StaticCapRenderTextureCamTex = Shader.PropertyToID(string.Intern("_StaticCapRenderTextureCamTex"));
}

