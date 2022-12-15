using System;
using UnityEngine;
using System.Collections.Generic;



[Serializable]
public class RoleBaseData
{
    public Sprite thumb;
    public GameObject go;
}


[Serializable]
public class RoleData
{
    public GameObject go;
    //public Mesh mesh;
    //public List<Material> materials;
}


[CreateAssetMenu]
public class RoleDataConfig : ScriptableObject
{
    public List<RoleBaseData> data = new List<RoleBaseData>(0);
}
