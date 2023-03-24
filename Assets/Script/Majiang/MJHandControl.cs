using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJHandControl : MonoBehaviour
{
    // Start is called before the first frame update
    public Animator ani;
    public float posx;
    public float posy;
    public List<int> listPaiNum = new List<int>();
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public GUIStyle style = new GUIStyle();
    void Awake()
    {
        ani = gameObject.GetComponent<Animator>();
    }
    void Start()
    {
        OnControllerHandAni(posx, posy);
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnControllerHandAni(float posX, float posY)
    {
        if (ani != null)
        {
            ani.SetFloat("PosX", posX);
            ani.SetFloat("PosY", posY);
        }
    }


    private void OnGUI()
    {
        int height = 70;
        float minPos = -1;
        float maxPos = 1;

        if (listPaiNum == null || listPaiNum.Count == 0)
            return;

        float Ystep = (maxPos - minPos) / (listPaiNum.Count - 1);
        for (int line = 0;  line < listPaiNum.Count; line++)
        {
            int paiNum = listPaiNum[line];
            if (paiNum <= 1)
                continue;
            posy = minPos + Ystep * line;

            for (int j = 0; j < paiNum; j++)
            {
                if (GUI.Button(new Rect(10 + j * ButtonWidthStep, height, ButtonWidth, ButtonHeight), "["+ line.ToString() + "," + j.ToString() + "]", style))
                {
                    float Xstep =  (maxPos - minPos) / (paiNum - 1);
                    posx = minPos + Xstep * j;
                    OnControllerHandAni(posx, posy);
                }
            }
            height += ButtonHeightStep;
        }
    }
}
