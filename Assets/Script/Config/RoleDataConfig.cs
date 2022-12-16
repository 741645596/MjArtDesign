using System;
using UnityEngine;
using System.Collections.Generic;



[Serializable]
public class RoleBaseData
{
    public Sprite thumb;
    public GameObject go;
}



[CreateAssetMenu]
public class RoleDataConfig : ScriptableObject
{
    public List<RoleBaseData> data = new List<RoleBaseData>(0);
}
