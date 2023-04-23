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
    /// �齫�����Ⱦ���
    /// </summary>
    public float mjStepWidth= 0.0354f;
    /// <summary>
    /// �齫������Ⱦ���
    /// </summary>
    public float MjStepHeight = 0.0485f;
    /// <summary>
    /// �齫�����Ⱦ���
    /// </summary>
    public float MjThickness = 0.025f;
    /// <summary>
    /// ��ʹ�õ�mesh
    /// </summary>
    public Mesh mjMesh;
    /// <summary>
    /// ��ʾ�齫����
    /// </summary>
    public bool isShowMjBody = true;
    /// <summary>
    /// �Ƿ���
    /// </summary>
    public bool isMultLayer = false;
    /// <summary>
    /// ��ʾ�齫��Ӱ
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
