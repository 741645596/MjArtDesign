using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJRolesControl : MonoBehaviour
{
    public List<MJHandControl> listRole = new List<MJHandControl>();
    public GUIStyle style = new GUIStyle();

    public int selRoleIndex = 0;
    public string[] selStrings = new string[] { "Self", "Right", "Face", "Left" };
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public Vector2Int topRightPos;

    public float intervalTime = 0.5f;
    // Start is called before the first frame update

    private void OnGUI()
    {
        if (listRole == null || listRole.Count == 0)
            return;
        selRoleIndex = GUI.SelectionGrid(new Rect(topRightPos.x, topRightPos.y, 600, 30), selRoleIndex, selStrings, 4, style);

        if (selRoleIndex < 0 || selRoleIndex >= listRole.Count)
            return;

        if (GUI.Button(new Rect(topRightPos.x + 700, topRightPos.y, ButtonWidth, ButtonHeight), "[È«Á÷³Ì]", style))
        {
            StartCoroutine(PlayAll());
        }




        MJHandControl mc = listRole[selRoleIndex];
        if (mc == null)
            return;

        int height = topRightPos.y + 70;
        if (GUI.Button(new Rect(10 + 0 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[clear one]", style))
        {
            mc.ClearUpMj();
        }

        if (GUI.Button(new Rect(10 + 1 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[clear all]", style))
        {
            mc.ClearAll();
        }

        if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[push all]", style))
        {
            mc.playAllMj();
        }
    }

    private IEnumerator PlayAll()
    {
        for (int i = 0; i < listRole.Count; i++)
        {
            listRole[i].ClearAll();
        }
        for (int i = 0; i < listRole.Count; i++)
        {
            yield return StartCoroutine(playOne(i));
        }
    }

    private IEnumerator playOne(int index)
    {
        if (index >= 0 && index < listRole.Count)
        {
            yield return new WaitForSeconds(intervalTime * index);
            listRole[index].playAllMjWithoutClear();
        }
    }
}

