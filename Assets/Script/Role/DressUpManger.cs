using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DressUpManger : MonoBehaviour
{
    // 头发
    [SerializeField] private RoleDataConfig hairConfig;
    [SerializeField] private Transform hairNode;
    [SerializeField] private GameObject hairItemPrefab;
    // 上衣
    [SerializeField] private ShangyiDataConfig shangyiConfig;
    [SerializeField] private Transform shangyiNode;
    [SerializeField] private GameObject shangyiItemPrefab;
    // 下衣
    [SerializeField] private XiayiDataConfig xiayiConfig;
    [SerializeField] private Transform xiayiNode;
    [SerializeField] private GameObject xiayiItemPrefab;
    // 鞋子
    [SerializeField] private XieziDataConfig xieziConfig;
    [SerializeField] private Transform xieziNode;
    [SerializeField] private GameObject xieziItemPrefab;

    void Start()
    {
        StartCoroutine(InitHair());
        StartCoroutine(InitShangyi());
        StartCoroutine(InitXiayi());
        StartCoroutine(InitXiezi());
    }

    private IEnumerator InitHair()
    {
        yield return ChangeAvatar(hairConfig.data, hairNode, hairItemPrefab);
    }

    private IEnumerator InitShangyi()
    {
        yield return ChangeAvatar(shangyiConfig.data, shangyiNode, shangyiItemPrefab);
    }

    private IEnumerator InitXiayi()
    {
        yield return ChangeAvatar(xiayiConfig.data, xiayiNode, xiayiItemPrefab);
    }

    private IEnumerator InitXiezi()
    {
        yield return ChangeAvatar(xieziConfig.data, xieziNode, xieziItemPrefab);
    }
    /// <summary>
    /// 更改item
    /// </summary>
    /// <param name="listData"></param>
    /// <param name="parentNode"></param>
    /// <param name="uiItem"></param>
    /// <returns></returns>
    private IEnumerator ChangeAvatar(List<RoleBaseData> listData, Transform parentNode, GameObject uiItem)
    {
        if (listData != null)
        {
            for (int i = 0; i < listData.Count; i++)
            {
                var data = listData[i];
                var instance = Instantiate(uiItem);
                instance.transform.SetParent(uiItem.transform.parent, false);
                instance.transform.SetSiblingIndex(uiItem.transform.parent.childCount - 2);
                instance.GetComponent<Image>().sprite = data.thumb;
                instance.SetActive(true);
                instance.GetComponent<Toggle>().onValueChanged.AddListener(isOn =>
                {
                    if (isOn)
                    {
                        int index = instance.transform.GetSiblingIndex();
                        GameObject go = parentNode.GetChild(0).gameObject;
                        if (go != null)
                        {
                            GameObject.Destroy(go);
                        }
                        GameObject g = Instantiate(listData[index].go);
                        if (g != null)
                        {
                            g.transform.parent = parentNode;
                            g.transform.localPosition = Vector3.zero;
                            g.transform.localRotation = Quaternion.identity;
                            g.transform.localScale = Vector3.one;
                        }
                    }
                });
                yield return null;
            }
        }
    }
}
