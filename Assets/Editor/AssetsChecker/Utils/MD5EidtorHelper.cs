using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using UnityEngine;

namespace EditerUtils
{
    public class MD5EidtorHelper
    {
        /// <summary>
        /// 将content转为MD5值
        /// </summary>
        /// <param name="content"></param>
        /// <returns></returns>
        public static string GetMD5(string content)
        {
            var md5 = MD5.Create();
            byte[] hash = md5.ComputeHash(Encoding.UTF8.GetBytes(content));

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < hash.Length; i++)
            {
                sb.Append(hash[i].ToString("x2"));
            }

            return sb.ToString();
        }

        /// <summary>
        /// 将文件转为MD5值
        /// </summary>
        /// <param name="fileName"> 文件地址 </param>
        /// <returns></returns>
        public static string GetMD5FromFile(string fileName)
        {
            try
            {
                FileStream file = new FileStream(fileName, FileMode.Open);
                MD5 md5 = new MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(file); //计算指定Stream 对象的哈希值
                file.Close();

                StringBuilder Ac = new StringBuilder();
                for (int i = 0; i < retVal.Length; i++)
                {
                    Ac.Append(retVal[i].ToString("x2"));
                }

                return Ac.ToString();
            }
            catch (Exception ex)
            {
                throw new Exception("GetMD5FromFile() fail,error:" + ex.Message);
            }
        }

        //将文件转为MD5值，
        //这个方法存去MD5Helper.cs
        public static string CalcMD5(byte[] data)
        {
            var md5 = MD5.Create();
            var fileMD5Bytes = md5.ComputeHash(data);
            return System.BitConverter.ToString(fileMD5Bytes).Replace("-", "").ToLower();
        }
    }

}

