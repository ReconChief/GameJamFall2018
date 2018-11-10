using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ChangeLevel : MonoBehaviour
{
    void Update()
    {
        if (Input.GetKeyDown("e") && Input.GetKeyDown("n") && Input.GetKeyDown("d"))
        {
            SceneManager.LoadScene("EndScreen");
        }
    }

    public void ChangeToGame()
    {
        SceneManager.LoadScene("Game");
    }
}
