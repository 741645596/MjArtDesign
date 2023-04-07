using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VolumeCloudColliderManager : MonoBehaviour
{

    static VolumeCloudColliderManager volumeCloudColliderManager;

    public static VolumeCloudColliderManager CloudColliderManager
    {
        get
        {
            if (volumeCloudColliderManager == null)
            {
                GameObject obj = new GameObject("VolumeCloudColliderManager");
                obj.hideFlags = HideFlags.HideInHierarchy;
                GameObject.DontDestroyOnLoad(obj);
                volumeCloudColliderManager = obj.AddComponent<VolumeCloudColliderManager>();
            }
            return volumeCloudColliderManager;
        }
    }

    List<VolumeCloudCollider> cloudColliders = new List<VolumeCloudCollider>();

    public void AddCollider(VolumeCloudCollider sc)
    {
        if (!cloudColliders.Contains(sc))
        {
            cloudColliders.Add(sc);
        }
    }

    public void RemoveCollider(VolumeCloudCollider sc)
    {
        if (sc!=null)
        {
            cloudColliders.Remove(sc);
        }
    }

    void Update()
    {
        float camRadius;
        if (Camera.main.orthographic)
        {
            camRadius = Camera.main.farClipPlane*1.5f;
        }
        else
        {
            camRadius = Camera.main.farClipPlane / Mathf.Cos(Mathf.Deg2Rad * Camera.main.fieldOfView * 0.5f);
        }
        Transform camTrans = Camera.main.transform;
        int count = cloudColliders.Count;
        for (int i=0;i< count; ++i)
        {
            if (i< cloudColliders.Count)
            {
                VolumeCloudCollider volumeCloudCollider = cloudColliders[i];
                Vector3 centor = Vector3.zero;
                float radius = 0;
                volumeCloudCollider.GetCenterAndRadius(ref centor, ref radius);
                float dis = Vector3.Distance(camTrans.position, centor);
                if (dis > (camRadius + radius))
                {
                    if (volumeCloudCollider.enabled)
                    {
                        volumeCloudCollider.enabled = false;
                    }
                }
                else
                {
                    if (!volumeCloudCollider.enabled)
                    {
                        volumeCloudCollider.enabled = true;
                    }

                }
            }
            else
            {
                break;
            }
        }
    }
}
