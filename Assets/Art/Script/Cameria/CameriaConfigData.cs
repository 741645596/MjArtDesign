using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static UnityEngine.Camera;
using System;

public class CameriaConfigData : ScriptableObject
{
    public List<CameriaGroupData> listData = new List<CameriaGroupData>();
}

[System.Serializable]
public class CameriaGroupData
{
    public string Name;
    public CameriaData MainCameriaData = new CameriaData();
    public CameriaData HandCameriaData = new CameriaData();
}
[System.Serializable]
public class CameriaData
{
    public Vector3 pos;
    public Vector3 rotation;
    public GateFitMode gateFit;
    public float nearClipPlane;
    public float farClipPlane;
    public float fieldOfView;
    public Vector2 sensorSize;
}


