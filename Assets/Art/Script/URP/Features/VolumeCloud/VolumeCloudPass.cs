using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System.Collections.Generic;
using System.Linq;

/// <summary>
/// 体积云区域需要 VolumeCollider 层级指定
/// cube区域需要指定Tag：VolumeColliderCube
/// </summary>
public class VolumeCloudPass : ScriptableRenderPass
{
    ProfilingSampler mProfilingSampler;

    Material material;

    RenderTargetIdentifier cameraColorTarget;

    RenderTargetHandle rayVolumeDepthTexture;

    RenderTargetHandle rayVolumeCloudTexture;

    RenderTargetHandle volumeCloudTemTexture;

    RenderTexture[] framDatas = new RenderTexture[2];

    RenderTexture[] framSceneDatas = new RenderTexture[2];

    public void Setup(LitePostFeature litePostFeature,RenderTargetIdentifier cameraColorTarget)
    {
        this.cameraColorTarget = cameraColorTarget;
    }

    public VolumeCloudPass(RenderPassEvent passEvent, Material material)
    {
        this.material = material;
        renderPassEvent = passEvent;//RenderPassEvent.AfterRenderingTransparents
        mProfilingSampler = new ProfilingSampler("VolumeCloudPass");
        rayVolumeCloudTexture.Init("_VolumeCloudTexture");
        rayVolumeDepthTexture.Init("_VolumeDepthTexture");
        volumeCloudTemTexture.Init("_VolumeCloudTemTexture");
        _CubeMin = new Vector4[maxArrayCount];
        _CubeMax = new Vector4[maxArrayCount];
        _CubeWorldToLocal = new Matrix4x4[maxArrayCount];
        _CubeLocalToWorld = new Matrix4x4[maxArrayCount];
        _SphereCenter = new Vector4[maxArrayCount];
        _SphereRadius = new float[maxArrayCount];
        _CubeScale= new Vector4[maxArrayCount];
        _ColliderWindInfo = new Vector4[maxArrayCount];
        _WeatherSetData = new Vector4[maxArrayCount];
        _WeatherCloudSetData = new Vector4[maxArrayCount];
        _StratusCloudRangeData = new Vector4[maxArrayCount];
        _CumulusCloudRangeData = new Vector4[maxArrayCount];
        _WeatherMapDatas = new Texture2D[maxArrayCount];
        _CloudWindSetData= new Vector4[maxArrayCount];
        _ShapeNoiseWeights = new Vector4[maxArrayCount];
        _FBMSetDatas = new Vector4[maxArrayCount];
        _CloudUVscale = new Vector4[maxArrayCount];
        _CloudLightData = new Vector4[maxArrayCount];

        _CloudBaseFBMs = new Vector4[maxArrayCount];
        _CloudDetailFBMs = new Vector4[maxArrayCount];
        _CloudGBA= new float[maxArrayCount];
        _CloudMaxIterationAndStep = new Vector4[maxArrayCount];
        _CloudColorDatas = new Vector4[maxArrayCount];

        _CloudColorDarkDatas = new Vector4[maxArrayCount];
        _CloudColorCentralDatas = new Vector4[maxArrayCount];
        _CloudColorBrightDatas = new Vector4[maxArrayCount];

        _VolumeCloudPhaseParamsDatas = new Vector4[maxArrayCount];
        _VolumeCloudPhaseBaseDatas = new float[maxArrayCount];
        _VolumeCloudPhaseWeightDatas = new float[maxArrayCount];
    }

    RenderTextureDescriptor textureDescriptor;

    RenderTextureDescriptor cameraDescriptor;

    int maxArrayCount = 8;

    VolumeCloud.ResolutionQuality resolutionQuality;

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        VolumeStack stack = VolumeManager.instance.stack;
        VolumeCloud volumeCloud = stack.GetComponent<VolumeCloud>();
        if (!volumeCloud.IsActive())
        {
            return;
        }
        cameraDescriptor = cameraTextureDescriptor;

        cmd.GetTemporaryRT(volumeCloudTemTexture.id, cameraTextureDescriptor);
        //
        textureDescriptor = cameraTextureDescriptor;

        resolutionQuality = (VolumeCloud.ResolutionQuality)volumeCloud.ResolutionQualityType.value;

