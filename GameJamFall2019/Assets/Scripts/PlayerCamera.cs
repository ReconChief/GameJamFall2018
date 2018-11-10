using UnityEngine;
using PixelEngine;

namespace GameJam2018 {
	public class PlayerCamera : MonoBehaviour {
		[SerializeField] private CameraMoveSettings moveSettings;

		private PlayerController target;


		private float cameraHorizontal;
		private float cameraVertical;
		private float cameraDolly;

		private float currentDistance;
		private float targetDistance;

		private Vector3 currentEulerAngles;
		private Vector3 targetEulerAngles;
		private Quaternion currentRotation;
		private Quaternion targetRotation;
		private Vector3 deltaRotation;

		private CursorMovementMode cursorMovementMode;
		private Transform xzOrientation;

		private Vector3 focusPosition;

		public PlayerController Target {
			get { return target; }
			set {
				target = value;
				if (target == null) {

				} else {
					targetEulerAngles.Set(30, target.transform.eulerAngles.y, 0);
				}
			}
		}

		public CursorMovementMode CursorMovementMode {
			get { return cursorMovementMode; }
			set {
				if (value == CursorMovementMode.ScreenUI) {
					Cursor.visible = true;
					Cursor.lockState = CursorLockMode.None;
				} else {
					Cursor.visible = false;
					Cursor.lockState = CursorLockMode.Locked;
				}
				cursorMovementMode = value;
			}
		}

		public Transform XZOrientation {
			get { return xzOrientation; }
		}

		public void Awake() {
			if (moveSettings == null)
				moveSettings = ScriptableObject.CreateInstance<CameraMoveSettings>();

			xzOrientation = new GameObject("XZ Orientation").transform;
			xzOrientation.SetParent(transform);
			xzOrientation.localPosition = Vector3.zero;
			xzOrientation.eulerAngles = new Vector3(0, transform.eulerAngles.y, 0);
		}

		public void Start() {
			CursorMovementMode = CursorMovementMode.WorldMovement;
		}

		public void Update() {
			if (target == null)
				return;
			SetTargetPosition();
			cameraHorizontal = cameraVertical = 0;

			if (Input.GetKeyDown(KeyCode.LeftControl) || Input.GetKeyDown(KeyCode.RightControl))
				ToggleCursorMovementMode();
			if (Input.GetKeyDown(KeyCode.Mouse2))
				ResetPositioning();

			cameraDolly = Input.GetAxis("Mouse ScrollWheel");
			targetDistance = Mathf.Clamp(targetDistance - cameraDolly * moveSettings.DollySensitivity * Time.deltaTime, moveSettings.MinDistance, moveSettings.MaxDistance);
			currentDistance = Mathf.Lerp(currentDistance, targetDistance, moveSettings.DistanceLerpSpeed * Time.deltaTime);

			if (cursorMovementMode == CursorMovementMode.WorldMovement) {
				cameraHorizontal = Input.GetAxis("Mouse X");
				cameraVertical = -Input.GetAxis("Mouse Y");

				ApplyRotationOffset(cameraHorizontal, cameraVertical, ref targetEulerAngles, true);

				targetRotation = Quaternion.Euler(targetEulerAngles);
				targetEulerAngles = targetRotation.eulerAngles;

				currentRotation = Quaternion.Lerp(currentRotation, targetRotation, moveSettings.RotationLerpSpeed);

				Vector3 newEulerAngles = currentRotation.eulerAngles;
				deltaRotation = newEulerAngles - currentEulerAngles;

				currentEulerAngles = newEulerAngles;
				transform.rotation = currentRotation;
			}

			xzOrientation.eulerAngles = new Vector3(0, currentEulerAngles.y, 0);

			UpdateThirdPersonCameraPos();
			CheckCameraCollisions();
		}

