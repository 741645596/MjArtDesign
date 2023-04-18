using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeatConfigData : MonoBehaviour
{
    public Seat seat;
    /// <summary>
    /// ��ɫ���ز���
    /// </summary>
    public List<string> listHidePart = new List<string>();
    /// <summary>
    /// ���Ƶ��齫����
    /// </summary>
    public MJConfigData mjData;
}
/// <summary>
/// ��λ
/// </summary>
public enum Seat : int
{
    Self = 0,
    Right = 1,
    Face = 2,
    Left = 3,
}
