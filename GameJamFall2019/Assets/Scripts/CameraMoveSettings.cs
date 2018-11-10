using UnityEngine;

namespace GameJam2018 {
	[CreateAssetMenu(fileName = "New Camera Move Settings", menuName = GameJamConstants.CreateAssetMenu + "Camera Move Settings")]
	public class CameraMoveSettings : ScriptableObject {
		[Header("Input & Sensitivity")]
		[SerializeField] private float tumbleSensitivity = 120;
		[SerializeField] private float dollySensitivity = 300;

		[Header("Rotation Settings")]
		[SerializeField] private float rotationLerpSpeed = 10;
		[SerializeField] private float maxXRotation = 70;

		[Header("Distance Settings")]
		[SerializeField] private float distanceLerpSpeed = 0.2f;
		[SerializeField] private float defaultDistance = 5;
		[SerializeField] private float minDistance = 1.7f;
		[SerializeField] private float maxDistance = 7;

		[Header("Camera Settings")]
		[SerializeField] private Vector3 focusOffset = new Vector3(0, 0.65f, 0);
		[SerializeField] private LayerMask blockingLayers;
		[SerializeField] private float blockDistance = 0.8f;

		public float TumbleSensitivity {
			get { return tumbleSensitivity; }
		}

		public float DollySensitivity {
			get { return dollySensitivity; }
		}

		public float RotationLerpSpeed {
			get { return rotationLerpSpeed; }
		}

		public float MaxXRotation {
			get { return maxXRotation; }
		}

		public float DistanceLerpSpeed {
			get { return distanceLerpSpeed; }
		}

		public float DefaultDistance {
			get { return defaultDistance; }
		}

		public float MinDistance {
			get { return minDistance; }
		}

		public float MaxDistance {
			get { return maxDistance; }
		}

		public Vector3 FocusOffset {
			get { return focusOffset; }
		}

		public LayerMask BlockingLayers {
			get { return blockingLayers; }
		}

		public float BlockDistance {
			get { return blockDistance; }
		}
	}
}