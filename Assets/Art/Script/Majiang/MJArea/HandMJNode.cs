using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using Weile.Core;

public class HandMJNode : MJConfigData
{
    private List<MJAction> listAllMj = new List<MJAction>();
    public Transform moveNode;
    public Transform liPaiNode;
    public float WaitTime = 3.0f;
    public float stepTime = 0.1f;
    private List<Vector3> bakeTransformInfo = new List<Vector3>();
    private Vector3 bakeScale;
    /// <summary>
    /// 插入麻将的位置。
    /// </summary>
    private int insertTargetPos;
    private MJAction targetAction = null;
    private int outindex;



    void Awake()
    {
        bakeTransformInfo.Add(transform.localPosition);
        bakeTransformInfo.Add(transform.localEulerAngles);
        
    }

    private void Start()
    {
        EventCenter.RegisterHooks(EventCenterType.ExchangMajiang, Event_HuanPai_Start);
        EventCenter.RegisterHooks(EventCenterType.ExchangMajiang_Finish, Event_HuanPai_Finish);
    }

    public void AddMJ(MJAction mj)
    {
        if (mj != null)
        {
            listAllMj.Add(mj);
        }
    }


    public void Clear()
    {
        listAllMj.Clear();
    }

    public void ResetPos()
    {
        transform.localPosition = bakeTransformInfo[0];
        transform.localEulerAngles = bakeTransformInfo[1];
    }

    /// <summary>
    /// 加载手牌, 注意加载牌的顺序，顺时针麻将影子才会正确。
    /// </summary>
    public IEnumerator LoadHandCardTeam(GameObject maJiangPrefab, float loadTimeStep)
    {
        int layer = LayerMask.NameToLayer("Default");
        for (int i = 0; i < 13; i++)
        {
            Vector3 worldPos = CalcWolrldPos(i);
            // 同时拿掉牌墙的牌。
            MJAction mj = MJManger.GetLastMJ(MJArea.Wall, true);
            if (mj != null)
            {
                GameObject.Destroy(mj.gameObject);
            }
            yield return LoadMajiang(maJiangPrefab, loadTimeStep, worldPos, layer);
        }
    }
    /// <summary>
    /// 计算世界坐标
    /// </summary>
    /// <param name="posX"></param>
    /// <returns></returns>
    public Vector3 CalcWolrldPos(int posX)
    {
        Vector3 startPos = new Vector3(-0.5640052f, 0.02659222f, 0.0f);
        Vector3 diff = this.mjStepWidth * ((this.c != MJDir.Horizontal) ? new Vector3(0, 0, 1) : new Vector3(1, 0, 0));
        Vector3 localPos = startPos + diff * posX;
        return transform.TransformPoint(localPos);
    }
    /// <summary>
    /// 加载麻将
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private IEnumerator LoadMajiang(GameObject maJiangPrefab,float loadTimeStep, Vector3 wolrldPos, int layer, bool isShowShadow = true, bool isSeclect = false)
    {
        if (transform.gameObject.activeSelf != false)
        {
            if (maJiangPrefab != null)
            {
                GameObject go = GameObject.Instantiate(maJiangPrefab);
                go.transform.parent = transform;
                go.transform.position = wolrldPos;
                this.bakeScale = go.transform.localScale;
                MJAction action = go.GetComponent<MJAction>();
                action.SetRotation(0);
                action.SetMJViewData(this, isShowShadow, isSeclect);
                action.SetLayer(layer);
                MJManger.AddMJ(MJArea.Hand, this.seat, action);
                AddMJ(action);
            }
            yield return new WaitForSeconds(loadTimeStep);
        }
    }
    /// <summary>
    /// 摸牌到手
    /// </summary>
    /// <param name="maJiangPrefab"></param>
    public void LoadMoPaiMajiang(GameObject maJiangPrefab)
    {
        int layer = LayerMask.NameToLayer("Default");
        Vector3 wolrldPos  = CalcWolrldPos(15);
        if (transform.gameObject.activeSelf != false)
        {
            if (maJiangPrefab != null)
            {
                GameObject go = GameObject.Instantiate(maJiangPrefab);
                go.transform.parent = this.liPaiNode;
                go.transform.position = wolrldPos;
                //this.bakeScale = go.transform.localScale;
                MJAction action = go.GetComponent<MJAction>();
                action.SetRotation(0);
                action.SetMJViewData(this, false, true);
                action.SetLayer(layer);
                MJManger.AddMJ(MJArea.Hand, this.seat, action);
                this.targetAction = action;
            }
        }
    }
    /// <summary>
    /// 判断能否理牌
    /// </summary>
    /// <returns></returns>
    public bool CheckCanLiPai()
    {
        if (listAllMj != null && this.targetAction != null)
        {
            return true;
        }
        return false;
    }
    /// <summary>
    /// 已经摸牌了
    /// </summary>
    /// <returns></returns>
    public bool HaveMoPai()
    {
        if ( this.targetAction != null)
        {
            return true;
        }
        return false;
    }
    /// <summary>
    /// 理牌准备工作
    /// </summary>
    /// <param name="insertPos"></param>
    public void AddHandPai(int insertPos)
    {
        this.insertTargetPos = insertPos;
        int count = listAllMj.Count;
        this.outindex = UnityEngine.Random.Range(0, count);
        this.targetAction.transform.parent = this.liPaiNode;
        this.targetAction.SetMjBody(this, true);
        this.targetAction.transform.position = CalcWolrldPos(15);
        //Debug.Log("outindex :" + this.outindex + "-----insertTargetPos:" + this.insertTargetPos);
        if (this.insertTargetPos != this.outindex)
        {
            if (this.insertTargetPos > this.outindex) // 插入点在后面
            {
                for (int i = this.outindex + 1; i <= this.insertTargetPos && i < count; i++)
                {
                    listAllMj[i].transform.parent = moveNode;
                }
                //listAllMj.RemoveAt(this.outindex);
                listAllMj.Insert(this.insertTargetPos, this.targetAction);
                
            }
            else 
            {
                for (int i = this.insertTargetPos; i < this.outindex && i < count; i++)
                {
                    listAllMj[i].transform.parent = moveNode;
                }
                //listAllMj.RemoveAt(this.outindex);
                listAllMj.Insert(this.insertTargetPos, this.targetAction);
            }
        }
    }
    /// <summary>
    /// 打出一个牌
    /// </summary>
    public void DaHandPai()
    {
        int count = listAllMj.Count;
        this.outindex = UnityEngine.Random.Range(0, count);
        MJAction mj = listAllMj[this.outindex];
        listAllMj.RemoveAt(this.outindex);
        MJManger.RemoveMJ(MJArea.Hand, this.seat, mj);
    }
    /// <summary>
    /// 理牌
    /// </summary>
    public void LiPaiStart()
    {
        Vector3 diff = this.mjStepWidth * ((this.c != MJDir.Horizontal) ? new Vector3(0, 0, 1) : new Vector3(1, 0, 0));
        if (this.outindex > this.insertTargetPos)
        {
            moveNode.transform.DOLocalMove(diff, WaitTime);
            transform.DORestart();
        }
        else if (this.outindex < this.insertTargetPos)
        {
            moveNode.transform.DOLocalMove(-diff, WaitTime);
            transform.DORestart();
        }
    }

