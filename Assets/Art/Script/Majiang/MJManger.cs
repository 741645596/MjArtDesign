using System.Collections.Generic;
using UnityEngine;

public class MJManger 
{
    /// <summary>
    /// �齫����
    /// </summary>
    private static Dictionary<MJArea, MJSeatData>  g_ListMJ = new Dictionary<MJArea, MJSeatData>(); 
    /// <summary>
    /// ���Ը�λ�ù���
    /// </summary>
    private static Dictionary<Seat, int> g_DicPcgPostion = new Dictionary<Seat, int>();
    /// <summary>
    /// PCG  ����
    /// </summary>
    private static Dictionary<Seat, List<GameObject>> g_DicPcgGO = new Dictionary<Seat, List<GameObject>>();
    /// <summary>
    /// ����λ�ù���
    /// </summary>
    public static Dictionary<Seat, int> g_DicHuPostion = new Dictionary<Seat, int>();
    /// <summary>
    /// ���ƶ������
    /// </summary>
    private static Dictionary<Seat, List<GameObject>> g_DicHuGo = new Dictionary<Seat, List<GameObject>>();
    /// <summary>
    /// ÿ���齫������
    /// </summary>
    private const int g_mjMumPerLayer = 3;
    /// <summary>
    /// �齫��������
    /// </summary>
    private const int g_HuLayer = 15;
    /// <summary>
    /// ����̯�ƹ���״̬
    /// </summary>
    private static Dictionary<Seat, bool> g_DicTanPaiState = new Dictionary<Seat, bool>();
    /// <summary>
    /// ��ȡ�����Ƶ�λ��
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public static int GetPcgPostion(Seat seat)
    {
        if (g_DicPcgPostion.ContainsKey(seat) == true)
        {
            return g_DicPcgPostion[seat] + 1;
        }
        else return 0;
    }
    /// <summary>
    /// ����PCG�齫λ��
    /// </summary>
    /// <param name="seat"></param>
    /// <param name="postion"></param>
    public static void AddPcgPostion(Seat seat, int postion) 
    {
        if (g_DicPcgPostion.ContainsKey(seat) == false)
        {
            g_DicPcgPostion.Add(seat, postion);
        }
        else
        {
            g_DicPcgPostion[seat] = postion;
        }
    }
    /// <summary>
    /// �������Ը�
    /// </summary>
    /// <param name="seat"></param>
    /// <param name="go"></param>
    public static void AddPCGgo(Seat seat, GameObject go)
    {
        if (go != null)
        {
            if (g_DicPcgGO.ContainsKey(seat) == true)
            {
                g_DicPcgGO[seat].Add(go);
            }
            else 
            {
                List<GameObject> list = new List<GameObject>();
                list.Add(go);
                g_DicPcgGO.Add(seat, list);
            }
        }
    }
    /// <summary>
    /// ����pcg����
    /// </summary>
    /// <param name="seat"></param>
    public static void ClearPCGgo(Seat seat)
    {
        g_DicPcgPostion.Remove(seat);
        List<GameObject> list = null;
        if (g_DicPcgGO.TryGetValue(seat, out list) == true)
        {
            foreach (GameObject mj in list)
            {
                if (mj != null)
                {
                    GameObject.Destroy(mj);
                }
            }
            list.Clear();
            g_DicPcgGO.Remove(seat);
        }
    }
    /// <summary>
    /// ��ȡmj ����
    /// </summary>
    /// <param name="area"></param>
    /// <param name="seat"></param>
    /// <returns></returns>
    public static int GetMJNum(MJArea area, Seat seat)
    {
        if (g_ListMJ.ContainsKey(area) == true)
        {
            return g_ListMJ[area].GetMJNum(seat);
        }
        else
        {
            return 0;
        }
    }
    /// <summary>
    /// ����齫��
    /// </summary>
    /// <param name="mj"></param>
    public static void AddMJ(MJArea area ,Seat seat, MJAction mj)
    {
        if (mj != null)
        {
            if (g_ListMJ.ContainsKey(area) == true)
            {
                g_ListMJ[area].AddMJ(seat, mj);
            }
            else 
            {
                MJSeatData data = new MJSeatData();
                data.AddMJ(seat, mj);
                g_ListMJ.Add(area, data);
            }
        }
    }
    /// <summary>
    /// �Ƴ��齫��
    /// </summary>
    /// <param name="area"></param>
    /// <param name="seat"></param>
    /// <param name="mj"></param>
    public static void RemoveMJ(MJArea area, Seat seat, MJAction mj)
    {
        if (mj != null)
        {
            if (g_ListMJ.ContainsKey(area) == true)
            {
                g_ListMJ[area].RemoveMJ(seat, mj);
            }
            GameObject.Destroy(mj.gameObject);
        }
    }
    /// <summary>
    /// ���������齫
    /// </summary>
    public static void ClearAllMJ(MJArea area)
    {
        if (area == MJArea.All)
        {
            foreach (MJSeatData data in g_ListMJ.Values)
            {
                data.ClearAllMJ();
            }
            g_ListMJ.Clear();
        }
        else 
        {
            if(g_ListMJ.ContainsKey(area) == true)
            {
                MJSeatData data = g_ListMJ[area];
                data.ClearAllMJ();
                g_ListMJ.Remove(area);
            }
        }
    }
    /// <summary>
    /// ����ָ����λ���齫��
    /// </summary>
    /// <param name="area"></param>
    /// <param name="seat"></param>
    public static void ClearAllMJ(MJArea area, Seat seat)
    {
        if (area == MJArea.All)
        {
            foreach (MJSeatData data in g_ListMJ.Values)
            {
                data.ClearAllMJ(seat);
            }
        }
        else
        {
            if (g_ListMJ.ContainsKey(area) == true)
            {
                MJSeatData data = g_ListMJ[area];
                data.ClearAllMJ(seat);
            }
        }
    }
    /// <summary>
    /// ����ָ����λ���һ����
    /// </summary>
    /// <param name="seat"></param>
    public static void ClearLastMJ(MJArea area, Seat seat)
    {
        if (g_ListMJ.ContainsKey(area) == true)
        {
            g_ListMJ[area].ClearLast(seat);
        }
    }
    /// <summary>
    ///   ��ȡ���һ���齫��
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public static MJAction GetLastMJ(MJArea area, Seat seat)
    {
        if (g_ListMJ.ContainsKey(area) == true)
        {
            return g_ListMJ[area].GetLast(seat);
        }
        return null;
    }

