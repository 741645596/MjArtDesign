using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Weile.Core;

public class MJHandControl : MonoBehaviour
{
    // Start is called before the first frame update
    public Animator ani;
    public float m_posx;
    public float m_posy;
    private List<int> listPaiNum = new List<int>();

    private Vector2Int mjBornPos = new Vector2Int(0,0);

    private float minPos = -1;
    private float maxPos = 1;
    public Transform OutMajiang
    {
        get 
        {
            return pgData.GetHandNode(PaiGroupInHand.OutMajiang);
        }
    }
    public float waitShowTime = 0.5f;
    /// <summary>
    /// 循环打牌间隔时间
    /// </summary>
    public float intervalTime = 0.5f;
    public bool isLoadFinish = true;
    public bool isRandom = false;
    private Seat seat;
    /// <summary>
    /// 牌组数据
    /// </summary>
    public PaiGroupData pgData = new PaiGroupData();

    void Awake()
    {
        ani = gameObject.GetComponent<Animator>();
    }

    private void OnControllerHandAni(float posX, float posY)
    {
        isLoadFinish = false;
        if (ani != null)
        {
            ani.SetFloat("PosX", posX);
            ani.SetFloat("PosY", posY);
            ani.SetInteger("actionType", (int)DaPaiActionType.DaPai);
            float ret = UnityEngine.Random.Range(0.0f, 1.0f);
            isRandom = (ret >= 0.5f) ? true : false;
            ani.SetBool("isRandom", isRandom);
        }
    }


    public void ShowMJ()
    {
        StartCoroutine(WaitShowMj());
    }
    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    private IEnumerator WaitShowMj()
    {
        yield return new WaitForSeconds(waitShowTime);
        if (OutMajiang != null)
        {
            OutMajiang.gameObject.SetActive(true);
        }
    }

    private IEnumerator WaitLoadMj()
    {
        MJAction mj = MJManger.GetOutLastMJ(this.seat);
        if(mj != null)
        {
            MJConfigData  mfg= mj.transform.parent.GetComponent<MJConfigData>();
            mj.SetMjBody(mfg, false);
        }
        //
        MJAction newmj = pgData.GetNode(PaiGroupInHand.OutMajiang).LoadMJ(this.mjBornPos);
        if (newmj != null)
        {
            MJManger.AddOutMJ(this.seat, newmj);
        }

        yield return new WaitForSeconds(intervalTime);
        isLoadFinish = true;
    }
    public void LoadMJ()
    {
        StartCoroutine(WaitLoadMj());
    }



    public void ClearUpMj()
    {
        MJManger.ClearOutLastMJ(this.seat);
    }

    public void ClearAll()
    {
        MJManger.ClearOutMJ(this.seat);
    }

    public void playAllMj()
    {
        ClearAll();
        StartCoroutine(PushAll());
    }

    public void playAllMjWithoutClear()
    {
        StartCoroutine(PushAll());
    }

    private IEnumerator PushAll()
    {
        if (listPaiNum != null && listPaiNum.Count > 0)
        {
            float Ystep = (maxPos - minPos) / (listPaiNum.Count - 1);
            for (int line = 0; line < listPaiNum.Count; line++)
            {
                int paiNum = listPaiNum[line];
                if (paiNum <= 1)
                    continue;
               
                for (int j = 0; j < paiNum; j++)
                {
                    yield return StartCoroutine(pushMJ(paiNum, Ystep, line, j));
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
    private IEnumerator pushMJ(int paiNum, float Ystep,int line, int j)
    {
        while (!isLoadFinish)
        {
            yield return new WaitForEndOfFrame();
        }
        float Xstep = (maxPos - minPos) / (paiNum - 1);
        m_posx = minPos + Xstep * j;
        m_posy = minPos + Ystep * line;
        this.mjBornPos = new Vector2Int(line, j);
        OnControllerHandAni(m_posx, m_posy);
    }


    public void TanPai()
    {
        if (ani != null)
        {
            OutMajiang.gameObject.SetActive(false);
            ani.SetInteger("actionType", (int)DaPaiActionType.TanPai);
        }
    }
    /// <summary>
    /// 摊牌时绑定手牌
    /// </summary>
    public void Event_TanPaiStart()
    {
        Debug.Log("Event_TanPaiStart");
        pgData.GetNode(PaiGroupInHand.Showdown).BindMjGroup();
    }
    /// <summary>
    /// 摊牌时放弃绑定手牌
    /// </summary>
    public void Event_TanPaiEnd()
    {
        Debug.Log("Event_TanPaiEnd");
        pgData.GetNode(PaiGroupInHand.Showdown).FreeBindMjGroup();
    }

    public void QiDongAnniu()
    {
        if (ani != null)
        {
            OutMajiang.gameObject.SetActive(false);
            ani.SetInteger("actionType", (int)DaPaiActionType.QidongAnAniu);
        }
    }

    public void HuanPai()
    {
        if (ani != null)
        {
            OutMajiang.gameObject.SetActive(false);
            pgData.GetNode(PaiGroupInHand.Exchange).LoadMJGroup();
            ani.SetInteger("actionType", (int)DaPaiActionType.HuanPai);
        }
    }
    /// <summary>
    /// 换牌到桌面
    /// </summary>
    public void Event_HuanPai2Table()
    {
        if (this.seat == Seat.Self)
        {
            float angle = 180.0f;
            EventCenter.DispatchEvent(EventCenterType.ExchangMajiang, 0, angle);
        }
        pgData.GetNode(PaiGroupInHand.Exchange).Change2Table();
    }

    public void Emoji()
    {
        if (ani != null)
        {
            OutMajiang.gameObject.SetActive(false);
            ani.SetInteger("actionType", (int)DaPaiActionType.Emoji);
            int ret = UnityEngine.Random.Range(0, 4);
            ani.SetInteger("EmojiType", ret);
        }
    }

    public void PengChiGang()
    {
        if (ani != null)
        {
            OutMajiang.gameObject.SetActive(false);
            pgData.GetNode(PaiGroupInHand.ChiPengGang).LoadMJGroup();

            float[] array = new float[3] { 0,0.5f, 1.0f};
            int index = UnityEngine.Random.Range(0, 3);
            ani.SetFloat("PosX", array[index]);
            ani.SetInteger("actionType", (int)DaPaiActionType.PengChiGang);
        }
    }

    /// <summary>
    /// 吃碰杠到桌面
    /// </summary>
    public void Event_PengChiGang2Table()
    {
        pgData.GetNode(PaiGroupInHand.ChiPengGang).Change2Table();
    }

    public void LiPai()
    {
        if (ani != null)
        {
            OutMajiang.gameObject.SetActive(false);
            ani.SetInteger("actionType", (int)DaPaiActionType.LiPai);
        }
    }

    public void HuPai()
    {
        if (ani != null)
        {
            OutMajiang.gameObject.SetActive(false);
            pgData.GetNode(PaiGroupInHand.HuPai).LoadMJGroup();
            ani.SetInteger("actionType", (int)DaPaiActionType.HuPai);
        }
    }

    /// <summary>
    /// 吃碰杠到桌面
    /// </summary>
    public void Event_HuPai2Table()
    {
        pgData.GetNode(PaiGroupInHand.HuPai).Change2Table();
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
}


