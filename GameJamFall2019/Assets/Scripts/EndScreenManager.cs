using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace GameJam2018 {
	public class EndScreenManager : MonoBehaviour {
		[Tooltip("The time spent on the end screen before fading out.")]
		[SerializeField] private float endScreenDuration = 5;
		[SerializeField] private float fadeOutDuration = 1;

		private Image screenFade;

		public void Awake() {
			screenFade = GameObject.Find("Full Screen Fade").GetComponent<Image>();
			StartCoroutine(FadeScreenAndLeave(fadeOutDuration));
		}

		private IEnumerator FadeScreenAndLeave(float duration) {
			yield return new WaitForSeconds(endScreenDuration);
			Color c = new Color(0, 0, 0, 1);
			screenFade.color = c;

			float localTime = 0;
			while (localTime < duration) {
				c.a = localTime / duration;
				screenFade.color = c;
				yield return null;
				localTime += Time.deltaTime;
			}
			c.a = 1;

			SceneManager.LoadScene("TitleScreen");
		}
	}
}
