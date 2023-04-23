using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
 
public class ScriptableObjectTool
{
    //Asset�ļ�����·��
    private const string assetPath = "Assets/Art/Data/Config/";

    [MenuItem("Tools/CameriaData")]
    public static void CreateTestAsset()
    {
        //��������
        CameriaConfigData testData = ScriptableObject.CreateInstance<CameriaConfigData>();
        //��鱣��·��
        if (!Directory.Exists(assetPath))
            Directory.CreateDirectory(assetPath);

        //ɾ��ԭ���ļ����������ļ�
        string fullPath = assetPath + "/" + "CameriaConfigData.asset";
        UnityEditor.AssetDatabase.DeleteAsset(fullPath);
        UnityEditor.AssetDatabase.CreateAsset(testData, fullPath);
        UnityEditor.AssetDatabase.Refresh();
    }
}
#endif