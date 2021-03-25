using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetResp : MonoBehaviour {

    public static bool resp;

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		SteamVR_TrackedObject trackedObject = GetComponent<SteamVR_TrackedObject>();
		var device = SteamVR_Controller.Input((int)trackedObject.index);

        if(ObjectMotion.phase == 0) {
            if(device.GetPressDown(SteamVR_Controller.ButtonMask.Touchpad)) {
				Vector2 touchPosition = device.GetAxis();
				if(touchPosition.y > 0) {
					Debug.Log("Press UP");
				} else if(touchPosition.y < 0){
					Debug.Log("Press DOWN");
				}
			} else if(device.GetPressDown(SteamVR_Controller.ButtonMask.Trigger)) {
				Debug.Log("Pull Trigger");
			}
		}
        if(ObjectMotion.SpaceKeyDown == true) {
            if(device.GetPressDown(SteamVR_Controller.ButtonMask.Touchpad)) {
				Vector2 touchPosition = device.GetAxis();
				resp = true;
				ObjectMotion.SpaceKeyDown = false;
				if(touchPosition.y > 0) {
					Debug.Log("Press UP");
					OutputResult.output(1, 0);
				} else if(touchPosition.y < 0){
					Debug.Log("Press DOWN");
					OutputResult.output(1 ,1);
				}
			} else if(device.GetPressDown(SteamVR_Controller.ButtonMask.Trigger)) {
				resp = true;
				ObjectMotion.SpaceKeyDown = false;
				Debug.Log("Pull Trigger");
				OutputResult.output(1, -1);
			}
        }
	}
}
