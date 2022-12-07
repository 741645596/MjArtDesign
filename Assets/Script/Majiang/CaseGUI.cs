using System.Collections.Generic;
using UnityEngine;

public class CaseGUI : MonoBehaviour
{
    public GameObject maJiangPrefab;
    /// <summary>
    /// 麻将宽度
    /// </summary>
    public float Mjwidth = 0.041f;
    public List<string> caseNames;


    void Awake()
    {
        LoadHandCardTeam();
        
    }

    private void OnGUI()
    {
        float width = 250 * display.srceenScaleFactor;
        float height = 55 * display.srceenScaleFactor;
        GUI.skin.button.fontSize = Mathf.FloorToInt(25 * display.srceenScaleFactor);

        GUILayout.BeginArea(new Rect(Screen.width - width, 0, width, Screen.height));
        caseNames.ForEach(n =>
        {
            string name = n.Substring(4);
            if (GUILayout.Button(name, GUILayout.Width(width), GUILayout.Height(height)))
            {
            }
        });
        GUILayout.EndArea();
    }

    private static void OnQuitting()
    {
        Application.quitting -= OnQuitting;
    }

    /// <summary>
    /// 加载手牌
    /// </summary>
    private void LoadHandCardTeam()
    {
        Transform parentNode = GameObject.Find("mjSpace/MJHandSetRoot/MJHandSet").transform;
        Vector3 startPos = new Vector3(-0.5640052f, 0.02659222f, 0.0f);
        int layer = LayerMask.NameToLayer("HandCard");
        for (int i = 0; i < 13; i++)
        {
            LoadMajiang(parentNode, startPos + new Vector3(1, 0, 0) * Mjwidth * i, layer);
        }
    }
    /// <summary>
    /// 加载麻将
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private void LoadMajiang(Transform parent,Vector3 pos,int layer)
    {
        if (maJiangPrefab != null)
        {
            GameObject go  = GameObject.Instantiate(maJiangPrefab);
            go.transform.parent = parent;
            MJAction action = go.GetComponent<MJAction>();
            action.SetPos(pos);
            action.SetLayer(layer);
        }
    }
}
