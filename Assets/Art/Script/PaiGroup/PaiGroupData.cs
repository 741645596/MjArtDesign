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
    public void SetNodeData(List<PaiGroupNodeBaseData> listNodeBaseData)
    {
        if (listNodeBaseData != null && listNodeBaseData.Count > 0)
        {
            foreach (PaiGroupNodeBaseData ph in listNodeBaseData)
            {
                SetNodeData(ph);
            }
        }
    }
    /// <summary>
    /// �������ݹ���
    /// </summary>
    /// <param name="data"></param>
    private void SetNodeData(PaiGroupNodeBaseData data)
    {
        if (data == null)
            return;
        foreach (PaiGroupNodeData ph in listHandNode)
        {
            if (ph.Type == data.Type)
            {
                ph.ParentNodeInTable = data.ParentNodeInTable;
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
public class PaiGroupNodeData: PaiGroupNodeBaseData
{
    /// <summary>
    /// ���ؽڵ�
    /// </summary>
    public Transform ParentNodeInHand;
    /// <summary>
    /// ���ض���
    /// </summary>
    public GameObject Prefab;
    /// <summary>
    /// ���ݵĸ��ڵ�
    /// </summary>
    private Transform BakeParent;
    /// <summary>
    /// �����齫��
    /// </summary>
    public void LoadMJGroup()
    {
        if (Prefab != null)
        {
            GameObject go = GameObject.Instantiate(Prefab);
            go.transform.parent = ParentNodeInHand.transform;
            go.transform.localPosition = Vector3.zero;
        }
    }
    /// <summary>
    /// �л�������
    /// </summary>
    public void Change2Table()
    {
       Transform t = ParentNodeInHand.GetChild(0);
       if (t != null)
       {
            t.parent = ParentNodeInTable;
            t.localPosition = Vector3.zero;
            t.localEulerAngles = Vector3.zero;
       }
    }
    /// <summary>
    /// ���齫��
    /// </summary>
    public void BindMjGroup()
    {
        BakeParent = ParentNodeInTable.parent;
        ParentNodeInTable.parent = ParentNodeInHand;
    }
    /// <summary>
    /// �ͷŰ��齫��
    /// </summary>
    public void FreeBindMjGroup()
    {
        ParentNodeInTable.parent = BakeParent;
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


[System.Serializable]
public class PaiGroupNodeBaseData
{
    /// <summary>
    /// ��������
    /// </summary>
    public PaiGroupInHand Type;
    /// <summary>
    /// ���õ�����Ľڵ�
    /// </summary>
    public Transform ParentNodeInTable;

}
