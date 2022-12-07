using System.Collections.Generic;
using UnityEngine;
    public class MJConst
    {
        public static float MJCardSizeLenth = 0.034f;
        public static float MJCardSizeWidth = 0.045f;
        public static float MJCardSizeHeigh = 0.02332f;
        public static float MJCardhorizonOffset = (MJCardSizeWidth - MJCardSizeLenth) / 2;
        public static Dictionary<int, Vector2> MJCardMatOffsets = new Dictionary<int, Vector2>() 
        {
            { 0, new Vector2(0, 0) },

            { 1, new Vector2(1, 0)  },
            { 2, new Vector2(1, 1)  },
            { 3, new Vector2(1, 2)  },
            { 4, new Vector2(1, 3)  },
            { 5, new Vector2(1, 4)  },
            { 6, new Vector2(1, 5)  },
            { 7, new Vector2(1, 6)  },
            { 8, new Vector2(1, 7)  },
            { 9, new Vector2(1, 8)  },

            { 17, new Vector2(0, 0)  },
            { 18, new Vector2(0, 1)  },
            { 19, new Vector2(0, 2)  },
            { 20, new Vector2(0, 3)  },
            { 21, new Vector2(0, 4)  },
            { 22, new Vector2(0, 5)  },
            { 23, new Vector2(0, 6)  },
            { 24, new Vector2(0, 7)  },
            { 25, new Vector2(0, 8)  },

            { 33, new Vector2(2, 0)  },
            { 34, new Vector2(2, 1)  },
            { 35, new Vector2(2, 2)  },
            { 36, new Vector2(2, 3)  },
            { 37, new Vector2(2, 4)  },
            { 38, new Vector2(2, 5)  },
            { 39, new Vector2(2, 6)  },
            { 40, new Vector2(2, 7)  },
            { 41, new Vector2(2, 8)  },

            { 49, new Vector2(3, 0)  },
            { 50, new Vector2(3, 1)  },
            { 51, new Vector2(3, 2)  },
            { 52, new Vector2(3, 3)  },
            { 53, new Vector2(3, 4)  },
            { 54, new Vector2(3, 5)  },
            { 55, new Vector2(3, 6)  },

            { 65, new Vector2(3, 7)  },
            { 66, new Vector2(4, 0)  },
            { 67, new Vector2(4, 1)  },
            { 68, new Vector2(3, 8)  },
            { 69, new Vector2(4, 2)  },
            { 70, new Vector2(4, 3)  },
            { 71, new Vector2(4, 4)  },
            { 72, new Vector2(4, 5)  },

            { 64, new Vector2(4, 6)  },//花牌
            { 82, new Vector2(4, 7)  },//百
            { 252, new Vector2(4, 8)  },//威乐
            { 253, new Vector2(5, 0)  },//癞子
            { 254, new Vector2(5, 1)  },//任意
        };
        
        //4点向上时
        public static Dictionary<int, Vector2> MJShaiZiMat1Offsets = new() 
        {
            { 1, new Vector2(2, 1)  },
            { 2, new Vector2(0, 0)  },
            { 3, new Vector2(1, 0)  },
            { 4, new Vector2(0, 1)  },
            { 5, new Vector2(2, 0)  },
            { 6, new Vector2(1, 1)  }
        };

        public static Vector3 MJCard_CardBack = new Vector3(-180, 0, 0);//牌墙 展示牌背的旋转
        public static Vector3 MJCard_Left = new Vector3(0, 90, 0);//牌向左旋转90°
        public static Vector3 MJCard_Right = new Vector3(0, -90, 0);//牌向右旋转90°
        public static Vector3 MJCard_Reverse = new Vector3(0, 180, 0);//牌顺时针旋转180°
        public static Vector3 MJCard_Stand = new Vector3(-90, 0, 0);//牌立起来
        public static Vector3 MJCard_StandBack = new Vector3(-90, 0, 180);//牌立起来展示牌背

        public static Color CardGray = new(195f/255f, 195f/255f, 195f/255f);//手牌置灰

        public static int OutCardCountPerRow = 6; //出牌堆每行个数
        public static int HuCardCountPerRow = 5; //胡牌堆每行个数
        public static int HuCardCountPerRow_4 = 4; //上家胡牌堆每行个数4个

        public static float HandCardSpace = 0.017f; //手牌的间距
        public static float FuziCardSpace = 0.017f; //附子的间距
    }
    public enum MJSeat
    {
        Unkonw = -1, //未知
        Self, //自己
        Next, //下家
        Opposite, //对家
        Last//上家
    }
    public enum MJDirection
    {
        Unkonw = -1, //未知
        East, //东
        South, //南
        West, //西
        North//北
    }
    public enum MaJAction
    {
        CreatCardWall,
        OutCard,
        SendCard,
        Action,
        Hu
    }