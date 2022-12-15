using System;
using MGame;
using UnityEngine;
using UnityEngine.Timeline;

namespace MJCommon
{
    /// <summary>
    /// 局内手部动画类型定义，美术新增动画的话需要同步更新一下
    /// </summary>
    public enum CharacterHandAnimType
    {
        [InspectorName("出牌动画(直接打到位置上)")]
        OutCard,

        [InspectorName("出牌动画2(先打到位置附近，再推到位置上)")]
        OutCard2,

        [InspectorName("打骰子动画")]
        CastDice,

        [InspectorName("吃碰杠动作")]
        Action,

        [InspectorName("自摸摸牌")]
        Draw,

        [InspectorName("理牌拿起")]
        Sort1,

        [InspectorName("理牌放下")]
        Sort2,

        [InspectorName("推倒牌(左手)")]
        LightCard,

        [InspectorName("推到牌(右手)")]
        LightCard2,


        [InspectorName("鼓掌(表情)")]
        GuZhang,
        [InspectorName("便便(表情)")]
        DaBian,
        [InspectorName("比心(表情)")]
        BiXIn,
    }

    [Serializable]
    public class CharacterHandAnimConfig : ScriptableObject
    {
        [Tooltip("Timeline 动画文件")]
        public TimelineAsset asset;

        [Tooltip("模型类型")]
        public AvatarHandModelType modelType;

        [Tooltip("动画类型")]
        public CharacterHandAnimType animType;

        [Tooltip("Timeline动画绑定的物体的层级路径")]
        public string[] bindings;

        [Tooltip("预挂的麻将牌物体层级路径，没有则留空。")]
        public string[] cards;

        [Tooltip("挂点物体层级路径")]
        public string[] guaDians;

        // 以下变量为了方便调试，正式都不能为true
        public bool pauseOnStart = false;
        public bool pauseOnDropPoint = false;
    }
}