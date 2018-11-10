using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PixelEngine;

namespace GameJam2018 {
	public class PlayerController : MonoBehaviour {
		private static readonly AnimationParameter IsMovingId = "Is Moving";
		private static readonly AnimationParameter FinalMovementSpeedId = "Final Movement Speed";

		[SerializeField] private PlayerMoveSettings moveSettings;
		[SerializeField] private PlayerCamera playerCameraPrefab;

		//[Header(PixelEngineConstants.AnimatedOnlyProperties)]
		//[Range(0, 1)]
		//[SerializeField] private float movementFactor = 1

		private PlayerCamera camera;
		private new Rigidbody rigidbody;
		private Animator animator;

		private float horizontal;
		private float vertical;
		private Vector3 desiredVelocity;
		private float finalMovementSpeed;

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

			desiredVelocity *= finalMovementSpeed;
			desiredVelocity = camera.XZOrientation.TransformDirection(desiredVelocity);

			rigidbody.AddForce(desiredVelocity - currentVelocity, ForceMode.VelocityChange);
		}

		public void Update() {
			horizontal = Input.GetAxis("Horizontal");
			vertical = Input.GetAxis("Vertical");

			//Debating whether or not to do this with physics too... hm...
			if (desiredVelocity.sqrMagnitude > 0.01f)
				transform.forward = Vector3.Lerp(transform.forward, desiredVelocity.normalized, moveSettings.TurnLerpSpeed * Time.deltaTime);

			UpdateFinalMovementSpeed();
			UpdateContinuousAnimatorParameters();
		}

		private void UpdateFinalMovementSpeed() {
			finalMovementSpeed = moveSettings.JogSpeed * Mathf.Max(Mathf.Abs(horizontal), Mathf.Abs(vertical));
		}

		private void UpdateContinuousAnimatorParameters() {
			animator.SetFloat(FinalMovementSpeedId, finalMovementSpeed);
			animator.SetBool(IsMovingId, finalMovementSpeed > 0);
				//&& Time.time - timeLastAttacked > AttackUnjoggableTime); //For later when we add attacks
		}
	}
}