using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MGame
{
    /// <summary>
    /// 换装数据
    /// @author : db
    /// </summary>
    public class AvatarData 
    {
        /// <summary>
        /// 当前的角色（男女m1,f1）
        /// </summary>
        public string CurRoleType;

        /// <summary>
        /// 背包的时装
        /// </summary>
        public Dictionary<uint, AvatarFashionData> BagFashionDic;

        /// <summary>
        /// 分好类的背包时装
        /// </summary>
        public Dictionary<AvatarPartType, Dictionary<uint, AvatarFashionData>> BagDetailFashionDic;

        /// <summary>
        /// 穿戴的时装(对应的模型穿戴的时装列表，麻将桌的时装也在里面)
        /// 当前模型：m1 : 男, f1 : 女, s1 : 麻将
        /// </summary>
        public Dictionary<string, List<AvatarEquipData>> EquipFashionDic;

        /// <summary>
        /// 当前性别下的 穿戴数据
        /// </summary>
        public List<AvatarEquipData> CurEquipFashionList => EquipFashionDic.ContainsKey(CurRoleType) ? EquipFashionDic[CurRoleType] : null;

        /// <summary>
        /// 其他玩家穿戴的时装（用户id，时装信息）
        /// </summary>
        public Dictionary<uint, AvatarOtherPlayerEquipData> OtherPlyaerEqFaDic;

        /// <summary>
        /// 女角色默认时装id
        /// </summary>
        public List<uint> GirlNorModelIdList;
        /// <summary>
        /// 男角色默认时装id
        /// </summary>
        public List<uint> BoyNorModelIdList;
    }

    public class AvatarFashionData
    {
        public uint id;             // 时装id
        public string uid;          // 时装uid
        public uint getTime;        // 获取时间戳
        public int expirationTime; // 过期时间戳
        public ushort count;        // 数量

        /*public void SetData(AvatarFashion msg)
        {
            id = msg.id;
            uid = msg.uid;
            getTime = msg.getTime;
            expirationTime = msg.expirationTime;
            count = msg.count;
        }*/
    }

    /// <summary>
    /// 装备的时装数据
    /// </summary>
    public class AvatarEquipData
    {
        public uint id;     // 时装id
        public string uid;  // 时装uid
        public uint pos;    // 时装挂载点
        public byte op;     // 0：装备，1：卸载

        public AvatarEquipData()
        { }

        public AvatarEquipData(uint id, string uid, uint pos, byte op)
        {
            this.id = id;
            this.uid = uid;
            this.pos = pos;
            this.op = op;
        }

        /*public void SetData(AvatarEquipRsp msg)
        {
            id = msg.id;
            uid = msg.uid;
            pos = msg.pos;
        }*/
    }

    /// <summary>
    /// 其他玩家的时装信息
    /// </summary>
    public class AvatarOtherPlayerEquipData
    {
        public string roleType;
        public List<AvatarEquipData> equipDataList;
    }

    /// <summary>
    /// 装扮rt数据
    /// </summary>
    public class AvatarRTData 
    {
        /// <summary>
        /// 标记，1：身体，2：手
        /// </summary>
        public int flag;

        public AvatarRTData(int flag)
        {
            this.flag = flag;
        }
    }

    /// <summary>
    /// 装扮rt截帧数据
    /// </summary>
    public class AvatarSnapRTData
    {
        /// <summary>
        /// 停止时间（0~1）
        /// </summary>
        public float nTime;
        /// <summary>
        /// 动画名字
        /// </summary>
        public string aniName;
        /// <summary>
        /// 模型位置
        /// </summary>
        public Vector3 pos;

        public AvatarSnapRTData(float time, string name)
        {
            nTime = time;
            aniName = name;
        }
    }

    /// <summary>
    /// 播放某些动画所使用到的小物件的数据
    /// </summary>
    public class AvatarAniModelData
    {
        /// <summary>
        /// 播放动画的状态名字
        /// </summary>
        public string StateName;
        /// <summary>
        /// 模型名字
        /// </summary>
        public string ModelName;

        public AvatarAniModelData(string modelName, string stateName)
        {
            ModelName = modelName;
            StateName = stateName;
        }
    }
}
