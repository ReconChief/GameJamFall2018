using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyScript : MonoBehaviour
{
    public Transform target;
    public Transform myTransform;

    private GameController gc;

    void Start()
    {
        gc = GameObject.FindWithTag("GameController").GetComponent<GameController>();
    }

    void Update()
    {
        transform.LookAt(target);
        transform.Translate(Vector3.forward * 1 * Time.deltaTime);
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            gc.ReturnPlayer();
        }
    }
}
