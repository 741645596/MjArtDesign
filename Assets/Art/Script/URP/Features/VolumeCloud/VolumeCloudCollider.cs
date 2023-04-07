using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class VolumeCloudCollider : MonoBehaviour
{
    [Header("运行时显示区域模型")]
    public bool ShowLineOnPlay = false;

    [HideInInspector]
    [Header("运行时显示区域模型材质")]
    public Material ShowMat;

    [Header("区域形状")]
    public MeshTypeEnum MeshType = MeshTypeEnum.Cube;

    [Header("区域尺寸")]
    public Vector3 Size = new Vector3 (1500, 100, 1500);

    public static List<VolumeCloudCollider> Colliders = new List<VolumeCloudCollider>();

    /// <summary>
    /// 刷新渲染排序
    /// </summary>
    static void FreshCollidersOrder()
    {

        for (int i=0,listCount= Colliders.Count;i< listCount;++i)
        {
            VolumeCloudCollider volumeCloudCollider = Colliders[i];
            volumeCloudCollider.FeshCameraFarDis();
        }

        Colliders.Sort((A,B)=> {
           return A.cameraFarDis.CompareTo(B.cameraFarDis);
        });
        Colliders.Reverse();
        FreshCollidersUsability();
    }

    /// <summary>
    /// 刷新穿插可用性
    /// </summary>
    static void FreshCollidersUsability()
    {
        for (int i = 0, listCount = Colliders.Count; i < listCount; ++i)
        {
            VolumeCloudCollider volumeCloudCollider = Colliders[i];
            Vector3 volumeCenter = volumeCloudCollider.thisCenter;
            float volumeRadius = volumeCloudCollider.thisRadius;
            volumeCloudCollider.Usability = true;
            for (int j = 0; j < listCount; ++j)
            {
                if (j!= i)
                {
                    VolumeCloudCollider nextCollider = Colliders[j];
                    Vector3 nextCenter = nextCollider.thisCenter;
                    float nextRadius = nextCollider.thisRadius;
                    if (Vector3.Distance(volumeCenter, nextCenter) <=(volumeRadius+ nextRadius))
                    {
                        volumeCloudCollider.Usability = false;
                        break;
                    }
                }
            }
        }
    }

    bool usability=true;

    /// <summary>
    /// 当前的可用性
    /// </summary>
    public bool Usability
    {
        get
        {
            return usability;
        }
        set
        {
            usability = value;
            if (usability)
            {
                ShowMat.SetColor(string.Intern("_MainColor"),new Color (0,1f, 0.2658609f, 0.1921569f));
            }
            else
            {
                ShowMat.SetColor(string.Intern("_MainColor"), new Color(1, 0f, 0.2658609f, 0.1921569f));
            }
        }
    }

    [Space(30)]

    #region//体积参数设定

    [Range(1, 64)]
    [Header("最大迭代次数")]
    public int MaxIteration = 24;

    [Range(0.01f, 20f)]
    [Header("每米步进次数")]
    public float StepCountPerMeter = 0.12f;

    [Header("米氏散射")]
    public Vector4 PhaseParams = new Vector4(0.6f, 0.6f, 0.55f, 0.6f);

    [Range(0f, 1f)]
    [Header("米氏散射基础值")]
    public float PhaseBase = 0.605f;

    [Range(0f, 1f)]
    [Header("米氏散射权重")]
    public float PhaseWeight = 1f;

    [Header("x:灯光强度 y:吸收倍数 视线方向 z ：吸收倍数 灯光方向 w:RGB插值")]
    public Vector4 CloudLightData = new Vector4(0.7f, 0.418f, 0.049f, 0.069f);

    [Range(0f, 1f)]
    [Header("颜色偏移")]
    public float ColorCentralOffset = 0.5f;

    [Range(0f, 1f)]
    [Header("暗部偏移")]
    public float DarknessThreshold = 0.143f;

    [Header("color A")]
    public Color ColorDark = new Color(0.901f, 0.9225515f, 1f, 1f);

    [Header("color B")]
    public Color ColorCentral = new Color(0.37808f, 0.4254858f, 0.544f, 1f);

    [Header("color C")]
    public Color ColorBright = new Color(0.03464706f, 0.05023367f, 0.05882353f, 1f);

    [Header("Weather纹理")]
    public Texture2D WeatherMap;

    [Header("xyz:风向 w:风速")]
    public Vector4 WindDirection =new Vector4(0.5f, 0.15f, 0.3f, 0.05f);

    [Header("x:Weather uv缩放 y:Weather风速缩放 z:吸收率缩放")]
    public Vector4 WeatherSetData = new Vector4(1f, 0.012f, 0.7f, 0f);

    [Header("x:密度插值 y:厚度插值")]
    public Vector2 WeatherCloudSetData = new Vector4(0.855f, 0.918f);

    [Header("x:层云下限 y:层云上限 z:层云插值")]
    public Vector3 StratusCloudRange = new Vector3(0.0806579f, 0.4129605f, 0.201f);

    [Header("x:积云下限 y:积云上限 z:积云插值")]
    public Vector3 CumulusCloudRange = new Vector3(0.06567776f, 0.7671939f, 0.05f);

    [Header("x:主体风速缩放 y:细节风速缩放 z:扭曲缩放 w:细节上升速度缩放")]
    public Vector4 CloudWindSetData = new Vector4(1f, 0.4f, 0.03f, 0.4f);

    [Header("x:细节边缘Pow y:布朗偏移 z:密度缩放 w:边缘倍数")]
    public Vector4 FBMSetDatas = new Vector4(10f, 0.176f, 0.198f, 1f);

    [Header("x:主体UV缩放 y:细节UV缩放 z:抖动UV缩放 w:")]
    public Vector4 CloudUVscale = new Vector4(0.0012f, 0.0156f, 12f,0f);

    [Space(30)]
    [Range(-1f,1f)]
    [Header("主体形状 R")]
    public float ShapeNoiseWeightsR = 0.06f;

    [Range(-1f, 1f)]
    public float ShapeNoiseWeightsG = 0.46f;

    [Range(-1f, 1f)]
    public float ShapeNoiseWeightsB = 0.26f;

    [Range(-1f, 1f)]
    public float ShapeNoiseWeightsA = -0.63f;

    #region// GBA

    [Space(30)]

    public bool GBA = false;

    [Range(-1f, 1f)]
    [Header("主体形状")]
    public float BaseFBM_G = 0.817f;

    [Range(-1f, 1f)]
    public float BaseFBM_B = 0.353f;

    [Range(-1f, 1f)]
    public float BaseFBM_A = 0.043f;

    [Range(-1f, 1f)]
    [Header("细节形状")]
    public float DetailFBM_G = 1f;

    [Range(-1f, 1f)]
    public float DetailFBM_B = 0.707f;

    [Range(-1f, 1f)]
    public float DetailFBM_A = 0.426f;

    #endregion

    #endregion

    static string layerName = "VolumeCollider";

    static string tagCube = "VolumeColliderCube";

    static string tagSphere = "VolumeColliderSphere";

    static int setLayer=-1;

    Transform _transform;

    GameObject _gameObject;

    /// <summary>
    /// 射线Box相交  box需要水平放置
    /// </summary>
    /// <param name="boundsMin">box最小点</param>
    /// <param name="boundsMax">box最大点</param>
    /// <param name="rayOrigin">射线起点</param>
    /// <param name="invRaydir">射线方向</param>
    /// <returns>x:射入交点距离射线起始点距离 y:射出交点距离射入交点的距离</returns>
    Vector2 RayBoxDst(Vector3 boundsMin, Vector3 boundsMax,
                    //世界相机位置      光线方向倒数
        Vector3 rayOrigin, Vector3 invRaydir)
    {

        float y = boundsMax.y - boundsMin.y;
        Vector3 v1 = boundsMin - rayOrigin;
        v1 = new Vector3(v1.x* invRaydir.x, v1.y * invRaydir.y, v1.z * invRaydir.z);
        Vector3 v2 = boundsMax - rayOrigin;
        v2 = new Vector3(v2.x * invRaydir.x, v2.y * invRaydir.y, v2.z * invRaydir.z);

        Vector3 t0 = v1;
        Vector3 t1 = v2;
        Vector3 tmin = new Vector3(Mathf.Min(t0.x, t1.x), Mathf.Min(t0.y, t1.y), Mathf.Min(t0.z, t1.z)); 
        Vector3 tmax = new Vector3(Mathf.Max(t0.x, t1.x), Mathf.Max(t0.y, t1.y), Mathf.Max(t0.z, t1.z)); 

        float dstA = Mathf.Max(Mathf.Max(tmin.x, tmin.y), tmin.z); //进入点
        float dstB = Mathf.Min(tmax.x, Mathf.Min(tmax.y, tmax.z)); //出去点

        float dstToBox = Mathf.Max(0, dstA);
        float dstInsideBox = Mathf.Max(0, dstB - dstToBox);
        return new Vector2(dstToBox, dstInsideBox);
    }

    /// <summary>
    /// 射线球相交
    /// </summary>
    /// <param name="sphereCenter">球心</param>
    /// <param name="sphereRadius">半径</param>
    /// <param name="rayOrigin">射线起点</param>
    /// <param name="raydir">射线方向</param>
    /// <returns>x:射入交点距离射线起始点距离 y:射出交点距离射入交点的距离</returns>
    Vector2 RaySphereDst(Vector3 sphereCenter, float sphereRadius, Vector3 rayOrigin, Vector3 raydir)
    {
        Vector3 oc = rayOrigin - sphereCenter;
        float b = Vector3.Dot(raydir, oc);
        float c = Vector3.Dot(oc, oc) - sphereRadius * sphereRadius;
        float t = b * b - c;//t > 0有两个交点, = 0 相切， < 0 不相交
        float delta =Mathf.Sqrt(Mathf.Max(t, 0));
        float dstToSphere = Mathf.Max(-b - delta, 0);
        float dstInSphere = Mathf.Max(-b + delta - dstToSphere, 0);
        return new Vector2(dstToSphere, dstInSphere);
    }

    float cameraFarDis = 0;

    /// <summary>
    /// 计算相机检测距离
    /// </summary>
    /// <returns></returns>
    void FeshCameraFarDis()
    {
        Transform transMainCam = Camera.main.transform;
        switch (MeshType)
        {
            case MeshTypeEnum.Cube:
                {
                    Vector3 boundsMin = Vector3.zero - Vector3.one * 0.5f;
                    Vector3 boundsMax = Vector3.zero + Vector3.one * 0.5f;
                    Vector3 camPos = Camera.main.transform.position;
                    Vector3 camPosB = camPos + Camera.main.transform.forward;
                    camPos = transform.InverseTransformPoint(camPos);
                    camPosB = transform.InverseTransformPoint(camPosB);
                    Vector3 rayDir = (camPosB - camPos).normalized;
                    Vector3 invRaydir = new Vector3(1f / rayDir.x, 1f / rayDir.y, 1f / rayDir.z);
                    Vector2 res = RayBoxDst(boundsMin, boundsMax, camPos, invRaydir);
                    camPosB = camPos + rayDir * (res.x+res.y);
                    camPos = transform.TransformPoint(camPos);
                    camPosB = transform.TransformPoint(camPosB);
                    cameraFarDis = Vector3.Distance(camPos, camPosB);
                }
                break;
            case MeshTypeEnum.Sphere:
                {
                    Vector3 camPos = Camera.main.transform.position;
                    Vector3 camPosB = camPos + Camera.main.transform.forward;
                    Vector3 rayDir = (camPosB - camPos).normalized;
                    Vector2 res = RaySphereDst(transform.position, Size.x * 0.5f, camPos, rayDir);
                    camPosB = camPos + rayDir * (res.x + res.y);
                    cameraFarDis = Vector3.Distance(camPos, camPosB);
                }
                break;
        }
    }

    GameObject obj1;

    GameObject obj2;

    void JJJJJ()
    {
        Vector3 kkkk1  = Vector3.zero - Vector3.one * 0.5f;
        Vector3 kkkk2 = Vector3.zero + Vector3.one * 0.5f;

        //kkkk1 = _transform.TransformPoint(kkkk1);
        //kkkk2 = _transform.TransformPoint(kkkk2);

        Vector3 camPos = Camera.main.transform.position;
        Vector3 camPosB = camPos + Camera.main.transform.forward;
        camPos = transform.InverseTransformPoint(camPos);
        camPosB = transform.InverseTransformPoint(camPosB);

        Vector3 invRaydir =(camPosB- camPos).normalized;
        invRaydir = new Vector3(1f/ invRaydir.x,1f/ invRaydir.y,1f/ invRaydir.z);
        Vector2 res = RayBoxDst(kkkk1, kkkk2, camPos, invRaydir);

 

        if (obj1==null)
        {
            obj1 = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            obj1.name = "obj1";
            //obj1.transform.SetParent(_transform);
        }

        Vector3 loclPos1 = camPos + res.x * (camPosB - camPos).normalized;
        obj1.transform.position = transform.TransformPoint(loclPos1);


        if (obj2 == null)
        {
            obj2 = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            obj2.name = "obj2";
            //obj2.transform.SetParent(_transform);
        }
        Vector3 loclPos2 = loclPos1 + res.y * (camPosB - camPos).normalized;
        obj2.transform.position = transform.TransformPoint(loclPos2);
    }

    private void Start()
    {
        if (Application.isPlaying)
        {
            VolumeCloudColliderManager.CloudColliderManager.AddCollider(this);
        }
        Init();
        DrawMesh();
    }

    private void OnEnable()
    {
        Colliders.Add(this);
        FreshCollidersOrder();
    }

    private void OnDisable()
    {
        Colliders.Remove(this);
        FreshCollidersUsability();
    }

    private void Update()
    {
        //JJJJJ();
        ChangeCheck();
    }

    private void OnDestroy()
    {
        if (Application.isPlaying)
        {
            if (ShowMat!=null)
            {
                GameObject.Destroy(ShowMat);
                ShowMat = null;
            }
            VolumeCloudColliderManager.CloudColliderManager.RemoveCollider(this);
        }
    }

    void Init()
    {
        if (_transform == null)
        {
            _transform = transform;
        }
        if (_gameObject == null)
        {
            _gameObject = gameObject;
        }
        if (setLayer == -1)
        {
            setLayer = LayerMask.NameToLayer(string.Intern(layerName));
        }
        if (_gameObject.layer!= setLayer)
        {
            _gameObject.layer = setLayer;
        }
        if (ShowMat==null)
        {
            ShowMat = new Material(Shader.Find("FB/PostProcessing/RayVolumeCloud/VolumeCloudCollider"));
            switch (MeshType)
            {
                case MeshTypeEnum.Cube:
                    {
                        ShowMat.SetFloat(string.Intern("_CenterDis"),1.0f);
                        ShowMat.DisableKeyword(string.Intern("ENBLE_SP_VDOTN"));
                    }
                    break;
                case MeshTypeEnum.Sphere:
                    {
                        ShowMat.SetFloat(string.Intern("_CenterDis"), 1.4142f);
                        ShowMat.EnableKeyword(string.Intern("ENBLE_SP_VDOTN"));
                    }
                    break;
            }
        }
    }

    private void OnDrawGizmos()
    {
        Init();
        switch (MeshType)
        {
            case MeshTypeEnum.Cube:
                {
                    transform.localScale = Size;
                }
                break;
            case MeshTypeEnum.Sphere:
                {
                    transform.localScale = Size.x*0.5f*Vector3.one;
                }
                break;
        }
        DrawMesh();
        FreshCubeRange();
        FreshSphereRange();
    }

    Vector3 saveSize = Vector3.zero;

    bool saveShowLineOnPlay;

    MeshTypeEnum saveMeshType;

    Material saveShowMat;

    Vector3 savePosWS;

    void ChangeCheck()
    {
        if (saveSize!= Size)
        {
            saveSize = Size;
            _transform.localScale = Size;
            FreshCubeRange();
            FreshSphereRange();
            FreshCollidersOrder();
            FreshCenterAndRadius();
        }
        if (saveShowLineOnPlay!= ShowLineOnPlay || saveMeshType!= MeshType || saveShowMat!= ShowMat)
        {
            saveShowLineOnPlay = ShowLineOnPlay;
            saveMeshType = MeshType;
            saveShowMat = ShowMat;
            DrawMesh();
            FreshCubeRange();
            FreshSphereRange();
            FreshCenterAndRadius();
            switch (MeshType)
            {
                case MeshTypeEnum.Cube:
                    {
                        ShowMat.SetFloat(string.Intern("_CenterDis"), 1.0f);
                        ShowMat.DisableKeyword(string.Intern("ENBLE_SP_VDOTN"));
                    }
                    break;
                case MeshTypeEnum.Sphere:
                    {
                        ShowMat.SetFloat(string.Intern("_CenterDis"), 1.4142f);
                        ShowMat.EnableKeyword(string.Intern("ENBLE_SP_VDOTN"));
                    }
                    break;
            }
        }
        if (savePosWS!=_transform.position)
        {
            savePosWS = _transform.position;
            FreshCenterAndRadius();
        }

    }

    void DrawMesh()
    {
        switch (MeshType)
        {
            case MeshTypeEnum.Cube:
                {
                    if (!_transform.CompareTag(string.Intern(tagCube)))
                    {
                        _transform.tag = string.Intern(tagCube);
                    }
                    DrawCube();
                }
                break;
            case MeshTypeEnum.Sphere:
                {
                    if (!_transform.CompareTag(string.Intern(tagSphere)))
                    {
                        _transform.tag = string.Intern(tagSphere);
                    }
                    DrawSphere();
                }
                break;
        }
    }

    Vector3 thisCenter;

    float thisRadius;

    void FreshCenterAndRadius()
    {
        thisCenter = sphereCenter;
        switch (MeshType)
        {
            case MeshTypeEnum.Cube:
                {
                    Vector3 scale = _transform.lossyScale;
                    float f = Mathf.Sqrt(scale.x * scale.x + scale.z * scale.z);
                    f = Mathf.Sqrt(f * f + scale.y * scale.y);
                    thisRadius = f * 0.5f;
                }
                break;
            case MeshTypeEnum.Sphere:
                {
                    thisRadius = sphereRadius;
                }
                break;
        }
        FreshCollidersUsability();
    }

    public void GetCenterAndRadius(ref Vector3 centor ,ref float radius)
    {
        if (_transform==null)
        {
            _transform = transform;
        }
        centor = _transform.position;
        switch (MeshType)
        {
            case MeshTypeEnum.Cube:
                {
                    Vector3 scale = _transform.lossyScale;
                    float f = Mathf.Sqrt(scale.x * scale.x + scale.z * scale.z);
                    f = Mathf.Sqrt(f * f + scale.y * scale.y);
                    radius = f * 0.5f;
                }
                break;
            case MeshTypeEnum.Sphere:
                {
                    radius = sphereRadius;
                }
                break;
        }
    }

    static Vector3 defoultPos = new Vector3(-100000f,-100000f,-100000f);

    BoxCollider boxCollider;

    Transform cubeRoot;

    MeshRenderer cubeMeshRenderer;

    Vector3 cubMinPos=new Vector3 (-0.5f,-0.5f,-0.5f);

    Vector3 cubMaxPos = new Vector3(0.5f, 0.5f, 0.5f);

    Matrix4x4 cubWorldToLocal;

    Matrix4x4 cubLocalToWorld;

    void FreshCubeRange()
    {
        if (_transform == null)
        {
            _transform = transform;
        }
        cubWorldToLocal = _transform.worldToLocalMatrix;
        cubLocalToWorld = _transform.localToWorldMatrix;
        sphereCenter = _transform.position;
    }

    Vector4 oldWindDirection;

    Vector4 oldWeatherSetData;

    Vector2 oldWeatherCloudSetData;

    Vector3 oldStratusCloudRange;

    Vector3 oldCumulusCloudRange;

    Texture2D oldWeatherMap;

    Vector4 oldCloudWindSetData;

    float oldShapeNoiseWeightsR;

    float oldShapeNoiseWeightsG;

    float oldShapeNoiseWeightsB;

    float oldShapeNoiseWeightsA;

    Vector4 oldFBMSetDatas;

    Vector4 oldCloudUVscale;

    int oldMaxIteration;

    float oldStepCountPerMeter;

    float oldBaseFBM_G;
    float oldBaseFBM_B;
    float oldBaseFBM_A;

    float oldDetailFBM_G;
    float oldDetailFBM_B;
    float oldDetailFBM_A;

    bool oldGBA;

    float oldColorCentralOffset;

    float oldDarknessThreshold;

    Vector4 oldCloudLightData;

    Color oldColorDark;
    Color oldColorCentral;
    Color oldColorBright;

    Vector4 oldPhaseParams;

    float oldPhaseBase;
    float oldPhaseWeight;

    bool SetDataChange()
    {
        if (oldWindDirection!= WindDirection || oldWeatherSetData!= WeatherSetData || oldWeatherCloudSetData!= WeatherCloudSetData
            || oldStratusCloudRange != StratusCloudRange || oldCumulusCloudRange != CumulusCloudRange || oldWeatherMap!= WeatherMap
            || oldCloudWindSetData!= CloudWindSetData || oldShapeNoiseWeightsR != ShapeNoiseWeightsR || oldShapeNoiseWeightsG!= ShapeNoiseWeightsG
            || oldShapeNoiseWeightsB!= ShapeNoiseWeightsB || oldShapeNoiseWeightsA!= ShapeNoiseWeightsA || oldFBMSetDatas!= FBMSetDatas
            || oldCloudUVscale!= CloudUVscale || oldBaseFBM_G!= BaseFBM_G || oldBaseFBM_B!= BaseFBM_B || oldBaseFBM_A!= BaseFBM_A
            || oldDetailFBM_G!= DetailFBM_G || oldDetailFBM_B!= DetailFBM_B || oldDetailFBM_A!= DetailFBM_A || oldGBA!= GBA
            || oldMaxIteration!= MaxIteration || oldStepCountPerMeter!= StepCountPerMeter || oldCloudLightData!= CloudLightData
            || oldColorCentralOffset!= ColorCentralOffset|| oldDarknessThreshold!= DarknessThreshold
            || oldColorDark!= ColorDark || oldColorCentral!= ColorCentral || oldColorBright!= ColorBright
            || oldPhaseParams!= PhaseParams || oldPhaseBase!= PhaseBase || oldPhaseWeight!= PhaseWeight)
        {
            oldWindDirection = WindDirection;
            oldWeatherSetData = WeatherSetData;
            oldWeatherCloudSetData = WeatherCloudSetData;
            oldStratusCloudRange = StratusCloudRange;
            oldCumulusCloudRange = CumulusCloudRange;
            oldWeatherMap = WeatherMap;
            oldCloudWindSetData = CloudWindSetData;
            oldShapeNoiseWeightsR = ShapeNoiseWeightsR;
            oldShapeNoiseWeightsG = ShapeNoiseWeightsG;
            oldShapeNoiseWeightsB = ShapeNoiseWeightsB;
            oldShapeNoiseWeightsA = ShapeNoiseWeightsA;
            oldFBMSetDatas = FBMSetDatas;
            oldCloudUVscale = CloudUVscale;
            oldBaseFBM_G = BaseFBM_G;
            oldBaseFBM_B = BaseFBM_B;
            oldBaseFBM_A = BaseFBM_A;
            oldDetailFBM_G = DetailFBM_G;
            oldDetailFBM_B = DetailFBM_B;
            oldDetailFBM_A = DetailFBM_A;
            oldGBA = GBA;
            oldMaxIteration = MaxIteration;
            oldStepCountPerMeter = StepCountPerMeter;
            oldCloudLightData = CloudLightData;
            oldColorCentralOffset = ColorCentralOffset;
            oldDarknessThreshold = DarknessThreshold;
            oldColorDark = ColorDark;
            oldColorCentral = ColorCentral;
            oldColorBright = ColorBright;
            oldPhaseParams = PhaseParams;
            oldPhaseBase = PhaseBase;
            oldPhaseWeight = PhaseWeight;
            return true; 
        }
        return false;
    }

    Vector3 oldLossyScale;

    Vector3 oldCubMinPos;

    Vector3 oldCubMaxPos;

    Vector3 oldEulerAngles;

    Vector3 oldPosition;

    public bool CubeRangeChange()
    {
        if (_transform == null)
        {
            _transform = transform;
        }
        if (oldLossyScale != _transform.lossyScale || oldCubMinPos!= cubMinPos || oldCubMaxPos!= cubMaxPos || oldEulerAngles!= _transform.eulerAngles || oldPosition!= _transform.position
            || SetDataChange())
        {
            oldLossyScale = _transform.lossyScale;
            oldCubMinPos = cubMinPos;
            oldCubMaxPos = cubMaxPos;
            oldEulerAngles = _transform.eulerAngles;
            oldPosition = _transform.position;
            return true;
        }
        return false;
    }

    public void GetCubeRange(ref Vector3 scale, ref Vector3 minPos,ref Vector3 maxPos,ref Matrix4x4 worldToLocal, ref Matrix4x4 localToWorld)
    {
        if (_transform == null)
        {
            _transform = transform;
        }
        scale = _transform.lossyScale;
        minPos = cubMinPos;
        maxPos = cubMaxPos;
        worldToLocal = cubWorldToLocal;
        localToWorld = cubLocalToWorld;
    }

    void DrawCube()
    {
        if (boxCollider == null)
        {
            boxCollider = _gameObject.GetComponent<BoxCollider>();
            if (boxCollider == null)
            {
                boxCollider = _gameObject.AddComponent<BoxCollider>();
                boxCollider.isTrigger = true;
            }
        }
        if (Application.isPlaying)
        {
            if (sphereCollider != null)
            {
                Destroy(sphereCollider);
            }
            if (sphereRoot!=null && sphereRoot.localScale!=Vector3.zero)
            {
                sphereRoot.localScale = Vector3.zero;
                sphereRoot.localPosition = defoultPos;
            }
            if (!ShowLineOnPlay)
            {
                if (cubeRoot!=null && cubeRoot.localScale!=Vector3.zero)
                {
                    cubeRoot.localScale = Vector3.zero;
                    cubeRoot.localPosition = defoultPos;
                }
                return;
            }
            CreateCubeMesh();
        }
        else
        {
            sphereCollider = _gameObject.GetComponent<SphereCollider>();
            if (sphereCollider != null)
            {
                DestroyImmediate(sphereCollider);
            }
        }

        bool needCreateMeshObj = false;
        if (Application.isPlaying)
        {
            if (cubeRoot == null)
            {
                needCreateMeshObj = true;
            }
        }
        if (needCreateMeshObj)
        {
            cubeRoot = new GameObject("CubeRoot").transform;
            cubeRoot.transform.SetParent(transform);
            cubeRoot.transform.localPosition = Vector3.zero;
            cubeRoot.transform.localEulerAngles = Vector3.zero;
            cubeRoot.transform.localScale = Vector3.one;
            MeshFilter meshFilter = cubeRoot.gameObject.AddComponent<MeshFilter>();
            meshFilter.sharedMesh = cubeMesh;
            cubeMeshRenderer= cubeRoot.gameObject.AddComponent<MeshRenderer>();
            cubeMeshRenderer.sharedMaterial = ShowMat;
        }
        if (Application.isPlaying)
        {
            if (!cubeRoot.gameObject.activeSelf)
            {
                cubeRoot.gameObject.SetActive(true);
            }
            if (cubeRoot.localScale != Vector3.one)
            {
                cubeRoot.localScale = Vector3.one;
                cubeRoot.localPosition = Vector3.zero;
            }
        }

        //Graphics.DrawMesh(cubeMesh, _transform.position, _transform.rotation, ShowMat, setLayer);
    }

    SphereCollider sphereCollider;

    Transform sphereRoot;

    MeshRenderer sphereMeshRenderer;

    Vector3 sphereCenter;

    float sphereRadius;

    void FreshSphereRange()
    {
        if (_transform == null)
        {
            _transform = transform;
        }
        sphereCenter = _transform.position;
        sphereRadius = Size.x * 0.5f;
    }

    float oldSizeX;

    public bool SphereRangeChange()
    {
        if (_transform == null)
        {
            _transform = transform;
        }
        if (oldPosition!= _transform.position || oldSizeX!= Size.x ||
            SetDataChange())
        {
            oldSizeX = Size.x;
            oldPosition = _transform.position;
            return true;
        }
        return false;
    }

    public void GetSphereRadius(ref Vector3 center,ref float radius)
    {
        center = sphereCenter;
        radius = sphereRadius;
    }

    void DrawSphere()
    {
        if (sphereCollider == null)
        {
            sphereCollider = _gameObject.GetComponent<SphereCollider>();
            if (sphereCollider==null)
            {
                sphereCollider = _gameObject.AddComponent<SphereCollider>();
                sphereCollider.isTrigger = true;
            }
        }
        if (Application.isPlaying)
        {
            if (boxCollider!=null)
            {
                Destroy(boxCollider);
            }
            if (cubeRoot != null && cubeRoot.localScale!=Vector3.zero)
            {
                cubeRoot.localScale = Vector3.zero;
                cubeRoot.localPosition = defoultPos;
            }
            if (!ShowLineOnPlay)
            {
                if (sphereRoot != null && sphereRoot.localScale != Vector3.zero)
                {
                    sphereRoot.localScale = Vector3.zero;
                    sphereRoot.localPosition = defoultPos;
                }
                return;
            }
            CreateSphereMesh();
        }
        else
        {
            boxCollider= _gameObject.GetComponent<BoxCollider>();
            if (boxCollider != null)
            {
               DestroyImmediate(boxCollider);
            }
        }

        bool needCreateMeshObj = false;
        if (Application.isPlaying)
        {
            if (sphereRoot == null)
            {
                needCreateMeshObj = true;
            }

        }
        if (needCreateMeshObj)
        {
            sphereRoot = new GameObject("SphereRoot").transform;
            sphereRoot.transform.SetParent(transform);
            sphereRoot.transform.localPosition = Vector3.zero;
            sphereRoot.transform.localEulerAngles = Vector3.zero;
            sphereRoot.transform.localScale = Vector3.one;
            MeshFilter meshFilter = sphereRoot.gameObject.AddComponent<MeshFilter>();
            meshFilter.sharedMesh = sphereMesh;
            sphereMeshRenderer = sphereRoot.gameObject.AddComponent<MeshRenderer>();
            sphereMeshRenderer.sharedMaterial = ShowMat;
        }
        if (Application.isPlaying)
        {
            if (!sphereRoot.gameObject.activeSelf)
            {
                sphereRoot.gameObject.SetActive(true);
            }
            if (sphereRoot.localScale != Vector3.one)
            {
                sphereRoot.localScale = Vector3.one;
                sphereRoot.localPosition = Vector3.zero;
            }
        }

        //Graphics.DrawMesh(sphereMesh, _transform.position, _transform.rotation, ShowMat, setLayer);
    }

    static Mesh cubeMesh;

    static void CreateCubeMesh()
    {
        if (cubeMesh==null)
        {
            cubeMesh = new Mesh();
            List<Vector3> tempList = new List<Vector3>();
            List<Vector2> tempList2 = new List<Vector2>();
            List<int> tempList3 = new List<int>();
            // 前面
            tempList.Add(new Vector3(0.5f, -0.5f, -0.5f)); // index 0
            tempList.Add(new Vector3(-0.5f, -0.5f, -0.5f));    // index 1
            tempList.Add(new Vector3(-0.5f, 0.5f, -0.5f)); // index 2
            tempList.Add(new Vector3(0.5f, 0.5f, -0.5f)); // index 3

            // 后面
            tempList.Add(new Vector3(0.5f, -0.5f, 0.5f));      // index 4
            tempList.Add(new Vector3(-0.5f, -0.5f, 0.5f));     // index 5
            tempList.Add(new Vector3(-0.5f, 0.5f, 0.5f));      // index 6
            tempList.Add(new Vector3(0.5f, 0.5f, 0.5f));   // index 7
            cubeMesh.vertices = tempList.ToArray();

            // 前面
            tempList3.Add(0);
            tempList3.Add(1);
            tempList3.Add(2);
            tempList3.Add(0);
            tempList3.Add(2);
            tempList3.Add(3);
            // 后面
            tempList3.Add(4);
            tempList3.Add(7);
            tempList3.Add(5);
            tempList3.Add(5);
            tempList3.Add(7);
            tempList3.Add(6);
            // 左面
            tempList3.Add(1);
            tempList3.Add(5);
            tempList3.Add(6);
            tempList3.Add(1);
            tempList3.Add(6);
            tempList3.Add(2);
            // 右面
            tempList3.Add(0);
            tempList3.Add(3);
            tempList3.Add(4);
            tempList3.Add(3);
            tempList3.Add(7);
            tempList3.Add(4);
            // 上面
            tempList3.Add(2);
            tempList3.Add(6);
            tempList3.Add(3);
            tempList3.Add(3);
            tempList3.Add(6);
            tempList3.Add(7);
            // 下面
            tempList3.Add(1);
            tempList3.Add(4);
            tempList3.Add(5);
            tempList3.Add(0);
            tempList3.Add(4);
            tempList3.Add(1);
            cubeMesh.triangles = tempList3.ToArray();

            tempList2.Add(new Vector2(1, 0));
            tempList2.Add(new Vector2(0, 0));
            tempList2.Add(new Vector2(0, 1));
            tempList2.Add(new Vector2(1, 1));

            tempList2.Add(new Vector2(1, 0));
            tempList2.Add(new Vector2(0, 0));
            tempList2.Add(new Vector2(0, 1));
            tempList2.Add(new Vector2(1, 1));
            cubeMesh.uv = tempList2.ToArray();

            cubeMesh.RecalculateBounds();
            cubeMesh.RecalculateNormals();
            cubeMesh.RecalculateTangents();

        }
    }

    static Mesh sphereMesh;

    static void CreateSphereMesh()
    {
        if (sphereMesh==null)
        {
            sphereMesh = new Mesh();

            //
            float _radius = 0.5f;
            int _latitude = 24;
            int _longitude = 24;
            int curIndex = 0;
            int arrayLen = (_latitude + 1) * (_longitude + 1);
            Vector3[] vertices = new Vector3[arrayLen];
            for (int lat = 0; lat <= _latitude; lat++)
            {
                //经线角度的取值范围是0~180度
                float latRad = lat * 1.0f / _latitude * Mathf.PI;
                float latCos = Mathf.Cos(latRad);
                float latSin = Mathf.Sin(latRad);
                for (int lon = 0; lon <= _longitude; lon++)
                {
                    //纬线角度的取值范围是0~360度
                    float lonRad = lon * 1.0f / _longitude * Mathf.PI * 2;//每一圈的最后一个点和第一个点重合(设置UV的坐标)
                    float lonCos = Mathf.Cos(lonRad);
                    float lonSin = Mathf.Sin(lonRad);
                    vertices[curIndex++] = new Vector3(latSin * lonCos, latCos, latSin * lonSin) * _radius;
                }
            }
            sphereMesh.vertices = vertices;
            //
            curIndex = 0;
            Vector3[] normals = new Vector3[vertices.Length];
            foreach (Vector3 vertex in vertices)
            {
                normals[curIndex++] = (vertex).normalized;
            }
            sphereMesh.normals = normals;
            //
            curIndex = 0;
            arrayLen = _latitude * _longitude * 3 * 2;
            int[] triangles = new int[arrayLen];
            //侧面
            for (int lat = 0; lat < _latitude; lat++)
            {
                for (int lon = 0; lon < _longitude; lon++)
                {
                    int current = lat * (_longitude + 1) + lon;
                    int next = current + _longitude + 1;

                    triangles[curIndex++] = current;
                    triangles[curIndex++] = current + 1;
                    triangles[curIndex++] = next;

                    triangles[curIndex++] = next;
                    triangles[curIndex++] = current + 1;
                    triangles[curIndex++] = next + 1;
                }
            }
            sphereMesh.triangles = triangles;
            //
            curIndex = 0;
            arrayLen = (_latitude + 1) * (_longitude + 1);
            Vector2[] uvs = new Vector2[arrayLen];
            for (int lat = 0; lat <= _latitude; lat++)
            {
                for (int lon = 0; lon <= _longitude; lon++)
                {
                    uvs[curIndex++] = new Vector2((float)lon / _longitude, 1f - (float)lat / _latitude);
                }
            }
            sphereMesh.uv = uvs;

            sphereMesh.RecalculateBounds();
            sphereMesh.RecalculateNormals();
            sphereMesh.RecalculateTangents();
        }
    }

    public enum MeshTypeEnum
    {
        Cube,
        Sphere,
    }
}
