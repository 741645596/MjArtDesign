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
    /// 设置数据关联
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
public class PaiGroupNodeData: PaiGroupNodeBaseData
{
    /// <summary>
    /// 挂载节点
    /// </summary>
    public Transform ParentNodeInHand;
    /// <summary>
    /// 挂载对象
    /// </summary>
    public GameObject Prefab;
    /// <summary>
    /// 备份的父节点
    /// </summary>
    private Transform BakeParent;
    /// <summary>
    /// 加载管理的对象
    /// </summary>
    private Transform targetGO;
    /// <summary>
    /// 加载麻将组
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
    /// 切换到桌面
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
    /// 绑定麻将组
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
    /// 释放绑定麻将组
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
    /// 部件类型
    /// </summary>
    public PaiGroupInHand Type;
    /// <summary>
    /// 放置到桌面的节点
    /// </summary>
    public Transform ParentNodeInTable;

}
