using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PixelEngine;

namespace GameJam2018 {
	public class PlayerController : MonoBehaviour {
		private static readonly AnimationParameter IsMovingId = "Is Moving";
		private static readonly AnimationParameter FinalMovementSpeedId = "Final Movement Speed";
		private static readonly AnimationParameter AttackId = "Attack";

		private const float AttackUnjoggableTime = 0.6f;

		[SerializeField] private PlayerMoveSettings moveSettings;
		[SerializeField] private PlayerCamera playerCameraPrefab;

		[Header(PixelEngineConstants.AnimatedOnlyProperties)]
		[Range(0, 1)]
		[SerializeField] private float movementFactor = 1;

		private PlayerCamera camera;
		private new Rigidbody rigidbody;
		private Animator animator;

		private float horizontal;
		private float vertical;
		private Vector3 desiredVelocity;
		private float finalMovementSpeed;
		private float timeLastAttacked;

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
			desiredVelocity.Normalize();
			desiredVelocity = camera.XZOrientation.TransformDirection(desiredVelocity);

			Vector3 currentForward = transform.forward;

			//Used to make the player turn faster when making them switch directions
			float fDotI = Vector3.Dot(currentForward, desiredVelocity); //Current forward dotted with the new movement direction
			float additionalTurnFactor = (fDotI < -0.8f) ? 2 : 1;

			transform.forward = Vector3.Lerp(currentForward, desiredVelocity, moveSettings.TurnLerpSpeed * additionalTurnFactor * Time.fixedDeltaTime);
			desiredVelocity *= finalMovementSpeed;

			desiredVelocity.y = currentVelocity.y;

			rigidbody.AddForce(desiredVelocity - currentVelocity, ForceMode.VelocityChange);
		}

		public void Update() {
			horizontal = Input.GetAxis("Horizontal");
			vertical = Input.GetAxis("Vertical");

			if (Input.GetKeyDown(KeyCode.Mouse0)) {
				Attack();
			}

			UpdateFinalMovementSpeed();
			UpdateContinuousAnimatorParameters();
		}

		private void Attack() {
			animator.SetTrigger(AttackId);
			timeLastAttacked = Time.time;
		}

		private void UpdateFinalMovementSpeed() {
			finalMovementSpeed = moveSettings.JogSpeed * Mathf.Max(Mathf.Abs(horizontal), Mathf.Abs(vertical));
			finalMovementSpeed *= movementFactor;
		}

		private void UpdateContinuousAnimatorParameters() {
			animator.SetFloat(FinalMovementSpeedId, finalMovementSpeed);
			animator.SetBool(IsMovingId, finalMovementSpeed > 0
				&& Time.time - timeLastAttacked > AttackUnjoggableTime); //For later when we add attacks
		}
	}
}