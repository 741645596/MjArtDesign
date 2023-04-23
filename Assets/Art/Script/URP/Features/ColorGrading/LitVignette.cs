using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("FB Post-Processing/Vignette")]
public sealed class LitVignette : VolumeComponent, IPostProcessComponent
{
    public FloatParameter vignetteIntensity = new FloatParameter(0f);

    public FloatParameter vignetteRoughness = new FloatParameter(1.5f);

    public FloatParameter vignetteSmothness = new FloatParameter(1.5f);

    public bool IsActive() => (float)vignetteIntensity.value > 0;

    public bool IsTileCompatible() => false;
}
