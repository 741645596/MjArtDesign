using Weile.Core;
using UnityEngine;
using Weile.Core.Module;
using Weile.Core.Manger.Coroutine;

/// <summary>
/// 帧调度，本组件绑定到gameobject以发挥作用
/// </summary>
public class Scheduler : MonoBehaviour
{
    public bool ac = false;
    
    public virtual void Awake()
    {
        WeileString.Init();
        DontDestroyOnLoad(gameObject);
        //Application.targetFrameRate = 30;
        EventCenter.Init();
    }
    
    
    public virtual void Update()
    {
        try {
        
            if (Input.GetKeyDown(KeyCode.Escape) == true) {
                Application.Quit();
            }
            // 通讯消息
            //场景数据调度
            // 携程工具
            WeileCoroutine.Update();
            // 定时器工具
            Timer.Update();
        } catch (System.Exception e) {
            Debug.LogError(e);
        }
    }
    
    public virtual void LateUpdate()
    {
    }
    
    public virtual void FixedUpdate()
    {
    }
    
    // 退出游戏的处理 临时
    bool allowQuit = false;
    void OnApplicationQuit()
    {
        if (allowQuit) {
            return;
        }
        ModuleMgr.ClearAllModuleDC();
        EventCenter.Free();
        Application.Quit();
    }
    
}
