using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace GameJam2018 {
	public class OutOfBoundaries : MonoBehaviour {
		public void OnTriggerEnter(Collider other) {
			if (other.gameObject == GameController.Player.gameObject) {
				GameController.ReturnPlayer();
			}
		}
	}
}