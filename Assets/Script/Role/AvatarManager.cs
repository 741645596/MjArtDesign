using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AvatarManager 
{
    /// <summary>
    /// 获取同名的骨骼
    /// </summary>
    /// <param name="SelfBones">自己的骨骼</param>
    /// <param name="TargetBones">目标骨骼</param>
    /// <returns></returns>
    public void ChangeMeshAndBones(SkinnedMeshRenderer self, SkinnedMeshRenderer part)
    {
        if (self.sharedMesh != part.sharedMesh)
        {
            Transform[] SelfBones = self.bones;
            Transform[] TargetBones = part.bones;
            // 找到相同的材质
            List<Transform> refreshBones = new List<Transform>();
            for (int i = 0; i < TargetBones.Length; i++)
            {
                for (int j = 0; j < SelfBones.Length; j++)
                {
                    if (TargetBones[i].name.Equals(SelfBones[j].name))
                    {
                        refreshBones.Add(SelfBones[j]);
                        break;
                    }
                }
            }
            self.sharedMesh = part.sharedMesh;
            part.bones = refreshBones.ToArray();
        }
        self.materials = part.materials;
    }
}
