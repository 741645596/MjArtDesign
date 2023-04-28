using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Weile.Core;

public class MJHandControl : MonoBehaviour
{
    // Start is called before the first frame update
    public Animator ani;
    /// <summary>
    /// 手中持牌,用于控制显示隐藏。
    /// </summary>
    public GameObject DaPaigo;
    private List<int> listPaiNum = new List<int>();

    private Vector2Int mjBornPos = new Vector2Int(0, 0);
    public bool isRandom = false;
    public Seat seat;

    private float DaPaiIntervalTime = 2.0f;
    /// <summary>
    /// 牌组数据
    /// </summary>
    public PaiGroupData pgData = new PaiGroupData();

    void Awake()
    {
        ani = gameObject.GetComponent<Animator>();
    }


    public void LoadMJ()
    {
        MJAction mj = MJManger.GetLastMJ(MJArea.Out, this.seat);
        if (mj != null)
        {
            MJConfigData mfg = mj.transform.parent.GetComponent<MJConfigData>();
            mj.SetMjBody(mfg, false);
        }
        //
        MJRolesControl mjr = transform.parent.parent.GetComponent<MJRolesControl>();
        if (mjr != null && mjr.ctrlUI != null)
        {
            OutMJNode on = mjr.ctrlUI.GetOutNode(this.seat);
            if (on != null)
            {
                on.LoadMJ(pgData.GetNode(PaiGroupInHand.OutMajiang).Prefab, this.mjBornPos, true);
            }
        }
    }



    public void ClearUpMj()
    {
        MJManger.ClearLastMJ(MJArea.Out,this.seat);
    }

    public void ClearAll()
    {
        MJManger.ClearAllMJ(MJArea.Out,this.seat);
    }

    public void playAllMj(float interval)
    {
        this.DaPaiIntervalTime = interval;
        ClearAll();
        StartCoroutine(PushAll());
    }

    public void playAllMjWithoutClear(float interval)
    {
        this.DaPaiIntervalTime = interval;
        StartCoroutine(PushAll());
    }

    private IEnumerator PushAll()
    {
        if (listPaiNum != null && listPaiNum.Count > 0)
        {
            for (int line = 0; line < listPaiNum.Count; line++)
            {
                for (int j = 0; j < listPaiNum[line]; j++)
                {
                    yield return StartCoroutine(pushMJ(line, j));
                }
            }
        }
    }
    /// <summary>
    /// 放置麻将子
    /// </summary>
    /// <param name="paiNum"></param>
    /// <param name="Ystep"></param>
    /// <param name="line"></param>
    /// <param name="j"></param>
    /// <returns></returns>
    private IEnumerator pushMJ(int line, int j)
    {
        yield return new WaitForSeconds(this.DaPaiIntervalTime);
        int paiNum = listPaiNum[line];
        if (paiNum > 1)
        {
            float Ystep = 1.0f / (listPaiNum.Count - 1);
            float Xstep = 1.0f / (paiNum - 1);
            float DaPaiX = Xstep * j;
            float DaPaiPage = Ystep * line;
            this.mjBornPos = new Vector2Int(line, j);

            if (ani != null)
            {
                ani.SetFloat("DaPaiX", DaPaiX);
                ani.SetFloat("DaPaiPage", DaPaiPage);
                ani.SetInteger("actionType", (int)DaPaiActionType.DaPai);
                float ret = UnityEngine.Random.Range(0.0f, 1.0f);
                isRandom = (ret >= 0.5f) ? true : false;
                ani.SetBool("isRandom", isRandom);
            }
        }
    }

