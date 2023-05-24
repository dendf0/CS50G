using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ChangeText : MonoBehaviour
{
    public Text text;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void TextChange(int num){
        text.text = num.ToString();
    }
}
