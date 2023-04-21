using System.Diagnostics;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.SceneManagement;

public class SceneTool : ScriptableObject
{
    [MenuItem("Tools/Scene/���齫���ڳ��� %#_u")]
    static void OpenMajiangInGame()
    {
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        EditorSceneManager.OpenScene("Assets/Art/Scenes/TestMajiangzi_02_BlendTest.unity");
    }

    [MenuItem("Tools/Scene/�򿪻�װ���� %#_u")]
    static void OpenChangCloth()
    {
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        EditorSceneManager.OpenScene("Assets/Art/Scenes/RoleAvatarChangeCloth_ChangeScene.unity");
    }

    [MenuItem("Tools/Scene/�򿪶�����չʾ���� %#_u")]
    static void OpenDoudizhu()
    {
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        EditorSceneManager.OpenScene("Assets/Art/Scenes/Role_Doudizhu.unity");
    }
}
