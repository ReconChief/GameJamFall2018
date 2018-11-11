using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace GameJam2018 {
	[RequireComponent(typeof(AudioSource))]
	public class BGMLoop : MonoBehaviour {
		private const float ScheduleTime = 5; //Seconds before scheduling next loop

		[SerializeField] private float restartTime = 0;
		//[SerializeField] private float crossFadeDuration = 0.3f;

		private AudioSource[] sources;
		private int currentIndex = 0;
		private float clipLength;

		public void OnValidate() {
			AudioSource a = GetComponent<AudioSource>();
			restartTime = Math.Min(Math.Max(restartTime, 0), a.clip.length); //Clamp with doubles

			//crossFadeDuration = Mathf.Max(0, crossFadeDuration);
		}

		public void Awake() {
			sources = new AudioSource[2];
			sources[0] = GetComponent<AudioSource>();

			sources[0].loop = false;

			sources[1] = new GameObject("Music Looper", typeof(AudioSource)).GetComponent<AudioSource>();
			sources[1].transform.SetParent(transform);
			sources[1].transform.localPosition = Vector3.zero;
			sources[1].transform.localRotation = Quaternion.identity;

			sources[1].loop = false;
			sources[1].clip = sources[0].clip;
			sources[1].outputAudioMixerGroup = sources[0].outputAudioMixerGroup;
			sources[1].minDistance = sources[0].minDistance;
			sources[1].maxDistance = sources[0].maxDistance;

			clipLength = sources[0].clip.length;
			sources[currentIndex].time = 0;
			sources[currentIndex].Play();

			//StartCoroutine(LoopCoroutine());
		}
		
		//For now, I assume the song goes till the end of the AudioClip.
		//Ouch, writing this hurt. And it didn't work well.
		/*private IEnumerator LoopCoroutine() {
			double songDuration = 5; //sources[0].clip.length;
			double loopDuration = sources[0].clip.length - restartTime;
			double halfSongDuration = songDuration / 2;
			double halfLoopDuration = loopDuration / 2;

			int i = 0;
			sources[i].time = sources[0].clip.length - 5; //songDuration - 5;
			//sources[i].Play();

			//StartCoroutine(Fade(sources[i], 1, 0, crossFadeDuration, halfSongDuration - crossFadeDuration));
			//StartCoroutine(Fade(sources[1 - i], 0, 1, crossFadeDuration, halfSongDuration - crossFadeDuration));
			yield return new WaitForSeconds((float) halfSongDuration);

			sources[1 - i].time = (float) restartTime;
			sources[1 - i].PlayScheduled(AudioSettings.dspTime + halfSongDuration);
			yield return new WaitForSeconds((float) halfSongDuration);

			i = 1 - i; //Switches to next source by index
			//StartCoroutine(Fade(sources[i], 1, 0, crossFadeDuration, halfSongDuration - crossFadeDuration));
			//StartCoroutine(Fade(sources[1 - i], 0, 1, crossFadeDuration, halfSongDuration - crossFadeDuration));
			//yield break;
			while (isActiveAndEnabled) {
				yield return new WaitForSeconds((float) halfLoopDuration);

				//half-time preparation for next scheduled play
				sources[1 - i].time = (float) restartTime;
				sources[1 - i].PlayScheduled(AudioSettings.dspTime + halfLoopDuration);

				yield return new WaitForSeconds((float) halfLoopDuration);

				//new song switch
				i = 1 - i;
				//StartCoroutine(Fade(sources[i], 1, 0, crossFadeDuration, halfLoopDuration - crossFadeDuration));
				//StartCoroutine(Fade(sources[1 - i], 0, 1, crossFadeDuration, halfLoopDuration - crossFadeDuration));
			}
		}

		private IEnumerator Fade(AudioSource source, float startVolume, float endVolume, float duration, float initialDelay = 0) {
			yield return null;
			//source.volume = startVolume;
			yield return new WaitForSeconds(initialDelay);
			float localTime = 0;
			float delta = endVolume - startVolume;
			while (localTime < duration) {
				//Debug.Log(System.Array.IndexOf(sources, source));
				source.volume = startVolume + (localTime / duration) * delta;
				yield return null;
				localTime += Time.deltaTime;
			}
			source.volume = endVolume;
		}
		*/

		//MUST use either coroutine with WaitForFixedUpdate OR FixedUpdate, for controlled time more suitable for precise audio
		//Update and coroutines don't cut it.
		public void FixedUpdate() {
			if (sources[currentIndex].time >= clipLength - ScheduleTime) {
				sources[1 - currentIndex].time = restartTime - 0.05f; //0.05 to make it start just a tiny bit before the actual looping part, so we can hear it start.. "nicer" I suppose
				sources[1 - currentIndex].PlayScheduled(AudioSettings.dspTime + (clipLength - sources[currentIndex].time));
			}
			if (!sources[currentIndex].isPlaying) {
				currentIndex = 1 - currentIndex;
			}
		}
	}
}