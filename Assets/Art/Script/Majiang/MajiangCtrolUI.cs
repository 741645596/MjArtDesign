using System.Collections.Generic;
using UnityEngine;
using System.Collections;

//[ExecuteInEditMode]
public class MajiangCtrolUI : MonoBehaviour
{
    public GameObject maJiangPrefab;
    /// <summary>
    /// 自己手牌节点
    /// </summary>
    public MJConfigData SelfHandNode;
    /// <summary>
    /// 麻将墙节点
    /// </summary>
    public List<MJConfigData> ListmajiangWallNode = new List<MJConfigData>();
    /// <summary>
    /// 手牌节点
    /// </summary>
    public List<MJConfigData> ListmajiangHandNode = new List<MJConfigData>();
    /// <summary>
    /// 加载间隔时间
    /// </summary>
    public float loadTimeStep = 0.05f;

    public GUIStyle style = new GUIStyle();

    public Vector2Int topRightPos;
    public int buttonWidthStep = 30;


    void Awake()
    {

    }

    private void OnGUI()
    {
        if (GUI.Button(new Rect(topRightPos.x, topRightPos.y, 150, 30), "加载麻将", style))
        {
            StartCoroutine(LoadAllMj());
        }
        if (GUI.Button(new Rect(topRightPos.x + 150 + buttonWidthStep, topRightPos.y, 200, 30), "卸载麻将", style))
        {
            FreeMajiang();
        }
    }
    /// <summary>
    /// 加载所有麻将
    /// </summary>
    private IEnumerator LoadAllMj()
    {
        FreeMajiang();
        //
        //StartCoroutine(LoadSelfHand());
        yield return StartCoroutine(LoadMjHand());
        yield return StartCoroutine(LoadMjWall());
    }
    /// <summary>
    /// 释放所有麻将
    /// </summary>
    private void FreeMajiang()
    {
        MJManger.ClearAllMJ();
    }
    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    private IEnumerator LoadSelfHand()
    {
        Vector3 startPos = new Vector3(-0.5640052f, 0.02659222f, 0.0f);
        yield return LoadHandCardTeam(SelfHandNode, startPos, LayerMask.NameToLayer("HandCard"));
    }
    /// <summary>
    /// 加载胡牌墙
    /// </summary>
    private IEnumerator LoadMjPengTeam(MJConfigData parentNode, Vector3 startPos)
    {
        int layer = LayerMask.NameToLayer("Default");
        Vector3 diff = parentNode.mjStepWidth * ((parentNode.c != MJDir.Horizontal) ? new Vector3(1, 0, 0)  : new Vector3(0, 0, 1)) ;
        for (int i = 0; i < 3; i++)
        {
            yield return LoadMajiang(parentNode, startPos - diff * i, layer);
        }
    }
    /// <summary>
    /// 加载胡牌墙
    /// </summary>
    private IEnumerator LoadMjHuTeam(MJConfigData parentNode, Vector3 startPos)
    {
        int layer = LayerMask.NameToLayer("Default");
        Vector3 diff = parentNode.mjStepWidth * ((parentNode.c != MJDir.Horizontal) ? new Vector3(1, 0, 0) : new Vector3(0, 0, 1));
        Vector3 thicknessdiff = parentNode.MjThickness * new Vector3(0, 1, 0) ;
        for (int i = 0; i < 4; i++)
        {
            yield return LoadMajiang(parentNode, startPos - diff * i, layer);
            if (parentNode.isMultLayer == true)
            {
                yield return LoadMajiang(parentNode, startPos + thicknessdiff - diff * i, layer, false);
                yield return LoadMajiang(parentNode, startPos + thicknessdiff * 2 - diff * i, layer, false);
            }
        }
    }
    private static void OnQuitting()
    {
        Application.quitting -= OnQuitting;
    }

    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    private IEnumerator LoadMjWall()
    {
        Vector3 startPos = new Vector3(0.3242994f, 0.01372704f, 0.0f);
        if (ListmajiangWallNode != null && ListmajiangWallNode.Count > 0)
        {
            foreach (MJConfigData node in ListmajiangWallNode)
            {
                yield return  LoadMjWallTeam(node, startPos);
            }
        }
    }
    /// <summary>
    /// 加载牌墙
    /// </summary>
    private IEnumerator LoadMjWallTeam(MJConfigData parentNode,Vector3 startPos)
    {
        int layer = LayerMask.NameToLayer("Default");
        Vector3 diff = parentNode.mjStepWidth * ((parentNode.c != MJDir.Horizontal) ? new Vector3(1, 0, 0) : new Vector3(0, 0, 1));
        Vector3 thicknessdiff = parentNode.MjThickness * new Vector3(0, 1, 0);
        for (int i = 0; i < 17; i++)
        {
            yield return LoadMajiang(parentNode, startPos - diff * i, layer);
            if (parentNode.isMultLayer == true)
            {
                yield return LoadMajiang(parentNode, startPos + thicknessdiff - diff * i, layer, false);
            } 
        }
    }
    /// <summary>
    /// 加载所有麻将墙
    /// </summary>
    public  IEnumerator  LoadMjHand()
    {
        Vector3 startPos = new Vector3(-0.5640052f, 0.02659222f, 0.0f);
        int layer = LayerMask.NameToLayer("Default");
        if (ListmajiangHandNode != null && ListmajiangHandNode.Count > 0)
        {
            for (int i = 0; i < ListmajiangHandNode.Count; i++)
            {
                yield return LoadHandCardTeam(ListmajiangHandNode[i], startPos, layer);
            }
        }
    }
    /// <summary>
    /// 加载手牌, 注意加载牌的顺序，顺时针麻将影子才会正确。
    /// </summary>
    private IEnumerator LoadHandCardTeam(MJConfigData parentNode, Vector3 startPos, int layer)
    {
        Vector3 diff = parentNode.mjStepWidth * ((parentNode.c != MJDir.Horizontal) ? new Vector3(0, 0, 1) : new Vector3(1, 0, 0));
        for (int i = 0; i < 13; i++)
        {
            yield return LoadMajiang(parentNode, startPos + diff  * i, layer);
        }
    }
    /// <summary>
    /// 加载麻将
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private IEnumerator LoadMajiang(MJConfigData parentNode, Vector3 pos,int layer, bool isShowShadow = true, bool isSeclect = false)
    {
        if (parentNode.transform.gameObject.activeSelf != false)
        {
            if (maJiangPrefab != null)
            {
                GameObject go = GameObject.Instantiate(maJiangPrefab);
                go.transform.parent = parentNode.transform;
                MJAction action = go.GetComponent<MJAction>();
                action.SetPos(pos);
                action.SetRotation(0);
                action.SetMJViewData(parentNode, isShowShadow, isSeclect);
                action.SetLayer(layer);
                MJManger.AddMJ(action);
            }
            yield return new WaitForSeconds(loadTimeStep);
        }

    }
}
