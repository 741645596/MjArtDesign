using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaiGroupManger 
{
   
}
/// <summary>
/// ������Դ
/// </summary>
public enum PaiGroupSource: int
{
    MajiangWall       = 0, // ��Դ�齫ǽ�����Ƶ�
    PlayerOutMajiang  = 1, // ��Ҵ��ȥ���ƣ������ܺ�
    HandMajiang       = 2, // ��Ҵ��ȥ���ƣ�����
    ExchangeMajiang   = 3, // ���ڽ�������
    // 
}


/// <summary>
/// ����ȥ��Ŀ��λ��
/// </summary>
public enum PaiGroupDestination : int
{

    HandMajiangArea = 0,          // ��������
    OutArea         = 1,          // ��������
    ChiPengGangArea = 2,          // ��Ҵ��ȥ���ƣ������ܺ�
    HuArea          = 3,          // ��������
    ExchangeMajiang = 4,          // ���ڽ�������
}

/// <summary>
/// ���鶯��
/// </summary>
public enum PaiGroupInHand : int
{
    OutMajiang  = 0,       // ����ʱ��������
    ChiPengGang = 1,       // ��������������
    HuPai       = 2,       // ����ʱ��������
    Exchange    = 3,       // ����ʱ��������
    Showdown    = 4,       // ̯��ʱ
}