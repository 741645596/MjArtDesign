using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("FB Post-Processing/Ray And Screen Volume Light")]
public sealed class RayAndScreenVolumeLight : VolumeComponent, IPostProcessComponent
{
    #region//光追体积光

    [Tooltip("光追:视线距离")]
    public FloatParameter RayLength = new FloatParameter(2);

    [Tooltip("光追:光强度，默认1")]
    public FloatParameter AttenStrength = new FloatParameter(0);

    [Tooltip("光追:采样次数")]
    public ClampedIntParameter StepCount = new ClampedIntParameter(40,8,500);

    [Tooltip("光追:散射系数")]
    public ClampedFloatParameter MieScatteringG = new ClampedFloatParameter(0.05f,0,1);

    [Tooltip("光追:吸收系数")]
    public ClampedFloatParameter Extingction = new ClampedFloatParameter(0.7f, 0, 1);

    [Tooltip("光追:开启噪点")]
    public BoolParameter RandomNoise = new BoolParameter(true);

    [Tooltip("光追:开启高斯模糊")]
    public BoolParameter GaussionBlur = new BoolParameter(true);

    [Tooltip("光追:开启附加灯")]
    public BoolParameter AddLights = new BoolParameter(false);

    [Tooltip("光追:高斯模糊迭代次数")]
    public ClampedIntParameter GaussionBlurCount = new ClampedIntParameter(8, 1, 8);

    [Tooltip("光追:高斯模糊范围")]
    public ClampedFloatParameter GaussionBlurSize = new ClampedFloatParameter(3f, 0, 6);

    #endregion

    [Space(30)]

    #region//屏幕镜像体积光

    [Tooltip("容积光:强度,推荐值0.3")]
    public ClampedFloatParameter SunShaftBlurStrength = new ClampedFloatParameter(0, 0,1);

    [Tooltip("容积光:屏幕长度范围")]
    public ClampedFloatParameter SunShafeLenght = new ClampedFloatParameter(0.354f, 0, 1);

    [Tooltip("容积光:取色")]
    public ColorParameter SunShafeThreshold = new ColorParameter(Color.black);

    [Tooltip("容积光:深度范围 值越小，范围越广")]
    public ClampedFloatParameter SunShafeDepthThreshold = new ClampedFloatParameter(0.018f, 0, 1);

    [Tooltip("容积光:径向模糊距离")]
    public FloatParameter SunShafeBlurRadius = new FloatParameter(2.5f);

    [Tooltip("容积光:径向模糊迭代次数")]
    public ClampedIntParameter SunShafeBlurIterations = new ClampedIntParameter(3, 1,4);

    #endregion

    public bool IsActive() => (float)AttenStrength.value >0 || (float)SunShaftBlurStrength.value>0;

    public bool IsTileCompatible() => false;

    //[Tooltip("体积光模式")]
    //public GodLightTypeParameter GodLightType = new GodLightTypeParameter(RayVolumeLightPass.GodLightType.RayVolumeLight);

    ///// <summary>
    ///// 自定义的面板显示属性
    ///// </summary>
    //[Serializable]
    //public sealed class GodLightTypeParameter : VolumeParameter<RayVolumeLightPass.GodLightType>
    //{
    //    /// <summary>
    //    /// 显示在面板中的属性
    //    /// </summary>
    //    /// <param name="value">体积光模式</param>
    //    /// <param name="overrideState">单选框默认是否勾选</param>
    //    public GodLightTypeParameter(RayVolumeLightPass.GodLightType value, bool overrideState = false)
    //        : base(value, overrideState) { }
    //}
}

