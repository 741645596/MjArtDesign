using System.Collections;
using UnityEngine;

public class HuMJNode : MJConfigData
{
    /// <summary>
    /// 加载胡牌墙
    /// </summary>
    public IEnumerator LoadMjHuTeam(GameObject maJiangPrefab, float loadTimeStep)
    {
        int layer = LayerMask.NameToLayer("Default");
        for (int page = 0; page < 2; page++)   // 两页
        {
            int maxH = this.isMultLayer ? 15 : 1;
            for (int h = 0; h < maxH; h++)
            {
                for (int X = 0; X < 3; X++)
                {
                    Vector3 worldPos = CalcWolrldPos(X, h, page);
                    yield return LoadMajiang(maJiangPrefab, loadTimeStep, worldPos, layer, false);
                }
            }
        }
    }
    /// <summary>
    /// 计算世界坐标
    /// </summary>
    /// <param name="posX"></param>
    /// <param name="hLayer"></param>
    /// <returns></returns>
    public Vector3 CalcWolrldPos(int posX, int hLayer, int page)
    {
        Vector3 startPos = new Vector3(0.3242994f, 0.01372704f, 0.0f);
        Vector3 diffX = this.mjStepWidth * ((this.c != MJDir.Horizontal) ? new Vector3(1, 0, 0) : new Vector3(0, 0, 1));
        Vector3 diffZ = this.MjStepHeight * ((this.c != MJDir.Horizontal) ? new Vector3(0, 0, 1) : new Vector3(1, 0, 0));


        Vector3 thicknessdiff = this.MjThickness * new Vector3(0, 1, 0);
        Vector3 localPos = startPos + thicknessdiff * hLayer - diffX * posX - diffZ * page;
        return transform.TransformPoint(localPos);
    }
    /// <summary>
    /// 加载麻将
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private IEnumerator LoadMajiang(GameObject maJiangPrefab,float loadTimeStep, Vector3 WorldPos, int layer, bool isShowShadow = true, bool isSeclect = false)
    {
        if (transform.gameObject.activeSelf != false)
        {
            if (maJiangPrefab != null)
            {
                GameObject go = GameObject.Instantiate(maJiangPrefab);
                go.transform.parent = transform;
                go.transform.position = WorldPos;
                MJAction action = go.GetComponent<MJAction>();
                action.SetRotation(0);
                action.SetMJViewData(this, isShowShadow, isSeclect);
                action.SetLayer(layer);
                MJManger.AddMJ(MJArea.Hu,this.seat,action);
            }
            yield return new WaitForSeconds(loadTimeStep);
        }

    }
}
