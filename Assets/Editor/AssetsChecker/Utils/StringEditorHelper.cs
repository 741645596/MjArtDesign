using System;
using System.Collections.Generic;

namespace EditerUtils
{
    public static class StringEditorHelper
    {
        /// <summary>
        /// 判断ch是否是字母(包括大小写)
        /// </summary>
        /// <param name="ch"></param>
        /// <returns></returns>
        public static bool IsLetter(char ch)
        {
            return IsUpper(ch) || IsLower(ch);
        }

        /// <summary>
        /// 判断ch是否都是大写字母
        /// </summary>
        /// <param name="ch"></param>
        /// <returns></returns>
        public static bool IsUpper(char ch)
        {
            return 'A' <= ch && ch <= 'Z';
        }

        /// <summary>
        /// 判断ch是否是小写字母
        /// </summary>
        /// <param name="ch"></param>
        /// <returns></returns>
        public static bool IsLower(char ch)
        {
            return 'a' <= ch && ch <= 'z';
        }
    }
}




