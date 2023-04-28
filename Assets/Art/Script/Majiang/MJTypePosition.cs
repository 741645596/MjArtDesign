using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MJTypePosition : MonoBehaviour
{
    // Start is called before the first frame update
    private Seat m_seat;
    private int m_index;
    private PaiGroupDestination m_pgd;

    /// <summary>
    /// 设置吸附参数
    /// </summary>
    /// <param name="seat"></param>
    /// <param name="posIndex"></param>
    /// <param name="pgd"></param>
    public void SetParam(Seat seat, int posIndex, PaiGroupDestination pgd)
    {
        this.m_seat = seat;
        this.m_index = posIndex;
        this.m_pgd = pgd;
    }
    /// <summary>
    /// 处理吸附效果
    /// </summary>
    public void DoPostion()
    {
        if (m_pgd == PaiGroupDestination.HuArea)
        {
            Vector3Int p = MJManger.GetHuPaiParam(m_index);
            HuMJNode hu = transform.parent.GetComponent<HuMJNode>();
            if (hu != null)
            {
                Vector3 worldPos = hu.CalcWolrldPos(p.z, p.y, p.x);
                transform.position = worldPos;
            }
        }
    }
}
