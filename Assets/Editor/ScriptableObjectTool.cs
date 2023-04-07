using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
 
public class ScriptableObjectTool
{
    //Asset文件保存路径
    private const string assetPath = "Assets/Art/Data/Config/";

    [MenuItem("Tools/CameriaData")]
    public static void CreateTestAsset()
    {
        //创建数据
        CameriaConfigData testData = ScriptableObject.CreateInstance<CameriaConfigData>();
        //检查保存路径
        if (!Directory.Exists(assetPath))
            Directory.CreateDirectory(assetPath);

        //删除原有文件，生成新文件
        string fullPath = assetPath + "/" + "CameriaConfigData.asset";
        UnityEditor.AssetDatabase.DeleteAsset(fullPath);
        UnityEditor.AssetDatabase.CreateAsset(testData, fullPath);
        UnityEditor.AssetDatabase.Refresh();
    }
}
#endif