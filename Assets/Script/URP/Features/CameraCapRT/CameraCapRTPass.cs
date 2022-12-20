using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CameraCapRTPass : ScriptableRenderPass
{
    string profilerTag = "CameraCapRTPass";
    ProfilingSampler mProfilingSampler;

    LitePostFeature litePostFeature;

    #region//RT相机

    RenderTexture capRenderTextureCamTex = null;

    #endregion

    public CameraCapRTPass(RenderPassEvent passEvent)
    {
        renderPassEvent = passEvent;
        mProfilingSampler = new ProfilingSampler(profilerTag);
    }

    public void Setup(LitePostFeature litePostFeature)
    {
        this.litePostFeature = litePostFeature;
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, mProfilingSampler))
        {
            capRenderTextureCamTex = RenderTexture.GetTemporary(Screen.width, Screen.height);
            cmd.Blit(CameraCapRTUtils.GetExecuteSrcColorTarget(), capRenderTextureCamTex);
            cmd.SetGlobalTexture("_CapRenderTextureCamTex", capRenderTextureCamTex);
        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
        CameraCapRTUtils.ClearExecuteSrcColorTarget();
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        RenderTexture.ReleaseTemporary(capRenderTextureCamTex);
    }

}
