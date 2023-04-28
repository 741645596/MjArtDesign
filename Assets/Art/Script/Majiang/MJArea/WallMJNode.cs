using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WallMJNode : MJConfigData
{
    /// <summary>
    /// º”‘ÿ≈∆«Ω
    /// </summary>
    public IEnumerator LoadMjWallTeam(GameObject maJiangPrefab, float loadTimeStep)
    {
        int layer = LayerMask.NameToLayer("Default");
        Vector3 startPos = new Vector3(0.3242994f, 0.01372704f, 0.0f);
        Vector3 diff = this.mjStepWidth * ((this.c != MJDir.Horizontal) ? new Vector3(1, 0, 0) : new Vector3(0, 0, 1));
        Vector3 thicknessdiff = this.MjThickness * new Vector3(0, 1, 0);
        for (int i = 0; i < 17; i++)
        {
            yield return LoadMajiang(maJiangPrefab, loadTimeStep, startPos - diff * i, layer);
            if (this.isMultLayer == true)
            {
                yield return LoadMajiang(maJiangPrefab, loadTimeStep, startPos + thicknessdiff - diff * i, layer, false);
            }
        }
    }
    /// <summary>
    /// º”‘ÿ¬ÈΩ´
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="startPos"></param>
    /// <param name="layer"></param>
    private IEnumerator LoadMajiang(GameObject maJiangPrefab, float loadTimeStep, Vector3 pos, int layer, bool isShowShadow = true, bool isSeclect = false)
    {
        if (gameObject.activeSelf != false)
        {
            if (maJiangPrefab != null)
            {
                GameObject go = GameObject.Instantiate(maJiangPrefab);
                go.transform.parent = transform;
                MJAction action = go.GetComponent<MJAction>();
                action.SetPos(pos);
                action.SetRotation(0);
                action.SetMJViewData(this, isShowShadow, isSeclect);
                action.SetLayer(layer);
                MJManger.AddMJ(MJArea.Wall, this.seat, action);
            }
            yield return new WaitForSeconds(loadTimeStep);
        }
    }
}
