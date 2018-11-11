using UnityEngine;
using UnityEngine.SceneManagement;

namespace GameJam2018 {
	public class MenuManager : MonoBehaviour {
		private static MenuManager instance;

		public void Awake() {
			if (instance != null && instance != this) {
				DestroyImmediate(gameObject);
				return;
			}
			instance = this;
		}

		#region Button Methods
		public void StartGame() {
			SceneManager.LoadScene("Game");
		}
		#endregion
	}
}