using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
//using Sirenix.OdinInspector;

public class TemporalAntiAliasingFeature : ScriptableRendererFeature
{

    public Shader m_TAAShader;
    [Header("颜色空间，效果会好一些")]
    public bool m_UseYCOCG = false;
    [Header("运动时候的效果提升")]
    public bool m_UseMotionVector = false;        

    [HideInInspector]
    [SerializeField]
    protected float m_JitterScale = 1.0f;

    [HideInInspector]
    [SerializeField]
    protected float m_FeedBackMin = 0.88f;

    [HideInInspector]
    [SerializeField]
    protected float m_FeedBackMax = 0.97f;

    int m_FrameIndex = 0;
    // 0: Camera Jitter Pass
    JitterPass m_JitterPass;
    // 1: Anit-Aliasing Pass
    TemporalAntiAliasingPass m_TAAPass;
    TemporalData m_TemporalData;
    Material m_TAAMaterial;

    public class TemporalData
    {
        public Vector4 ActiveSample = Vector4.zero; // xy = current sample, zw = previous sample
        public Matrix4x4 JitterP = Matrix4x4.identity;
        public Matrix4x4 currVP = Matrix4x4.identity;
        public Matrix4x4 LastVP = Matrix4x4.identity;

        // Feedback
        public Vector2 FeedBack = Vector2.zero;

        // Halton Sequence
        public bool m_First = true;
        public bool m_UseYCOCG = false;
        public bool m_UseMotionVector = false;
        public int m_LastUpdateFrame = -1;
        public TemporalData()
        {
        }
    }

    /// <inheritdoc/>
    public override void Create()
    {
        TemporalAntiAliasingUtils.TemporalAntiAliasingFeature = this;
        if (m_TAAShader != null)
        {
            m_TAAMaterial = CoreUtils.CreateEngineMaterial(m_TAAShader);
            if (m_TAAMaterial != null)
            {
                m_JitterPass = new JitterPass(RenderPassEvent.BeforeRenderingOpaques);
                //m_TAAPass = new TemporalAntiAliasingPass(RenderPassEvent.BeforeRenderingPostProcessing-1, m_TAAMaterial);
                m_TAAPass = new TemporalAntiAliasingPass(RenderPassEvent.AfterRenderingPostProcessing + 11, m_TAAMaterial);
            }
        }

        m_TemporalData = new TemporalData();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // if (OverdrawForURP.OverdrawRendererFeature.Open)
        // {
        //     return;
        // }
        Camera camera = renderingData.cameraData.camera;
        if (TemporalAntiAliasingUtils.IsTemporalAntiAliasingCamera(renderingData.cameraData))
        {
            TemporalAntiAliasingUtils.InitColorTarget(renderer, ref renderingData);
            const int kMaxSampleCount = 8;
            if (++m_FrameIndex >= kMaxSampleCount)
                m_FrameIndex = 0;

            UpdateTemporalData(m_TemporalData, renderingData.cameraData.renderScale, camera);

            if (m_JitterPass != null)
            {
                m_JitterPass.Setup(m_TemporalData);
                renderer.EnqueuePass(m_JitterPass);
            }

            if (m_TAAPass != null)
            {
                //m_TAAPass.Setup(renderer.cameraColorTarget, m_TemporalData);
                m_TAAPass.Setup(m_TemporalData);
                renderer.EnqueuePass(m_TAAPass);
            }
        }
    }

    void UpdateTemporalData(TemporalData temporalData, float renderScale, Camera camera)
    {
        // Update offset & matrix
        if (temporalData.m_First)
        {
            temporalData.ActiveSample = Vector4.zero;
            temporalData.m_First = false;

            temporalData.JitterP = camera.projectionMatrix;
            var gpuProj = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true);
            var gpuView = camera.worldToCameraMatrix;
            var gpuVP = gpuProj * gpuView;
            temporalData.currVP = temporalData.LastVP = gpuVP;
        }
        else
        {
            var jitterX = m_JitterScale * (HaltonSequence.Get((m_FrameIndex & 1023) + 1, 2) - 0.5f);
            var jitterY = m_JitterScale * (HaltonSequence.Get((m_FrameIndex & 1023) + 1, 3) - 0.5f);
            
            temporalData.ActiveSample.z = temporalData.ActiveSample.x;
            temporalData.ActiveSample.w = temporalData.ActiveSample.y;
            temporalData.ActiveSample.x = jitterX;
            temporalData.ActiveSample.y = jitterY;

            if (temporalData.m_LastUpdateFrame != Time.frameCount)
            {
                temporalData.LastVP = temporalData.currVP;
            }

            var gpuProj = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true); // Had to change this from 'false'
            var gpuView = camera.worldToCameraMatrix;
            var gpuVP = gpuProj * gpuView;
            temporalData.currVP = gpuVP;
            temporalData.JitterP = camera.GetProjectionMatrix(renderScale, jitterX, jitterY);
        }

        temporalData.m_LastUpdateFrame = Time.frameCount;
        temporalData.FeedBack = new Vector2(m_FeedBackMin, m_FeedBackMax);
        temporalData.m_UseMotionVector = m_UseMotionVector;
        temporalData.m_UseYCOCG = m_UseYCOCG;
    }

    protected override void Dispose(bool disposing)
    {
        m_TAAPass?.Destroy();
        base.Dispose(disposing);
    }
}


