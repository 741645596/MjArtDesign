using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Weile.Core;
public class RoleBindBones : MonoBehaviour
{
    
    public GameObject OutGameBody;
    public GameObject InGameBody;
    private GameObject rootBody;
    private Animator ani;
    public List<DefaultCloth> listDefaultCloth = new List<DefaultCloth>();
    public RoleClothData clothData = new RoleClothData();
    //
    private Dictionary<int, GameObject> g_Cloth = new Dictionary<int, GameObject>();
    // Start is called before the first frame update
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public GUISkin skin;
    public bool IsInGame = false;




    private void Awake()
    {
        ChangeBody();
        ProcessDefaultCloth();
    }
    void Start()
    {

    }


    private void ChangeBody()
    {
        GameObject newBody = null;
        if (InGameBody != OutGameBody)
        {
            if (IsInGame == true)
            {
                InGameBody.SetActive(true);
                OutGameBody.SetActive(false);
                newBody = InGameBody;
            }
            else
            {
                InGameBody.SetActive(false);
                OutGameBody.SetActive(true);
                newBody = OutGameBody;
            }
        }
        else 
        {
            newBody = OutGameBody;
        }

        if (rootBody != newBody)
        {
            rootBody = newBody;
            if (rootBody != null)
            {
                ani = rootBody.GetComponent<Animator>();
            }
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
        if (GUI.Button(new Rect(10, height, ButtonWidth, ButtonHeight), "defalut cloth", skin.button))
        {
            DefaultCloth();
        }

        if (GUI.Button(new Rect(10 + ButtonWidthStep, height, ButtonWidth, ButtonHeight), "play skill1", skin.button))
        {
            if (ani != null)
            {
                ani.SetInteger("state", 1);
            }
        }

        if (GUI.Button(new Rect(10 + ButtonWidthStep * 2, height, ButtonWidth, ButtonHeight), "play skill2", skin.button))
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
                        if (GUI.Button(new Rect(10 + j * ButtonWidthStep, height, ButtonWidth, ButtonHeight), part.partName, skin.button))
                        {
                            LoadPart(data.ParentNode, data.partType, part);
                        }
                    }
                    height += ButtonHeightStep;
                }
            }
        }

        // save
        if (IsInGame == false)
        {
            if (GUI.Button(new Rect(10, height, ButtonWidth, ButtonHeight), "进入游戏局内", skin.button))
            {
                InGame();
            }
        }
        else
        {
            if (GUI.Button(new Rect(10, height, ButtonWidth, ButtonHeight), "进入商城", skin.button))
            {
                OutGame();
            }
        }
    }
    /// <summary>
    /// 保存选定好的衣服进入游戏内
    /// </summary>
    private void InGame()
    {
        IsInGame = true;
        ChangGameScene();
    }
    /// <summary>
    /// 退出游戏
    /// </summary>
    private void OutGame()
    {
        IsInGame = false;
        ChangGameScene();
    }
    /// <summary>
    /// 更换游戏环境
    /// </summary>
    private void ChangGameScene()
    {
        ChangeBody();
        //
        if (rootBody == null)
            return;
        foreach (DefaultCloth cloth in listDefaultCloth)
        {
            if (cloth == null || cloth.clothGO == null)
                continue;
            // 默认衣服处理
            if (cloth.clothGO.activeSelf == true)
            {
                // 隐藏部件处理
                Transform hide = cloth.clothGO.transform.Find("hide");
                if (hide != null)
                {
                    hide.gameObject.SetActive(!IsInGame);
                }
                //
                foreach (SkinnedMeshRenderer smr in cloth.clothGO.GetComponentsInChildren<SkinnedMeshRenderer>())
                {
                    RoleAniHelp.ChangeMeshAndBones(rootBody, smr);
                }
            }
            // 主动换装的的衣服处理
            foreach (GameObject go in g_Cloth.Values)
            {
                if (go.activeSelf == true)
                {
                    Transform hide = go.transform.Find("hide");
                    if (hide != null)
                    {
                        hide.gameObject.SetActive(!IsInGame);
                    }
                    //
                    foreach (SkinnedMeshRenderer smr in go.GetComponentsInChildren<SkinnedMeshRenderer>())
                    {
                        RoleAniHelp.ChangeMeshAndBones(rootBody, smr);
                    }
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
                GameObject clothGo = listDefaultCloth[i].clothGO;
                if (clothGo != null)
                {
                    clothGo.SetActive(true);
                    // 隐藏部件处理
                    Transform hide = clothGo.transform.Find("hide");
                    if (hide != null)
                    {
                        hide.gameObject.SetActive(!IsInGame);
                    }
                    // 骨骼重绑定
                    if (rootBody != null)
                    {
                        foreach (SkinnedMeshRenderer smr in clothGo.GetComponentsInChildren<SkinnedMeshRenderer>())
                        {
                            RoleAniHelp.ChangeMeshAndBones(rootBody, smr);
                        }
                    }
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
            if (IsInGame == true)
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
