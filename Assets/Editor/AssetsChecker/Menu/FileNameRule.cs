﻿using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace EditerUtils
{
    public static class FileNameRule
    {
        /// <summary>
        /// 规范：禁止文件名包含空格和中文字符
        /// </summary>
        [MenuItem("Tools/文件名规范检测", false, 100)]
        public static void CheckFileName()
        {
            LogHelper.ClearLogConsole();

            Debug.Log("开始检查 (禁止文件名包含空格和中文字符)");
            var assets = AssetsHelper.GetGameAssetsPaths();
            bool res = true;
            foreach (var path in assets)
            {
                var r = CheckFileName(path);
                if (r == false)
                {
                    res = false;
                }
            }
            if (res)
            {
                Debug.Log("检查结束，未发现问题");
            }
            else
            {
                Debug.LogError("检查结束，请向上看，日志可以点击跳转");
            }
        }

        /// <summary>
        /// 检查文件路径是否包含空格或中文字符
        /// </summary>
        /// <param name="path"></param>
        public static bool CheckFileName(string path)
        {
            var fileName = Path.GetFileName(path);

            // 检查是否包含空格
            if (PathHelper.HasEmptyChar(fileName))
            {
                Debug.LogWarning($"错误提示：文件名{path}包含空格，请修改文件名！", AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path));
                return false;
            }

            // 文件名是否包含中文字符
            if (PathHelper.HasChineseChar(fileName))
            {
                Debug.LogError($"错误提示：文件名{path}包含中文字符，请修改文件名！", AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path));
                return false;
            }
            return true;
        }
    }
}


