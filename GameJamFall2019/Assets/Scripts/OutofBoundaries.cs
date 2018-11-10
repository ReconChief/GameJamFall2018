using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutofBoundaries : MonoBehaviour
{
    private GameController gc;

    void Start()
    {
        gc = GameObject.FindWithTag("GameController").GetComponent<GameController>();
    }

    void Update()
    {

    }

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            gc.ReturnPlayer();
        }
    }
}
