
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 大图检测用到的数据
/// </summary>
public class BigPicAssetInfo : AssetInfoBase
{
    public const int Recommonnd_Aniso_Level_Value = 1;

    public bool isSpriete2D;
    public bool isReadable;
    public bool isMipmap;
    public FilterMode filterMode;

    // 图片宽/高
    public int width;
    public int height;

    // 面积 width x height
    public int area; 

    // 安卓&苹果&webgl压缩格式
    public bool isAndroidOverride;
    public TextureImporterFormat androidFormat;
    public bool isIosOverride;
    public TextureImporterFormat iosFormat;
    public bool isWebGLOverride;
    public TextureImporterFormat webGLFormat;

    // 是否拥有透明像素
    public bool haveAlpha;
    public TextureImporterAlphaSource alphaSource;

    // 各向异性
    public int anisoLevel;

    // max size是否一致
    public bool isSameMaxSize;

    // 是否需要开启单通道
    public bool isNeedSingleChannel;

    public override bool CanFix()
    {
        if (IsNeedSetNone())
        {
            return true;
        }

        if (isReadable)
        {
            return true;
        }

        if (isMipmap && isSpriete2D)
        {
            return true;
        }

        if (filterMode == FilterMode.Trilinear)
        {
            return true;
        }

        if (anisoLevel > Recommonnd_Aniso_Level_Value)
        {
            return true;
        }

        if (isAndroidOverride == false ||
            isIosOverride == false ||
            isWebGLOverride == false ||
            BigPicChecker.IsAstcFormat(androidFormat) == false ||
            BigPicChecker.IsAstcFormat(iosFormat) == false ||
            BigPicChecker.IsAstcFormat(webGLFormat) == false)
        {
            return true;
        }

        if (isNeedSingleChannel)
        {
            return true;
        }

        return false;
    }

    public override void Fix()
    {
        var importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;

        // 过滤模式
        if (importer.filterMode == FilterMode.Trilinear)
        {
            importer.filterMode = FilterMode.Bilinear;
            filterMode = FilterMode.Bilinear;
        }

        if (anisoLevel > Recommonnd_Aniso_Level_Value)
        {
            importer.anisoLevel = Recommonnd_Aniso_Level_Value;
            anisoLevel = Recommonnd_Aniso_Level_Value;
        }

        // 修复None 
        if (IsNeedSetNone())
        {
            importer.alphaSource = TextureImporterAlphaSource.None;
            alphaSource = TextureImporterAlphaSource.None;
        }

        // 修复纹理格式
        if (isAndroidOverride == false ||
            isIosOverride == false ||
            isWebGLOverride == false)
        {
            _FixOverride(importer);
        }

        // 修复纹理格式
        if (BigPicChecker.IsAstcFormat(androidFormat) == false ||
            BigPicChecker.IsAstcFormat(iosFormat) == false ||
            BigPicChecker.IsAstcFormat(webGLFormat) == false)
        {
            var newFormat = BigPicChecker.GetRecommonFormat(haveAlpha);
            _FixFormat(importer, newFormat);
        }

        // 读写
        if (isReadable)
        {
            importer.isReadable = false;
            isReadable = false;
        }
        
        // mipmap
        if (isSpriete2D)
        {
            importer.mipmapEnabled = false;
            isMipmap = false;
        }

        // single channel
        if (isNeedSingleChannel)
        {
            importer.textureType = TextureImporterType.SingleChannel;
            isNeedSingleChannel = false;

            TextureImporterSettings settings = new TextureImporterSettings();
            importer.ReadTextureSettings(settings);
            settings.singleChannelComponent = TextureImporterSingleChannelComponent.Red;
            importer.SetTextureSettings(settings);
        }
        
        importer.SaveAndReimport();
    }

