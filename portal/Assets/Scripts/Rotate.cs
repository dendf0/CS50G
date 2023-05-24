using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public float rotationSpeed = 10f;

    void Update()
    {
        // Calculate the amount of rotation based on the rotation speed
        float rotationAmount = rotationSpeed * Time.deltaTime;

        // Rotate the object around the Y-axis
        transform.Rotate(0f, rotationAmount, 0f);
    }
}
