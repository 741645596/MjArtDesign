using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoleAniHelp 
{
    /// <summary>
    /// ����mesh�͹���
    /// </summary>
    /// <param name="selfRoot"></param>
    /// <param name="targetSmr"></param>
    public static void ChangeMeshAndBones(GameObject selfRoot, SkinnedMeshRenderer targetSmr)
    {
        Transform selfChangeBone = FindChild(selfRoot.transform, targetSmr.rootBone.name);
        if (selfChangeBone == null)
        {
            return;
        }

        // ��������  --> ���ε����������淶�йأ��������µĲ�Ӧ����ӡ�
        UpdateBones(selfChangeBone, targetSmr.rootBone);

        var selfBones = selfRoot.GetComponentsInChildren<Transform>(true);
        List<Transform> newBones = GetSameNameBones(selfBones, targetSmr.bones, targetSmr.rootBone.name);

        targetSmr.bones = newBones.ToArray();
        targetSmr.rootBone = selfChangeBone;
    }
    /// <summary>
    /// ��ȡͬ���Ĺ���
    /// </summary>
    /// <param name="SelfBones">�Լ��Ĺ���</param>
    /// <param name="selfroot">�Լ��Ĺ������ڵ�</param>
    /// <param name="TargetBones">Ŀ�����</param>
    /// <param name="targetroot">Ŀ��������ڵ�</param>
    /// <returns></returns>
    private static List<Transform> GetSameNameBones(Transform[] SelfBones, Transform[] TargetBones, string rootName)
    {
        List<Transform> refreshBones = new List<Transform>();

        for (int i = 0; i < TargetBones.Length; i++)
        {
            Transform result = FindBestBone(SelfBones, TargetBones[i], rootName);
            if (result != null)
            {
                refreshBones.Add(result);
            }
        }
        return refreshBones;
    }
    /// <summary>
    /// find best
    /// </summary>
    /// <param name="SelfBones"></param>
    /// <param name="target"></param>
    /// <param name="rootName"></param>
    /// <returns></returns>
    private static Transform FindBestBone(Transform[] SelfBones, Transform target, string rootName)
    {
        List<Transform> listResult = new List<Transform>();
        for (int i = 0; i < SelfBones.Length; i++)
        {
            if (target.name.Equals(SelfBones[i].name))
            {
                listResult.Add(SelfBones[i]);
            }
        }
        if (listResult.Count > 0)
        {
            /*if (listResult.Count > 1) 
            {
                foreach (Transform s in listResult)
                {
                    if (CheckSameNameBones(s, target, rootName) == true)
                    {
                        return s;
                    }
                }
                return listResult[0];
            }
            else*/ return listResult[0];
        }
        return null;
    }
    /// <summary>
    /// ��������������ͬ������·��ҲӦ����ͬ
    /// </summary>
    /// <param name="selfBone"></param>
    /// <param name="selfroot"></param>
    /// <param name="targetBone"></param>
    /// <param name="targetroot"></param>
    /// <returns></returns>
    private static bool CheckSameNameBones(Transform selfBone, Transform targetBone, string rootName)
    {
        if (selfBone == null || targetBone == null)
        {
            return false;
        }
        Transform s1 = selfBone;
        Transform t1 = targetBone;
        while (s1.name.Equals(t1.name) == true)
        {
            s1 = s1.parent;
            t1 = t1.parent;
            if (s1 == null || t1 == null)
            {
                return false;
            }
            else if (s1.name.Equals(rootName) && t1.name.Equals(rootName))
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// ���¹���
    /// </summary>
    /// <param name="selfTf"></param>
    /// <param name="targetTf"></param>
    private static void UpdateBones(Transform selfTf, Transform targetTf)
    {
        if (selfTf.name.Equals(targetTf.name))
        {
            var addTrans = new List<Transform>();

            for (int i = 0; i < targetTf.childCount; i++)
            {
                var isFound = false;
                for (int j = 0; j < selfTf.childCount; j++)
                {
                    if (targetTf.GetChild(i).name.Equals(selfTf.GetChild(j).name))
                    {
                        isFound = true;

                        UpdateBones(selfTf.GetChild(j), targetTf.GetChild(i));
                    }
                    if (isFound)
                    {
                        break;
                    }
                }

                if (!isFound)
                {
                    addTrans.Add(targetTf.GetChild(i));
                }
            }

            for (int i = 0; i < addTrans.Count; i++)
            {
                var addTf = Object.Instantiate(addTrans[i].gameObject).transform;

                addTf.name = addTrans[i].name;

                addTf.SetParent(selfTf.transform);
                addTf.localPosition = addTrans[i].localPosition;
                addTf.localScale = addTrans[i].localScale;
                addTf.localRotation = addTrans[i].localRotation;
            }
        }
    }
    /// <summary>
    /// ͨ�����ڵ��ҵ���Ӧ���ӽڵ�
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="name"></param>
    /// <returns></returns>
    private static Transform FindChild(Transform parent, string name)
    {
        if (string.IsNullOrEmpty(name))
        {
            return null;
        }

        for (int i = 0; i < parent.childCount; i++)
        {
            var child = parent.GetChild(i);

            if (child.name.Equals(name))
            {
                return child;
            }

            if (child.childCount > 0)
            {
                var chChild = FindChild(child, name);
                if (chChild != null)
                {
                    return chChild;
                }
            }
        }

        return null;
    }
}
