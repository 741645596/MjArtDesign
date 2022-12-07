using System.Collections.Generic;
using UnityEngine;

public class CaseGUI : MonoBehaviour
{
    public GameObject maJiangPrefab;
    /// <summary>
    /// 麻将墙节点
    /// </summary>
    public List<Transform> ListmajiangWallNode;
    /// <summary>
    /// 手牌节点
    /// </summary>
    public List<Transform> ListmajiangHandNode;
    /// <summary>
    /// 麻将宽度
    /// </summary>
    public float Mjwidth = 0.041f;
    /// <summary>
    /// 麻将厚度
    /// </summary>
    public float MjThickness = 0.0281f;
    public List<string> caseNames;


    void Awake()
    {
        LoadMjHand();
        LoadMjWall();
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
    /// 加载所有麻将墙
    /// </summary>
    private void LoadMjWall()
    {
        if (ListmajiangWallNode == null || ListmajiangWallNode.Count == 0)
            return;
        Vector3 startPos = new Vector3(0.3242994f, 0.01372704f, 0.0f);
        foreach (Transform node in ListmajiangWallNode)
        {
            LoadMjWallTeam(node, startPos);
        }
    }
    /// <summary>
    /// 加载牌墙
    /// </summary>
    private void LoadMjWallTeam(Transform parentNode,Vector3 startPos)
    {
        int layer = LayerMask.NameToLayer("Default");
        for (int i = 0; i < 17; i++)
        {
            LoadMajiang(parentNode, startPos - new Vector3(1, 0, 0) * Mjwidth * i,270, layer);
            LoadMajiang(parentNode, startPos + new Vector3(0, MjThickness, 0.0f) - new Vector3(1, 0, 0) * Mjwidth * i, 270, layer);
        }
    }
    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    private void LoadMjHand()
    {
        if (ListmajiangHandNode == null || ListmajiangHandNode.Count == 0)
            return;
        Vector3 startPos = new Vector3(-0.5640052f, 0.02659222f, 0.0f);
        for(int i= 0; i< ListmajiangHandNode.Count; i++)
        {
            
            LoadHandCardTeam(ListmajiangHandNode[i], startPos, i == 0 ? LayerMask.NameToLayer("HandCard"):LayerMask.NameToLayer("Default"));
        }
    }
    /// <summary>
    /// 加载手牌
    /// </summary>
    private void LoadHandCardTeam(Transform parentNode, Vector3 startPos, int layer)
    {
        for (int i = 0; i < 13; i++)
        {
            LoadMajiang(parentNode, startPos + new Vector3(1, 0, 0) * Mjwidth * i,0, layer);
        }
    }
    /// <summary>
    /// 加载麻将
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private void LoadMajiang(Transform parent,Vector3 pos,float angel,int layer)
    {
        if (maJiangPrefab != null)
        {
            GameObject go  = GameObject.Instantiate(maJiangPrefab);
            go.transform.parent = parent;
            MJAction action = go.GetComponent<MJAction>();
            action.SetPos(pos);
            action.SetRotation(angel);
            action.SetLayer(layer);
        }
    }
}
