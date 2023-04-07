using UnityEngine;

public class MoveCameria : MonoBehaviour
{
    public float moveSpeed = 1.0f;
    private Vector3 lastMousePosition;

    void Update()
    {

        if (Input.GetMouseButton(1))
        {
            Vector3 mouseDelta = Input.mousePosition - lastMousePosition;
            float dot = Vector2.Dot(Vector2.right, new Vector2(mouseDelta.x, mouseDelta.y));
            float dis = mouseDelta.magnitude * moveSpeed * 0.1f;
            dis = Mathf.Min(dis, 1.0f);
            if (dot > 0)
            {
                dis = -dis;
            }

            transform.Translate(Vector3.right * dis, Space.World);
        }
        lastMousePosition = Input.mousePosition;
    }

}

