using System;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PaiGroupData
{
    public List<PaiGroupNodeData> listHandNode = new List<PaiGroupNodeData>();

    /// <summary>
    /// ��ȡ�ҵ�
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
    /// ���ø��ڵ�
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
    /// ��ȡ�ҵ�
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
    /// ���ؽڵ�
    /// </summary>
    public Transform ParentNodeInHand;
    /// <summary>
    /// ��������
    /// </summary>
    public PaiGroupInHand Type;
    /// <summary>
    /// ���õ�����Ľڵ�
    /// </summary>
    public Transform ParentNodeInTable;
    /// <summary>
    /// ���ض���
    /// </summary>
    public GameObject Prefab;
    /// <summary>
    /// �����齫��
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
    /// �����齫��
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
    /// �����齫
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
