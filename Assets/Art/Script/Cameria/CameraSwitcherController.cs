using UnityEngine;
using UnityEngine.UI;

public class CameraSwitcherController : MonoBehaviour
{
    public Transform cameraPosition1;
    public Transform cameraPosition2;
    public Slider slider;

    private void Start()
    {
        slider.onValueChanged.AddListener(delegate { OnSliderValueChange(); });
    }

    private void OnSliderValueChange()
    {
        float sliderValue = slider.value;
        Vector3 newPosition = Vector3.Lerp(cameraPosition1.position, cameraPosition2.position, sliderValue);
        transform.position = newPosition;
        transform.rotation = Quaternion.Lerp(cameraPosition1.rotation, cameraPosition2.rotation, sliderValue);
    }
}
