using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float zoomSpeed = 1f;
    private float bakefieldOfView;
    private float limitZoom;
    public float minZoom;
    public float maxZoom;
    private void Awake()
    {
        bakefieldOfView = Camera.main.fieldOfView;
    }

    void Update()
    {
        // Zoom in and out with the mouse wheel
        float zoom = Input.GetAxis("Mouse ScrollWheel") * zoomSpeed;
        limitZoom += zoom;
        limitZoom = Mathf.Min(limitZoom, minZoom);
        limitZoom = Mathf.Max(limitZoom, maxZoom);
        Camera.main.fieldOfView = bakefieldOfView + limitZoom;
    }
}

