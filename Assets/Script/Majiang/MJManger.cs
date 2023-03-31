using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJManger 
{
    private static List<MJAction> g_ListMJ = new List<MJAction>();
    /// <summary>
    /// 已出牌
    /// </summary>
    private static Dictionary<Seat, List<MJAction>>  g_DicOutMJ = new Dictionary<Seat, List<MJAction>>();
    /// <summary>
    /// 添加麻将子
    /// </summary>
    /// <param name="mj"></param>
    public static void AddMJ(MJAction mj)
    {
        if (mj != null)
        {
            g_ListMJ.Add(mj);
        }
    }
    /// <summary>
    /// 清理所有麻将
    /// </summary>
    public static void ClearAllMJ()
    {
        for (int i = 0; i < g_ListMJ.Count; i++)
        {
            if (g_ListMJ[i] != null)
            {
                GameObject.Destroy(g_ListMJ[i].gameObject);
            }
        }
        g_ListMJ.Clear();
    }
    /// <summary>
    /// 添加已出牌麻将子
    /// </summary>
    /// <param name="seat"></param>
    /// <param name="mj"></param>
    public static void AddOutMJ(Seat seat, MJAction mj)
    {
        List<MJAction> list = null;
        if (g_DicOutMJ.TryGetValue(seat, out list) == true)
        {
            list.Add(mj);
        }
        else 
        {
            list = new List<MJAction>();
            list.Add(mj);
            g_DicOutMJ.Add(seat, list);
        }
    }

    /// <summary>
    /// 清理指定座位最后一张牌
    /// </summary>
    /// <param name="seat"></param>
    public static void ClearOutLastMJ(Seat seat)
    {
        List<MJAction> list = null;
        if (g_DicOutMJ.TryGetValue(seat, out list) == true)
        {
            if (list != null && list.Count > 0)
            {
                MJAction mj = list[list.Count - 1];
                if (mj != null)
                {
                    GameObject.Destroy(mj.gameObject);
                }
                list.RemoveAt(list.Count -1);
            }
        }
    }
    /// <summary>
    ///   获取最后一个麻将子
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public static MJAction GetOutLastMJ(Seat seat)
    {
        List<MJAction> list = null;
        if (g_DicOutMJ.TryGetValue(seat, out list) == true)
        {
            if (list != null && list.Count > 0)
            {
                return list[list.Count - 1];
            }
        }
        return null;
    }
    /// <summary>
    /// 清理指定座位已出牌
    /// </summary>
    /// <param name="seat"></param>
    public static void ClearOutMJ(Seat seat)
    {
        List<MJAction> list = null;
        if (g_DicOutMJ.TryGetValue(seat, out list) == true)
        {
            foreach (MJAction mj in list)
            {
                if (mj != null)
                {
                    GameObject.Destroy(mj.gameObject);
                }
            }
            list.Clear();
            g_DicOutMJ.Remove(seat);
        }
    }
    /// <summary>
    /// 清理指定座位已出牌
    /// </summary>
    /// <param name="seat"></param>
    public static void ClearAllOutMJ()
    {
        foreach(List<MJAction> list in g_DicOutMJ.Values)
        {
            foreach (MJAction mj in list)
            {
                if (mj != null)
                {
                    GameObject.Destroy(mj.gameObject);
                }
            }
            list.Clear();
        }
        g_DicOutMJ.Clear();
    }
}
/// <summary>
/// 座位
/// </summary>
public enum Seat:int
{
    Self  = 0,
    Right = 1,
    Face  = 2,
    Left  = 3,
}
