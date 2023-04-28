using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJRolesControl : MonoBehaviour
{
    public MajiangAreaCtrl ctrlUI;
    private List<MJHandControl> listRole = new List<MJHandControl>();
    private int selRoleIndex = -1;
    private string[] selStrings = new string[] { "Self", "Right", "Face", "Left" };

    public GUISkin skin;
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public Vector2Int topRightPos;

    private float intervalTime = 0.7f;
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
        if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, 10, ButtonWidth, ButtonHeight), "[emoji]", skin.button))
        {
            foreach (MJHandControl v in listRole)
            {
                v.Emoji();
            }
        }

        if (GUI.Button(new Rect(10 + 3 * ButtonWidthStep, 10, ButtonWidth, ButtonHeight), "[·¢ÅÆ]", skin.button))
        {
            listRole[0].QiDongAnniu();
        }


        if (GUI.Button(new Rect(10 + 4 * ButtonWidthStep, 10, ButtonWidth, ButtonHeight), "[»»ÅÆ]", skin.button))
        {
            for (int i = 0; i < listRole.Count; i++)
            {
                listRole[i].HuanPai();
            }
        }

        //
        selRoleIndex = GUI.SelectionGrid(new Rect(topRightPos.x, topRightPos.y, 600, 30), selRoleIndex, selStrings, 4, skin.toggle);

        if (selRoleIndex < 0 || selRoleIndex >= listRole.Count)
            return;

        if (GUI.Button(new Rect(topRightPos.x + 700, topRightPos.y, ButtonWidth, ButtonHeight), "[È«Á÷³Ì]", skin.button))
        {
            StartCoroutine(PlayAll());
        }
        //
        int height = topRightPos.y + 10;
        //

        MJHandControl mc = listRole[selRoleIndex];
        if (mc == null)
            return;
        //
        height = height + ButtonHeight + 5;
        if (GUI.Button(new Rect(10 + 0 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[clear one]", skin.button))
        {
            mc.ClearUpMj();
        }

        if (GUI.Button(new Rect(10 + 1 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[clear all]", skin.button))
        {
            //mc.ClearAll();
            foreach (MJHandControl v in listRole)
            {
                v.ClearAll();
            }
        }

        if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[push all]", skin.button))
        {
            mc.playAllMj(2.0f);
        }



        height = height + ButtonHeight + 5;



        HandMJNode hn = ctrlUI.GetHandNode(mc.seat);
        if (hn != null)
        {


            if (GUI.Button(new Rect(10 + 0 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[Ì¯ÅÆ]", skin.button))
            {
                foreach (MJHandControl v in listRole)
                {
                    v.TanPai();
                }
            }

            if (GUI.Button(new Rect(10 + 1 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[ºúÅÆ]", skin.button))
            {
                mc.HuPai();
                /*foreach (MJHandControl v in listRole)
                {
                    v.HuPai();
                }*/
            }

            if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[Åö³Ô¸Ü]", skin.button))
            {
                //mc.PengChiGang();
                foreach (MJHandControl v in listRole)
                {
                    v.PengChiGang();
                }
            }

            if (GUI.Button(new Rect(10 + 3 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[¼Ó¸Ü]", skin.button))
            {
            }




            height = height + ButtonHeight + 5;
            if (GUI.Button(new Rect(10 + 0 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[ÃþÅÆ]", skin.button))
            {
                mc.MoPai();
            }

            if (hn.HaveMoPai() == true)
            {
                if (GUI.Button(new Rect(10 + 1 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[´òÅÆ]", skin.button))
                {
                    hn.DaHandPai();
                    OutMJNode on = ctrlUI.GetOutNode(mc.seat);
                    mc.DaPai(on.GetNextMJ());
                }


                if (GUI.Button(new Rect(10 + 2 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "[ÀíÅÆ]", skin.button))
                {
                    mc.LiPai();
                }
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
            listRole[index].playAllMjWithoutClear(5.0f);
        }
    }
}

