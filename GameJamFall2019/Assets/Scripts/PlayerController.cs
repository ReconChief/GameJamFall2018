using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace GameJam2018 {
	public class PlayerController : MonoBehaviour {
		[SerializeField] private PlayerMoveSettings moveSettings;

		private new Rigidbody rigidbody;
		private Animator animator;

		private float horizontal;
		private float vertical;
		private Vector3 desiredVelocity;

		public void Awake() {
			if (moveSettings == null)
				moveSettings = ScriptableObject.CreateInstance<PlayerMoveSettings>();

			rigidbody = GetComponent<Rigidbody>();
			animator = GetComponent<Animator>();
		}

		public void FixedUpdate() {
			Vector3 currentVelocity = rigidbody.velocity;

			desiredVelocity.Set(horizontal, 0, vertical);
			desiredVelocity *= moveSettings.JogSpeed;

			rigidbody.AddForce(desiredVelocity - currentVelocity, ForceMode.VelocityChange);
		}

		public void Update() {
			horizontal = Input.GetAxis("Horizontal");
			vertical = Input.GetAxis("Vertical");


		}
	}
}