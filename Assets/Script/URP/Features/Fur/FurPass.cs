using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class FurPass : ScriptableRenderPass
{
    ProfilingSampler mProfilingSampler;

    RenderTargetHandle tempOpaqueTexture;

    RenderTargetHandle cameraDepthTarget;

    LitePostFeature litePostFeature;

    float furMaxLenght;

    public FurPass(RenderPassEvent passEvent)
    {
        mProfilingSampler = new ProfilingSampler("FurPassSampler");
        renderPassEvent = passEvent;
        tempOpaqueTexture.Init("_TempOpaqueColorTextureA");
        cameraDepthTarget.Init("_CameraDepthAttachment");
    }

    public void Setup(LitePostFeature litePostFeature, float furMaxLenght)
    {
        this.litePostFeature = litePostFeature;
        this.furMaxLenght = furMaxLenght;
    }

    RenderTextureDescriptor cameraTextureDescriptor;

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        this.cameraTextureDescriptor = cameraTextureDescriptor;
    }

    ShaderTagId m_ShaderTagIdClip = new ShaderTagId(string.Intern("Translucence Fur Clip"));
    ShaderTagId m_ShaderTagId = new ShaderTagId(string.Intern("Translucence Fur"));

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        //int count = (int)(furMaxLenght / 0.005f);
        int count = (int)(furMaxLenght / 0.004f);
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, mProfilingSampler))
        {
            for (int i = 0; i < count; ++i)
            {
                float lerpValue = (float)i / count;
                float alphaMul = Mathf.Lerp(2, 0.9f, 1);
                cmd.SetGlobalFloat("_TranslucenceFurAlphaMul", alphaMul);
                cmd.SetGlobalFloat("_TranslucenceFurStep", (float)i / count);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                //Fur渲染
                SortingCriteria sortingCriteria = SortingCriteria.CommonTransparent;
                DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagId, ref renderingData, sortingCriteria);

                int overrideMaterialPassIndex = 0;
                drawingSettings.overrideMaterial = null;
                drawingSettings.overrideMaterialPassIndex = overrideMaterialPassIndex;

                FilteringSettings m_FilteringSettings;
                RenderQueueRange renderQueueRange = RenderQueueRange.all;
                m_FilteringSettings = new FilteringSettings(renderQueueRange);
                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);

            }
        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(tempOpaqueTexture.id);
    }
}
