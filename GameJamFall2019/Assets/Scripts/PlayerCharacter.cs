﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PixelEngine;
using PixelEngine.Combat;
using PixelEngine.Mobs;

namespace GameJam2018
{
    public class PlayerCharacter : MonoBehaviour, IMortal
    {
        private static readonly AnimationParameter AttackTagId = "Attack";
        private const float FallCheckInterval = 0.8f;
        private const float FallCheckYValue = -30;

        [SerializeField] private float impactHitSpeed = 5;

        private Animator animator;
        private new Rigidbody rigidbody;
        private WeaponController weaponController;
        private Status status;
        public AudioClip warp;
        public AudioClip damagesfx;
        AudioSource audio;
        public Status Status
        {
            get { return status; }
        }

        private bool CanHaveHitboxesActivated
        {
            get
            {
                if (animator.IsInTransition(0))
                {
                    return animator.GetNextAnimatorStateInfo(0).tagHash == AttackTagId;
                }
                return animator.GetCurrentAnimatorStateInfo(0).tagHash == AttackTagId;
            }
        }

        public GameObject GetGameObject()
        {
            return gameObject;
        }

        public Transform GetTransform()
        {
            return transform;
        }

        public MonoBehaviour GetMonoBehaviour()
        {
            return this;
        }

        public void Awake()
        {
            audio = GetComponent<AudioSource>();
            animator = GetComponent<Animator>();
            rigidbody = GetComponent<Rigidbody>();
            weaponController = GetComponentInChildren<WeaponController>();
            status = new Status();
            status.MaxHealth = 10;
            status.HealthRegenRate = 0;
            status.onDamaged += OnDamaged;
            status.onDefeated += OnDefeated;

            StartCoroutine(FallCheckCoroutine());
        }

        public DamageInfo ModifyIncomingDamage(DamageInfo baseInDamage)
        {
            return baseInDamage;
        }

        public DamageInfo ModifyOutgoingDamage(DamageInfo baseOutDamage)
        {
            return baseOutDamage;
        }

        private void OnDamaged(DamageInfo finalDamage)
        {
            Vector3 xzDir = transform.position - finalDamage.Collision.contacts[0].point;
            xzDir.y = 0;
            xzDir.Normalize();
            rigidbody.AddForce(xzDir * impactHitSpeed, ForceMode.VelocityChange);
            audio.PlayOneShot(damagesfx, 1.0f);
            //OnDefeated(finalDamage);
            //Debug.Log();
        }

        private void OnDefeated(DamageInfo finalDamage)
        {
            StartCoroutine(Ugh());
        }

        //</3 :'(
        private IEnumerator Ugh()
        {
            yield return null;
            status.ResetOnRespawn(this); //Resets the health
            GameController.ReturnPlayer();
        }

        private IEnumerator FallCheckCoroutine()
        {
            WaitForSeconds waitInstruction = new WaitForSeconds(FallCheckInterval);
            while (isActiveAndEnabled)
            {
                yield return waitInstruction;
                if (transform.position.y < FallCheckYValue)
                {
                    audio.PlayOneShot(warp, 0.2f);
                    GameController.ReturnPlayer();
                }

            }
        }

        /// <summary>
        /// Makes sure that Hitboxes get deactivated when the Animator's state machine goes OUT of an attack AnimationState.
        /// This ensures Hitboxes never get "glitched on" from weird/quick transitioning and stuff.
        /// </summary>
        private IEnumerator HitboxAnimationCheck()
        {
            float localTime = 0; //For now, I'ma just have it check for 7 seconds afterwards. You never know what infinite boolean loops can do...
            while (weaponController.IsActivated && localTime < 7)
            {
                if (!CanHaveHitboxesActivated)
                {
                    DeactivateWeaponHitboxes();
                    yield break;
                }
                yield return null;
                localTime += Time.deltaTime;
            }
        }

        #region Public Animator Methods
        public void ActivateWeaponHitboxes()
        {
            weaponController.ActivateHitboxes();
            StartCoroutine(HitboxAnimationCheck());
        }

        private void DeactivateWeaponHitboxes()
        {
            weaponController.DeactivateHitboxes();
        }

        public void ActivateWeaponHitboxesVisuallyOnly()
        {
            weaponController.DeactivateHitboxes();
            StartCoroutine(HitboxAnimationCheck());
        }
        #endregion

        public void OnDrawGizmosSelected()
        {
            Gizmos.DrawLine(new Vector3(-100, FallCheckYValue, 0), new Vector3(100, FallCheckYValue, 0));
            Gizmos.DrawLine(new Vector3(0, FallCheckYValue, -100), new Vector3(0, FallCheckYValue, 100));
        }
    }
}
