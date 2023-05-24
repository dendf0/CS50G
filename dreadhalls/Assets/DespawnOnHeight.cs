using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DespawnOnHeight : MonoBehaviour
{
    public float despawnHeight;

    void Update()
    {
        if (transform.position.y < despawnHeight)
        {
            LevelGenerator.curMaze = 0;
            SceneManager.LoadScene("GameOver");
        }
    }
}