    public void LiPaiEnd()
    {
        StartCoroutine(Finish(stepTime));
        this.targetAction = null;
    }

    /// <summary>
    ///  重新整理
    /// </summary>
    /// <param name="waitTime"></param>
    /// <returns></returns>
    private IEnumerator Finish(float stepTime)
    {
        yield return new WaitForSeconds(stepTime);
        for (int i = 0; i < listAllMj.Count; i++)
        {
            Vector3 worldPos = CalcWolrldPos(i);
            if (listAllMj[i].transform.parent != transform)
            {
                /*if (this.listAllMj[i].transform.parent != this.liPaiNode)
                {
                    listAllMj[i].SetMjBody(this, false);
                }*/
                listAllMj[i].transform.parent = transform;
                listAllMj[i].transform.localEulerAngles = Vector3.zero;
                listAllMj[i].transform.position = worldPos;
                listAllMj[i].transform.localScale = this.bakeScale;
            }
            else
            {
                listAllMj[i].transform.position = worldPos;
                listAllMj[i].SetMjBody(this, false);
            }
        }
        this.moveNode.localPosition = Vector3.zero;
        this.liPaiNode.localPosition = Vector3.zero;
        this.liPaiNode.localEulerAngles = Vector3.zero;
    }
    /// <summary>
    /// 控制隐藏
    /// </summary>
    /// <param name="Event_Send"></param>
    /// <param name="Param"></param>
    public void Event_HuanPai_Start(int Event_Send, object Param)
    {
        ShowLast3MJ(false);
    }
    /// <summary>
    /// 控制显示
    /// </summary>
    /// <param name="Event_Send"></param>
    /// <param name="Param"></param>
    public void Event_HuanPai_Finish(int Event_Send, object Param)
    {
        ShowLast3MJ(true);
    }

    private void ShowLast3MJ(bool isShow)
    {
        if (listAllMj == null || listAllMj.Count == 0)
            return;
        for (int i = 0; i < 3; i++)
        {
            int index = listAllMj.Count - 1 - i;
            if (index > 0)
            {
                listAllMj[index].gameObject.SetActive(isShow);
            }
        }
    }

    void OnDestroy()
    {
        EventCenter.AntiRegisterHooks(EventCenterType.ExchangMajiang, Event_HuanPai_Start);
        EventCenter.AntiRegisterHooks(EventCenterType.ExchangMajiang_Finish, Event_HuanPai_Finish);
    }
}
