using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJAction : MonoBehaviour
{
    /// <summary>
    /// 正面材质
    /// </summary>
    public Material fontMaterial;
    /// <summary>
    /// 背面材质
    /// </summary>
    public Material backMaterial;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
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
    public void SetDir()
    {
        
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
}