    public void Event_DaPaiStart(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            DaPaigo.SetActive(true);
        }
    }
    public void Event_DaPaiEnd(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            DaPaigo.SetActive(false);
            LoadMJ();
        }
    }

    public void TanPai()
    {
        if (MJManger.GetTanPaiState(this.seat) == true && ani != null)
        {
            float[] array = new float[5] { 0, 1, 2, 3, 4 };
            int index = UnityEngine.Random.Range(0, 5);
            index = 4;
            ani.SetFloat("PosX", array[index]);
            ani.SetInteger("actionType", (int)DaPaiActionType.TanPai);
        }
    }
    /// <summary>
    /// 摊牌时绑定手牌
    /// </summary>
    public void Event_TanPaiStart(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            pgData.GetNode(PaiGroupInHand.Showdown).BindMjGroup();
        }
    }
    /// <summary>
    /// 摊牌时放弃绑定手牌
    /// </summary>
    public void Event_TanPaiEnd(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            pgData.GetNode(PaiGroupInHand.Showdown).FreeBindMjGroup();
            MJManger.SetTanPaiState(this.seat, false);
        }
    }

    public void QiDongAnniu()
    {
        if (ani != null)
        {
            ani.SetInteger("actionType", (int)DaPaiActionType.QidongAnAniu);
        }
    }

    /// <summary>
    /// 发牌
    /// </summary>
    /// <param name="ev"></param>
    public void Event_FaPai(AnimationEvent ev)
    {
        EventCenter.DispatchEvent(EventCenterType.FaMajiang, -1, null);
    }

    public void HuanPai()
    {
        if (ani != null)
        {
            pgData.GetNode(PaiGroupInHand.Exchange).LoadMJGroup();
            ani.SetInteger("actionType", (int)DaPaiActionType.HuanPai);
        }
    }
    /// <summary>
    /// 换牌到桌面
    /// </summary>
    public void Event_HuanPai2Table(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            pgData.GetNode(PaiGroupInHand.Exchange).Change2Table();
            float angle = -180.0f;
            EventCenter.DispatchEvent(EventCenterType.ExchangMajiang, (int)this.seat, angle);
        }
    }

    public void Emoji()
    {
        if (ani != null)
        {
            ani.SetInteger("actionType", (int)DaPaiActionType.Emoji);
            int ret = UnityEngine.Random.Range(0, 4);
            ani.SetInteger("EmojiType", ret);
        }
    }
    /// <summary>
    /// 摸牌
    /// </summary>
    public void MoPai()
    {
        MJAction mj = MJManger.GetLastMJ(MJArea.Wall, true);
        if (mj != null)
        {
            GameObject.Destroy(mj.gameObject);
        }
        // 执行摸牌动作
        if (ani != null)
        {
            ani.SetInteger("actionType", (int)DaPaiActionType.MoPai);
        }
        // 牌出现。
        PaiGroupNodeData pd = pgData.GetNode(PaiGroupInHand.MoPai);
        if (pd != null)
        {
            MJRolesControl mjr = transform.parent.parent.GetComponent<MJRolesControl>();
            if (mjr == null || mjr.ctrlUI == null)
                return;
            HandMJNode hn = mjr.ctrlUI.GetHandNode(this.seat);
            if (hn == null)
                return;
            hn.LoadMoPaiMajiang(pd.Prefab);
        }
    }


    public void PengChiGang()
    {
        int index = MJManger.GetPcgPostion(this.seat);
        float[] array = new float[4] { 0, 1, 2, 3 };
        if (index >= array.Length)
        {
            MJManger.ClearPCGgo(this.seat);
            index = MJManger.GetPcgPostion(this.seat);
        }
        //
        if (ani != null)
        {
            GameObject go = pgData.GetNode(PaiGroupInHand.ChiPengGang).LoadMJGroup();
            if (go != null)
            {
                MJManger.AddPCGgo(this.seat, go);
            }
            ani.SetFloat("PosX", array[index]);
            ani.SetInteger("actionType", (int)DaPaiActionType.PengChiGang);
            MJManger.AddPcgPostion(this.seat, index);
        }
    }

    /// <summary>
    /// 吃碰杠到桌面
    /// </summary>
    public void Event_PengChiGang2Table(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            pgData.GetNode(PaiGroupInHand.ChiPengGang).Change2Table();
        }
    }
    /// <summary>
    /// 理牌
    /// </summary>
    public void LiPai()
    {
        if (ani == null)
            return;
        MJRolesControl mjr = transform.parent.parent.GetComponent<MJRolesControl>();
        if (mjr == null || mjr.ctrlUI == null)
            return;
        HandMJNode hn = mjr.ctrlUI.GetHandNode(this.seat);
        if (hn == null)
            return;
        if (hn.CheckCanLiPai() == false)
            return;
        //
        int insertTargetPos = UnityEngine.Random.Range(0, 13);
        hn.AddHandPai(insertTargetPos);

        float aniParam = insertTargetPos * 1.0f / 13;
        ani.SetFloat("LiPaiPos", aniParam);
        ani.SetInteger("actionType", (int)DaPaiActionType.LiPai);
    }
    /// <summary>
    /// 打牌
    /// </summary>
    public void DaPai(Vector2Int bornPos)
    {
        Debug.Log("bornPos:" + bornPos);
        int paiNum = listPaiNum[bornPos.x];
        if (paiNum > 1)
        {
            float Ystep = 1.0f / (listPaiNum.Count - 1);
            float Xstep = 1.0f / (paiNum - 1);
            float DaPaiX = Xstep * bornPos.y;
            float DaPaiPage = Ystep * bornPos.x;
            this.mjBornPos = bornPos;

            if (ani != null)
            {
                ani.SetFloat("DaPaiX", DaPaiX);
                ani.SetFloat("DaPaiPage", DaPaiPage);
                ani.SetInteger("actionType", (int)DaPaiActionType.DaPai);
                float ret = UnityEngine.Random.Range(0.0f, 1.0f);
                isRandom = (ret >= 0.5f) ? true : false;
                ani.SetBool("isRandom", isRandom);
            }
        }
    }
    /// <summary>
    /// 摊牌时绑定手牌
    /// </summary>
    public void Event_LiPaiStart(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            pgData.GetNode(PaiGroupInHand.LiPai).BindMjGroup();

            MJRolesControl mjr = transform.parent.parent.GetComponent<MJRolesControl>();
            if (mjr == null || mjr.ctrlUI == null)
                return;
            HandMJNode hn = mjr.ctrlUI.GetHandNode(this.seat);
            if (hn == null)
                return;

            hn.LiPaiStart();
        }
    }
    /// <summary>
    /// 摊牌时放弃绑定手牌
    /// </summary>
    public void Event_LiPaiEnd(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            pgData.GetNode(PaiGroupInHand.LiPai).FreeBindMjGroup();

            MJRolesControl mjr = transform.parent.parent.GetComponent<MJRolesControl>();
            if (mjr == null || mjr.ctrlUI == null)
                return;
            HandMJNode hn = mjr.ctrlUI.GetHandNode(this.seat);
            if (hn == null)
                return;

            hn.LiPaiEnd();
        }
    }


    public void HuPai()
    {
        if (ani != null)
        {
            int index = MJManger.GetHuPostion(this.seat);
            GameObject go = pgData.GetNode(PaiGroupInHand.HuPai).LoadMJGroup();
            if (go != null)
            {
                MJManger.AddPCGgo(this.seat, go);
                MJTypePosition mp = go.AddComponent<MJTypePosition>();
                mp.SetParam(this.seat,index, PaiGroupDestination.HuArea);
            }
            Vector3 pos = MJManger.GetHuPaiAniParam(index);
            ani.SetFloat("HuPaiX", pos.z);
            ani.SetFloat("HuPaiLayer", pos.y);
            ani.SetFloat("HuPaiPage", pos.x);
            ani.SetInteger("actionType", (int)DaPaiActionType.HuPai);
            MJManger.AddHuPostion(this.seat, index);
        }
    }

    /// <summary>
    /// 吃碰杠到桌面
    /// </summary>
    public void Event_HuPai2Table(AnimationEvent ev)
    {
        if (ev.animatorClipInfo.weight >= 0.5f)
        {
            pgData.GetNode(PaiGroupInHand.HuPai).Change2Table();
        }
            
    }
    /// <summary>
    /// 设置角色座位数据
    /// </summary>
    /// <param name="data"></param>
    public void SetSeatConfig(SeatConfigData data, List<int> listPM)
    {
        transform.localPosition = Vector3.zero;
        transform.localEulerAngles = Vector3.zero;
        this.pgData.SetNodeData(data.listNodeBaseData);
        this.listPaiNum.Clear();
        this.listPaiNum.AddRange(listPM);
        this.seat = data.seat;
        foreach (string part in data.listHidePart)
        {
            Transform t = transform.Find(part);
            if (t != null)
            {
                t.gameObject.SetActive(false);
            }
        }
    }

}

public enum DaPaiActionType:int 
{
    DaPai        = 1,
    HuPai        = 2,
    LiPai        = 3,
    PengChiGang  = 4,
    Emoji        = 7,
    HuanPai      = 8,
    QidongAnAniu = 9,
    TanPai       = 10,
    MoPai        = 11,
}