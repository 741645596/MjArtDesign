using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class DressUpManger : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] private RoleDataConfig hairConfig;
    [SerializeField] private Transform hairNode;
    [SerializeField] private GameObject hairItemPrefab;
    void Start()
    {
        StartCoroutine(InitHair());
    }

    private IEnumerator InitHair()
    {
        if (hairConfig != null)
        {
            for (int i = 0; i < hairConfig.data.Count; i++)
            {
                var data = hairConfig.data[i];
                var instance = Instantiate(hairItemPrefab);
                instance.transform.SetParent(hairItemPrefab.transform.parent, false);
                instance.transform.SetSiblingIndex(hairItemPrefab.transform.parent.childCount - 2);
                instance.GetComponent<Image>().sprite = data.thumb;
                instance.SetActive(true);
                instance.GetComponent<Toggle>().onValueChanged.AddListener(isOn =>
                {
                    if (isOn)
                    {
                        int index = instance.transform.GetSiblingIndex();
                        GameObject go = hairNode.GetChild(0).gameObject;
                        if (go != null)
                        {
                            GameObject.Destroy(go);
                        }
                        GameObject g = Instantiate(hairConfig.data[index].go);
                        if (g != null)
                        {
                            g.transform.parent = hairNode;
                            g.transform.localPosition = Vector3.zero;
                            g.transform.localScale = Vector3.one;
                        }
                    }
                });
                yield return null;
            }
        }
    }
}
