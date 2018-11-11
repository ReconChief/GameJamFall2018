using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PixelEngine;
using PixelEngine.Combat;
using PixelEngine.Mobs;

namespace GameJam2018 {
	public class Enemy : MonoBehaviour, IMortal {
		private static readonly AnimationParameter AttackId = "Attack";

		[SerializeField] private float stopDistance = 0.3f;

		[Header(PixelEngineConstants.AnimatedOnlyProperties)]
		[Range(0, 1)]
		[SerializeField] private float movementFactor = 1;

		private Animator animator;
		private new Rigidbody rigidbody;
		private Status status;

		private Vector3 desiredVelocity;

		public Status Status {
			get { return status; }
		}

		public GameObject GetGameObject() {
			return gameObject;
		}

		public Transform GetTransform() {
			return transform;
		}

		public MonoBehaviour GetMonoBehaviour() {
			return this;
		}

		public void Awake() {
			animator = GetComponent<Animator>();
			rigidbody = GetComponent<Rigidbody>();
			status = new Status();
		}

		public void FixedUpdate() {
			Vector3 currentVelocity = rigidbody.velocity;

			desiredVelocity = movementFactor * transform.forward;
			desiredVelocity.y = currentVelocity.y;

			rigidbody.AddForce(desiredVelocity - currentVelocity, ForceMode.VelocityChange);
		}

		public void Update() {
			Vector3 worldPos = transform.position;
			Vector3 playerPos = GameController.Player.transform.position;
			Vector3 xzForward = playerPos - worldPos + stopDistance * Vector3.Normalize(worldPos - playerPos);
			xzForward.y = 0;
			transform.forward = xzForward;
		}

		public DamageInfo ModifyIncomingDamage(DamageInfo finalDamage) {
			return finalDamage;
		}

		public DamageInfo ModifyOutgoingDamage(DamageInfo finalDamage) {
			return finalDamage;
		}

		public void OnTriggerEnter(Collider other) {
			if (other.gameObject == GameController.Player.gameObject) {
				GameController.ReturnPlayer();
			}
		}

		public void Attack() {
			animator.SetTrigger(AttackId);
		}
	}
}