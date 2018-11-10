using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace GameJam2018 {
	public class PlayerController : MonoBehaviour {
		[SerializeField] private PlayerMoveSettings moveSettings;
		[SerializeField] private PlayerCamera playerCameraPrefab;

		private PlayerCamera camera;
		private new Rigidbody rigidbody;
		private Animator animator;

		private float horizontal;
		private float vertical;
		private Vector3 desiredVelocity;

		public void Awake() {
			if (moveSettings == null)
				moveSettings = ScriptableObject.CreateInstance<PlayerMoveSettings>();

			camera = GameObject.Instantiate(playerCameraPrefab.gameObject).GetComponent<PlayerCamera>();
			camera.Target = this;

			rigidbody = GetComponent<Rigidbody>();
			animator = GetComponent<Animator>();
		}

		public void FixedUpdate() {
			Vector3 currentVelocity = rigidbody.velocity;

			desiredVelocity.Set(horizontal, 0, vertical);
			desiredVelocity *= moveSettings.JogSpeed;
			desiredVelocity = camera.XZOrientation.TransformDirection(desiredVelocity);
			transform.forward = desiredVelocity;

			rigidbody.AddForce(desiredVelocity - currentVelocity, ForceMode.VelocityChange);
		}

		public void Update() {
			horizontal = Input.GetAxis("Horizontal");
			vertical = Input.GetAxis("Vertical");


		}
	}
}