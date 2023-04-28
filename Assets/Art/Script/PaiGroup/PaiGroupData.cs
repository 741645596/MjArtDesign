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
    /// ���ع���Ķ���
    /// </summary>
    private Transform targetGO;
    /// <summary>
    /// �����齫��
    /// </summary>
    public GameObject LoadMJGroup()
    {
        if (Prefab != null)
        {
            GameObject go = GameObject.Instantiate(Prefab);
            this.targetGO = go.transform;
            this.targetGO.parent = ParentNodeInHand.transform;
            this.targetGO.localPosition = Vector3.zero;
            this.targetGO.localEulerAngles = Vector3.zero;
            return go;
        }
        return null;
    }
    /// <summary>
    /// �л�������
    /// </summary>
    public void Change2Table()
    {
       if (this.targetGO != null)
       {
            this.targetGO.parent = ParentNodeInTable;
            //t.localPosition = Vector3.zero;
            //t.localEulerAngles = Vector3.zero;
            MJTypePosition mp = this.targetGO.GetComponent<MJTypePosition>();
            if (mp != null)
            {
                mp.DoPostion();
            }
        }
    }
    /// <summary>
    /// ���齫��
    /// </summary>
    public void BindMjGroup()
    {
        if (ParentNodeInTable != null)
        {
            BakeParent = ParentNodeInTable.parent;
            ParentNodeInTable.parent = ParentNodeInHand;
        }

    }
    /// <summary>
    /// �ͷŰ��齫��
    /// </summary>
    public void FreeBindMjGroup()
    {
        if (ParentNodeInTable != null)
        {
            ParentNodeInTable.parent = BakeParent;
        }
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
