using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeatConfigData : MonoBehaviour
{
    public Seat seat;
    /// <summary>
    /// 角色隐藏部件
    /// </summary>
    public List<string> listHidePart = new List<string>();
    /// <summary>
    /// 控制的麻将属性
    /// </summary>
    public MJConfigData mjData;
}
/// <summary>
/// 座位
/// </summary>
public enum Seat : int
{
    Self = 0,
    Right = 1,
    Face = 2,
    Left = 3,
}
