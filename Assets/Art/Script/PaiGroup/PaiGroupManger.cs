using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaiGroupManger 
{
   
}
/// <summary>
/// 牌组来源
/// </summary>
public enum PaiGroupSource: int
{
    MajiangWall       = 0, // 来源麻将墙，摸牌的
    PlayerOutMajiang  = 1, // 玩家打出去的牌，吃碰杠胡
    HandMajiang       = 2, // 玩家打出去的牌：手牌
    ExchangeMajiang   = 3, // 用于交换的牌
    // 
}


/// <summary>
/// 牌组去的目标位置
/// </summary>
public enum PaiGroupDestination : int
{

    HandMajiangArea = 0,          // 手牌区域
    OutArea         = 1,          // 出牌区域
    ChiPengGangArea = 2,          // 玩家打出去的牌，吃碰杠胡
    HuArea          = 3,          // 胡牌区域
    ExchangeMajiang = 4,          // 用于交换的牌
}

/// <summary>
/// 牌组动作
/// </summary>
public enum PaiGroupInHand : int
{
    OutMajiang  = 0,       // 出牌时手中拿牌
    ChiPengGang = 1,       // 吃碰杠手中拿牌
    HuPai       = 2,       // 胡牌时手中拿牌
    Exchange    = 3,       // 换牌时手中拿牌
    Showdown    = 4,       // 摊牌时
}