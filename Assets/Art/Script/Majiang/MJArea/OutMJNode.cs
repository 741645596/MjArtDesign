using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutMJNode : MJConfigData
{
    /// <summary>
    ///  牌的摆设
    /// </summary>
    public List<int> listPaiNum = new List<int>();
    /// <summary>
    /// 加载已出麻将。
    /// </summary>
    /// <param name="Prefab"></param>
    /// <param name="loadTimeStep"></param>
    /// <returns></returns>
    public IEnumerator LoadMjOutTeam(GameObject Prefab, float loadTimeStep)
    {
        if (listPaiNum != null && listPaiNum.Count > 0)
        {
            float Ystep = 1.0f / (listPaiNum.Count - 1);
            for (int line = 0; line < listPaiNum.Count; line++)
            {
                int paiNum = listPaiNum[line];
                if (paiNum <= 1)
                    continue;
                for (int j = 0; j < paiNum; j++)
                {
                    LoadMJ(Prefab, new Vector2Int(line, j), false);
                    yield return new WaitForSeconds(loadTimeStep);
                }
            }
        }
    }
    /// <summary>
    /// 加载麻将子
    /// </summary>
    /// <param name="mjBornPos"></param>
    /// <returns></returns>
    public MJAction LoadMJ(GameObject Prefab, Vector2Int mjBornPos, bool isSeclect)
    {
        int layer = LayerMask.NameToLayer("Default");
        Vector3 pos = Vector3.zero + new Vector3(this.MjStepHeight * (mjBornPos.x), 0, this.mjStepWidth * (-mjBornPos.x + mjBornPos.y));
        return LoadMajiang(Prefab, pos, layer, this.isShowMjShadow, isSeclect);
    }
    /// <summary>
    /// 加载麻将
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private MJAction LoadMajiang(GameObject Prefab, Vector3 pos, int layer, bool isShowShadow = true, bool isSeclect = false)
    {
        if (Prefab != null)
        {
            GameObject go = GameObject.Instantiate(Prefab);
            go.transform.parent = transform;
            MJAction action = go.GetComponent<MJAction>();
            action.SetPos(pos);
            action.SetRotation(0);
            action.SetMJViewData(this, isShowShadow, isSeclect);
            action.SetLayer(layer);
            MJManger.AddMJ(MJArea.Out, this.seat, action);
            Debug.Log("AddMJ(MJArea.Out");
            return action;
        }
        return null;
    }
    /// <summary>
    ///  获取下一个麻将出生位置
    /// </summary>
    /// <returns></returns>
    public Vector2Int GetNextMJ()
    {
        int mjNum = MJManger.GetMJNum(MJArea.Out, this.seat);
        for (int i = 0; i < listPaiNum.Count; i++)
        {
            if (mjNum > listPaiNum[i])
            {
                mjNum -= listPaiNum[i];
            }
            else 
            {
                return new Vector2Int(i, mjNum);
            }
        }
        return Vector2Int.zero;
    }
}
