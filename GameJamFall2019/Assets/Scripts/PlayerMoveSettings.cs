using UnityEngine;

namespace GameJam2018 {
	[CreateAssetMenu(fileName = "New Player Move Settings", menuName = GameJamConstants.CreateAssetMenu + "Player Move Settings")]
	public class PlayerMoveSettings : ScriptableObject {
		[SerializeField] private float jogSpeed = 5;
		[SerializeField] private float turnLerpSpeed = 10;

		public float JogSpeed {
			get { return jogSpeed; }
		}

		public float TurnLerpSpeed {
			get { return turnLerpSpeed; }
		}
	}
}