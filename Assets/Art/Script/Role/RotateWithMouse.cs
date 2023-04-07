using UnityEngine;

public class RotateWithMouse : MonoBehaviour
{
    public float sensitivity = 100f;
    public int aixsType = 1;

    public float rotationSpeed = 10f;
    public float zoomSpeed = 10f;
    public float minZoomDistance = 1f;
    public float maxZoomDistance = 10f;

    private Vector3 lastMousePosition;

    void Update()
    {
        // Ðý×ª
        if (Input.GetMouseButton(0))
        {
            Vector3 mouseDelta = Input.mousePosition - lastMousePosition;
            float dot = Vector2.Dot(Vector2.right, new Vector2(mouseDelta.x, mouseDelta.y));
            float dis = mouseDelta.magnitude * rotationSpeed * 0.1f;
            dis = Mathf.Min(dis, 20f);
            if (dot > 0)
            {
                dis = -dis;
            }

            if (aixsType == 1)
            {
                transform.Rotate(Vector3.forward, dis);
            }
            else if (aixsType == 2)
            {
                transform.Rotate(Vector3.up, dis);
            }
            else
            {
                transform.Rotate(Vector3.right, dis);
            }
        }
        lastMousePosition = Input.mousePosition;
    }

}

