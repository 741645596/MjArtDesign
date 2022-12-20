using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class EditorTextureChromaticPass : ScriptableRenderPass
{

    const string m_ProfilerTag = "EditorTextureChromaticPass";

    ProfilingSampler m_ProfilingSampler;

    public static Material TargetMaterial;

    public static Texture2D MainTex;

    public static RenderTexture TargetRenderTexture;

    public EditorTextureChromaticPass(RenderPassEvent passEvent)
    {
        renderPassEvent = passEvent;
        m_ProfilingSampler = new ProfilingSampler(m_ProfilerTag);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, m_ProfilingSampler))
        {
            cmd.Blit(MainTex, TargetRenderTexture, TargetMaterial, 0);
        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
        LitePostFeature.EditorTextureChromaticOpen = false;
    }


}
