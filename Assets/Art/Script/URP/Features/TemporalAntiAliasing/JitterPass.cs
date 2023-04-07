using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class JitterPass : ScriptableRenderPass
{
    const string m_ProfilerTag = "Camera Jitter Pass";
    TemporalAntiAliasingFeature.TemporalData m_TemporalData;

    
    public JitterPass(RenderPassEvent passEvent)
    {
        renderPassEvent = passEvent;
    }

    public void Setup(TemporalAntiAliasingFeature.TemporalData temporalData)
    {
        m_TemporalData = temporalData;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        //Camera camera = renderingData.cameraData.camera;

        CommandBuffer cmd = CommandBufferPool.Get(m_ProfilerTag);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
        cmd.SetViewProjectionMatrices(renderingData.cameraData.camera.worldToCameraMatrix, m_TemporalData.JitterP);

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);        
    }

    // Cleanup any allocated resources that were created during the execution of this render pass.
    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        
    }


    
    
}