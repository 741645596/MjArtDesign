using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using Weile.Core;

//[ExecuteInEditMode]
public class MajiangAreaCtrl : MonoBehaviour
{
    public GameObject maJiangPrefab;
    /// <summary>
    /// 麻将墙节点
    /// </summary>
    public List<WallMJNode> ListmajiangWallNode = new List<WallMJNode>();
    /// <summary>
    /// 手牌节点
    /// </summary>
    public List<HandMJNode> ListmajiangHandNode = new List<HandMJNode>();
    /// <summary>
    /// 胡牌节点
    /// </summary>
    public List<HuMJNode> ListmajiangHuNode = new List<HuMJNode>();
    /// <summary>
    /// 出牌节点
    /// </summary>
    public List<OutMJNode> ListMajingOutNode = new List<OutMJNode>();
    /// <summary>
    /// 加载间隔时间
    /// </summary>
    public float loadTimeStep = 0.05f;

    public GUISkin skin;

    public Vector2Int topRightPos;
    public int buttonWidthStep = 30;


    void Awake()
    {
        EventCenter.RegisterHooks(EventCenterType.FaMajiang, Event_FaPai);
    }

    private void OnGUI()
    {
        if (GUI.Button(new Rect(topRightPos.x, topRightPos.y, 150, 30), "加载麻将", skin.button))
        {
            StartCoroutine(LoadAllMj());
        }
        if (GUI.Button(new Rect(topRightPos.x + 150 + buttonWidthStep, topRightPos.y, 200, 30), "卸载麻将", skin.button))
        {
            FreeMajiang();
        }
    }
    /// <summary>
    /// 加载所有麻将
    /// </summary>
    private IEnumerator LoadAllMj()
    {
        FreeMajiang();
        //
        yield return StartCoroutine(LoadMjWall());
        //yield return StartCoroutine(LoadMjHand());
        //yield return StartCoroutine(LoadMjHu());
        //yield return StartCoroutine(LoadMjOut());
    }
    /// <summary>
    /// 释放所有麻将
    /// </summary>
    private void FreeMajiang()
    {
        MJManger.ClearAllMJ(MJArea.All);
        // 还原手牌数据
        for (int i = 0; i < ListmajiangHandNode.Count; i++)
        {
            ListmajiangHandNode[i].ResetPos();
            ListmajiangHandNode[i].Clear();
        }
    }
    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    private IEnumerator LoadMjHu()
    {
        
        if (ListmajiangHuNode != null && ListmajiangHuNode.Count > 0)
        {
            foreach (HuMJNode node in ListmajiangHuNode)
            {
                yield return node.LoadMjHuTeam(maJiangPrefab, loadTimeStep);
            }
        }
    }
    private static void OnQuitting()
    {
        Application.quitting -= OnQuitting;
    }

    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    private IEnumerator LoadMjWall()
    {
        if (ListmajiangWallNode != null && ListmajiangWallNode.Count > 0)
        {
            foreach (WallMJNode node in ListmajiangWallNode)
            {
                yield return node.LoadMjWallTeam(maJiangPrefab, loadTimeStep);
            }
        }
    }
    /// <summary>
    /// 加载已出麻将
    /// </summary>
    public IEnumerator LoadMjOut()
    {
        if (ListMajingOutNode != null && ListMajingOutNode.Count > 0)
        {
            for (int i = 0; i < ListMajingOutNode.Count; i++)
            {
                yield return ListMajingOutNode[i].LoadMjOutTeam(maJiangPrefab, loadTimeStep);
            }
        }
    }
    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    public  IEnumerator  LoadMjHand()
    {
        
        if (ListmajiangHandNode != null && ListmajiangHandNode.Count > 0)
        {
            for (int i = 0; i < ListmajiangHandNode.Count; i++)
            {
                yield return ListmajiangHandNode[i].LoadHandCardTeam(maJiangPrefab,loadTimeStep);
                MJManger.SetTanPaiState((Seat)i, true);
            }
        }
    }
    /// <summary>
    /// 获取对应座位的手牌
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public HandMJNode GetHandNode(Seat seat)
    {
        int index = (int)seat;
        if (ListmajiangHandNode == null && ListmajiangHandNode.Count == 0 || index >= ListmajiangHandNode.Count)
            return null;
        return ListmajiangHandNode[index];
    }
    /// <summary>
    /// 获取出牌区域
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public OutMJNode GetOutNode(Seat seat)
    {
        int index = (int)seat;
        if (ListMajingOutNode == null && ListMajingOutNode.Count == 0 || index >= ListMajingOutNode.Count)
            return null;
        return ListMajingOutNode[index];
    }

    /// <summary>
    /// 获取出牌区域
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public WallMJNode GetWallNode(Seat seat)
    {
        int index = (int)seat;
        if (ListmajiangWallNode == null && ListmajiangWallNode.Count == 0 || index >= ListmajiangWallNode.Count)
            return null;
        return ListmajiangWallNode[index];
    }

    public void Event_FaPai(int Event_Send, object Param)
    {
        StartCoroutine(LoadMjHand());
    }

    void OnDestroy()
    {
        EventCenter.AntiRegisterHooks(EventCenterType.FaMajiang, Event_FaPai);
    }
}
