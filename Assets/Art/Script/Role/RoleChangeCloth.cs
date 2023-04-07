using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class RoleChangeCloth : MonoBehaviour
{
    public GameObject rootBody;
    public RoleClothData clothData = new RoleClothData();
    public List<DefaultCloth> listDefaultCloth = new List<DefaultCloth>();

    private Dictionary<int, GameObject> g_Cloth = new Dictionary<int, GameObject>();
    // Start is called before the first frame update
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public GUIStyle style = new GUIStyle();

    public Vector3[] CameraPositionForPanels;
    //public Vector3[] CameraEulerForPanels;
    /// <summary>
    /// 控制是否动画的选项
    /// </summary>
    private int currentPanelIndex = 0;

    public Camera Camera;


    void Awake()
    {
        ProcessDefaultCloth();
    }
    void Start()
    {
        
    }

    private void Update()
    {
        if (CameraPositionForPanels.Length > currentPanelIndex && currentPanelIndex >= 0)
        {
            Camera.transform.position = Vector3.Lerp(Camera.transform.position, CameraPositionForPanels[currentPanelIndex], Time.deltaTime * 5);
            //Camera.transform.eulerAngles = Vector3.Lerp(Camera.transform.eulerAngles, CameraEulerForPanels[currentPanelIndex], Time.deltaTime * 5);
        }
    }

    private void ProcessDefaultCloth()
    {
        if (rootBody == null)
            return;
        foreach (DefaultCloth cloth in listDefaultCloth)
        {
            if (cloth == null || cloth.clothGO == null)
                continue;
            foreach (SkinnedMeshRenderer smr in cloth.clothGO.GetComponentsInChildren<SkinnedMeshRenderer>())
            {
                RoleAniHelp.ChangeMeshAndBones(rootBody, smr);
            }
        }
    }

    private void OnGUI()
    {
        int height = 70;
        if (clothData == null)
            return;
        if (GUI.Button(new Rect(10 , height, ButtonWidth, ButtonHeight), "defalut cloth", style))
        {
            DefaultCloth();
        }
        if (GUI.Button(new Rect(10 + ButtonWidthStep, height, ButtonWidth, ButtonHeight), "defalut view", style))
        {
            currentPanelIndex = 0;
        }
        height += ButtonHeightStep;

        //
        if (clothData.listClothData != null && clothData.listClothData.Count > 0)
        {
            for (int i = 0; i < clothData.listClothData.Count; i++)
            {
                RolePartData data = clothData.listClothData[i];
                if (data != null && data.listItems.Count > 0)
                {
                    for (int j = 0; j < data.listItems.Count; j++)
                    {
                        RolePart part = data.listItems[j];
                        if (GUI.Button(new Rect(10 + j * ButtonWidthStep, height, ButtonWidth, ButtonHeight), part.partName, style))
                        {
                            LoadPart(data.ParentNode, data.partType, part);
                        }
                    }
                    height += ButtonHeightStep;
                }
            }
        }
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="hairGO"></param>
    public void DefaultCloth()
    {

        if (listDefaultCloth != null && listDefaultCloth.Count > 0)
        {
            for (int i = 0; i < listDefaultCloth.Count; i++)
            {
                if (listDefaultCloth[i].clothGO != null)
                {
                    listDefaultCloth[i].clothGO.SetActive(true);
                }
            }
        }
        //
        for (int i = (int)RolePartType.Hair; i <= (int)RolePartType.downCloth; i++)
        {
            GameObject oldgo = null;
            g_Cloth.TryGetValue(i, out oldgo);
            if (oldgo != null)
                oldgo.SetActive(false);
        }
        currentPanelIndex = 0;
    }

    private void LoadPart(Transform ParentNode, RolePartType partType, RolePart part)
    {
        GameObject go = GameObject.Instantiate(part.part);
        if (go != null)
        {
            go.transform.parent = ParentNode;
            go.transform.localPosition = Vector3.zero;
            go.transform.localEulerAngles = Vector3.zero;
            // 同步动画
            if (rootBody != null)
            {
                foreach (SkinnedMeshRenderer smr in go.GetComponentsInChildren<SkinnedMeshRenderer>())
                {
                    RoleAniHelp.ChangeMeshAndBones(rootBody, smr);
                }
            }
            // 执行替换动作：
            if (part.listReplacePart != null && part.listReplacePart.Count > 0)
            {
                foreach (RolePartType type in part.listReplacePart)
                {
                    int replaceIndex = (int)type;
                    g_Cloth.TryGetValue(replaceIndex, out GameObject oldgo);
                    if (oldgo != null)
                    {
                        g_Cloth[replaceIndex] = null;
                        GameObject.Destroy(oldgo);
                        oldgo = null;
                    }
                    //
                    ReplaceDefaultCloth(type);
                }
            }
            if (part.listNeedPart != null && part.listNeedPart.Count > 0)
            {
                foreach (RolePartType type in part.listNeedPart)
                {
                    NeedDefalutCloth(type);
                }
            }
            // 加入管理
            int index = (int)partType;
            if(g_Cloth.ContainsKey(index) == true)
            {
                g_Cloth[index] = go;
            }
            else
            {
                g_Cloth.Add(index, go);
            }
            currentPanelIndex = index;
        }
    }

    private void ReplaceDefaultCloth(RolePartType type)
    {
        if (listDefaultCloth != null && listDefaultCloth.Count > 0)
        {
            foreach (DefaultCloth cloth in listDefaultCloth)
            {
                if (cloth != null && cloth.partType == type)
                {
                    if (cloth.clothGO != null)
                    {
                        cloth.clothGO.SetActive(false);
                    }
                }
            }
        }
    }

    private void NeedDefalutCloth(RolePartType type)
    {
        if (listDefaultCloth != null && listDefaultCloth.Count > 0)
        {
            foreach (DefaultCloth cloth in listDefaultCloth)
            {
                if (cloth != null && cloth.partType == type && g_Cloth.ContainsKey((int)type) == false)
                {
                    if (cloth.clothGO != null)
                    {
                        cloth.clothGO.SetActive(true);
                    }
                }
            }
        }
    }
}
[System.Serializable]
public class RolePart
{
    public string partName;
    public GameObject part;
    public List<RolePartType> listReplacePart = new List<RolePartType>();
    public List<RolePartType> listNeedPart = new List<RolePartType>();
}

[System.Serializable]
public class RoleClothData
{
    public List<RolePartData> listClothData = new List<RolePartData>();
}


[System.Serializable]
public class RolePartData
{
    /// <summary>
    /// 挂载节点
    /// </summary>
    public Transform ParentNode;
    /// <summary>
    /// 部件类型
    /// </summary>
    public RolePartType partType;
    /// <summary>
    /// 资产
    /// </summary>
    public List<RolePart> listItems = new List<RolePart>();
}

/// <summary>
/// 默认服装数据
/// </summary>
[System.Serializable]
public class DefaultCloth
{
    public RolePartType partType;
    public GameObject clothGO;
}

public enum RolePartType : int
{
    Hair = 1,
    cloth = 2,
    shoes = 3,
    upCloth= 4,
    downCloth = 5,
}
