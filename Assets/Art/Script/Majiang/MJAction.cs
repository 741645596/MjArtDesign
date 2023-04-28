using System.Collections.Generic;
using UnityEngine;

public class MJAction : MonoBehaviour
{
    /// <summary>
    /// 所在座位
    /// </summary>
    public Seat seat;
    /// <summary>
    /// 本体
    /// </summary>
    public List<GameObject> listMJ = new List<GameObject>();
    /// <summary>
    /// 影子
    /// </summary>
    public List<GameObject> listShadowMJ = new List<GameObject>();
    /// <summary>
    /// 选中颜色
    /// </summary>
    public Color selectCol = new Color(1.0f, 0.0f, 0.0f, 1.00f);
    /// <summary>
    /// 设定麻将的位置
    /// </summary>
    /// <param name="pos"></param>
    public void SetPos(Vector3 pos)
    {
        transform.localPosition = pos;
    }
    /// <summary>
    /// 设定麻将的旋转
    /// </summary>
    public void SetRotation(float angle)
    {
        transform.localEulerAngles = new Vector3(angle, 0,0);
    }
    /// <summary>
    /// 是否显示影子
    /// </summary>
    /// <param name="isShow"></param>
    public void ShowShadow(bool isShow)
    {
        
    }
    /// <summary>
    /// 设置麻将牌面
    /// </summary>
    public void SetMajiangNum()
    {
        
    }
    /// <summary>
    /// 设置layer
    /// </summary>
    /// <param name="layer"></param>
    public void SetLayer(int layer)
    {
        int count = transform.childCount;
        for (int i = 0; i < count; i++)
        {
            transform.GetChild(i).gameObject.layer = layer;
        }
    }
    /// <summary>
    /// 设置麻将显示数据
    /// </summary>
    /// <param name="a"></param>
    /// <param name="b"></param>
    /// <param name="c"></param>
    public void SetMJViewData(MJConfigData data, bool isShowShadow = true, bool isSeclect = false)
    {
        SetMjBody(data, isSeclect);
        SetMjShadow(data, isShowShadow);
    }
    /// <summary>
    /// 设置麻将本体
    /// </summary>
    public void SetMjBody(MJConfigData data, bool isSeclect = false)
    {
        if (listMJ != null && listMJ.Count > 0)
        {
            foreach (GameObject go in listMJ)
            {
                go.SetActive(false);
            }
            int index = 0;
            if (data.a == MJMesh.Back)
            {
                if (data.b == MJGesture.Lie)
                {
                    if (data.c == MJDir.Horizontal)
                        index = 7;
                    else index = 8;
                }
                else
                {
                    if (data.c == MJDir.Horizontal)
                        index = 4;
                    else 
                    {
                        if (data.c == MJDir.VerticalLeft)
                            index = 5;
                        else index = 6;
                    }
                }
            }
            else
            {
                if (data.b == MJGesture.Lie)
                {
                    if (data.c == MJDir.Horizontal)
                        index = 2;
                    else index = 3;
                }
                else
                {
                    if (data.c == MJDir.Horizontal)
                        index = 0;
                    else index = 1;
                }
            }
            listMJ[index].SetActive(data.isShowMjBody);
            MeshFilter mf = listMJ[index].gameObject.GetComponent<MeshFilter>();
            mf.mesh = data.mjMesh;
            MeshRenderer mr = listMJ[index].gameObject.GetComponent<MeshRenderer>();
            mr.material = data.mjMaterial;
            if (isSeclect == true)
            {
                mr.material.SetColor("_u_MainColor", selectCol);
            }
        }
    }
    /// <summary>
    /// 设置麻将影子
    /// </summary>
    /// <param name="b"></param>
    /// <param name="c"></param>
    /// <param name="isShowShadow"></param>
    private void SetMjShadow(MJConfigData data, bool isShowShadow = true)
    {
        if (listShadowMJ != null && listShadowMJ.Count > 0)
        {
            foreach (GameObject go in listShadowMJ)
            {
                go.SetActive(false);
            }
            if (isShowShadow == true && data.isShowMjShadow == true)
            {
                int index = 0;
                if (data.b == MJGesture.Lie)
                {
                    if (data.c == MJDir.Horizontal)
                        index = 2;
                    else index = 3;
                }
                else
                {
                    if (data.c == MJDir.Horizontal)
                        index = 0;
                    else index = 1;
                }
                listShadowMJ[index].SetActive(true);
            }
        }
    }
}


public enum MJMesh
{
    Back,       // 背面显示麻将
    Font        // 字面显示麻将
}

public enum MJDir
{
    Horizontal,     // 水平
    VerticalLeft,   // 垂直左
    VerticalRight,  // 垂直右

}

public enum MJGesture
{
    Stand,     // 站立
    Lie        // 躺着
}


