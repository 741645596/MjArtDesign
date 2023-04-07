using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
    
class TemporalAntiAliasingPass : ScriptableRenderPass
{
    const string m_ProfilerTag = "Temporal Anti Aliasing Pass";
    const string USE_YCOCG = "USE_YCOCG";
    const string USE_MOTIONVECTOR = "USE_MOTIONVECTOR";
    ProfilingSampler m_ProfilingSampler;
    Material m_TAAMaterial;
    RenderTexture[] m_RenderBuffer;
    //RenderTargetIdentifier m_CameraColorTarget;
    int m_IndexWrite = 0;
    int m_IndexRead = 0;
    bool m_First = true;
    TemporalAntiAliasingFeature.TemporalData m_TemporalData;

    public TemporalAntiAliasingPass(RenderPassEvent passEvent, Material material)
    {
        // Pass event
        renderPassEvent = passEvent;

        // Shader
        m_TAAMaterial = material;

        // Profiler
        m_ProfilingSampler = new ProfilingSampler(m_ProfilerTag);
    }

    public void Setup(TemporalAntiAliasingFeature.TemporalData temporalData)
    {
        //m_CameraColorTarget = cameraColorTarget;
        m_TemporalData = temporalData;
        if (temporalData.m_UseMotionVector)
        {
            ConfigureInput(ScriptableRenderPassInput.Motion);
        }
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        EnsureArray(ref m_RenderBuffer, 2);
        
        EnsureRenderTarget(ref m_RenderBuffer[0], cameraTextureDescriptor.width, cameraTextureDescriptor.height, cameraTextureDescriptor.colorFormat, FilterMode.Point);
        EnsureRenderTarget(ref m_RenderBuffer[1], cameraTextureDescriptor.width, cameraTextureDescriptor.height, cameraTextureDescriptor.colorFormat, FilterMode.Point);
    }


    void ConfigMaterial(Camera camera, float renderScale)
    {
        m_TAAMaterial.SetVector(TemporalAntiAliasingUtils.ShaderParams._TAAParams, new Vector4(
               m_TemporalData.FeedBack.x,
               m_TemporalData.FeedBack.y,
               m_TemporalData.ActiveSample.x / (camera.scaledPixelWidth * renderScale),
               m_TemporalData.ActiveSample.y / (camera.scaledPixelHeight * renderScale)));

        m_TAAMaterial.SetTexture(TemporalAntiAliasingUtils.ShaderParams._PrevTex, m_RenderBuffer[m_IndexRead]);
        //m_TAAMaterial.SetKeyword(USE_YCOCG, m_TemporalData.m_UseYCOCG);
        //m_TAAMaterial.SetKeyword(USE_MOTIONVECTOR, m_TemporalData.m_UseMotionVector);
        m_TAAMaterial.DisableKeyword(string.Intern("ENABLE_UVSCALE"));
    }


    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        // Camera
        Camera camera  = renderingData.cameraData.camera;

        // Profiler
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, m_ProfilingSampler))
        {
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            SwapBuffer(ref m_IndexRead, ref m_IndexWrite);
            if (m_First) 
            {
                cmd.Blit(TemporalAntiAliasingUtils.GetExecuteSrcColorTarget(), m_RenderBuffer[m_IndexRead]);
                m_First = false;
            }

            ConfigMaterial(camera, renderingData.cameraData.renderScale);

            m_RenderBuffer[m_IndexWrite].DiscardContents();
            cmd.Blit(TemporalAntiAliasingUtils.GetExecuteSrcColorTarget(), m_RenderBuffer[m_IndexWrite], m_TAAMaterial);
            cmd.Blit(m_RenderBuffer[m_IndexWrite], TemporalAntiAliasingUtils.GetExecuteDesColorTarget());
        }

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
        TemporalAntiAliasingUtils.ClearExecuteSrcColorTarget();
    }


    // Leave this callback empty as we need to store curr & prev render textures.
    // Cleanup is done in "Destory()" function.
    public override void OnCameraCleanup(CommandBuffer cmd)
    {
    }


    void SwapBuffer(ref int read, ref int write)
    {
        read = write;
        write = (++write) % 2;
    }


    void EnsureArray<T>(ref T[] array, int size, T initialValue = default(T))
    {
        if (array == null || array.Length != size)
        {
            array = new T[size];
            for (int i = 0; i != size; i++)
                array[i] = initialValue;
        }
    }


    bool EnsureRenderTarget(ref RenderTexture rt, int width, int height, RenderTextureFormat format, FilterMode filterMode, int depthBits = 0, int antiAliasing = 1)
    {
        if (rt != null && (rt.width != width || rt.height != height || rt.format != format || rt.filterMode != filterMode || rt.antiAliasing != antiAliasing))
        {
            RenderTexture.ReleaseTemporary(rt);
            rt = null;
        }
        if (rt == null)
        {
            rt = RenderTexture.GetTemporary(width, height, depthBits, format, RenderTextureReadWrite.Default, antiAliasing);
            rt.filterMode = filterMode;
            rt.wrapMode = TextureWrapMode.Clamp;
            return true;// new target
        }
        return false;// same target
    }

    public void Destroy()
    {
        if(m_RenderBuffer != null)
        {
            for(int i = 0; i < m_RenderBuffer.Length; i++)
            {
                if (m_RenderBuffer[i] != null)
                {
                    RenderTexture.ReleaseTemporary(m_RenderBuffer[i]);
                }
            }
        }
        m_RenderBuffer = null;
    }
}
