using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MGame
{
    /// <summary>
    /// 换装自定义数据
    /// @author: db
    /// </summary>
    public class AvatarDefine
    {
        public const int NorBodyPartCount = 5;
        public const int GirlNorHandModelId = 99998;//特殊id，女初始的手，不在表里面体现
        public const int BoyNorHandModelId = 99999;//特殊id，男初始的手，不在表里面体现

        public const string BoyHeadName = "B_";
        public const string GirlHeadName = "G_";

        public const string UpperBodySmrName = "shangshen000";
        public const string JacketSmrName = "shangyi001";
        public const string PantsSmrName = "xiayi001";
        public const string LegSmrName = "xiashen000";
        public const string ShoesSmrName = "xiezi001";
        public const string NailSmrName = "zhijia000";
        public const string HandRSmrName = "handR001";
        public const string HandLSmrName = "handL001";

        public const string GirlModelPath = "Assets/AppAssets/Avater/ResAB/Girl/";
        public const string GirlCommonModelPath = "Assets/AppAssets/Avater/ResAB/Common/Girl/";

        public const string BoyModelPath = "Assets/AppAssets/Avater/ResAB/Boy/";
        public const string BoyCommonModelPath = "Assets/AppAssets/Avater/ResAB/Common/Boy/";

        public const string HandModelPath = "Assets/AppAssets/Avater/ResAB/Hand/";
        public const string HandCommonModelPath = "Assets/AppAssets/Avater/ResAB/Common/Hand/";

        public const string OhterHandModelPath = "Assets/AppAssets/Avater/ResAB/Avatar/AvatarModel/Hand/Hand/";
        public const string AniCommonModelPath = "Assets/AppAssets/Avater/ResAB/Common/AniModel/";

        public const string NudeModel = "luomo000.prefab";
        public const string HandModel = "hand.prefab";

        public const string GenderMan = "m1";       //性别，男
        public const string GenderWoman = "f1";     //性别，女

        #region 数据部分       

        /// <summary>
        /// 挂点名字
        /// </summary>
        public static Dictionary<AvatarHangType, string> HangName = new Dictionary<AvatarHangType, string>()
        {
            {AvatarHangType.Head, "p_tou" },
            {AvatarHangType.FingerR01, "p_jiezhiR_5" },
            {AvatarHangType.FingerR02, "p_jiezhiR_1" },
            {AvatarHangType.FingerR03, "p_jiezhiR_2" },
            {AvatarHangType.FingerR04, "p_jiezhiR_3" },
            {AvatarHangType.FingerR05, "p_jiezhiR_4" },
            {AvatarHangType.FingerL01, "p_jiezhiL_5" },
            {AvatarHangType.FingerL02, "p_jiezhiL_1" },
            {AvatarHangType.FingerL03, "p_jiezhiL_2" },
            {AvatarHangType.FingerL04, "p_jiezhiL_3" },
            {AvatarHangType.FingerL05, "p_jiezhiL_4" },
            {AvatarHangType.WristR01, "p_shoubiaoR_1" },
            {AvatarHangType.WristR02, "p_shouzhuoR_1" },
            {AvatarHangType.WristL01, "p_shoubiaoL_1" },
            {AvatarHangType.WristL02, "p_shouzhuoL_1" },
            {AvatarHangType.PasterR01, "" },
            {AvatarHangType.PasterL01, "" },
            {AvatarHangType.Hand, "" },
            {AvatarHangType.Nail, "" },
        };

        /// <summary>
        /// 身体动作名字
        /// </summary>
        public static Dictionary<AvatarBodyAni, string> BodyAniName = new Dictionary<AvatarBodyAni, string>()
        {
            {AvatarBodyAni.Idel, "Idel" },
            {AvatarBodyAni.Idel2, "Idel2" },
            {AvatarBodyAni.Show, "Show" },
            {AvatarBodyAni.Show2, "Show2" },
            {AvatarBodyAni.Show3, "Show3" },
            {AvatarBodyAni.ChangePart, "ChangePart" },
            {AvatarBodyAni.Win, "Win" },
            {AvatarBodyAni.Fail, "Fail" },
            {AvatarBodyAni.Fail2, "Fail2" },
            {AvatarBodyAni.Fail3, "Fail3" },
        };

        /// <summary>
        /// 手部动作名字
        /// </summary>
        public static Dictionary<AvatarHandAni, string> HandAniName = new Dictionary<AvatarHandAni, string>()
        {
            {AvatarHandAni.ReachOut, "ReachOut" },
            {AvatarHandAni.Idel, "Idel" },
            {AvatarHandAni.TakeBack, "TakeBack" },
            {AvatarHandAni.DrawCard, "DrawCard" },
            {AvatarHandAni.OutCard, "OutCard" },
            {AvatarHandAni.SortCard, "SortCard" },
            {AvatarHandAni.Fuzi, "Fuzi" },
            {AvatarHandAni.Shuffle, "Shuffle" },
            {AvatarHandAni.Win, "Win" },
        };

        //客户端数据，会走服务器同步，主要是用于解决服务器下发对应部件为0时，不显示裸模形态
        public static List<uint> GirlNorModelIdList = new List<uint>() { 252001, 253001, 254001, 255001, 261001 };
        public static List<uint> BoyNorModelIdList = new List<uint>() { 252004, 253004, 254004, 255003, 261001 };

        /// <summary>
        /// 动作需要的小物件数据
        /// </summary>
        public static Dictionary<string, List<AvatarAniModelData>> AniModelData = new Dictionary<string, List<AvatarAniModelData>>()
        {
            {
                "GirlBodyNorAni",
                new List<AvatarAniModelData>()
                {
                    new AvatarAniModelData("a_g_xiuxian02_sj_sc", "Show3")
                }
            }
        };

        public static Dictionary<AvatarHandModelType, Vector3> HandRTPosData = new Dictionary<AvatarHandModelType, Vector3>()
        {
            {AvatarHandModelType.Boy, new Vector3(0, 0.72f, -2.93f) },
            {AvatarHandModelType.Girl, new Vector3(0, 0.67f, -3f) },
            {AvatarHandModelType.Cat, new Vector3(0, 0.75f, -2.93f) },
            {AvatarHandModelType.IronMan, new Vector3(0, 0.72f, -2.93f) },
        };

        #endregion

        #region 2d资源的路径

        public const string SpritePath = "Assets/AppAssets/Hall/ResAB/Icons/CreateRole/Sprites/";

        #endregion
    }

    /// <summary>
    /// 换装部件类型
    /// </summary>
    public enum AvatarPartType
    {
        None = 0,
        Suit = 51,              //套装
        Head = 52,              //头
        Jacket = 53,            //上衣
        Pants = 54,             //裤子
        Shoes = 55,             //鞋子
        Nail = 61,              //指甲
        Ring = 62,              //戒指  
        Wrist = 63,             //手腕
        Paster = 64,            //贴纸
        Hand = 65,              //手臂

        Table = 71,             //牌桌
        Card = 72,              //牌背
        Effect = 73,            //特效
        HeadPortrait = 74,      //头像
        Bubble = 75,            //气泡
        Voice = 76,             //语音
        Scene = 77,             //场景

        All = 1000,             //所有部件
    }

    /// <summary>
    /// 换装挂点类型
    /// </summary>
    public enum AvatarHangType
    {
        None,
        Head = 1,       //头
        Jacket,         //上衣
        Pants,          //裤子
        Shoes,          //鞋子
        Nail,           //指甲
        FingerR01,      //右大拇指
        FingerR02,      //右食指
        FingerR03,      //右中指
        FingerR04,      //右无名指
        FingerR05,      //右小拇指
        FingerL01,      //左大拇指
        FingerL02,      //左食指
        FingerL03,      //左中指
        FingerL04,      //左无名指
        FingerL05,      //左小拇指
        WristR01,       //右手腕1
        WristR02,       //右手腕2
        WristL01,       //左手腕1
        WristL02,       //左手腕2
        PasterR01,      //右贴纸
        PasterL01,      //左贴纸
        Hand,           //手臂
        Suit,           //套装

        Table = 101,    //牌桌
        Card = 102,     //牌背

        UseHand = 999,  //特殊挂载位置，用于判断当前使用的是手臂还是首饰（该挂载点被挂载就是使用了手臂，服务器没下发这个挂载点就是使用首饰）
        All = 1000,     //全部
    }

    /// <summary>
    /// 换装身体动画
    /// </summary>
    public enum AvatarBodyAni
    {
        Idel,           //待机
        Idel2,          //待机2

        Show,           //展示
        Show2,          //展示2
        Show3,          //展示3

        ChangePart,     //换装

        Win,            //胜利
        Fail,           //失败
        Fail2,          //失败2
        Fail3,          //失败3
    }

    /// <summary>
    /// 换装手部动画
    /// </summary>
    public enum AvatarHandAni
    {
        #region 局外使用的手部动作

        ReachOut,       //伸手
        Idel,           //待机
        TakeBack,       //缩手

        #endregion

        #region 局内使用的手部动作

        DrawCard,       //摸牌
        OutCard,        //出牌
        SortCard,       //理牌
        Fuzi,           //整理副子牌
        Shuffle,        //点骰子
        Win,            //赢牌

        #endregion
    }

    /// <summary>
    /// 换装手类型
    /// </summary>
    public enum AvatarHandModelType
    {
        Boy,        //男手
        Girl,       //女手
        Cat,        //猫手
        IronMan,    //钢铁侠手
    }
}
