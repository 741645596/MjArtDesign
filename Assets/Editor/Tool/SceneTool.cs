using System.Diagnostics;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.SceneManagement;

public class SceneTool : ScriptableObject
{
    [MenuItem("Tools/Scene/打开麻将局内场景 %#_u")]
    static void OpenMajiangInGame()
    {
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        EditorSceneManager.OpenScene("Assets/Art/Scenes/TestMajiangzi_02_BlendTest.unity");
    }

    [MenuItem("Tools/Scene/打开换装场景 %#_u")]
    static void OpenChangCloth()
    {
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        EditorSceneManager.OpenScene("Assets/Art/Scenes/RoleAvatarChangeCloth_ChangeScene.unity");
    }

    [MenuItem("Tools/Scene/打开斗地主展示场景 %#_u")]
    static void OpenDoudizhu()
    {
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        EditorSceneManager.OpenScene("Assets/Art/Scenes/Role_Doudizhu.unity");
    }
}
