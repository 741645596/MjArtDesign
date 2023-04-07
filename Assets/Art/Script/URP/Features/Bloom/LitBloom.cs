using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("FB Post-Processing/Bloom")]
public class LitBloom : VolumeComponent, IPostProcessComponent
{
    public ClampedFloatParameter m_BloomThreshold = new ClampedFloatParameter(1.0f, 0.0f, 20.0f);
    public ClampedFloatParameter m_BloomIntensity = new ClampedFloatParameter(0.0f, 0.0f, 20.0f);
    public ClampedIntParameter m_BloomIterations = new ClampedIntParameter(7, 1, 16);
    public ColorParameter m_BloomTintColor = new ColorParameter(Color.white, true, true, false);

    public ClampedFloatParameter m_BlurRadius = new ClampedFloatParameter(0.2f, 0.0f, 5.0f);
    public ClampedIntParameter m_DownScaling = new ClampedIntParameter(3,1, 8);

    public bool IsActive() => (float)m_BloomIntensity.value > 0;

    public bool IsTileCompatible() => false;

}
