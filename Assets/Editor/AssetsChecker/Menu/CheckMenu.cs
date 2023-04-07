using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace EditerUtils
{
    /// <summary>
    /// 右键资源规范检测工具类
    /// </summary>
    public static class CheckMenu
    {
        #region "音频资源"
        [MenuItem("Assets/资源规范检查/音频资源", true)]
        private static bool rAudioCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Audio_Types);
        }

        [MenuItem("Assets/资源规范检查/音频资源", false, 0)]
        private static void AudioCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Audio_Types, (path) =>
            {
                var info = AudioCheckLogic.GetAssetInfo(path);
                _PrintAssetInfo(info, AudioCheckEditorWindow.Title);
            });
        }

        private static void AudioCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Audio_Types))
            {
                var info = AudioCheckLogic.GetAssetInfo(path);
                _PrintAssetInfo(info, AudioCheckEditorWindow.Title);
            }
        }

        private static void AudioFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Audio_Types, (path) =>
            {
                var info = AudioCheckLogic.GetAssetInfo(path);
                _FixAssetInfo(info, AudioCheckEditorWindow.Title);
            });
        }

        private static void AudioFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Audio_Types))
            {
                var info = AudioCheckLogic.GetAssetInfo(path);
                _FixAssetInfo(info, AudioCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "模型fbx资源"
        [MenuItem("Assets/资源规范检查/模型fbx资源", true)]
        private static bool vModelCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Model_Type);
        }

        [MenuItem("Assets/资源规范检查/模型fbx资源", false, 0)]
        private static void ModelCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Model_Type, (path) =>
            {
                var info = ModelChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, ModelCheckEditorWindow.Title);
            });
        }

        private static void ModelCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Model_Type))
            {
                var info = ModelChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, ModelCheckEditorWindow.Title);
            }
        }

        private static void ModelFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Model_Type, (path) =>
            {
                var info = ModelChecker.GetAssetInfo(path);
                _FixAssetInfo(info, ModelCheckEditorWindow.Title);
            });
        }

        private static void ModelFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Model_Type))
            {
                var info = ModelChecker.GetAssetInfo(path);
                _FixAssetInfo(info, ModelCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "重复Mesh"
        [MenuItem("Assets/资源规范检查/重复Mesh", true)]
        private static bool vRepeatMeshCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Model_Type);
        }

        [MenuItem("Assets/资源规范检查/重复Mesh", false, 0)]
        private static void RepeatMeshCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Model_Type, (path) =>
            {
                RepeatMeshHelper.PrintRepeatMesh(path);
            });
        }
        #endregion

        #region "重复资源"
        [MenuItem("Assets/资源规范检查/重复资源", false, 0)]
        private static void RepeatResourceCheck()
        {
            var paths = SelectionHelper.GetSelectPaths();
            RepeatResourceHelper.PrintRepeatRes(paths.ToArray());
        }
        #endregion

        #region "材质球资源"
        [MenuItem("Assets/资源规范检查/材质球", true)]
        private static bool vMaterialCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Material_Type);
        }

        [MenuItem("Assets/资源规范检查/材质球", false, 0)]
        private static void MaterialCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Material_Type, (path) =>
            {
                var info = MaterialChecker.GetAssetInfo(path);
                if (info == null)
                {
                    Debug.Log($"恭喜：{MaterialCheckEditorWindow.Title}符合规范");
                }
                else
                {
                    _PrintAssetInfo(info, MaterialCheckEditorWindow.Title);
                }
            });
        }

        private static void MaterialCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Material_Type))
            {
                var info = MaterialChecker.GetAssetInfo(path);
                if (info != null)
                {
                    _PrintAssetInfo(info, MaterialCheckEditorWindow.Title);
                }
            }
        }

        private static void MaterialFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Material_Type, (path) =>
            {
                var info = MaterialChecker.GetAssetInfo(path);
                if (null == info)
                {
                    Debug.Log($"{MaterialCheckEditorWindow.Title}很规范，不需要修复");
                }
                else
                {
                    _FixAssetInfo(info, MaterialCheckEditorWindow.Title);
                }
            });
        }

        private static void MaterialFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Material_Type))
            {
                var info = MaterialChecker.GetAssetInfo(path);
                if (null != info)
                {
                    _FixAssetInfo(info, MaterialCheckEditorWindow.Title);
                }
            }
        }
        #endregion


        #region "纹理图片"
        [MenuItem("Assets/资源规范检查/纹理图片", true)]
        private static bool vTextureCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Texture_Types);
        }

        [MenuItem("Assets/资源规范检查/纹理图片", false, 0)]
        private static void TextureCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Texture_Types, (path) =>
            {
                var info = BigPicChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, BigPicCheckEditorWindow.Title);
            });
        }

        private static void TextureCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Texture_Types))
            {
                var info = BigPicChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, BigPicCheckEditorWindow.Title);
            }
        }

        private static void TextureFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Texture_Types, (path) =>
            {
                var info = BigPicChecker.GetAssetInfo(path);
                _FixAssetInfo(info, BigPicCheckEditorWindow.Title);
            });
        }

        private static void TextureFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Texture_Types))
            {
                var info = BigPicChecker.GetAssetInfo(path);
                _FixAssetInfo(info, BigPicCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "合图资源"
        [MenuItem("Assets/资源规范检查/合图资源", true)]
        private static bool vAtlasCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Sprite_Atlas_Type);
        }

        [MenuItem("Assets/资源规范检查/合图资源", false, 0)]
        private static void AtlasCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Sprite_Atlas_Type, (path) =>
            {
                var info = AtlasChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, AtlasCheckEditorWindow.Title);
            });
        }

        private static void AtlasCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Sprite_Atlas_Type))
            {
                var info = AtlasChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, AtlasCheckEditorWindow.Title);
            }
        }

        private static void AtlasFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Sprite_Atlas_Type, (path) =>
            {
                var info = AtlasChecker.GetAssetInfo(path);
                _FixAssetInfo(info, AtlasCheckEditorWindow.Title);
            });
        }

        private static void AtlasFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Sprite_Atlas_Type))
            {
                var info = AtlasChecker.GetAssetInfo(path);
                _FixAssetInfo(info, AtlasCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "Shader资源"
        [MenuItem("Assets/资源规范检查/Shader资源", true)]
        private static bool vShaderCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Shader_Type);
        }

        [MenuItem("Assets/资源规范检查/Shader资源", false, 0)]
        private static void ShaderCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Shader_Type, (path) =>
            {
                var info = ShaderChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, ShaderCheckEditorWindow.Title);
            });
        }

        private static void ShaderCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Shader_Type))
            {
                var info = ShaderChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, ShaderCheckEditorWindow.Title);
            }
        }

        private static void ShaderFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Shader_Type, (path) =>
            {
                var info = ShaderChecker.GetAssetInfo(path);
                _FixAssetInfo(info, ShaderCheckEditorWindow.Title);
            });
        }

        private static void ShaderFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Shader_Type))
            {
                var info = ShaderChecker.GetAssetInfo(path);
                _FixAssetInfo(info, ShaderCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "动画资源"
        [MenuItem("Assets/资源规范检查/动画资源", true)]
        private static bool vAnimCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Anim_Types);
        }

        [MenuItem("Assets/资源规范检查/动画资源", false, 0)]
        private static void AnimCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Anim_Types, (path) =>
            {
                var info = AnimAssetCherker.GetAssetInfo(path);
                _PrintAssetInfo(info, AnimAssetEditorWindow.Title);
            });
        }

        private static void AnimCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Anim_Types))
            {
                var info = AnimAssetCherker.GetAssetInfo(path);
                _PrintAssetInfo(info, AnimAssetEditorWindow.Title);
            }
        }

        private static void AnimFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Anim_Types, (path) =>
            {
                var info = AnimAssetCherker.GetAssetInfo(path);
                _FixAssetInfo(info, AnimAssetEditorWindow.Title);
            });
        }

        private static void AnimFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Anim_Types))
            {
                var info = AnimAssetCherker.GetAssetInfo(path);
                _FixAssetInfo(info, AnimAssetEditorWindow.Title);
            }
        }
        #endregion


        #region "预制模型面数"
        [MenuItem("Assets/资源规范检查/预制模型面数", true)]
        private static bool vModelFaceCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Prefab_Type);
        }

        [MenuItem("Assets/资源规范检查/预制模型面数", false, 0)]
        private static void ModelFaceCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = ModelFaceChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, ModelFaceCheckEditorWindow.Title);
            });
        }

        private static void ModelFaceCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = ModelFaceChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, ModelFaceCheckEditorWindow.Title);
            }
        }

        private static void ModelFaceFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = ModelFaceChecker.GetAssetInfo(path);
                _FixAssetInfo(info, ModelFaceCheckEditorWindow.Title);
            });
        }

        private static void ModelFaceFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = ModelFaceChecker.GetAssetInfo(path);
                _FixAssetInfo(info, ModelFaceCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "预制阴影开关"
        [MenuItem("Assets/资源规范检查/预制阴影开关", true)]
        private static bool vPrefabMeshCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Prefab_Type);
        }

        [MenuItem("Assets/资源规范检查/预制阴影开关", false, 0)]
        private static void PrefabMeshCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabMeshChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabMeshCheckEditorWindow.Title);
            });
        }

        private static void PrefabMeshCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabMeshChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabMeshCheckEditorWindow.Title);
            }
        }

        private static void PrefabMeshFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabMeshChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabMeshCheckEditorWindow.Title);
            });
        }

        private static void PrefabMeshFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabMeshChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabMeshCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "预制实例耗时"
        [MenuItem("Assets/资源规范检查/预制实例耗时", true)]
        private static bool vPrefabInstantiateCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Prefab_Type);
        }

        [MenuItem("Assets/资源规范检查/预制实例耗时", false, 0)]
        private static void PrefabInstantiateCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabInstantiateTimeChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabInstantiateTimeCheckEditorWindow.Title);
            });
        }

        private static void PrefabInstantiateCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabInstantiateTimeChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabInstantiateTimeCheckEditorWindow.Title);
            }
        }

        private static void PrefabInstantiateFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabInstantiateTimeChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabInstantiateTimeCheckEditorWindow.Title);
            });
        }

        private static void PrefabInstantiateFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabInstantiateTimeChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabInstantiateTimeCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "预制粒子"
        [MenuItem("Assets/资源规范检查/预制粒子", true)]
        private static bool vPrefabParticleCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Prefab_Type);
        }

        [MenuItem("Assets/资源规范检查/预制粒子", false, 0)]
        private static void PrefabParticleCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabParticleChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabParticleCheckEditorWindow.Title);
            });
        }

        private static void PrefabParticleCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabParticleChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabParticleCheckEditorWindow.Title);
            }
        }

        private static void PrefabParticleFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabParticleChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabParticleCheckEditorWindow.Title);
            });
        }

        private static void PrefabParticleFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabParticleChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabParticleCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "预制Raycast"
        [MenuItem("Assets/资源规范检查/预制Raycast", true)]
        private static bool vPrefabUICheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Prefab_Type);
        }

        [MenuItem("Assets/资源规范检查/预制Raycast", false, 0)]
        private static void PrefabUICheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabUIChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabUICheckEditorWindow.Title);
            });
        }

        private static void PrefabUICheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabUIChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabUICheckEditorWindow.Title);
            }
        }

        private static void PrefabUIFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabUIChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabUICheckEditorWindow.Title);
            });
        }

        private static void PrefabUIFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabUIChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabUICheckEditorWindow.Title);
            }
        }
        #endregion


        #region "预制嵌套层级"
        [MenuItem("Assets/资源规范检查/预制嵌套层级", true)]
        private static bool vPrefabHierarchyCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Prefab_Type);
        }

        [MenuItem("Assets/资源规范检查/预制嵌套层级", false, 0)]
        private static void PrefabHierarchyCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabHierarchyChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabHierarchyCheckEditorWindow.Title);
            });
        }

        private static void PrefabHierarchyCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabHierarchyChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabHierarchyCheckEditorWindow.Title);
            }
        }

        private static void PrefabHierarchyFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabHierarchyChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabHierarchyCheckEditorWindow.Title);
            });
        }

        private static void PrefabHierarchyFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabHierarchyChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabHierarchyCheckEditorWindow.Title);
            }
        }
        #endregion


        #region "预制AB冗余"
        [MenuItem("Assets/资源规范检查/预制AB冗余", true)]
        private static bool vPrefabRedundanceCheck()
        {
            return SelectionHelper.IsSuffixExist(AssetsCheckEditorWindow.Prefab_Type);
        }

        [MenuItem("Assets/资源规范检查/预制AB冗余", false, 0)]
        private static void PrefabRedundanceCheck()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabRedundanceChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabRedundanceCheckEditorWindow.Title);
            });
        }

        private static void PrefabRedundanceCheck(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabRedundanceChecker.GetAssetInfo(path);
                _PrintAssetInfo(info, PrefabRedundanceCheckEditorWindow.Title);
            }
        }

        private static void PrefabRedundanceFix()
        {
            SelectionHelper.Foreach(AssetsCheckEditorWindow.Prefab_Type, (path) =>
            {
                var info = PrefabRedundanceChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabRedundanceCheckEditorWindow.Title);
            });
        }

        private static void PrefabRedundanceFix(string path)
        {
            if (PathHelper.IsSuffixExist(path, AssetsCheckEditorWindow.Prefab_Type))
            {
                var info = PrefabRedundanceChecker.GetAssetInfo(path);
                _FixAssetInfo(info, PrefabRedundanceCheckEditorWindow.Title);
            }
        }
        #endregion

        [MenuItem("Assets/资源规范检查/一键检查", false, 100)]
        private static void CheckAll()
        {
            LogHelper.ClearLogConsole();

            // 文件夹
            FolderCheck();

            AudioCheck();

            ModelCheck();

            MaterialCheck();

            TextureCheck();

            AtlasCheck();

            ShaderCheck();

            AnimCheck();

            ModelFaceCheck();

            PrefabMeshCheck();

            PrefabInstantiateCheck();

            PrefabParticleCheck();

            PrefabUICheck();

            PrefabHierarchyCheck();

            PrefabRedundanceCheck();
        }

        [MenuItem("Assets/资源规范检查/一键修复", false, 100)]
        private static void FixAll()
        {
            LogHelper.ClearLogConsole();

            // 文件夹
            FolderFix();

            AudioFix();

            ModelFix();

            MaterialFix();

            TextureFix();

            AtlasFix();

            ShaderFix();

            AnimFix();

            ModelFaceFix();

            PrefabMeshFix();

            PrefabInstantiateFix();

            PrefabParticleFix();

            PrefabUIFix();

            PrefabHierarchyFix();

            PrefabRedundanceFix();
        }

        // 获取选中文件夹内的所有文件
        private static List<string> GetFolderFiles()
        {
            var res = new List<string>();
            var paths = SelectionHelper.GetSelectPaths();
            foreach (var p in paths)
            {
                if (Directory.Exists(p) == false)
                {
                    continue;
                }

                var filePaths = DirectoryHelper.GetAllFilesIgnoreExt(p, ".meta");
                foreach (var filePath in filePaths)
                {
                    res.Add(filePath);
                }
            }
            return res;
        }

        // 获取图集的文件集合
        private static List<string> GetSpriteAtlas(List<string> filePaths)
        {
            var res = new List<string>();
            foreach (var path in filePaths)
            {
                if (path.EndsWith(AssetsCheckEditorWindow.Sprite_Atlas_Type))
                {
                    res.Add(path);
                }
            }
            return res;
        }

        // 获取图集的文件夹集合
        private static List<string> GetSpriteAtlasFolder(List<string> atlasPaths)
        {
            var res = new List<string>();
            foreach (var path in atlasPaths)
            {
                var dir = PathHelper.GetDirectoryName(path);
                res.Add(dir);
            }
            return res;
        }

        // 获取选中文件夹内的所有有效文件
        private static List<string> GetFolderVaildFiles()
        {
            var filePaths = GetFolderFiles();

            // 剔除合集相关的图片
            var atlasPaths = GetSpriteAtlas(filePaths);
            var atlasFolders = GetSpriteAtlasFolder(atlasPaths);
            ListEditorHelper.RemoveByCondition(filePaths, (path)=>
            {
                // 删除图集包含的文件
                foreach (var altasFolder in atlasFolders)
                {
                    if (path.StartsWith(altasFolder) &&
                        path.EndsWith(AssetsCheckEditorWindow.Sprite_Atlas_Type)==false)
                    {
                        return true;
                    }
                }
                return false;
            });

            return filePaths;
        }

        private static void FolderCheck()
        {
            var filePaths = GetFolderVaildFiles();
            foreach (var filePath in filePaths)
            {
                FileCheck(filePath);
            }
        }

        private static void FileCheck(string path)
        {
            AudioCheck(path);

            ModelCheck(path);

            MaterialCheck(path);

            TextureCheck(path);

            AtlasCheck(path);

            ShaderCheck(path);

            AnimCheck(path);

            ModelFaceCheck(path);

            PrefabMeshCheck(path);

            PrefabInstantiateCheck(path);

            PrefabParticleCheck(path);

            PrefabUICheck(path);

            PrefabHierarchyCheck(path);

            PrefabRedundanceCheck(path);
        }

        private static void FolderFix()
        {
            var filePaths = GetFolderVaildFiles();
            foreach (var filePath in filePaths)
            {
                FileFix(filePath);
            }
        }

        private static void FileFix(string path)
        {
            AudioFix(path);

            ModelFix(path);

            MaterialFix(path);

            TextureFix(path);

            AtlasFix(path);

            ShaderFix(path);

            AnimFix(path);

            ModelFaceFix(path);

            PrefabMeshFix(path);

            PrefabInstantiateFix(path);

            PrefabParticleFix(path);

            PrefabUIFix(path);

            PrefabHierarchyFix(path);

            PrefabRedundanceFix(path);
        }

        private static void _PrintAssetInfo(AssetInfoBase info, string title)
        {
            if (info == null)
            {
                Debug.Log($"{title} ok!!!");
                return;
            }

            var des = info.GetErrorDes();
            if (string.IsNullOrEmpty(des))
            {
                Debug.Log($"恭喜：{title} 符合规范");
            }
            else
            {
                if (info.IsError())
                {
                    LogHelper.Warning($"{title} 问题描述：{des}", info.assetPath);
                }
                else
                {
                    Debug.Log($"(请根据规范决定是否手动处理)：{des}");
                }
            }
        }

        private static void _FixAssetInfo(AssetInfoBase info, string title)
        {
            if (info == null)
            {
                Debug.Log($"{title} ok!!!");
                return;
            }

            if (info.CanFix())
            {
                info.Fix();

                var des = info.GetErrorDes();
                if (string.IsNullOrEmpty(des))
                {
                    Debug.Log($"{title} 已修复");
                }
                else
                {
                    Debug.Log($"(请根据规范决定是否手动处理)：{des}");
                }    
            }
            else
            {
                var des = info.GetErrorDes();
                if (string.IsNullOrEmpty(des))
                {
                    Debug.Log($"{title} 不需要处理");
                }
                else
                {
                    Debug.Log($"(请根据规范决定是否手动处理)：{des}");
                }
            }
        }
    }
}


