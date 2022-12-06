using System.Collections.Generic;
using UnityEngine;

public class CaseGUI : MonoBehaviour
{
    public List<string> caseNames;

    private void OnGUI()
    {
        float width = 250 * display.srceenScaleFactor;
        float height = 55 * display.srceenScaleFactor;
        GUI.skin.button.fontSize = Mathf.FloorToInt(25 * display.srceenScaleFactor);

        GUILayout.BeginArea(new Rect(Screen.width - width, 0, width, Screen.height));
        caseNames.ForEach(n =>
        {
            string name = n.Substring(4);
            if (GUILayout.Button(name, GUILayout.Width(width), GUILayout.Height(height)))
            {
            }
        });
        GUILayout.EndArea();
    }

    private static void OnQuitting()
    {
        Application.quitting -= OnQuitting;
    }
}
