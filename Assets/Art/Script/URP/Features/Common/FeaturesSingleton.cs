using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;

namespace GF
{
    public class FeaturesSingleton<T> where T : FeaturesSingleton<T>, new()
    {
        private static T _instance = null;

        private static object lockObj = new object();

        /// <summary>
        /// 统计有多少单例
        /// </summary>
        public static int count;

        /// <summary>
        ///  获取单例
        /// </summary>
        /// 
        public static T Instance
        {
            get
            {
                if (_instance == null)
                {
                    lock (lockObj)
                    {
                        if (_instance!=null)
                        {
                            return _instance;
                        }
                        count++;
                        _instance = new T();
                        _instance.Init();
                    }
                }
                return _instance;
            }
        }

        public static bool HasInstance()
        {
            return _instance != null;
        }

        public static void DestroyInstance()
        {
            if (HasInstance())
                _instance.Destroy();
        }

        protected FeaturesSingleton()
        {
        }

        protected virtual void Init()
        {

        }
        protected virtual void OnDestroy()
        {

        }

        public virtual void Destroy()
        {
            _instance = null;
            count--;
            OnDestroy();
        }
    }
}


