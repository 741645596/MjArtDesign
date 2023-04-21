using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Weile.Core;
public class GameLogic : MonoBehaviour
{
    public static bool g_IsInGame = false;
    // Start is called before the first frame update
    public RoleBindBones OutGameGO;
    public RoleBindBones InGameGO;

    void Start()
    {
        g_IsInGame = false;
        EventCenter.RegisterHooks(EventCenterType.InGame, IntoGame);
        EventCenter.RegisterHooks(EventCenterType.OutGame, OutGame);
        if (OutGameGO != null)
        {
            OutGameGO.gameObject.SetActive(true);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnDestroy()
    {
        EventCenter.AntiRegisterHooks(EventCenterType.InGame, IntoGame);
        EventCenter.AntiRegisterHooks(EventCenterType.OutGame, OutGame);
    }
    /// <summary>
    /// 进入游戏
    /// </summary>
    /// <param name="Event_Send"></param>
    /// <param name="Param"></param>
    private void IntoGame(int Event_Send, object Param)
    {
        if (InGameGO != null)
        {
            InGameGO.gameObject.SetActive(true);
        }
        if (OutGameGO != null)
        {
            OutGameGO.gameObject.SetActive(false);
        }
        g_IsInGame = true;
    }
    /// <summary>
    /// 出游戏
    /// </summary>
    /// <param name="Event_Send"></param>
    /// <param name="Param"></param>
    private void OutGame(int Event_Send, object Param)
    {
        if (InGameGO != null)
        {
            InGameGO.gameObject.SetActive(false);
        }
        if (OutGameGO != null)
        {
            OutGameGO.gameObject.SetActive(true);
        }
        g_IsInGame = false;
    }
}
