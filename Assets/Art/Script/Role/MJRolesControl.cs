using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJRolesControl : MonoBehaviour
{
    private List<MJHandControl> listRole = new List<MJHandControl>();
    private int selRoleIndex = -1;
    private string[] selStrings = new string[] { "Self", "Right", "Face", "Left" };


    public GUIStyle style = new GUIStyle();
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public Vector2Int topRightPos;

    public float intervalTime = 0.5f;
    /// <summary>
    /// ×ø×À½ÇÉ«preab
    /// </summary>
    public GameObject SeatPrefab;
    /// <summary>
    /// ÅÆµÄ°ÚÉè
    /// </summary>
    public List<int> listPaiNum = new List<int>();

    private void Awake()
    {
        List<string> listStr = new List<string>();
        if (SeatPrefab != null)
        {
            foreach (SeatConfigData s in transform.GetComponentsInChildren<SeatConfigData>())
            {
                if (s != null)
                {
                    GameObject go = GameObject.Instantiate(SeatPrefab);
                    go.transform.parent = s.transform;
                    MJHandControl mh = go.GetComponent<MJHandControl>();
                    mh.SetSeatConfig(s, listPaiNum);
                    listRole.Add(mh);
                    listStr.Add(s.gameObject.name);
                }
            }
        }
        selStrings = listStr.ToArray();
    }



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
            //mc.ClearAll();
            foreach (MJHandControl v in listRole)
            {
                v.ClearAll();
            }
        }

        if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[push all]", style))
        {
            mc.playAllMj();
        }

        height = height + ButtonHeight + 5;

        if (GUI.Button(new Rect(10 + 0 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[Æô¶¯°´Å¥]", style))
        {
            foreach (MJHandControl v in listRole)
            {
                v.QiDongAnniu(); 
            }
            //mc.QiDongAnniu();
        }

        if (GUI.Button(new Rect(10 + 1 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[»»ÅÆ]", style))
        {
            foreach (MJHandControl v in listRole)
            {
                v.HuanPai();
            }
            //mc.HuanPai();
        }

        if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[Åö³Ô¸Ü]", style))
        {
            //mc.PengChiGang();
            foreach (MJHandControl v in listRole)
            {
                v.PengChiGang();
            }
        }

        if (GUI.Button(new Rect(10 + 3 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[Ì¯ÅÆ]", style))
        {
            //mc.TanPai();
            foreach (MJHandControl v in listRole)
            {
                v.TanPai();
            }
        }

        height = height + ButtonHeight + 5;

        if (GUI.Button(new Rect(10 + 0 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[ºúÅÆ]", style))
        {
            //mc.HuPai();
            foreach (MJHandControl v in listRole)
            {
                v.HuPai();
            }
        }

        if (GUI.Button(new Rect(10 + 1 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[ÀíÅÆ]", style))
        {
            mc.LiPai();
        }

        if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[emoji]", style))
        {
            //mc.Emoji();
            foreach (MJHandControl v in listRole)
            {
                v.Emoji();
            }
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

