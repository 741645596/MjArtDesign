using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Weile.Core;
public class RoleBindBones : MonoBehaviour
{
    public Animator ani;
    public GameObject rootBody;
    public List<DefaultCloth> listDefaultCloth = new List<DefaultCloth>();
    public RoleClothData clothData = new RoleClothData();
    //
    private Dictionary<int, GameObject> g_Cloth = new Dictionary<int, GameObject>();
    // Start is called before the first frame update
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public GUIStyle style = new GUIStyle();

    private void Awake()
    {
        ProcessDefaultCloth();
        if (rootBody != null)
        {
            ani = rootBody.GetComponent<Animator>();
        }
    }
    void Start()
    {
        //ani.SetInteger("state", 1);
    }

    // Update is called once per frame
    void Update()
    {
        
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
        if (GameLogic.g_IsInGame == false)
        {
            GUI.Label(new Rect(Screen.width / 2 - 150, 10, 300, 40), "局外全骨骼测试",style);
        }
        else 
        {
            GUI.Label(new Rect(Screen.width / 2 - 150, 10, 300, 40), "局内全骨骼测试",style);
        }

        int height = 70;
        if (clothData == null)
            return;
        if (GUI.Button(new Rect(10, height, ButtonWidth, ButtonHeight), "defalut cloth", style))
        {
            DefaultCloth();
        }

        if (GUI.Button(new Rect(10 + ButtonWidthStep, height, ButtonWidth, ButtonHeight), "play skill1", style))
        {
            if (ani != null)
            {
                ani.SetInteger("state", 1);
            }
        }

        if (GUI.Button(new Rect(10 + ButtonWidthStep * 2, height, ButtonWidth, ButtonHeight), "play skill2", style))
        {
            if (ani != null)
            {
                ani.SetInteger("state", 2);
            }
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

        // save
        if (GameLogic.g_IsInGame == false)
        {
            if (GUI.Button(new Rect(10, height, ButtonWidth, ButtonHeight), "Save", style))
            {
                Save();
            }
        }
        else
        {
            if (GUI.Button(new Rect(10, height, ButtonWidth, ButtonHeight), "Exit", style))
            {
                Exit();
            }
        }
    }
    /// <summary>
    /// 保存选定好的衣服进入游戏内
    /// </summary>
    private void Save()
    {
        EventCenter.DispatchEvent(EventCenterType.InGame, -1, 0);
    }
    /// <summary>
    /// 退出游戏
    /// </summary>
    private void Exit()
    {
        EventCenter.DispatchEvent(EventCenterType.OutGame, -1, 0);
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
    }
    private void LoadPart(Transform ParentNode, RolePartType partType, RolePart part)
    {
        GameObject go = GameObject.Instantiate(part.part);
        if (go != null)
        {
            go.transform.parent = ParentNode;
            go.transform.localPosition = Vector3.zero;
            go.transform.localEulerAngles = Vector3.zero;
            if (GameLogic.g_IsInGame == true)
            {
               Transform hide  = go.transform.Find("hide");
                if (hide != null)
                {
                    hide.gameObject.SetActive(false);
                }
            }
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
            if (g_Cloth.ContainsKey(index) == true)
            {
                g_Cloth[index] = go;
            }
            else
            {
                g_Cloth.Add(index, go);
            }
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