        switch (resolutionQuality)
        {
            case VolumeCloud.ResolutionQuality.Full:
                {
                    textureDescriptor.width = cameraTextureDescriptor.width;
                    textureDescriptor.height = cameraTextureDescriptor.height;
                }
                break;
            case VolumeCloud.ResolutionQuality.Half:
                {
                    textureDescriptor.width = cameraTextureDescriptor.width >> 1;
                    textureDescriptor.height = cameraTextureDescriptor.height >> 1;
                }
                break;
            case VolumeCloud.ResolutionQuality.Quarter:
                {
                    textureDescriptor.width = cameraTextureDescriptor.width >> 2;
                    textureDescriptor.height = cameraTextureDescriptor.height >> 2;
                }
                break;
        }
        for (int i=0;i<2;++i)
        {
            if (framDatas[i] == null || framDatas[i].width!= textureDescriptor.width || framDatas[i].height != textureDescriptor.height)
            {
                RenderTexture.ReleaseTemporary(framDatas[i]);
                framDatas[i] = RenderTexture.GetTemporary(cameraTextureDescriptor);
            }
        }
        for (int i = 0; i < 2; ++i)
        {
            if (framSceneDatas[i] == null || framSceneDatas[i].width != textureDescriptor.width || framSceneDatas[i].height != textureDescriptor.height)
            {
                RenderTexture.ReleaseTemporary(framSceneDatas[i]);
                framSceneDatas[i] = RenderTexture.GetTemporary(cameraTextureDescriptor);
            }
        }
        int mW = textureDescriptor.width % 8;
        if (mW!=0)
        {
            textureDescriptor.width = textureDescriptor.width - mW;
        }
        int mH = textureDescriptor.height % 8;
        if (mH != 0)
        {
            textureDescriptor.height = textureDescriptor.height - mH;
        }
        textureDescriptor.depthBufferBits = 0;
        textureDescriptor.graphicsFormat = GraphicsFormat.R8G8B8A8_SNorm;
        cmd.GetTemporaryRT(rayVolumeCloudTexture.id, textureDescriptor, FilterMode.Trilinear);
        cmd.GetTemporaryRT(rayVolumeDepthTexture.id, textureDescriptor, FilterMode.Point);
    }

    Vector4[] _CubeMin;
    Vector4[] _CubeMax;
    Vector4[] _CubeScale;
    Vector4[] _ColliderWindInfo;
    Vector4[] _CloudWindSetData;
    Vector4[] _ShapeNoiseWeights;
    Vector4[] _FBMSetDatas;
    Vector4[] _CloudUVscale;
    Vector4[] _CloudMaxIterationAndStep;
    Vector4[] _CloudLightData;
    Vector4[] _CloudColorDatas;

    Vector4[] _CloudColorDarkDatas;
    Vector4[] _CloudColorCentralDatas;
    Vector4[] _CloudColorBrightDatas;

    Vector4[] _CloudBaseFBMs;
    Vector4[] _CloudDetailFBMs;
    float[] _CloudGBA;

    Texture2D[] _WeatherMapDatas;

    Vector4[] _WeatherSetData;
    Vector4[] _WeatherCloudSetData;

    Vector4[] _StratusCloudRangeData;
    Vector4[] _CumulusCloudRangeData;

    Matrix4x4[] _CubeWorldToLocal;
    Matrix4x4[] _CubeLocalToWorld;
    Vector4[] _SphereCenter;
    float[] _SphereRadius;

    Vector4[] _VolumeCloudPhaseParamsDatas;
    float[] _VolumeCloudPhaseBaseDatas;
    float[] _VolumeCloudPhaseWeightDatas;

    Dictionary<int, RenderTargetIdentifier> globalTextures = new Dictionary<int, RenderTargetIdentifier>();

    public enum DistinguishFrameType
    {
        Off,
        _2X2,
        _4X4,
    }

    public DistinguishFrameType DistinguishFrame = DistinguishFrameType.Off;

    int currentFrameIndex = -1;

    int currentFrameSceneIndex = -1;

    void SetGlobalTexture(CommandBuffer cmd,int shaderId, RenderTargetIdentifier value)
    {
        if (globalTextures.ContainsKey(shaderId))
        {
            if (globalTextures[shaderId] != value)
            {
                cmd.SetGlobalTexture(shaderId, value);
                globalTextures[shaderId] = value;
            }
        }
        else
        {
            cmd.SetGlobalTexture(shaderId, value);
            globalTextures.Add(shaderId, value);
        }
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        VolumeStack stack = VolumeManager.instance.stack;
        VolumeCloud volumeCloud = stack.GetComponent<VolumeCloud>();
        if (!volumeCloud.IsActive())
        {
            return;
        }

#if UNITY_EDITOR
        List<VolumeCloudCollider> colliders = VolumeCloudCollider.FindObjectsOfType<VolumeCloudCollider>().ToList<VolumeCloudCollider>();
#else
        List<VolumeCloudCollider> colliders = VolumeCloudCollider.Colliders;
#endif

        if (colliders.Count == 0 && !(bool)volumeCloud.UseSky.value)
        {
            return;
        }

        //
        CommandBuffer cmd = CommandBufferPool.Get();
        //
        using (new ProfilingScope(cmd, mProfilingSampler))
        {
            int rtIndex = 0;
            switch (DistinguishFrame)
            {
                case DistinguishFrameType.Off:
                    {
                        if (renderingData.cameraData.cameraType == CameraType.Game)
                        {
                            currentFrameIndex = -1;
                        }
                        else
                        {
                            currentFrameSceneIndex = -1;
                        }
                        cmd.EnableShaderKeyword(string.Intern("DISTINGUISH_OFF"));
                        cmd.DisableShaderKeyword(string.Intern("DISTINGUISH_2X2"));
                        cmd.DisableShaderKeyword(string.Intern("DISTINGUISH_4X4"));
                    }
                    break;
                case DistinguishFrameType._2X2:
                    {
                        if (renderingData.cameraData.cameraType == CameraType.Game)
                        {
                            currentFrameIndex = currentFrameIndex + 1;
                            if (currentFrameIndex > 3)
                            {
                                currentFrameIndex = 0;
                            }
                            rtIndex = currentFrameIndex % 2;
                            cmd.SetGlobalInt(ShaderParams._DistinguishIndex, currentFrameIndex);
                        }
                        else
                        {
                            currentFrameSceneIndex = currentFrameSceneIndex + 1;
                            if (currentFrameSceneIndex > 3)
                            {
                                currentFrameSceneIndex = 0;
                            }
                            rtIndex = currentFrameSceneIndex % 2;
                            cmd.SetGlobalInt(ShaderParams._DistinguishIndex, currentFrameSceneIndex);
                        }
                        cmd.DisableShaderKeyword(string.Intern("DISTINGUISH_OFF"));
                        cmd.EnableShaderKeyword(string.Intern("DISTINGUISH_2X2"));
                        cmd.DisableShaderKeyword(string.Intern("DISTINGUISH_4X4"));

                        cmd.SetGlobalInt(ShaderParams._DistinguishWidth, textureDescriptor.width);
                        cmd.SetGlobalInt(ShaderParams._DistinguishHeight, textureDescriptor.height);
                    }
                    break;
                case DistinguishFrameType._4X4:
                    {
                        if (renderingData.cameraData.cameraType == CameraType.Game)
                        {
                            currentFrameIndex = currentFrameIndex + 1;
                            if (currentFrameIndex > 15)
                            {
                                currentFrameIndex = 0;
                            }
                            rtIndex = currentFrameIndex % 2;
                            cmd.SetGlobalInt(ShaderParams._DistinguishIndex, currentFrameIndex);
                        }
                        else
                        {
                            currentFrameSceneIndex = currentFrameSceneIndex + 1;
                            if (currentFrameSceneIndex > 15)
                            {
                                currentFrameSceneIndex = 0;
                            }
                            rtIndex = currentFrameSceneIndex % 2;
                            cmd.SetGlobalInt(ShaderParams._DistinguishIndex, currentFrameSceneIndex);

                        }
                        cmd.DisableShaderKeyword(string.Intern("DISTINGUISH_OFF"));
                        cmd.DisableShaderKeyword(string.Intern("DISTINGUISH_2X2"));
                        cmd.EnableShaderKeyword(string.Intern("DISTINGUISH_4X4"));
                        cmd.SetGlobalInt(ShaderParams._DistinguishWidth, textureDescriptor.width);
                        cmd.SetGlobalInt(ShaderParams._DistinguishHeight, textureDescriptor.height);
                    }
                    break;
            }

            Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(renderingData.cameraData.camera.projectionMatrix, false);
            if ((bool)volumeCloud.UseSky.value)
            {
                cmd.EnableShaderKeyword(string.Intern("VOLUMECLOUD_USE_EARTH"));
            }
            else
            {
                cmd.DisableShaderKeyword(string.Intern("VOLUMECLOUD_USE_EARTH"));
            }

            cmd.SetGlobalMatrix(ShaderParams._VolumeInverseProjectionMatrix, projectionMatrix.inverse);
            cmd.SetGlobalMatrix(ShaderParams._VolumeCameraToWorldMatrix, renderingData.cameraData.camera.cameraToWorldMatrix);
            cmd.SetGlobalInt(ShaderParams._VolumeCloudMaxIteration, (int)volumeCloud.MaxIteration.value);
            cmd.SetGlobalFloat(ShaderParams._VolumeCloudStepCountPerMeter, (float)volumeCloud.StepCountPerMeter.value);
            if (volumeCloud.WeatherTex.value!=null)
            {
                SetGlobalTexture(cmd,ShaderParams._VolumeCloudWeatherAndSpeedMap, (Texture2D)volumeCloud.WeatherTex.value);
                cmd.SetGlobalFloat(ShaderParams._VolumeCloudWeatherAndSpeedMapScale, (float)volumeCloud.WeatherMapScale.value);
            }
            if (volumeCloud.NoiseTex.value!=null)
            {
                SetGlobalTexture(cmd, ShaderParams._VolumeCloudNoise3DTex, (Texture3D)volumeCloud.NoiseTex.value);
            }
            if (volumeCloud.DetailNoiseTex.value != null)
            {
                SetGlobalTexture(cmd, ShaderParams._VolumeCloudDetailNoise3DTex, (Texture3D)volumeCloud.DetailNoiseTex.value);
            }
            if (volumeCloud.BlueNoiseTex.value != null)
            {
                SetGlobalTexture(cmd, ShaderParams._VolumeCloudBlueNoiseMap, (Texture2D)volumeCloud.BlueNoiseTex.value);
                Vector4 screenUv = new Vector4(
                    textureDescriptor.width / (float)volumeCloud.BlueNoiseTex.value.width,
                    textureDescriptor.height / (float)volumeCloud.BlueNoiseTex.value.height, 0, 0);
                cmd.SetGlobalVector(ShaderParams._VolumeCloudBlueNoiseCoords, screenUv);
            }
            switch (resolutionQuality)
            {
                case VolumeCloud.ResolutionQuality.Full:
                    {
                        cmd.SetGlobalFloat(ShaderParams._VolumeCloudBlueNoiseTexScale, (float)volumeCloud.BlueNoiseTexScale.value);
                    }
                    break;
                case VolumeCloud.ResolutionQuality.Half:
                    {
                        cmd.SetGlobalFloat(ShaderParams._VolumeCloudBlueNoiseTexScale, ((float)volumeCloud.BlueNoiseTexScale.value) * 0.25f);
                    }
                    break;
                case VolumeCloud.ResolutionQuality.Quarter:
                    {
                        cmd.SetGlobalFloat(ShaderParams._VolumeCloudBlueNoiseTexScale, ((float)volumeCloud.BlueNoiseTexScale.value) * 0.25f);
                    }
                    break;
            }

            Vector2 stratusCloudRange = (Vector2)volumeCloud.StratusCloudRange.value;
            float stratusCloudMid = Mathf.Clamp((float)volumeCloud.StratusCloudMid.value,0, stratusCloudRange.y);
            Vector2 cumulusCloudRange = (Vector2)volumeCloud.CumulusCloudRange.value;
            float cumulusCloudMid = Mathf.Clamp((float)volumeCloud.CumulusCloudMid.value, 0, cumulusCloudRange.y);
            cmd.SetGlobalVector(ShaderParams._StratusCloudRange, new Vector3(stratusCloudRange.x, stratusCloudRange.y, stratusCloudMid));
            cmd.SetGlobalVector(ShaderParams._CumulusCloudRange, new Vector3(cumulusCloudRange.x, cumulusCloudRange.y, cumulusCloudMid));

            Vector3 baseFBM = new Vector3((float)volumeCloud.BaseFBM_G.value, (float)volumeCloud.BaseFBM_B.value, (float)volumeCloud.BaseFBM_A.value);
            cmd.SetGlobalVector(ShaderParams._VolumeCloudBaseFBM, baseFBM);
            Vector3 detailFBM = new Vector3((float)volumeCloud.DetailFBM_G.value, (float)volumeCloud.DetailFBM_B.value, (float)volumeCloud.DetailFBM_A.value);
            cmd.SetGlobalVector(ShaderParams._VolumeCloudDetailFBM, detailFBM);
            cmd.SetGlobalFloat(ShaderParams._BaseShapeDetailEffect, (float)volumeCloud.BaseShapeDetailEffect.value);
            cmd.SetGlobalFloat(ShaderParams._BaseShapeDetailEffectEdge, (float)volumeCloud.BaseShapeDetailEffectEdge.value);
            cmd.SetGlobalFloat(ShaderParams._CircleBaseShapeTiling, (float)volumeCloud.CircleBaseShapeTiling.value);
            cmd.SetGlobalFloat(ShaderParams._CloudAbsorbAdjust, (float)volumeCloud.CloudAbsorbAdjust.value);
            cmd.SetGlobalFloat(ShaderParams._CircleDetailTiling, (float)volumeCloud.CircleDetailTiling.value);
            cmd.SetGlobalFloat(ShaderParams._WeatherWindSpeed, (float)volumeCloud.WeatherWindSpeed.value);
            cmd.SetGlobalFloat(ShaderParams._ThicknessDifferenceValue, (float)volumeCloud.ThicknessDifferenceValue.value);
            cmd.SetGlobalFloat(ShaderParams._DensityDifferenceValue, (float)volumeCloud.DensityDifferenceValue.value);

            cmd.SetGlobalFloat(ShaderParams._VolumeCloudRayAbsorptionScale, (float)volumeCloud.RayAbsorptionScale.value);
            cmd.SetGlobalFloat(ShaderParams._VolumeCloudLightAbsorptionScale, (float)volumeCloud.LightAbsorptionScale.value);
            cmd.SetGlobalFloat(ShaderParams._VolumeCloudDetailWeights, (float)volumeCloud.DetailWeightsPower.value);
            cmd.SetGlobalFloat(ShaderParams._VolumeCloudDensityMultiplier, (float)volumeCloud.DensityMultiplier.value);
            cmd.SetGlobalFloat(ShaderParams._VolumeCloudLightStrength, (float)volumeCloud.LightStrength.value);
            cmd.SetGlobalVector(ShaderParams._VolumeCloudWindInfo, (Vector4)volumeCloud.WindDirection.value);
            cmd.SetGlobalFloat(ShaderParams._VolumeCloudLightmarchLerp, (float)volumeCloud.LightmarchLerp.value);

            cmd.SetGlobalFloat(ShaderParams._CloudColorCentralOffset, (float)volumeCloud.ColorCentralOffset.value);
            cmd.SetGlobalFloat(ShaderParams._CloudDarknessThreshold, (float)volumeCloud.DarknessThreshold.value);
            cmd.SetGlobalColor(ShaderParams._CloudColorDark, (Color)volumeCloud.ColorDark.value);
            cmd.SetGlobalColor(ShaderParams._CloudColorCentral, (Color)volumeCloud.ColorCentral.value);
            cmd.SetGlobalColor(ShaderParams._CloudColorBright, (Color)volumeCloud.ColorBright.value);

            cmd.SetGlobalVector(ShaderParams._VolumeCloudPhaseParams, (Vector4)volumeCloud.PhaseParams.value);
            cmd.SetGlobalFloat(ShaderParams._VolumeCloudPhaseBase, (float)volumeCloud.PhaseBase.value);
            cmd.SetGlobalFloat(ShaderParams._VolumeCloudPhaseWeight, (float)volumeCloud.PhaseWeight.value);

            int cubeCount = 0;
            int sphereCount = 0;
            for (int i=0,listCount= colliders.Count;i< listCount;++i)
            {
                VolumeCloudCollider volumeCloudCollider = colliders[i];
                if (volumeCloudCollider==null || !volumeCloudCollider.Usability)
                {
                    continue;
                }
                switch (volumeCloudCollider.MeshType)
                {
                    case VolumeCloudCollider.MeshTypeEnum.Cube:
                        {
                            if (cubeCount< maxArrayCount)
                            {
                                if (volumeCloudCollider.CubeRangeChange())
                                {
                                    Vector3 scale = Vector3.zero;
                                    Vector3 minPos = Vector3.zero;
                                    Vector3 maxPos = Vector3.zero;
                                    Matrix4x4 worldToLocal = Matrix4x4.identity;
                                    Matrix4x4 localToWorld = Matrix4x4.identity;
                                    volumeCloudCollider.GetCubeRange(ref scale, ref minPos, ref maxPos, ref worldToLocal, ref localToWorld);
                                    _CubeScale[cubeCount] = scale;
                                    _CubeMin[cubeCount] = minPos;
                                    _CubeMax[cubeCount] = maxPos;
                                    _CubeWorldToLocal[cubeCount] = worldToLocal;
                                    _CubeLocalToWorld[cubeCount] = localToWorld;
                                    _ColliderWindInfo[cubeCount] = new Vector4(volumeCloudCollider.WindDirection.x, volumeCloudCollider.WindDirection.y, volumeCloudCollider.WindDirection.z, Mathf.Abs(volumeCloudCollider.WindDirection.w));
                                    Vector4 weatherSetData = new Vector4(Mathf.Abs(volumeCloudCollider.WeatherSetData.x), Mathf.Abs(volumeCloudCollider.WeatherSetData.y),
                                        Mathf.Abs(volumeCloudCollider.WeatherSetData.z), Mathf.Abs(volumeCloudCollider.WeatherSetData.w));
                                    _WeatherSetData[cubeCount] = weatherSetData;
                                    Vector2 weatherCloudSetData = new Vector2(Mathf.Clamp(volumeCloudCollider.WeatherCloudSetData.x, 0f,1f), Mathf.Clamp(volumeCloudCollider.WeatherCloudSetData.y, 0f, 1f));
                                    _WeatherCloudSetData[cubeCount] = new Vector4(weatherCloudSetData.x, weatherCloudSetData.y,0,0);

                                    Vector3 stratusCloudRangeData = new Vector3(Mathf.Clamp(volumeCloudCollider.StratusCloudRange.x, 0.01f, 0.5f), Mathf.Clamp(volumeCloudCollider.StratusCloudRange.y, 0.01f, 0.5f),
                                        0);
                                    stratusCloudRangeData.z = Mathf.Clamp(volumeCloudCollider.StratusCloudRange.z, stratusCloudRangeData.x, stratusCloudRangeData.y);
                                    _StratusCloudRangeData[cubeCount] = new Vector4(stratusCloudRangeData.x, stratusCloudRangeData.y, stratusCloudRangeData.z,0);
                                    Vector3 cumulusCloudRangeData = new Vector3(Mathf.Clamp(volumeCloudCollider.CumulusCloudRange.x, 0.01f, 0.98f), Mathf.Clamp(volumeCloudCollider.CumulusCloudRange.y, 0.01f, 0.98f),
                                        0);
                                    cumulusCloudRangeData.z = Mathf.Clamp(volumeCloudCollider.CumulusCloudRange.z, cumulusCloudRangeData.x, cumulusCloudRangeData.y);
                                    _CumulusCloudRangeData[cubeCount] = new Vector4(cumulusCloudRangeData.x, cumulusCloudRangeData.y, cumulusCloudRangeData.z, 0);

                                    _WeatherMapDatas[cubeCount] = volumeCloudCollider.WeatherMap;
                                    switch (cubeCount)
                                    {
                                        case 0:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas0, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 1:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas1, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 2:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas2, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 3:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas3, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 4:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas4, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 5:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas5, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 6:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas6, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 7:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas7, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                    }

                                    Vector4 cloudWindSetData = new Vector4(Mathf.Abs(volumeCloudCollider.CloudWindSetData.x), Mathf.Abs(volumeCloudCollider.CloudWindSetData.y),
                                        Mathf.Abs(volumeCloudCollider.CloudWindSetData.z), Mathf.Abs(volumeCloudCollider.CloudWindSetData.w));
                                    _CloudWindSetData[cubeCount] = cloudWindSetData;
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudWindSetData, _CloudWindSetData);

                                    _ShapeNoiseWeights[cubeCount] = new Vector4(volumeCloudCollider.ShapeNoiseWeightsR, volumeCloudCollider.ShapeNoiseWeightsG, volumeCloudCollider.ShapeNoiseWeightsB,
                                        volumeCloudCollider.ShapeNoiseWeightsA);

                                    Vector4 fbmSetData = new Vector4(Mathf.Abs(volumeCloudCollider.FBMSetDatas.x), volumeCloudCollider.FBMSetDatas.y, Mathf.Abs(volumeCloudCollider.FBMSetDatas.z), Mathf.Abs(volumeCloudCollider.FBMSetDatas.w));
                                    _FBMSetDatas[cubeCount] = fbmSetData;

                                    Vector4 cloudUVscale = new Vector4(Mathf.Abs(volumeCloudCollider.CloudUVscale.x), Mathf.Abs(volumeCloudCollider.CloudUVscale.y),
                                        Mathf.Abs(volumeCloudCollider.CloudUVscale.z), Mathf.Abs(volumeCloudCollider.CloudUVscale.w));

                                    switch (resolutionQuality)
                                    {
                                        case VolumeCloud.ResolutionQuality.Full:
                                            {
                                                cloudUVscale.z = cloudUVscale.z * 1.0f;
                                            }
                                            break;
                                        case VolumeCloud.ResolutionQuality.Half:
                                            {
                                                cloudUVscale.z = cloudUVscale.z * 0.25f;
                                            }
                                            break;
                                        case VolumeCloud.ResolutionQuality.Quarter:
                                            {
                                                cloudUVscale.z = cloudUVscale.z * 0.25f;
                                            }
                                            break;
                                    }

                                    _CloudUVscale[cubeCount] = cloudUVscale;

                                    Vector4 cloudBaseFBMs = new Vector4(volumeCloudCollider.BaseFBM_G, volumeCloudCollider.BaseFBM_B, volumeCloudCollider.BaseFBM_A,0);
                                    _CloudBaseFBMs[cubeCount] = cloudBaseFBMs;
                                    Vector4 cloudDetailFBMs = new Vector4(volumeCloudCollider.DetailFBM_G, volumeCloudCollider.DetailFBM_B, volumeCloudCollider.DetailFBM_A, 0);
                                    _CloudDetailFBMs[cubeCount] = cloudDetailFBMs;

                                    if (volumeCloudCollider.GBA)
                                    {
                                        _CloudGBA[cubeCount] = 1;
                                    }
                                    else
                                    {
                                        _CloudGBA[cubeCount] = 0;
                                    }

                                    Vector4 cloudMaxIterationAndStep = new Vector4(volumeCloudCollider.MaxIteration, volumeCloudCollider.StepCountPerMeter,0,0);
                                    _CloudMaxIterationAndStep[cubeCount] = cloudMaxIterationAndStep;
                                    _CloudLightData[cubeCount] = volumeCloudCollider.CloudLightData;

                                    Vector4 cloudColorDatas = new Vector4(volumeCloudCollider.ColorCentralOffset, volumeCloudCollider.DarknessThreshold,0,0);
                                    _CloudColorDatas[cubeCount] = cloudColorDatas;

                                    _CloudColorDarkDatas[cubeCount] = new Vector4(volumeCloudCollider.ColorDark.r, volumeCloudCollider.ColorDark.g, volumeCloudCollider.ColorDark.b, volumeCloudCollider.ColorDark.a);
                                    _CloudColorCentralDatas[cubeCount] = new Vector4(volumeCloudCollider.ColorCentral.r, volumeCloudCollider.ColorCentral.g, volumeCloudCollider.ColorCentral.b, volumeCloudCollider.ColorCentral.a);
                                    _CloudColorBrightDatas[cubeCount] = new Vector4(volumeCloudCollider.ColorBright.r, volumeCloudCollider.ColorBright.g, volumeCloudCollider.ColorBright.b, volumeCloudCollider.ColorBright.a);

                                    _VolumeCloudPhaseParamsDatas[cubeCount] = volumeCloudCollider.PhaseParams;
                                    _VolumeCloudPhaseBaseDatas[cubeCount] = volumeCloudCollider.PhaseBase;
                                    _VolumeCloudPhaseWeightDatas[cubeCount] = volumeCloudCollider.PhaseWeight;

                                    cmd.SetGlobalVectorArray(ShaderParams._VolumeCloudPhaseParamsDatas, _VolumeCloudPhaseParamsDatas);
                                    cmd.SetGlobalFloatArray(ShaderParams._VolumeCloudPhaseBaseDatas, _VolumeCloudPhaseBaseDatas);
                                    cmd.SetGlobalFloatArray(ShaderParams._VolumeCloudPhaseWeightDatas, _VolumeCloudPhaseWeightDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudColorDarkDatas, _CloudColorDarkDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudColorCentralDatas, _CloudColorCentralDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudColorBrightDatas, _CloudColorBrightDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudColorDatas, _CloudColorDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudLightData, _CloudLightData);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudMaxIterationAndStep, _CloudMaxIterationAndStep);
                                    cmd.SetGlobalFloatArray(ShaderParams._CloudGBA, _CloudGBA);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudBaseFBMs, _CloudBaseFBMs);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudDetailFBMs, _CloudDetailFBMs);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudUVscale, _CloudUVscale);
                                    cmd.SetGlobalVectorArray(ShaderParams._FBMSetDatas, _FBMSetDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._ShapeNoiseWeights, _ShapeNoiseWeights);
                                    cmd.SetGlobalVectorArray(ShaderParams._StratusCloudRangeData, _StratusCloudRangeData);
                                    cmd.SetGlobalVectorArray(ShaderParams._CumulusCloudRangeData, _CumulusCloudRangeData);
                                    cmd.SetGlobalVectorArray(ShaderParams._WeatherCloudSetData, _WeatherCloudSetData);
                                    cmd.SetGlobalVectorArray(ShaderParams._WeatherSetData, _WeatherSetData);
                                    cmd.SetGlobalVectorArray(ShaderParams._ColliderWindInfo, _ColliderWindInfo);
                                    cmd.SetGlobalVectorArray(ShaderParams._RayVolumeCloudCubeMin, _CubeMin);
                                    cmd.SetGlobalVectorArray(ShaderParams._RayVolumeCloudCubeMax, _CubeMax);
                                    cmd.SetGlobalMatrixArray(ShaderParams._RayVolumeCloudCubeWorldToLocal, _CubeWorldToLocal);
                                    cmd.SetGlobalMatrixArray(ShaderParams._RayVolumeCloudCubeLocalToWorld, _CubeLocalToWorld);
                                    cmd.SetGlobalVectorArray(ShaderParams._RayVolumeCloudCubeScale, _CubeScale);
                                }
                            }
                            cubeCount++;
                        }
                        break;
                    case VolumeCloudCollider.MeshTypeEnum.Sphere:
                        {
                            if (sphereCount < maxArrayCount)
                            {
                                if (volumeCloudCollider.SphereRangeChange())
                                {
                                    Vector3 center = Vector3.zero;
                                    float radius = 0;
                                    volumeCloudCollider.GetSphereRadius(ref center, ref radius);
                                    _SphereCenter[sphereCount] = center;
                                    _SphereRadius[sphereCount] = radius;
                                    _ColliderWindInfo[cubeCount] = new Vector4(volumeCloudCollider.WindDirection.x, volumeCloudCollider.WindDirection.y, volumeCloudCollider.WindDirection.z, Mathf.Abs(volumeCloudCollider.WindDirection.w));
                                    Vector4 weatherSetData = new Vector4(Mathf.Abs(volumeCloudCollider.WeatherSetData.x), Mathf.Abs(volumeCloudCollider.WeatherSetData.y),
                                        Mathf.Abs(volumeCloudCollider.WeatherSetData.z), Mathf.Abs(volumeCloudCollider.WeatherSetData.w));
                                    _WeatherSetData[cubeCount] = weatherSetData;
                                    Vector2 weatherCloudSetData = new Vector2(Mathf.Clamp(volumeCloudCollider.WeatherCloudSetData.x, 0f, 1f), Mathf.Clamp(volumeCloudCollider.WeatherCloudSetData.y, 0f, 1f));
                                    _WeatherCloudSetData[cubeCount] = new Vector4(weatherCloudSetData.x, weatherCloudSetData.y, 0, 0);

                                    Vector3 stratusCloudRangeData = new Vector3(Mathf.Clamp(volumeCloudCollider.StratusCloudRange.x, 0.01f, 0.5f), Mathf.Clamp(volumeCloudCollider.StratusCloudRange.y, 0.01f, 0.5f),
                                        0);
                                    stratusCloudRangeData.z = Mathf.Clamp(volumeCloudCollider.StratusCloudRange.z, stratusCloudRangeData.x, stratusCloudRangeData.y);
                                    _StratusCloudRangeData[cubeCount] = new Vector4(stratusCloudRangeData.x, stratusCloudRangeData.y, stratusCloudRangeData.z, 0);
                                    Vector3 cumulusCloudRangeData = new Vector3(Mathf.Clamp(volumeCloudCollider.CumulusCloudRange.x, 0.01f, 0.98f), Mathf.Clamp(volumeCloudCollider.CumulusCloudRange.y, 0.01f, 0.98f),
                                        0);
                                    cumulusCloudRangeData.z = Mathf.Clamp(volumeCloudCollider.CumulusCloudRange.z, cumulusCloudRangeData.x, cumulusCloudRangeData.y);
                                    _CumulusCloudRangeData[cubeCount] = new Vector4(cumulusCloudRangeData.x, cumulusCloudRangeData.y, cumulusCloudRangeData.z, 0);

                                    _WeatherMapDatas[cubeCount] = volumeCloudCollider.WeatherMap;
                                    switch (cubeCount)
                                    {
                                        case 0:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas0, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 1:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas1, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 2:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas2, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 3:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas3, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 4:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas4, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 5:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas5, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 6:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas6, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                        case 7:
                                            {
                                                cmd.SetGlobalTexture(ShaderParams._WeatherMapDatas7, _WeatherMapDatas[cubeCount]);
                                            }
                                            break;
                                    }
                                    Vector4 cloudWindSetData = new Vector4(Mathf.Abs(volumeCloudCollider.CloudWindSetData.x), Mathf.Abs(volumeCloudCollider.CloudWindSetData.y),
                                        Mathf.Abs(volumeCloudCollider.CloudWindSetData.z), Mathf.Abs(volumeCloudCollider.CloudWindSetData.w));
                                    _CloudWindSetData[cubeCount] = cloudWindSetData;
                                    _ShapeNoiseWeights[cubeCount] = new Vector4(volumeCloudCollider.ShapeNoiseWeightsR, volumeCloudCollider.ShapeNoiseWeightsG, volumeCloudCollider.ShapeNoiseWeightsB,
                                        volumeCloudCollider.ShapeNoiseWeightsA);
                                    Vector4 fbmSetData = new Vector4(Mathf.Abs(volumeCloudCollider.FBMSetDatas.x), volumeCloudCollider.FBMSetDatas.y, Mathf.Abs(volumeCloudCollider.FBMSetDatas.z), Mathf.Abs(volumeCloudCollider.FBMSetDatas.w));
                                    _FBMSetDatas[cubeCount] = fbmSetData;
                                    Vector4 cloudUVscale = new Vector4(Mathf.Abs(volumeCloudCollider.CloudUVscale.x), Mathf.Abs(volumeCloudCollider.CloudUVscale.y),
                                        Mathf.Abs(volumeCloudCollider.CloudUVscale.z), Mathf.Abs(volumeCloudCollider.CloudUVscale.w));
                                    _CloudUVscale[cubeCount] = cloudUVscale;
                                    switch (resolutionQuality)
                                    {
                                        case VolumeCloud.ResolutionQuality.Full:
                                            {
                                                cloudUVscale.z = cloudUVscale.z * 1.0f;
                                            }
                                            break;
                                        case VolumeCloud.ResolutionQuality.Half:
                                            {
                                                cloudUVscale.z = cloudUVscale.z * 0.25f;
                                            }
                                            break;
                                        case VolumeCloud.ResolutionQuality.Quarter:
                                            {
                                                cloudUVscale.z = cloudUVscale.z * 0.25f;
                                            }
                                            break;
                                    }
                                    Vector4 cloudBaseFBMs = new Vector4(volumeCloudCollider.BaseFBM_G, volumeCloudCollider.BaseFBM_B, volumeCloudCollider.BaseFBM_A, 0);
                                    _CloudBaseFBMs[cubeCount] = cloudBaseFBMs;
                                    Vector4 cloudDetailFBMs = new Vector4(volumeCloudCollider.DetailFBM_G, volumeCloudCollider.DetailFBM_B, volumeCloudCollider.DetailFBM_A, 0);
                                    _CloudDetailFBMs[cubeCount] = cloudDetailFBMs;
                                    if (volumeCloudCollider.GBA)
                                    {
                                        _CloudGBA[cubeCount] = 1;
                                    }
                                    else
                                    {
                                        _CloudGBA[cubeCount] = 0;
                                    }
                                    Vector4 cloudMaxIterationAndStep = new Vector4(volumeCloudCollider.MaxIteration, volumeCloudCollider.StepCountPerMeter, 0, 0);
                                    _CloudMaxIterationAndStep[cubeCount] = cloudMaxIterationAndStep;
                                    _CloudLightData[cubeCount] = volumeCloudCollider.CloudLightData;
                                    Vector4 cloudColorDatas = new Vector4(volumeCloudCollider.ColorCentralOffset, volumeCloudCollider.DarknessThreshold, 0, 0);
                                    _CloudColorDatas[cubeCount] = cloudColorDatas;
                                    _CloudColorDarkDatas[cubeCount] = new Vector4(volumeCloudCollider.ColorDark.r, volumeCloudCollider.ColorDark.g, volumeCloudCollider.ColorDark.b, volumeCloudCollider.ColorDark.a);
                                    _CloudColorCentralDatas[cubeCount] = new Vector4(volumeCloudCollider.ColorCentral.r, volumeCloudCollider.ColorCentral.g, volumeCloudCollider.ColorCentral.b, volumeCloudCollider.ColorCentral.a);
                                    _CloudColorBrightDatas[cubeCount] = new Vector4(volumeCloudCollider.ColorBright.r, volumeCloudCollider.ColorBright.g, volumeCloudCollider.ColorBright.b, volumeCloudCollider.ColorBright.a);
                                    _VolumeCloudPhaseParamsDatas[cubeCount] = volumeCloudCollider.PhaseParams;
                                    _VolumeCloudPhaseBaseDatas[cubeCount] = volumeCloudCollider.PhaseBase;
                                    _VolumeCloudPhaseWeightDatas[cubeCount] = volumeCloudCollider.PhaseWeight;

                                    cmd.SetGlobalVectorArray(ShaderParams._VolumeCloudPhaseParamsDatas, _VolumeCloudPhaseParamsDatas);
                                    cmd.SetGlobalFloatArray(ShaderParams._VolumeCloudPhaseBaseDatas, _VolumeCloudPhaseBaseDatas);
                                    cmd.SetGlobalFloatArray(ShaderParams._VolumeCloudPhaseWeightDatas, _VolumeCloudPhaseWeightDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudColorDarkDatas, _CloudColorDarkDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudColorCentralDatas, _CloudColorCentralDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudColorBrightDatas, _CloudColorBrightDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudColorDatas, _CloudColorDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudLightData, _CloudLightData);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudMaxIterationAndStep, _CloudMaxIterationAndStep);
                                    cmd.SetGlobalFloatArray(ShaderParams._CloudGBA, _CloudGBA);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudBaseFBMs, _CloudBaseFBMs);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudDetailFBMs, _CloudDetailFBMs);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudUVscale, _CloudUVscale);
                                    cmd.SetGlobalVectorArray(ShaderParams._FBMSetDatas, _FBMSetDatas);
                                    cmd.SetGlobalVectorArray(ShaderParams._ShapeNoiseWeights, _ShapeNoiseWeights);
                                    cmd.SetGlobalVectorArray(ShaderParams._CloudWindSetData, _CloudWindSetData);
                                    cmd.SetGlobalVectorArray(ShaderParams._StratusCloudRangeData, _StratusCloudRangeData);
                                    cmd.SetGlobalVectorArray(ShaderParams._CumulusCloudRangeData, _CumulusCloudRangeData);
                                    cmd.SetGlobalVectorArray(ShaderParams._WeatherCloudSetData, _WeatherCloudSetData);
                                    cmd.SetGlobalVectorArray(ShaderParams._WeatherSetData, _WeatherSetData);
                                    cmd.SetGlobalVectorArray(ShaderParams._ColliderWindInfo, _ColliderWindInfo);
                                    cmd.SetGlobalVectorArray(ShaderParams._RayVolumeCloudSphereCenter, _SphereCenter);
                                    cmd.SetGlobalFloatArray(ShaderParams._RayVolumeCloudSphereRadius, _SphereRadius);
                                }
                            }
                            sphereCount++;
                        }
                        break;
                }
            }
            cubeCount = Mathf.Min(cubeCount, maxArrayCount);
            cmd.SetGlobalInt(ShaderParams._RayVolumeCloudCubeCount, cubeCount);


            sphereCount = Mathf.Min(sphereCount, maxArrayCount);
            cmd.SetGlobalInt(ShaderParams._RayVolumeCloudSphereCount, sphereCount);


            cmd.Blit(cameraColorTarget, rayVolumeDepthTexture.id, material,1);
            cmd.SetGlobalTexture(ShaderParams._VolumeDepthTexture, rayVolumeDepthTexture.id);

            if (DistinguishFrame== DistinguishFrameType.Off)
            {
                cmd.Blit(cameraColorTarget, rayVolumeCloudTexture.id, material, 0);
                cmd.SetGlobalTexture(ShaderParams._VolumeCloudResColor, rayVolumeCloudTexture.id);
            }
            else
            {
                int lastRTIndex = rtIndex + 1;
                if (lastRTIndex>=2)
                {
                    lastRTIndex = 0;
                }
                RenderTexture curRT=null;
                RenderTexture lastRT = null;
                if (renderingData.cameraData.cameraType == CameraType.Game)
                {
                     curRT = framDatas[rtIndex];
                     lastRT = framDatas[lastRTIndex];
                }
                else
                {
                     curRT = framSceneDatas[rtIndex];
                     lastRT = framSceneDatas[lastRTIndex];
                }
                cmd.Blit(lastRT, curRT, material, 0);
                cmd.SetGlobalTexture(ShaderParams._VolumeCloudResColor, curRT);
            }

            cmd.Blit(cameraColorTarget, volumeCloudTemTexture.id, material, 2);
            cmd.Blit(volumeCloudTemTexture.id, cameraColorTarget);
        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(rayVolumeCloudTexture.id);
        cmd.ReleaseTemporaryRT(volumeCloudTemTexture.id);
        cmd.ReleaseTemporaryRT(rayVolumeDepthTexture.id);
    }


    public static class ShaderParams
    {
        public static readonly int _VolumeInverseProjectionMatrix = Shader.PropertyToID(string.Intern("_VolumeInverseProjectionMatrix"));

        public static readonly int _VolumeCameraToWorldMatrix = Shader.PropertyToID(string.Intern("_VolumeCameraToWorldMatrix"));

        public static readonly int _RayVolumeCloudCubeCount = Shader.PropertyToID(string.Intern("_RayVolumeCloudCubeCount"));

        public static readonly int _RayVolumeCloudCubeMin = Shader.PropertyToID(string.Intern("_RayVolumeCloudCubeMin"));

        public static readonly int _RayVolumeCloudCubeMax = Shader.PropertyToID(string.Intern("_RayVolumeCloudCubeMax"));

        public static readonly int _RayVolumeCloudCubeScale = Shader.PropertyToID(string.Intern("_RayVolumeCloudCubeScale"));

        public static readonly int _ColliderWindInfo = Shader.PropertyToID(string.Intern("_ColliderWindInfo"));

        public static readonly int _RayVolumeCloudCubeWorldToLocal = Shader.PropertyToID(string.Intern("_RayVolumeCloudCubeWorldToLocal"));

        public static readonly int _RayVolumeCloudCubeLocalToWorld = Shader.PropertyToID(string.Intern("_RayVolumeCloudCubeLocalToWorld"));

        public static readonly int _RayVolumeCloudSphereCount = Shader.PropertyToID(string.Intern("_RayVolumeCloudSphereCount"));

        public static readonly int _RayVolumeCloudSphereCenter = Shader.PropertyToID(string.Intern("_RayVolumeCloudSphereCenter"));

        public static readonly int _RayVolumeCloudSphereRadius = Shader.PropertyToID(string.Intern("_RayVolumeCloudSphereRadius"));

        public static readonly int _VolumeCloudMaxIteration = Shader.PropertyToID(string.Intern("_VolumeCloudMaxIteration"));

        public static readonly int _VolumeCloudStepCountPerMeter = Shader.PropertyToID(string.Intern("_VolumeCloudStepCountPerMeter"));

        public static readonly int  _VolumeCloudNoise3DTex = Shader.PropertyToID(string.Intern("_VolumeCloudNoise3DTex"));

        public static readonly int _VolumeCloudWeatherAndSpeedMap = Shader.PropertyToID(string.Intern("_VolumeCloudWeatherAndSpeedMap"));

        public static readonly int _VolumeCloudWeatherAndSpeedMapScale = Shader.PropertyToID(string.Intern("_VolumeCloudWeatherAndSpeedMapScale"));

        public static readonly int _VolumeCloudBlueNoiseMap = Shader.PropertyToID(string.Intern("_VolumeCloudBlueNoiseMap"));

        public static readonly int _VolumeCloudBlueNoiseCoords = Shader.PropertyToID(string.Intern("_VolumeCloudBlueNoiseCoords"));

        public static readonly int _VolumeCloudPhaseParams = Shader.PropertyToID(string.Intern("_VolumeCloudPhaseParams"));

        public static readonly int _VolumeCloudBlueNoiseTexScale = Shader.PropertyToID(string.Intern("_VolumeCloudBlueNoiseTexScale"));

        public static readonly int _VolumeCloudRayAbsorptionScale = Shader.PropertyToID(string.Intern("_VolumeCloudRayAbsorptionScale"));

        public static readonly int _VolumeCloudLightAbsorptionScale = Shader.PropertyToID(string.Intern("_VolumeCloudLightAbsorptionScale"));

        public static readonly int _VolumeCloudDetailNoise3DTex = Shader.PropertyToID(string.Intern("_VolumeCloudDetailNoise3DTex"));

        public static readonly int _VolumeCloudDetailWeights = Shader.PropertyToID(string.Intern("_VolumeCloudDetailWeights"));

        public static readonly int _VolumeCloudDensityMultiplier = Shader.PropertyToID(string.Intern("_VolumeCloudDensityMultiplier"));

        public static readonly int _VolumeCloudResColor = Shader.PropertyToID(string.Intern("_VolumeCloudResColor"));

        public static readonly int _VolumeCloudLightStrength = Shader.PropertyToID(string.Intern("_VolumeCloudLightStrength"));

        public static readonly int _VolumeCloudLightmarchLerp = Shader.PropertyToID(string.Intern("_VolumeCloudLightmarchLerp"));

        //
        public static readonly int _DensityDifferenceValue = Shader.PropertyToID(string.Intern("_DensityDifferenceValue"));

        public static readonly int _ThicknessDifferenceValue = Shader.PropertyToID(string.Intern("_ThicknessDifferenceValue"));

        public static readonly int _WeatherWindSpeed = Shader.PropertyToID(string.Intern("_WeatherWindSpeed"));

        public static readonly int _StratusCloudRange = Shader.PropertyToID(string.Intern("_StratusCloudRange"));
        public static readonly int _StratusCloudMid = Shader.PropertyToID(string.Intern("_StratusCloudMid"));
        public static readonly int _CumulusCloudRange = Shader.PropertyToID(string.Intern("_CumulusCloudRange"));
        public static readonly int _CumulusCloudMid = Shader.PropertyToID(string.Intern("_CumulusCloudMid"));
        public static readonly int _CloudAbsorbAdjust = Shader.PropertyToID(string.Intern("_CloudAbsorbAdjust"));

        public static readonly int _VolumeCloudBaseFBM = Shader.PropertyToID(string.Intern("_VolumeCloudBaseFBM"));
        public static readonly int _VolumeCloudDetailFBM = Shader.PropertyToID(string.Intern("_VolumeCloudDetailFBM"));

        public static readonly int _BaseShapeDetailEffect = Shader.PropertyToID(string.Intern("_BaseShapeDetailEffect"));

        public static readonly int _BaseShapeDetailEffectEdge = Shader.PropertyToID(string.Intern("_BaseShapeDetailEffectEdge"));
        public static readonly int _CircleBaseShapeTiling = Shader.PropertyToID(string.Intern("_CircleBaseShapeTiling"));
        public static readonly int _CircleDetailTiling = Shader.PropertyToID(string.Intern("_CircleDetailTiling"));
        public static readonly int _VolumeCloudWindInfo = Shader.PropertyToID(string.Intern("_VolumeCloudWindInfo"));

        public static readonly int _WeatherSetData = Shader.PropertyToID(string.Intern("_WeatherSetData"));

        public static readonly int _WeatherCloudSetData = Shader.PropertyToID(string.Intern("_WeatherCloudSetData"));

        public static readonly int _StratusCloudRangeData = Shader.PropertyToID(string.Intern("_StratusCloudRangeData"));
        public static readonly int _CumulusCloudRangeData = Shader.PropertyToID(string.Intern("_CumulusCloudRangeData"));
        public static readonly int _WeatherMapDatas0 = Shader.PropertyToID(string.Intern("_WeatherMapDatas0"));
        public static readonly int _WeatherMapDatas1 = Shader.PropertyToID(string.Intern("_WeatherMapDatas1"));
        public static readonly int _WeatherMapDatas2 = Shader.PropertyToID(string.Intern("_WeatherMapDatas2"));
        public static readonly int _WeatherMapDatas3 = Shader.PropertyToID(string.Intern("_WeatherMapDatas3"));
        public static readonly int _WeatherMapDatas4 = Shader.PropertyToID(string.Intern("_WeatherMapDatas4"));
        public static readonly int _WeatherMapDatas5 = Shader.PropertyToID(string.Intern("_WeatherMapDatas5"));
        public static readonly int _WeatherMapDatas6 = Shader.PropertyToID(string.Intern("_WeatherMapDatas6"));
        public static readonly int _WeatherMapDatas7 = Shader.PropertyToID(string.Intern("_WeatherMapDatas7"));

        public static readonly int _CloudWindSetData = Shader.PropertyToID(string.Intern("_CloudWindSetData"));
        public static readonly int _ShapeNoiseWeights = Shader.PropertyToID(string.Intern("_ShapeNoiseWeights"));

        public static readonly int _FBMSetDatas = Shader.PropertyToID(string.Intern("_FBMSetDatas"));
        public static readonly int _CloudUVscale = Shader.PropertyToID(string.Intern("_CloudUVscale"));

        public static readonly int _CloudBaseFBMs = Shader.PropertyToID(string.Intern("_CloudBaseFBMs"));

        public static readonly int _CloudDetailFBMs = Shader.PropertyToID(string.Intern("_CloudDetailFBMs"));
        public static readonly int _CloudGBA = Shader.PropertyToID(string.Intern("_CloudGBA"));
        public static readonly int _CloudMaxIterationAndStep = Shader.PropertyToID(string.Intern("_CloudMaxIterationAndStep"));
        public static readonly int _CloudLightData = Shader.PropertyToID(string.Intern("_CloudLightData"));


        public static readonly int _CloudColorCentralOffset = Shader.PropertyToID(string.Intern("_CloudColorCentralOffset"));
        public static readonly int _CloudDarknessThreshold = Shader.PropertyToID(string.Intern("_CloudDarknessThreshold"));
        public static readonly int _CloudColorDark = Shader.PropertyToID(string.Intern("_CloudColorDark"));
        public static readonly int _CloudColorCentral = Shader.PropertyToID(string.Intern("_CloudColorCentral"));
        public static readonly int _CloudColorBright = Shader.PropertyToID(string.Intern("_CloudColorBright"));

        public static readonly int _CloudColorDatas = Shader.PropertyToID(string.Intern("_CloudColorDatas"));
        public static readonly int _CloudColorDarkDatas = Shader.PropertyToID(string.Intern("_CloudColorDarkDatas"));
        public static readonly int _CloudColorCentralDatas = Shader.PropertyToID(string.Intern("_CloudColorCentralDatas"));
        public static readonly int _CloudColorBrightDatas = Shader.PropertyToID(string.Intern("_CloudColorBrightDatas"));

        public static readonly int _VolumeCloudPhaseBase = Shader.PropertyToID(string.Intern("_VolumeCloudPhaseBase"));
        public static readonly int _VolumeCloudPhaseWeight = Shader.PropertyToID(string.Intern("_VolumeCloudPhaseWeight"));

        public static readonly int _VolumeCloudPhaseBaseDatas = Shader.PropertyToID(string.Intern("_VolumeCloudPhaseBaseDatas"));
        public static readonly int _VolumeCloudPhaseWeightDatas = Shader.PropertyToID(string.Intern("_VolumeCloudPhaseWeightDatas"));
        public static readonly int _VolumeCloudPhaseParamsDatas = Shader.PropertyToID(string.Intern("_VolumeCloudPhaseWeightDatas"));

        public static readonly int _DistinguishWidth = Shader.PropertyToID(string.Intern("_DistinguishWidth"));
        public static readonly int _DistinguishHeight = Shader.PropertyToID(string.Intern("_DistinguishHeight"));
        public static readonly int _DistinguishIndex = Shader.PropertyToID(string.Intern("_DistinguishIndex"));
        public static readonly int _VolumeDepthTexture = Shader.PropertyToID(string.Intern("_VolumeDepthTexture"));
    }

}
