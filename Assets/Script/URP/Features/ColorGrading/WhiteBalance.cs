using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("FB Post-Processing/(LUT)White Balance")]
public sealed class WhiteBalance : VolumeComponent, IPostProcessComponent
{

    [Tooltip("Sets the white balance to a custom color temperature.")]
    public ClampedFloatParameter temperature = new ClampedFloatParameter(0f, -100, 100f);

    [Tooltip("Sets the white balance to compensate for a green or magenta tint.")]
    public ClampedFloatParameter tint = new ClampedFloatParameter(0f, -100, 100f);

    public bool IsActive() => (float)temperature.value != 0f || (float)tint.value != 0f;

    public bool IsTileCompatible() => false;
}

