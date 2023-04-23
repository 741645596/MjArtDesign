using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Weile.Core;
using DG.Tweening;

public class ExchangeMajingAction : MonoBehaviour
{
    // Start is called before the first frame update
    public float rotateTime = 1.0f;
    private Vector3 bakeRorate;
    void Start()
    {
        EventCenter.RegisterHooks(EventCenterType.ExchangMajiang, RotateMajiang);
        bakeRorate = transform.localEulerAngles;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnDestroy()
    {
        EventCenter.AntiRegisterHooks(EventCenterType.ExchangMajiang, RotateMajiang);
    }

    private void RotateMajiang(int Event_Send, object Param)
    {
        ResetMJ();
        float angle = (float)Param;
        transform.DORotate(new Vector3(0,angle, 0), rotateTime);
        transform.DORestart();
    }

    private void ResetMJ()
    {
        transform.localEulerAngles = bakeRorate;
        int total = transform.childCount;
        for (int i = 0; i < total; i++)
        {
            Transform child = transform.GetChild(i);
            DestoryChild(child);
        }
    }

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
}
