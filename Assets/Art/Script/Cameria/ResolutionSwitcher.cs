using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResolutionSwitcher : MonoBehaviour
{
    public CameriaConfigData cameriaData;
    public Camera main;
    public Camera hand;

    public int ButtonWidth = 200;
    public int ButtonHeight = 30;
    public int ButtonWidthStep = 220;
    public int ButtonHeightStep = 35;
    public Vector2Int topRightPos;
    public GUIStyle style = new GUIStyle();
    // Start is called before the first frame update

    private void Awake()
    {
    }

    private void OnGUI()
    {
        if (cameriaData == null || cameriaData.listData == null || cameriaData.listData.Count == 0)
            return;

        int height = topRightPos.y + 70;

        for (int i = 0; i < cameriaData.listData.Count; i++)
        {
            CameriaGroupData data = cameriaData.listData[i];
            if (data != null)
            {
                if (GUI.Button(new Rect(10 + 0 * ButtonWidthStep, height, ButtonWidth, ButtonHeight), data.Name, style))
                {
                    ChangeCameria(cameriaData.listData[i]);
                }
                height += ButtonHeightStep;
            }
        }

    }

    private void ChangeCameria(CameriaGroupData data)
    {
        ChangeCameria(data.MainCameriaData, this.main);
        ChangeCameria(data.HandCameriaData, this.hand);
    }

    private void ChangeCameria(CameriaData data, Camera cam)
    {
        if (data == null || cam == null)
            return;
        cam.gateFit = data.gateFit;
        cam.farClipPlane = data.farClipPlane;
        cam.fieldOfView = data.fieldOfView;
        cam.nearClipPlane = data.nearClipPlane;
        cam.sensorSize = data.sensorSize;
        cam.transform.position = data.pos;
        cam.transform.rotation = Quaternion.Euler(data.rotation);
    }
}
