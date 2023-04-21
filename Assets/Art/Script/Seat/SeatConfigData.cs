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
    /// ������ؽڵ�����
    /// </summary>
    public List<PaiGroupNodeBaseData> listNodeBaseData = new List<PaiGroupNodeBaseData>();
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
