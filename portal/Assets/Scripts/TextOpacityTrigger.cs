using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TextOpacityTrigger : MonoBehaviour
{
    public Text displayText;
    private float fullOpacity = 1f;
    private float noOpacity = 0;

    private void Start()
    {
        ChangeTextOpacity(noOpacity);
    }

    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            ChangeTextOpacity(fullOpacity);
        }
    }

    private void ChangeTextOpacity(float opacity)
    {
        Color newColor = displayText.color;
        newColor.a = opacity;
        displayText.color = newColor;
    }
}
