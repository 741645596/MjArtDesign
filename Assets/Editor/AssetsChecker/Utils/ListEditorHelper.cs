using System;
using System.Collections.Generic;

namespace EditerUtils
{
    public static class ListEditorHelper
    {
        /// <summary>
        /// 根据条件删除元素
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="list"></param>
        /// <param name="condition"></param>
        public static void RemoveByCondition<T>(List<T> list, Func<T, bool> condition)
        {
            for (int i = list.Count - 1; i >= 0; i--)
            {
                if (condition(list[i]))
                {
                    list.RemoveAt(i);
                }
            }
        }
    }
}




