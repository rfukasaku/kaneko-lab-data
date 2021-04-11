using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class VIVECamFix : MonoBehaviour {

	[SerializeField] Camera target;

	// Use this for initialization
	void Start () {
		target.transform.position = new Vector3(0, 10, 0);
		target.transform.rotation = Quaternion.Euler(0, 0, 0);

		XRDevice.DisableAutoXRCameraTracking(target, true);
	}
	
	// Update is called once per frame
	void Update () {}
}