    public override string GetErrorDes()
    {
        if (IsError() == false) return $"尺寸{width}x{height}；纹理格式{BigPicChecker.GetAstcName(androidFormat)}";

        var desArr = new List<string>();

        desArr.Add($"尺寸{width}x{height}");

        if (isReadable)
        {
            desArr.Add($"R&W未关闭");
        }

        if (isMipmap)
        {
            var des = isSpriete2D ? $"Mipmap未关闭(2D and UI)" : $"Mipmap未关闭(Defalut)";
            desArr.Add(des);
        }

        if (filterMode == FilterMode.Trilinear)
        {
            desArr.Add($"filterMode建议为Bilinear");
        }

        if (anisoLevel > Recommonnd_Aniso_Level_Value)
        {
            desArr.Add($"AnisoLevel={anisoLevel}");
        }

        if (isAndroidOverride == false)
        {
            desArr.Add("Android未开启overridden");
        }

        if (isIosOverride == false)
        {
            desArr.Add("iOS未开启overridden");
        }

        if (isWebGLOverride == false)
        {
            desArr.Add("WebGL未开启overridden");
        }

        if (isSameMaxSize == false)
        {
            desArr.Add("max size不一样");
        }

        if (BigPicChecker.IsAstcFormat(androidFormat) == false)
        {
            desArr.Add("Android非astc格式");
        }

        if (BigPicChecker.IsAstcFormat(iosFormat) == false)
        {
            desArr.Add("iOS非astc格式");
        }

        if (BigPicChecker.IsAstcFormat(webGLFormat) == false)
        {
            desArr.Add("WebGL非astc格式");
        }

        if (IsNeedSetNone())
        {
            desArr.Add("AlphaSource可设置为None");
        }

        if (isNeedSingleChannel)
        {
            desArr.Add("可设置单通道");
        }

        return string.Join("；", desArr);
    }

    public override bool IsError()
    {
        if (IsNeedSetNone())
        {
            return true;
        }

        if (isReadable)
        {
            return true;
        }

        if (isMipmap)
        {
            return true;
        }

        if (isSameMaxSize == false)
        {
            return true;
        }

        if (filterMode == FilterMode.Trilinear)
        {
            return true;
        }

        if (anisoLevel > Recommonnd_Aniso_Level_Value)
        {
            return true;
        }

        if (isAndroidOverride == false ||
            isIosOverride == false ||
            BigPicChecker.IsAstcFormat(androidFormat) == false ||
            BigPicChecker.IsAstcFormat(iosFormat) == false)
        {
            return true;
        }

        if (isNeedSingleChannel)
        {
            return true;
        }

        return false;
    }

    /// <summary>
    /// 是否需要将纹理Alpha Source设置为None
    /// </summary>
    /// <param name="info"></param>
    /// <returns></returns>
    public bool IsNeedSetNone()
    {
        if (alphaSource == TextureImporterAlphaSource.FromGrayScale)
        {
            return false;
        }

        // 如果没有透明通道，需要设置为None
        if (haveAlpha == false)
        {
            return alphaSource != TextureImporterAlphaSource.None;
        }
        return false;
    }

    /// <summary>
    /// 设置纹理格式
    /// </summary>
    /// <param name="info"></param>
    /// <param name="newFormat"></param>
    public void SetTextureFormat(TextureImporterFormat newFormat)
    {
        var importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;
        _FixFormat(importer, newFormat);
        importer.SaveAndReimport();
    }

    /// <summary>
    /// 按推荐的纹理格式设置，带Alpha通道ASTC 5x5，不带Alpha通道ASTC 6x6
    /// </summary>
    /// <param name="info"></param>
    public void RecommonFormat()
    {
        var newFormat = BigPicChecker.GetRecommonFormat(haveAlpha);
        SetTextureFormat(newFormat);
    }

    public void OpenDefaultMipmap()
    {
        if (isMipmap)
        {
            return;
        }

        if (isSpriete2D)
        {
            return;
        }

        var importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;
        importer.mipmapEnabled = true;
        importer.SaveAndReimport();
        isMipmap = true;
    }

    public void CloseMipmap()
    {
        if (isMipmap == false)
        {
            return;
        }

        var importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;
        importer.mipmapEnabled = false;
        importer.SaveAndReimport();
        isMipmap = false;
    }

    private void _FixOverride(TextureImporter importer)
    {
        BigPicChecker.SetOverridden(importer, true);
        isAndroidOverride = true;
        isIosOverride = true;
        isWebGLOverride = true;
    }

    private void _FixFormat(TextureImporter importer, TextureImporterFormat newFormat)
    {
        BigPicChecker.SetTextureFormat(importer, newFormat);

        isAndroidOverride = true;
        androidFormat = newFormat;

        isIosOverride = true;
        iosFormat = newFormat;

        isWebGLOverride = true;
        webGLFormat = newFormat;
    }
}
