using UnityEngine;
using UnityEngine.XR;

public class VIVECamFix : MonoBehaviour
{
	[SerializeField] Camera target;

	void Start ()
    {
		target.transform.position = new Vector3(0, 0, 0);
		target.transform.rotation = Quaternion.Euler(0, 0, 0);

		XRDevice.DisableAutoXRCameraTracking(target, true);
	}
	
	void Update () {}
}