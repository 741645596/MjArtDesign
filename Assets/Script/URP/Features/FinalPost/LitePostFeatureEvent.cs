using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace GF
{
    public delegate void FeatureEvent();

    public delegate void GetRendertextEvent(RenderTexture rt);

    public class LitePostFeatureEvent: FeaturesSingleton<LitePostFeatureEvent>
    {

        const int ACTION_MAXCOUNT = 8;

        private List<LitePostFeatureEventType> actionList = new List<LitePostFeatureEventType>(ACTION_MAXCOUNT);

        private Dictionary<LitePostFeatureRTGetType, GetRendertextEvent> rtActionDic = new Dictionary<LitePostFeatureRTGetType, GetRendertextEvent>();

        public void Update()
        {
            if (actionList.Count>0)
            {
                for (int i=0,listCount= actionList.Count;i< listCount;++i)
                {
                    LitePostFeatureEventType eventType= actionList[i];
                    InvokeEvent(eventType);
                }
                actionList.Clear();
            }
        }

        public GetRendertextEvent GetRendertex(LitePostFeatureRTGetType eventType)
        {
            GetRendertextEvent del = null;
            if (rtActionDic.TryGetValue(eventType,out del))
            {
                return del;
            }
            return null;
        }

        public void AddRendertexEvent(LitePostFeatureRTGetType eventType, GetRendertextEvent del)
        {
            rtActionDic[eventType] = del;
        }

        public void RemoveRendertexEvent(LitePostFeatureRTGetType eventType)
        {
            rtActionDic.Remove(eventType);
        }

        public void AddEvent(LitePostFeatureEventType eventType)
        {
            if (actionList.Count>= ACTION_MAXCOUNT)
            {
                throw (new System.Exception("actionList cout out of range!"));
            }
            actionList.Add(eventType);
        }

        void InvokeEvent(LitePostFeatureEventType eventType)
        {
            switch (eventType)
            {
                case LitePostFeatureEventType.CapRTMainCameraOpen:
                    {
                        staticCapRT = true;
                    }
                    break;
                case LitePostFeatureEventType.CapRTMainCameraClose:
                    {
                        staticCapRT = false;
                    }
                    break;
                case LitePostFeatureEventType.CapRTUICameraOpen:
                    {
                        staticUICapRT = true;
                    }
                    break;
                case LitePostFeatureEventType.CapRTUICameraClose:
                    {
                        staticUICapRT = false;
                    }
                    break;
            }
        }

        bool staticCapRT = false;

        /// <summary>
        /// 单帧主相机截取
        /// </summary>
        public bool StaticCapRT
        {
            get
            {
                return staticCapRT;
            }
        }

        bool staticUICapRT = false;

        /// <summary>
        /// 单帧UI相机截取
        /// </summary>
        public bool StaticUICapRT
        {
            get
            {
                return staticUICapRT;
            }
        }
    }

    public enum LitePostFeatureEventType
    {
        CapRTMainCameraOpen=0,
        CapRTMainCameraClose=1,
        CapRTUICameraOpen=2,
        CapRTUICameraClose=3,
    }

    public enum LitePostFeatureRTGetType
    {
        CapRTMainCamera=0,
        CapRTUICamera=1,
    }
}

