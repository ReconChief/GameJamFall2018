using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameController : MonoBehaviour
{
    public GameObject returnPoint;
    public GameObject player;

    public GameObject[] spawnEnemiesPrefab;
    public GameObject[] spawnEnemiesScene;

    public Transform[] location;

    void Start()
    {
        StartCoroutine(Spawner());
    }

    IEnumerator Spawner()
    {
        while(isActiveAndEnabled)
        {
            SpawnEnemies();
            yield return new WaitForSeconds(2f);
        }
    }

    public void ReturnPlayer()
    {
        player.gameObject.transform.position = returnPoint.transform.position;
    }

    public void SpawnEnemies()
    {
        //Spawn Enemies
        spawnEnemiesScene[0] = (GameObject) Instantiate(spawnEnemiesPrefab[0], location[0].transform.position, Quaternion.Euler(0, 0, 0));
    }

}
