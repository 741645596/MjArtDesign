using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class Example : MonoBehaviour
{
    [SerializeField] private GameObject hairItemPrefab;

    [SerializeField] private SkinnedMeshRenderer head, body, top, bottom, footwear, hair, glasses, beard;
    private Material currentHeadMat;
    private Material cacheHeadMat;

    private void Start()
    {
        //StartCoroutine(InitHair());
    }

    /*private IEnumerator InitHair()
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
                        hair.sharedMesh = hairConfig.data[index].hairMesh;
                        hair.sharedMaterial = hairConfig.data[index].hairMaterial;
                    }
                });
                yield return null;
            }
        }
    }*/

}