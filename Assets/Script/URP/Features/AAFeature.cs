using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class AAFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Setting
    {
        public RenderPassEvent Event = RenderPassEvent.AfterRenderingSkybox;
        public float Sharpness = 4.0f;
        public float Threshold = 0.2f;
        public Shader BlitShader = null;
    }

    public Setting settings;

    public class AARenderFeaturePass : ScriptableRenderPass
    {
        Material material;
        private readonly string tag;
        private readonly float sharpness;
        private readonly float threshold;

        CommandBuffer cmd;

        private RenderTargetIdentifier source;
        private RenderTargetIdentifier tempCopy = new RenderTargetIdentifier(tempCopyString);

        static readonly int tempCopyString = Shader.PropertyToID("_TempCopy");
        static readonly int sharpnessString = Shader.PropertyToID("_Sharpness");
        static readonly int thresholdString = Shader.PropertyToID("_Threshold");

        public AARenderFeaturePass(RenderPassEvent renderPassEvent, Shader blitShader,
            float sharpness, float threshold, string tag)
        {
            if (blitShader != null)
            {
                this.renderPassEvent = renderPassEvent;
                this.material = CoreUtils.CreateEngineMaterial(blitShader);
                this.tag = tag;
                this.sharpness = sharpness;
                this.threshold = threshold;
            }
        }

        public void Setup(RenderTargetIdentifier source)
        {
            this.source = source;
            cmd = CommandBufferPool.Get(tag);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;

            cmd.GetTemporaryRT(tempCopyString, opaqueDesc, FilterMode.Bilinear);
            cmd.CopyTexture(source, tempCopy);

            material.SetFloat(sharpnessString, sharpness);
            material.SetFloat(thresholdString, threshold);

            cmd.Blit(tempCopy, source, material, 0);

            context.ExecuteCommandBuffer(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(tempCopyString);
        }

    }

    public AARenderFeaturePass featurePass;

    // Execute when adding render feature
    public override void Create()
    {
        if (settings.BlitShader != null)
            featurePass = new AARenderFeaturePass(settings.Event, settings.BlitShader, settings.Sharpness, settings.Threshold, this.name);
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.BlitShader == null)
        {
            Debug.LogError("AAFeature找不到相关的AAShader！");
            return;
        }
        featurePass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(featurePass);
    }



}
