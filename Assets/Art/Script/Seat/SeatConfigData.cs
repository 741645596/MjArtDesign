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
    /// 桌面挂载节点数据
    /// </summary>
    public List<PaiGroupNodeBaseData> listNodeBaseData = new List<PaiGroupNodeBaseData>();
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
