using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class GetRightResp : MonoBehaviour {

	public GameObject RightBar;
	public GameObject LeftBar;

	public static bool rightResp = false;
	float changeAngleUnit = 0.1f;

	// Use this for initialization
	void Start () {}
	
	// Update is called once per frame
	void Update () {
		SteamVR_TrackedObject trackedObject = GetComponent<SteamVR_TrackedObject>();
		var device = SteamVR_Controller.Input((int)trackedObject.index);

		if(Main.permitResp & Main.stage == 1) {
			if(device.GetPressDown(SteamVR_Controller.ButtonMask.Trigger)) {
				rightResp = true;
			}
		} else if(Main.permitResp & Main.stage == 2) {
			if(device.GetPress(SteamVR_Controller.ButtonMask.Touchpad)) {
				Vector2 touchPosition = device.GetAxis();
				if(touchPosition.y > 0) {
					RightBar.transform.RotateAround(new Vector3(0, Main.hight, Main.depth), Vector3.forward, changeAngleUnit);
					if(Main.mode == 2) {
						LeftBar.transform.RotateAround(new Vector3(0, Main.hight, Main.depth), Vector3.forward, -changeAngleUnit);
					}
				} else if(touchPosition.y < 0) {
					RightBar.transform.RotateAround(new Vector3(0, Main.hight, Main.depth), Vector3.forward, -changeAngleUnit);
					if(Main.mode == 2) {
						LeftBar.transform.RotateAround(new Vector3(0, Main.hight, Main.depth), Vector3.forward, changeAngleUnit);
					}
				}
			} else if(device.GetPressDown(SteamVR_Controller.ButtonMask.Trigger)) {
				rightResp = true;
				OutputResult.output(Main.phase, Math.Round(LeftBar.transform.eulerAngles.z, 1), Math.Round(RightBar.transform.eulerAngles.z, 1));
			}
		}
	}
}
