using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Weile.Core;
using DG.Tweening;

public class ExchangeMajingAction : MonoBehaviour
{
    // Start is called before the first frame update
    public float rotateTime = 1.0f;
    public float waitTime = 0.3f;
    private Vector3 bakeRorate;
    private HashSet<Seat> listSeat = new HashSet<Seat>();
    private bool isHaveMJ = false;
    void Start()
    {
        EventCenter.RegisterHooks(EventCenterType.ExchangMajiang, RotateMajiang);
        EventCenter.RegisterHooks(EventCenterType.ExchangMajiang_Start, ExchangMajiang_Start);
        bakeRorate = transform.localEulerAngles;
    }


    void OnDestroy()
    {
        EventCenter.AntiRegisterHooks(EventCenterType.ExchangMajiang, RotateMajiang);
        EventCenter.AntiRegisterHooks(EventCenterType.ExchangMajiang_Start, ExchangMajiang_Start);
    }

    private void RotateMajiang(int Event_Send, object Param)
    {
        if (Event_Send < 0 || Event_Send > 3)
            return;
        Seat seat = (Seat)Event_Send;
        if (listSeat.Contains(seat) == false)
        {
            listSeat.Add(seat);
            if (listSeat.Count == 4)
            {
                isHaveMJ = true;
                float angle = (float)Param;
                listSeat.Clear();
                StartCoroutine(WaitRotate(angle));
            }
        }
    }
    /// <summary>
    /// 等待旋转
    /// </summary>
    /// <param name="angle"></param>
    /// <returns></returns>
    private IEnumerator WaitRotate(float angle)
    {
        yield return new WaitForSeconds(waitTime);
        transform.DORotate(new Vector3(0, angle, 0), rotateTime);
        transform.DORestart();
        StartCoroutine(WaitFinishNotify(rotateTime + 0.1f));
    }
    /// <summary>
    /// reset
    /// </summary>
    private void ExchangMajiang_Start(int Event_Send, object Param)
    {
        if (isHaveMJ == true)
        {
            isHaveMJ = false;
            transform.localEulerAngles = bakeRorate;
            int total = transform.childCount;
            for (int i = 0; i < total; i++)
            {
                Transform child = transform.GetChild(i);
                DestoryChild(child);
            }
        }
    }
    /// <summary>
    /// destory
    /// </summary>
    /// <param name="t"></param>
    private void DestoryChild(Transform t)
    {
        List<GameObject> listGo = new List<GameObject>();
        if (t != null)
        {
            int total = t.childCount;
            for (int i = 0; i < total; i++)
            {
                Transform c = t.GetChild(i);
                if (c != null)
                {
                    listGo.Add(c.gameObject);
                }
            }
            foreach (GameObject g in listGo)
            {
                if (g != null)
                {
                    GameObject.Destroy(g);
                }
            }
        }
    }

    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    private IEnumerator WaitFinishNotify(float waitTime)
    {
        yield return new WaitForSeconds(waitTime);
        if (isHaveMJ == true)
        {
            isHaveMJ = false;
            transform.localEulerAngles = bakeRorate;
            int total = transform.childCount;
            for (int i = 0; i < total; i++)
            {
                Transform child = transform.GetChild(i);
                DestoryChild(child);
            }
        }
        EventCenter.DispatchEvent(EventCenterType.ExchangMajiang_Finish, -1, null);
    }
}
