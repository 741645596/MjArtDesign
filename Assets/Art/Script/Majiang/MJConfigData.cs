using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJConfigData : MonoBehaviour
{
    public MJMesh a;
    public MJGesture b;
    public MJDir c;
    public Material mjMaterial;
    /// <summary>
    /// 麻将间隔宽度距离
    /// </summary>
    public float mjStepWidth= 0.0354f;
    /// <summary>
    /// 麻将间隔长度距离
    /// </summary>
    public float MjStepHeight = 0.0485f;
    /// <summary>
    /// 麻将间隔厚度距离
    /// </summary>
    public float MjThickness = 0.025f;
    /// <summary>
    /// 所使用的mesh
    /// </summary>
    public Mesh mjMesh;
    /// <summary>
    /// 显示麻将本体
    /// </summary>
    public bool isShowMjBody = true;
    /// <summary>
    /// 是否多层
    /// </summary>
    public bool isMultLayer = false;
    /// <summary>
    /// 显示麻将阴影
    /// </summary>
    public bool isShowMjShadow = true;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
