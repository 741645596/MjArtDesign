using System.Diagnostics;
using UnityEngine;
using UnityEditor;

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

    static string GetProjPath()
    {
        string projFolder = Application.dataPath;
        return projFolder.Substring(0, projFolder.Length - 7);
    }
}