    public static MJAction GetLastMJ(MJArea area, bool isRemove)
    {
        if (g_ListMJ.ContainsKey(area) == true)
        {
            return g_ListMJ[area].GetLastMJ(isRemove);
        }
        return null;
    }
    /// <summary>
    /// ��ȡ�ɺ��Ƶ�λ��
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public static int GetHuPostion(Seat seat)
    {
        if (g_DicHuPostion.ContainsKey(seat) == true)
        {
            return g_DicHuPostion[seat] + 1;
        }
        else return 0;
    }
    /// <summary>
    /// ��ȡ�����齫�������Ʋ���
    /// </summary>
    /// <returns>x:�ڼ����齫��y:�ڼ��� z: ÿ��ڼ���</returns>
    public static Vector3 GetHuPaiAniParam(int pos)
    {
        Vector3 ret = Vector3.zero;
        int onelayerMax = g_mjMumPerLayer * g_HuLayer;
        if (pos >= onelayerMax)
        {
            ret.x = 1;
        }
        else ret.x = 0;
        //
        pos %= onelayerMax;
        ret.y = (pos / g_mjMumPerLayer) * 1.0f / (g_HuLayer -1);
        ret.z = (pos % g_mjMumPerLayer) * 1.0f / (g_mjMumPerLayer - 1);
        return ret;
    }

    /// <summary>
    /// ��ȡ�����齫�������Ʋ���
    /// </summary>
    /// <returns>x:�ڼ����齫��y:�ڼ��� z: ÿ��ڼ���</returns>
    public static Vector3Int GetHuPaiParam(int pos)
    {
        Vector3Int ret = Vector3Int.zero;
        int onelayerMax = g_mjMumPerLayer * g_HuLayer;
        if (pos >= onelayerMax)
        {
            ret.x = 1;
        }
        else ret.x = 0;
        //
        pos %= onelayerMax;
        ret.y = pos / g_mjMumPerLayer;
        ret.z = pos % g_mjMumPerLayer;
        return ret;
    }

    /// <summary>
    /// ����Hu�齫λ��
    /// </summary>
    /// <param name="seat"></param>
    /// <param name="postion"></param>
    public static void AddHuPostion(Seat seat, int postion)
    {
        if (g_DicHuPostion.ContainsKey(seat) == false)
        {
            g_DicHuPostion.Add(seat, postion);
        }
        else
        {
            g_DicHuPostion[seat] = postion;
        }
    }

    /// <summary>
    /// �������Ը�
    /// </summary>
    /// <param name="seat"></param>
    /// <param name="go"></param>
    public static void AddHugo(Seat seat, GameObject go)
    {
        if (go != null)
        {
            if (g_DicHuGo.ContainsKey(seat) == true)
            {
                g_DicHuGo[seat].Add(go);
            }
            else
            {
                List<GameObject> list = new List<GameObject>();
                list.Add(go);
                g_DicHuGo.Add(seat, list);
            }
        }
    }
    /// <summary>
    /// ����pcg����
    /// </summary>
    /// <param name="seat"></param>
    public static void ClearHugo(Seat seat)
    {
        g_DicHuPostion.Remove(seat);
        List<GameObject> list = null;
        if (g_DicHuGo.TryGetValue(seat, out list) == true)
        {
            foreach (GameObject mj in list)
            {
                if (mj != null)
                {
                    GameObject.Destroy(mj);
                }
            }
            list.Clear();
            g_DicHuGo.Remove(seat);
        }
    }
    /// <summary>
    /// ����̯�ƹ���״̬
    /// </summary>
    /// <param name="seat"></param>
    /// <param name="isCan"></param>
    public static void SetTanPaiState(Seat seat, bool isCan)
    {
        if (g_DicTanPaiState.ContainsKey(seat) == true)
        {
            g_DicTanPaiState[seat]= isCan;
        }
        else
        {
            g_DicTanPaiState.Add(seat, isCan);
        }
    }
    /// <summary>
    /// ��ȡ̯��״̬
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public static bool GetTanPaiState(Seat seat)
    {
        if (g_DicTanPaiState.ContainsKey(seat) == true)
        {
            return g_DicTanPaiState[seat];
        }
        else
        {
            return false;
        }
    }
}


