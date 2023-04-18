using System;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PaiGroupData
{
    public List<PaiGroupNodeData> listHandNode = new List<PaiGroupNodeData>();

    /// <summary>
    /// 获取挂点
    /// </summary>
    /// <param name="type"></param>
    /// <returns></returns>
    public Transform GetHandNode(PaiGroupInHand type)
    {
        foreach (PaiGroupNodeData ph in listHandNode)
        {
            if (ph.Type == type)
            {
                return ph.ParentNodeInHand;
            }
        }
        return null;
    }
    /// <summary>
    /// 设置父节点
    /// </summary>
    /// <param name="type"></param>
    /// <param name="Parent"></param>
    public void SetHandNode(PaiGroupInHand type, Transform Parent)
    {
        foreach (PaiGroupNodeData ph in listHandNode)
        {
            if (ph.Type == type)
            {
                ph.ParentNodeInTable = Parent;
            }
        }
    }
    /// <summary>
    /// 获取挂点
    /// </summary>
    /// <param name="type"></param>
    /// <returns></returns>
    public PaiGroupNodeData GetNode(PaiGroupInHand type)
    {
        foreach (PaiGroupNodeData ph in listHandNode)
        {
            if (ph.Type == type)
            {
                return ph;
            }
        }
        return null;
    }
}


[System.Serializable]
public class PaiGroupNodeData
{
    /// <summary>
    /// 挂载节点
    /// </summary>
    public Transform ParentNodeInHand;
    /// <summary>
    /// 部件类型
    /// </summary>
    public PaiGroupInHand Type;
    /// <summary>
    /// 放置到桌面的节点
    /// </summary>
    public Transform ParentNodeInTable;
    /// <summary>
    /// 挂载对象
    /// </summary>
    public GameObject Prefab;
    /// <summary>
    /// 加载麻将组
    /// </summary>
    public void LoadMJGroup()
    {
        if (Prefab != null)
        {
            GameObject go = GameObject.Instantiate(Prefab);
            go.transform.parent = ParentNodeInTable.transform;
        }
    }
    /// <summary>
    /// 加载麻将子
    /// </summary>
    /// <param name="mjBornPos"></param>
    /// <returns></returns>
    public MJAction LoadMJ(Vector2Int mjBornPos)
    {
        int layer = LayerMask.NameToLayer("Default");
        MJConfigData mcd = ParentNodeInTable.GetComponent<MJConfigData>();
        if (mcd != null)
        {
            Vector3 pos = Vector3.zero + new Vector3(mcd.MjStepHeight * (mjBornPos.x), 0, mcd.mjStepWidth * (-mjBornPos.x + mjBornPos.y));
            return LoadMajiang(mcd, pos, layer, mcd.isShowMjShadow, true);
        }
        return null;
    }

    /// <summary>
    /// 加载麻将
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private MJAction LoadMajiang(MJConfigData parentNode, Vector3 pos, int layer, bool isShowShadow = true, bool isSeclect = false)
    {
        if (Prefab != null)
        {
            GameObject go = GameObject.Instantiate(Prefab);
            go.transform.parent = parentNode.transform;
            MJAction action = go.GetComponent<MJAction>();
            action.SetPos(pos);
            action.SetRotation(0);
            action.SetMJViewData(parentNode, isShowShadow, isSeclect);
            action.SetLayer(layer);
            return action;
        }
        return null;
    }

}
