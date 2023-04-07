using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("FB Post-Processing/Volume Cloud")]
public sealed class VolumeCloud : VolumeComponent, IPostProcessComponent
{
    public BoolParameter Open = new BoolParameter(false);

    [Tooltip("使用天空")]
    public BoolParameter UseSky = new BoolParameter(true);

    [Tooltip("分辨率")]
    public ResolutionQualityParameter ResolutionQualityType = new ResolutionQualityParameter(ResolutionQuality.Full);

    //迭代
    [Space(30)]
    [Header("最大迭代次数")]
    public ClampedIntParameter MaxIteration = new ClampedIntParameter(24, 1, 64);

    [Header("每米步进次数")]
    public ClampedFloatParameter StepCountPerMeter = new ClampedFloatParameter(0.12f, 0.01f, 20f);

    [Space(30)]
    [Header("xyz:风向 w:风速")]
    public Vector4Parameter WindDirection = new Vector4Parameter(new Vector4(0.5f, 0.15f, 0.3f, 0.05f));

    //
    [Space(30)]
    [Header("颗粒饱和度-密度")]
    public ClampedFloatParameter DensityMultiplier = new ClampedFloatParameter(0.191f, 0f, 1f);

    [Header("吸收率")]
    public ClampedFloatParameter CloudAbsorbAdjust = new ClampedFloatParameter(0.7f, 0, 1f);

    [Header("密度差值")]
    public ClampedFloatParameter DensityDifferenceValue = new ClampedFloatParameter(0.5f, 0f, 1f);

    [Header("厚度差值")]
    public ClampedFloatParameter ThicknessDifferenceValue = new ClampedFloatParameter(0.5f, 0f, 1f);

    [Space(30)]
    [Header("层云范围")]
    public FloatRangeParameter StratusCloudRange = new FloatRangeParameter(new Vector2(0.1f, 0.5f), 0.01f, 0.5f);

    [Header("层云差值")]
    public ClampedFloatParameter StratusCloudMid = new ClampedFloatParameter(0.3f, 0, 0.5f);

    [Header("积云范围")]
    public FloatRangeParameter CumulusCloudRange = new FloatRangeParameter(new Vector2(0.1422567f, 0.98f), 0.01f, 0.98f);

    [Header("积云差值")]
    public ClampedFloatParameter CumulusCloudMid = new ClampedFloatParameter(0.345f, 0, 0.5f);

    [Space(30)]
    [Header("本体取值")]
    public ClampedFloatParameter BaseFBM_G = new ClampedFloatParameter(0.5f, 0f, 1f);
    public ClampedFloatParameter BaseFBM_B = new ClampedFloatParameter(0.19f, 0f, 1f);
    public ClampedFloatParameter BaseFBM_A = new ClampedFloatParameter(0.125f, 0f, 1f);

    [Header("细节取值")]
    public ClampedFloatParameter DetailFBM_G = new ClampedFloatParameter(0.67f, 0f, 1f);
    public ClampedFloatParameter DetailFBM_B = new ClampedFloatParameter(0.83f, 0f, 1f);
    public ClampedFloatParameter DetailFBM_A = new ClampedFloatParameter(0.18f, 0f, 1f);

    [Header("细节强度")]
    public ClampedFloatParameter BaseShapeDetailEffect = new ClampedFloatParameter(0.178f, 0, 1f);

    [Header("细节边缘保留强度")]
    public ClampedFloatParameter BaseShapeDetailEffectEdge = new ClampedFloatParameter(0.158f, 0, 1f);

    [Header("细节权重")]
    public ClampedFloatParameter DetailWeightsPower = new ClampedFloatParameter(10.1f, 0f, 30f);

    //色彩
    [Space(30)]
    [Header("灯光强度")]
    public FloatParameter LightStrength = new FloatParameter(1);

    [Header("米氏散射")]
    public Vector4Parameter PhaseParams = new Vector4Parameter(new Vector4(0.6f, 1, 0.55f, 0.5f));

    [Header("米氏散射基础值")]
    public ClampedFloatParameter PhaseBase = new ClampedFloatParameter(0.605f, 0f, 1f);

    [Header("米氏散射权重")]
    public ClampedFloatParameter PhaseWeight = new ClampedFloatParameter(1f, 0f, 1f);

    [Header("吸收倍数 视线方向")]
    public ClampedFloatParameter RayAbsorptionScale = new ClampedFloatParameter(0.418f, 0f, 1f);

    [Header("吸收倍数 光源方向")]
    public ClampedFloatParameter LightAbsorptionScale = new ClampedFloatParameter(0.049f, 0f, 1f);

    [Header("光源RGB吸收")]
    public ClampedFloatParameter LightmarchLerp = new ClampedFloatParameter(0.364f, 0f, 1f);

    [Header("颜色偏移")]
    public ClampedFloatParameter ColorCentralOffset = new ClampedFloatParameter(0.5f, 0f, 1f);

    [Header("暗部偏移")]
    public ClampedFloatParameter DarknessThreshold = new ClampedFloatParameter(0.143f, 0f, 1f);

    [Header("color A")]
    public ColorParameter ColorDark = new ColorParameter(new Color(0.901f, 0.9225515f, 1f,1f));

    [Header("color B")]
    public ColorParameter ColorCentral = new ColorParameter(new Color(0.37808f, 0.4254858f, 0.544f, 1f));

    [Header("color C")]
    public ColorParameter ColorBright = new ColorParameter(new Color(0.03464706f, 0.05023367f, 0.05882353f, 1f));

    //抖动
    [Space(30)]
    [Header("抖动图")]
    public Texture2DParameter BlueNoiseTex = new Texture2DParameter(null);

    [Header("抖动图缩放")]
    public ClampedFloatParameter BlueNoiseTexScale = new ClampedFloatParameter(12f, 0f, 40f);

    //厚度 高度
    [Header("分布 主体流动偏移 图 r:云层分布 g:主体流动偏移")]
    public Texture2DParameter WeatherTex = new Texture2DParameter(null);

    [Header("分布图缩放")]
    public ClampedFloatParameter WeatherMapScale = new ClampedFloatParameter(1f, 0f, 5f);

    [Header("分布图移动速度")]
    public ClampedFloatParameter WeatherWindSpeed = new ClampedFloatParameter(0.1f, 0f, 5f);

    [Header("主图")]
    public Texture3DParameter NoiseTex = new Texture3DParameter(null);

    [Header("主体缩放")]
    public ClampedFloatParameter CircleBaseShapeTiling = new ClampedFloatParameter(1.37f, 0.1f, 5f);

    [Header("细节图")]
    public Texture3DParameter DetailNoiseTex = new Texture3DParameter(null);

    [Header("细节图缩放")]
    public ClampedFloatParameter CircleDetailTiling = new ClampedFloatParameter(2f, 0.1f, 10f);

    public bool IsActive() => (bool)Open.value;

    public bool IsTileCompatible() => false;

    /// <summary>
    /// 自定义的面板显示属性
    /// </summary>
    [Serializable]
    public sealed class ResolutionQualityParameter : VolumeParameter<ResolutionQuality>
    {
        /// <summary>
        /// 显示在面板中的属性
        /// </summary>
        /// <param name="value">分辨率模式</param>
        /// <param name="overrideState">单选框默认是否勾选</param>
        public ResolutionQualityParameter(ResolutionQuality value, bool overrideState = false)
            : base(value, overrideState) { }
    }

    /// <summary>
    /// 分辨率
    /// </summary>
    public enum ResolutionQuality
    {
        Full,
        Half,
        Quarter,
    }

}

