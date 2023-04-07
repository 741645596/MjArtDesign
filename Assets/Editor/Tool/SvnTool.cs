using System.Diagnostics;
using UnityEngine;
using UnityEditor;
using System.IO;

public class SvnTool : ScriptableObject
{
    [MenuItem("Tools/SVN/更新版本 %#_u")]
    static void SvnUpdate()
    {
        string batPath = GetProjPath() + "/SvnUpdate.bat";
        Process.Start(batPath);
    }

    [MenuItem("Tools/SVN/提交版本 %#_v")]
    static void SvnCommit()
    {
        string batPath = GetProjPath() + "/SvnCommit.bat";
        Process.Start(batPath);
    }

    [MenuItem("Tools/SVN/更新Doc版本 %#_d")]
    static void SvnDocUpdate()
    {
        string batPath = GetProjPath() + "/SvnDocUpdate.bat";
        Process.Start(batPath);
    }

    [MenuItem("Tools/规范文档/美术资源规范 %#_o")]
    static void ArtDoc()
    {
        string docPath = GetProjPath() + "/Doc/ArtStandard.doc";
        if (File.Exists(docPath))
        {
            System.Diagnostics.Process.Start(docPath);
        }
        else
        {
            UnityEngine.Debug.Log("不存在文档：" + docPath);
        }
    }

    [MenuItem("Tools/规范文档/PBR规范 %#_p")]
    static void pbrDoc()
    {
        string docPath = GetProjPath() + "/Doc/PBR贴图规范.pptx";
        if (File.Exists(docPath))
        {
            System.Diagnostics.Process.Start(docPath);
        }
        else
        {
            UnityEngine.Debug.Log("不存在文档：" + docPath);
        }
    }

    static string GetProjPath()
    {
        string projFolder = Application.dataPath;
        return projFolder.Substring(0, projFolder.Length - 7);
    }
}