		public void ApplyRotationOffset(float cameraHorizontal, float cameraVertical, ref Vector3 target, bool applyCameraRotationLimits) {
			float deltaEulerAngleX = cameraHorizontal * moveSettings.TumbleSensitivity * Time.deltaTime;
			float deltaEulerAngleY = cameraVertical * moveSettings.TumbleSensitivity * Time.deltaTime;
			if (applyCameraRotationLimits) {
				target.y = MathUtil.EnsureAngleIs0To360(target.y + deltaEulerAngleX);
				target.x = MathUtil.EnsureAngleIs0To360(target.x + deltaEulerAngleY);

				if (target.x > moveSettings.MaxXRotation && target.x <= 180)
					target.x = moveSettings.MaxXRotation;
				else if (target.x < 360 - moveSettings.MaxXRotation && target.x > 180)
					target.x = 360 - moveSettings.MaxXRotation;
			} else {
				target.y += deltaEulerAngleX;
				target.x += deltaEulerAngleY;
			}
		}

		private void SetTargetPosition() {
			focusPosition = target.transform.position + Vector3.up;

			Vector3 focusOffset = moveSettings.FocusOffset;
			if (focusOffset != Vector3.zero) {
				float xzInfluenceFactor = (Vector3.Dot(transform.forward, target.transform.forward) + 1) / 2;
				focusPosition += target.transform.TransformDirection(new Vector3(xzInfluenceFactor * focusOffset.x, focusOffset.y, xzInfluenceFactor * focusOffset.z));
			}
		}

		public void ResetPositioning() {
			targetDistance = moveSettings.DefaultDistance;
			targetEulerAngles.Set(30, target.transform.eulerAngles.y, 0);
			xzOrientation.rotation = Quaternion.Euler(0, xzOrientation.eulerAngles.y, 0);

			UpdateThirdPersonCameraPos();
			CheckCameraCollisions();
		}

		private void UpdateThirdPersonCameraPos() {
			//NOTE: -cosx is also used as cos(x + 180°), and same with -sinx for sin(x + 180°)
			float cosx = Mathf.Cos(Mathf.Deg2Rad * currentEulerAngles.x);
			float siny = Mathf.Sin(Mathf.Deg2Rad * currentEulerAngles.y);
			float sinx = Mathf.Sin(Mathf.Deg2Rad * currentEulerAngles.x);

			Vector3 offset = new Vector3(
				currentDistance * -cosx * siny,
				-currentDistance * -sinx,
				0
			);

			float args = currentDistance * currentDistance * cosx * cosx;
			args *= 1 - siny * siny;

			offset.z = (currentEulerAngles.y < 270 && currentEulerAngles.y > 90) ? Mathf.Sqrt(args) : -Mathf.Sqrt(args);

			transform.position = focusPosition + offset;
		}

		private void CheckCameraCollisions() {
			Vector3 position = transform.position;
			Vector3 direction = position - focusPosition;
			float magnitude = direction.magnitude;
			Vector3 normalizedDir = direction / magnitude;

			Ray ray = new Ray(focusPosition, normalizedDir);
			RaycastHit hit;
			//if (Physics.Raycast(ray, out hit, magnitude + 0.05f, blockingLayers)) {
			//	transform.position = focusPosition + (hit.distance - 1.3f) * normalizedDir;
			//}
			if (Physics.SphereCast(ray, moveSettings.BlockDistance, out hit, magnitude + 0.05f, moveSettings.BlockingLayers)) {
				transform.position = focusPosition + (hit.distance) * normalizedDir;
			}
		}

		private void ToggleCursorMovementMode() {
			if (CursorMovementMode == CursorMovementMode.ScreenUI)
				CursorMovementMode = CursorMovementMode.WorldMovement;
			else
				CursorMovementMode = CursorMovementMode.ScreenUI;
		}

		public void OnDrawGizmosSelected() {
			Color defaultColor = Gizmos.color;

			if (moveSettings != null) {
				Gizmos.color = new Color(0.2f, 0.8f, 1, 0.8f);
				Gizmos.DrawWireSphere(transform.position, moveSettings.BlockDistance);
			}

			Gizmos.color = defaultColor;
		}
	}
}