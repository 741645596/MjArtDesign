using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoleChange : MonoBehaviour
{
    // Start is called before the first frame update
    public List<GameObject> listRole = new List<GameObject>();
    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public GUISkin skin;

    private GameObject m_CurGo = null;


    private void OnGUI()
    {

        for (int i = 0; i < listRole.Count; i++)
        {
            if (GUI.Button(new Rect(10 + i * ButtonWidthStep, 10, ButtonWidth, ButtonHeight), listRole[i].name, skin.button))
            {
                LoadRole(listRole[i]);
            }
        }
    }
    /// <summary>
    /// ╪сть╫ги╚
    /// </summary>
    /// <param name="prefab"></param>
    private void LoadRole(GameObject prefab)
    {
        if (m_CurGo != null)
        {
            GameObject.Destroy(m_CurGo);
            m_CurGo = null;
        }
        if (prefab != null)
        {
          GameObject go  =  GameObject.Instantiate(prefab);
          if(go != null)
          {
                go.transform.parent = this.transform;
                go.transform.localPosition = Vector3.zero;
                RotateWithMouse r = go.AddComponent<RotateWithMouse>();
                r.aixsType = 2;
                m_CurGo = go;
          }
        }
    }
}
