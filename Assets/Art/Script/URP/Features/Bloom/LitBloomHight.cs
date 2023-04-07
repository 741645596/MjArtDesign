using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("FB Post-Processing/BloomHight")]
public class LitBloomHight : VolumeComponent, IPostProcessComponent
{
    public BoolParameter useKarisAverage = new BoolParameter(false);

    public ClampedIntParameter downSampleStep = new ClampedIntParameter(7, 3, 16);
    public ClampedIntParameter downSampleBlurSize = new ClampedIntParameter(5, 3, 15);
    public ClampedFloatParameter downSampleBlurSigma = new ClampedFloatParameter(1.0f, 0.01f, 10.0f);

    public ClampedIntParameter upSampleBlurSize = new ClampedIntParameter(5, 3, 15);
    public ClampedFloatParameter upSampleBlurSigma = new ClampedFloatParameter(1.0f, 0.01f, 10.0f);

    public ClampedFloatParameter luminanceThreshole = new ClampedFloatParameter(1.0f, 0.001f, 10.0f);
    public ClampedFloatParameter bloomIntensity = new ClampedFloatParameter(0f, 0.001f, 10.0f);

    public bool IsActive(){
       return (float)bloomIntensity.value > 0;
    }

    public bool IsTileCompatible() => false;

}
