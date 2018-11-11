using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class DialogueScript : MonoBehaviour
{

    public GameObject dialogueManager;
    public Text dialogueText;
    public bool dialogueActive;
    public string[] dialogueLines;


    public int currentLine;

    // Use this for initialization
    void Start()
    {



        dialogueManager.SetActive(true);
        dialogueActive = true;
        StartCoroutine(TextPlayer());

    }

    // Update is called once per frame
    void Update()
    {

        dialogueText.text = dialogueLines[currentLine];

    }
    private IEnumerator TextPlayer()
    {
        while (isActiveAndEnabled&& currentLine < dialogueLines.Length-1)
        {
           currentLine++; 

            yield return new WaitForSeconds(10f);
        }
    }
}
