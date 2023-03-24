using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ButtonTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public class Text : MonoBehaviour
    {
        /// <summary>
        /// 开始按钮点击后调用此方法
        /// </summary>
        public void OnStartButtonClick()
        {
            Debug.Log("哈哈哈哈！看，你好像是个憨憨！！");
        }
    }
}
