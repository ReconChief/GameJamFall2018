using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace GameJam2018 {
	public class GameController : MonoBehaviour {
		private static GameController instance;

		[SerializeField] private GameObject returnPoint;
		[SerializeField] private Vector2 enemySpawnRange = new Vector2(30, 40);
		[SerializeField] private Enemy[] enemyPrefabs;


		private List<Enemy> spawnedEnemies = new List<Enemy>(16);
		private PlayerCharacter player;

		public static PlayerCharacter Player {
			get { return instance.player; }
		}

		public void Awake() {
			if (instance != null && instance != this) {
				DestroyImmediate(gameObject);
				return;
			}
			instance = this;

			player = GameObject.FindWithTag("Player").GetComponent<PlayerCharacter>();
		}

		public void Start() {
			StartCoroutine(Spawner());
		}

		private IEnumerator Spawner() {
			while (isActiveAndEnabled) {
				SpawnEnemies();
				yield return new WaitForSeconds(2f);
			}
		}

		public void Update() {
			
		}

		private void SpawnEnemies() {
			spawnedEnemies.Add(GameObject.Instantiate(enemyPrefabs[0].gameObject, GetRandomEnemyPosition(enemySpawnRange), Quaternion.identity).GetComponent<Enemy>());
		}

		/// <summary>
		/// Gets a position in a circle around the world original (around the fog)
		/// </summary>
		private Vector3 GetRandomEnemyPosition(Vector2 distanceRange) {
			float angle = Random.Range(0f, 2 * Mathf.PI);
			Vector3 worldPosition = new Vector3(Mathf.Cos(angle), 0, Mathf.Sin(angle)); //Unit vector
			return worldPosition * Random.Range(distanceRange.x, distanceRange.y) + new Vector3(0, 0.3f, 0);
		}

		public static void ReturnPlayer() {
			instance.player.transform.position = instance.returnPoint.transform.position;
		}

		public void OnDrawGizmosSelected() {
			Color defaultColor = Gizmos.color;

			Gizmos.color = new Color(1, 0.2f, 0, 0.3f);
			Gizmos.DrawWireSphere(Vector3.zero, enemySpawnRange.x);
			Gizmos.color = new Color(1, 0.8f, 0, 0.3f);
			Gizmos.DrawWireSphere(Vector3.zero, enemySpawnRange.y);

			Gizmos.color = defaultColor;
		}
	}
}