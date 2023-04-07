using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public enum TonemappingMode
{
    Unity,
    GT,
    Unreal,
}

[Serializable, VolumeComponentMenu("FB Post-Processing/(LUT)ToneMapping")]
public sealed class LitToneMapping : VolumeComponent, IPostProcessComponent
{
    [Tooltip("是否开启ToneMapping")]
    public BoolParameter openToneMapping = new BoolParameter(false);

    [Tooltip("ACES模式")]
    public TonemappingModeParameter tonemappingMode = new TonemappingModeParameter(TonemappingMode.Unity);

    public ClampedFloatParameter Unreal_FilmSlope = new ClampedFloatParameter(0.63f,0,1);

    public ClampedFloatParameter Unreal_FilmToe = new ClampedFloatParameter(0.55f, 0, 1);

    public ClampedFloatParameter Unreal_FilmShoulder = new ClampedFloatParameter(0.47f, 0, 1);

    public ClampedFloatParameter Unreal_FilmBlackClip = new ClampedFloatParameter(0f, 0, 1);

    public ClampedFloatParameter Unreal_FilmWhiteClip = new ClampedFloatParameter(0.01f, 0, 1);

    public bool IsActive()
    {
        return (bool)openToneMapping.value;
    }

    public bool IsTileCompatible() => true;
}

[Serializable]
public class TonemappingModeParameter : VolumeParameter<TonemappingMode> 
{ 
    public TonemappingModeParameter(TonemappingMode value, bool overrideState = false) : base(value, overrideState) 
    { 
    } 
}