public class MJSeatData
{
    private Dictionary<Seat, List<MJAction>> m_DicMJ = new Dictionary<Seat, List<MJAction>>();
    /// <summary>
    /// ����齫��
    /// </summary>
    /// <param name="mj"></param>
    public void AddMJ(Seat seat, MJAction mj)
    {
        if (mj != null)
        {
            if (m_DicMJ.ContainsKey(seat) == true)
            {
                m_DicMJ[seat].Add(mj);
            }
            else 
            {
                List<MJAction> l = new List<MJAction>();
                l.Add(mj);
                m_DicMJ.Add(seat,l);
            }
        }
    }
    /// <summary>
    /// �Ƴ��齫��
    /// </summary>
    /// <param name="seat"></param>
    /// <param name="mj"></param>
    public void RemoveMJ(Seat seat,MJAction mj)
    {
        if (mj != null)
        {
            if (m_DicMJ.ContainsKey(seat) == true)
            {
                m_DicMJ[seat].Remove(mj);
            }
            GameObject.Destroy(mj.gameObject);
        }
    }
    /// <summary>
    /// ���������齫
    /// </summary>
    public void ClearAllMJ()
    {
        foreach (List<MJAction> list in m_DicMJ.Values)
        {
            foreach (MJAction v in list)
            {
                if (v != null)
                {
                    GameObject.Destroy(v.gameObject);
                }
                
            }
        }
        m_DicMJ.Clear();
    }

    public void ClearAllMJ(Seat seat)
    {
        if (m_DicMJ.ContainsKey(seat) == true)
        {
            foreach (MJAction v in m_DicMJ[seat])
            {
                if (v != null)
                {
                    GameObject.Destroy(v.gameObject);
                }
            }
            m_DicMJ[seat].Clear();
        }
    }
    /// <summary>
    /// ��ȡ���һ���齫��
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public MJAction GetLast(Seat seat)
    {
        if (m_DicMJ.ContainsKey(seat) == true)
        {
            int count = m_DicMJ[seat].Count;
            if (count > 0)
            {
                return m_DicMJ[seat][count - 1];
            }  
        }
        return null;
    }
    /// <summary>
    /// ��ȡ���һ���齫��
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public MJAction GetLast(Seat seat, bool isRemove)
    {
        if (m_DicMJ.ContainsKey(seat) == true)
        {
            int count = m_DicMJ[seat].Count;
            if (count > 0)
            {
                MJAction mj = m_DicMJ[seat][count - 1];
                if (isRemove == true)
                {
                    m_DicMJ[seat].RemoveAt(count -1);
                }
                return mj;
            }
        }
        return null;
    }
    /// <summary>
    /// ����λ����������һ���齫��
    /// </summary>
    /// <param name="isRemove"></param>
    /// <returns></returns>
    public MJAction GetLastMJ(bool isRemove)
    {
        for (int s = (int)Seat.Left; s >= (int)Seat.Self; s--)
        {
            MJAction mj = GetLast((Seat)s, isRemove);
            if (mj != null)
            {
                return mj;
            }
        }
        return null;
    }
    /// <summary>
    /// �������һ���齫��
    /// </summary>
    /// <param name="seat"></param>
    public void ClearLast(Seat seat)
    {
        if (m_DicMJ.ContainsKey(seat) == true)
        {
            int count = m_DicMJ[seat].Count;
            if (count > 0)
            {
                MJAction mj = m_DicMJ[seat][count - 1];
                m_DicMJ[seat].RemoveAt(count -1);
                if (mj != null)
                {
                    GameObject.Destroy(mj.gameObject);
                }
            }
        }
    }
    /// <summary>
    /// ��ȡ����
    /// </summary>
    /// <param name="seat"></param>
    /// <returns></returns>
    public int GetMJNum(Seat seat)
    {
        if (m_DicMJ.ContainsKey(seat) == true)
        {
            return m_DicMJ[seat].Count;
        }
        else
        {
            return 0;
        }
    }
}

public enum MJArea : int 
{
    Wall = 0,
    Hand = 1,
    Out  = 2,
    Hu   = 3,
    All  = 99,
}

