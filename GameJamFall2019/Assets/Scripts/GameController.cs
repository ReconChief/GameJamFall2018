using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameController : MonoBehaviour
{
    public GameObject returnPoint;
    public GameObject player;

    void Start()
    {

    }

    void Update()
    {

    }

    public void ReturnPlayer()
    {
        player.gameObject.transform.position = returnPoint.transform.position;
    }
}
