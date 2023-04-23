
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using EditerUtils;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public static class MaterialChecker
{
    /// <summary>
    /// 搜索有问题的材质球信息
    /// </summary>
    /// <returns></returns>
    public static void CollectAssetInfo(Action<List<MaterialAssetInfo>> finishCB)
    {
        var files = DirectoryHelper.GetAllFiles(AssetsCheckEditorWindow.Asset_Search_Path, ".mat");
        FixHelper.AsyncCollect<MaterialAssetInfo>(files, (file) =>
        {
            return GetAssetInfo(file);
        },
        (res)=>
        {
            finishCB(res);
        });
    }

    /// <summary>
    /// 获取材质球信息
    /// </summary>
    /// <param name="file"></param>
    /// <returns> 材质球无问题返回null </returns>
    public static MaterialAssetInfo GetAssetInfo(string file)
    {
        var material = AssetDatabase.LoadAssetAtPath<Material>(file);
        if (material == null)
        {
            Debug.LogWarning($"错误提示：读取材质球{file}失败");
            return null;
        }

        var redundanceKeywords = MaterialLogic.GetRedundanceKeywords(material);
        var redunanceRes = MaterialLogic.GetRedunanceRes(material);
        var hasEmpty = HasEmptyTexture(material);
        if (redundanceKeywords.Count == 0 &&
            redunanceRes.Count == 0 &&
            hasEmpty == false)
        {
            return null;
        }

        var info = new MaterialAssetInfo();
        info.assetPath = file;
        info.filesize = EditerUtils.FileHelper.GetFileSize(file);

        info.hasEmptyTexture = hasEmpty;
        info.redundanceKeywords = redundanceKeywords;
        info.redundanceRes = redunanceRes;

        return info;
    }

    public static void FixAll(List<MaterialAssetInfo> infos, Action<bool> finishCB)
    {
        FixHelper.FixStep<MaterialAssetInfo>(infos, (info) =>
        {
            if (info.CanFix())
            {
                info.FixNotRefresh();
            }
        },
        (isCancel) =>
        {
            AssetDatabase.Refresh();

            finishCB(isCancel);
        });
    }

    /// <summary>
    /// 是否有空纹理
    /// </summary>
    /// <param name="material"></param>
    /// <returns></returns>
    public static bool HasEmptyTexture(Material material)
    {
        var shader = material.shader;
        var count = shader.GetPropertyCount();
        for (var i = 0; i < count; i++)
        {
            if (shader.GetPropertyType(i) != ShaderPropertyType.Texture)
            {
                continue;
            }

            var name = shader.GetPropertyName(i);
            var texture = material.GetTexture(name);
            if (texture != null)
            {
                continue;
            }

            // keyword没打开则表示空纹理
            var keyword = _GetKeyword(name);
            if (material.IsKeywordEnabled(keyword) == true)
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// 规范：控制贴图开关的keyword为首字符_ON，如纹理名称为"_DistortTex"则关键字为"DISTORT_ON"
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    private static string _GetKeyword(string name)
    {
        var firstName = _GetFristWord(name).ToUpper();
        return firstName + "_ON";
    }

    private static string _GetFristWord(string str)
    {
        if (string.IsNullOrEmpty(str))
        {
            return "";
        }

        var strLen = str.Length;
        var firstIndex = _GetFirstLetterIndex(0, str, strLen);
        var lastIndex = _GetLastLetterIndex(firstIndex, str, strLen);
        return str.Substring(firstIndex, lastIndex);
    }

    private static int _GetLastLetterIndex(int fromIndex, string str, int strLen)
    {
        for (int i = fromIndex + 1; i < strLen; i++)
        {
            if (StringEditorHelper.IsUpper(str[i]))
            {
                return i - 1;
            }
        }
        return strLen - 1;
    }

    private static int _GetFirstLetterIndex(int fromIndex, string str, int strLen)
    {
        for (int i = fromIndex; i < strLen; i++)
        {
            if (StringEditorHelper.IsLetter(str[i]))
            {
                return i;
            }
        }
        return strLen - 1;
    }
}

