using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace EditerUtils
{
    public class TextureSizeMenu
    {
        [MenuItem("Assets/设置纹理最大尺寸/2048", true)]
        static bool vDoIt2048()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/2048", false, 0)]
        static void DoIt2048()
        {
            DoIt(2048);
        }

        [MenuItem("Assets/设置纹理最大尺寸/1024", true)]
        static bool vDoIt1024()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/1024", false, 0)]
        static void DoIt1024()
        {
            DoIt(1024);
        }
        
        [MenuItem("Assets/设置纹理最大尺寸/512", true)]
        static bool vDoIt512()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/512", false, 0)]
        static void DoIt512()
        {
            DoIt(512);
        }

        [MenuItem("Assets/设置纹理最大尺寸/256", true)]
        static bool vDoIt256()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/256", false, 0)]
        static void DoIt256()
        {
            DoIt(256);
        }

        [MenuItem("Assets/设置纹理最大尺寸/128", true)]
        static bool vDoIt128()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/128", false, 0)]
        static void DoIt128()
        {
            DoIt(128);
        }

        [MenuItem("Assets/设置纹理最大尺寸/64", true)]
        static bool vDoIt64()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/64", false, 0)]
        static void DoIt64()
        {
            DoIt(64);
        }

        [MenuItem("Assets/设置纹理最大尺寸/32", true)]
        static bool vDoIt32()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/32", false, 0)]
        static void DoIt32()
        {
            DoIt(32);
        }

        [MenuItem("Assets/设置纹理最大尺寸/16", true)]
        static bool vDoIt16()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/16", false, 0)]
        static void DoIt16()
        {
            DoIt(16);
        }

        [MenuItem("Assets/设置纹理最大尺寸/8", true)]
        static bool vDoIt8()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/设置纹理最大尺寸/8", false, 0)]
        static void DoIt8()
        {
            DoIt(8);
        }

        static void DoIt(int maxSize)
        {
            var paths = SelectionHelper.GetSelectPaths();
            foreach (var path in paths)
            {
                SetTextureMaxSize(path, maxSize);
            }

            Debug.Log($"已将最大尺寸设置为{maxSize}！！！");
        }

        static void SetTextureMaxSize(string path, int maxSize)
        {
            var textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
            if (textureImporter == null)
            {
                return;
            }
           
            textureImporter.maxTextureSize = maxSize;

            var iosTextureSettings = textureImporter.GetPlatformTextureSettings("iPhone");
            iosTextureSettings.maxTextureSize = maxSize;
            textureImporter.SetPlatformTextureSettings(iosTextureSettings);

            var androidTextureSettings = textureImporter.GetPlatformTextureSettings("Android");
            androidTextureSettings.maxTextureSize = maxSize;
            textureImporter.SetPlatformTextureSettings(androidTextureSettings);

            var webGLTextureSettings = textureImporter.GetPlatformTextureSettings("WebGL");
            webGLTextureSettings.maxTextureSize = maxSize;
            textureImporter.SetPlatformTextureSettings(webGLTextureSettings);

            textureImporter.SaveAndReimport();
        }

    }

}
