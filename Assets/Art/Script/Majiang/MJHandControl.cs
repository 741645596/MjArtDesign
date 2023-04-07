using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJHandControl : MonoBehaviour
{
    // Start is called before the first frame update
    public Animator ani;
    public float m_posx;
    public float m_posy;
    public List<int> listPaiNum = new List<int>();
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    private bool isShowUI = false;
    public GUIStyle style = new GUIStyle();

    private Vector2Int mjBornPos = new Vector2Int(0,0);

    private float minPos = -1;
    private float maxPos = 1;
    public Transform mjzNode;
    public GameObject mjziPrefab;
    public float waitShowTime = 0.5f;
    /// <summary>
    /// 循环打牌间隔时间
    /// </summary>
    public float intervalTime = 0.5f;
    public MJConfigData tParentPutMajiang;
    public bool isLoadFinish = true;
    public bool isRandom = false;
    public Seat seat;

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
            ani.SetBool("isPlay", true);
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
        if (mjzNode != null)
        {
            mjzNode.gameObject.SetActive(true);
        }
    }

    private IEnumerator WaitLoadMj()
    {
        MJAction mj = MJManger.GetOutLastMJ(this.seat);
        if(mj != null)
        {
            mj.SetMjBody(tParentPutMajiang, false);
        }
        //
        int layer = LayerMask.NameToLayer("Default");
        Vector3 pos = Vector3.zero + new Vector3(tParentPutMajiang.MjStepHeight * (this.mjBornPos.x), 0, tParentPutMajiang.mjStepWidth * (-this.mjBornPos.x + this.mjBornPos.y));
        LoadMajiang(tParentPutMajiang, pos, layer, tParentPutMajiang.isShowMjShadow, true);
        yield return new WaitForSeconds(intervalTime);
        isLoadFinish = true;
    }
    public void LoadMJ()
    {
        StartCoroutine(WaitLoadMj());
    }

    /// <summary>
    /// 加载麻将
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private void LoadMajiang(MJConfigData parentNode, Vector3 pos, int layer, bool isShowShadow = true, bool isSeclect = false)
    {
        if (mjziPrefab != null)
        {
            GameObject go = GameObject.Instantiate(mjziPrefab);
            go.transform.parent = tParentPutMajiang.transform;
            MJAction action = go.GetComponent<MJAction>();
            action.SetPos(pos);
            action.SetRotation(0);
            action.SetMJViewData(parentNode, isShowShadow, isSeclect);
            action.SetLayer(layer);
            //listMJ.Add(action);
            MJManger.AddOutMJ(this.seat,action);
        }
    }
    private void OnGUI()
    {
        return;
        int height = 20;
        if (GUI.Button(new Rect(10 + 0 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[clear one]", style))
        {
            ClearUpMj();
        }

        if (GUI.Button(new Rect(10 + 1 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[clear all]", style))
        {
            ClearAll();
        }

        if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[push all]", style))
        {
            playAllMj();
        }

        isShowUI = GUI.Toggle(new Rect(30 + 3 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), isShowUI, "显示定位发麻将", style);

        if (isShowUI == true)
        {
            height += ButtonHeightStep;
            if (listPaiNum == null || listPaiNum.Count == 0)
                return;
            float Ystep = (maxPos - minPos) / (listPaiNum.Count - 1);
            for (int line = 0; line < listPaiNum.Count; line++)
            {
                int paiNum = listPaiNum[line];
                if (paiNum <= 1)
                    continue;
                m_posy = minPos + Ystep * line;

                for (int j = 0; j < paiNum; j++)
                {
                    if (GUI.Button(new Rect(10 + j * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[" + line.ToString() + "," + j.ToString() + "]", style))
                    {
                        if (isLoadFinish == true)
                        {
                            float Xstep = (maxPos - minPos) / (paiNum - 1);
                            m_posx = minPos + Xstep * j;
                            this.mjBornPos = new Vector2Int(line, j);
                            OnControllerHandAni(m_posx, m_posy);
                        }
                    }
                }
                height += ButtonHeightStep;
            }
        }
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
}
