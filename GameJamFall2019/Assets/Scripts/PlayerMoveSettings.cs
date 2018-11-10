using UnityEngine;

namespace GameJam2018 {
	[CreateAssetMenu(fileName = "New Player Move Settings", menuName = "Game Jam 2018/Player Move Settings")]
	public class PlayerMoveSettings : ScriptableObject {
		[SerializeField] private float jogSpeed = 5;

		public float JogSpeed {
			get { return jogSpeed; }
		}
	}
}