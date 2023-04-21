using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Weile.Core;
using DG.Tweening;

public class ExchangeMajingAction : MonoBehaviour
{
    // Start is called before the first frame update
    public float rotateTime = 1.0f;
    void Start()
    {
        EventCenter.RegisterHooks(EventCenterType.ExchangMajiang, RotateMajiang);
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
        float angle = (float)Param;
        transform.DORotate(new Vector3(0,angle, 0), rotateTime);
        transform.DORestart();
    }
}
