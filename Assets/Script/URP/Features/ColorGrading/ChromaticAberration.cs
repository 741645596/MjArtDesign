using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("FB Post-Processing/Chromatic Aberration")]
public sealed class ChromaticAberration : VolumeComponent, IPostProcessComponent
{
    public FloatParameter intensity = new FloatParameter(0f);

    public bool IsActive() => (float)intensity.value > 0;

    public bool IsTileCompatible() => false;
}
