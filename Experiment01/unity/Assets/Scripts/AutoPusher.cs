using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoPusher : MonoBehaviour {

	public static bool AKeyDown = false;
	public static bool AutoSpaceKeyDown = false;
	float pushTime = 0.5f;
	float time = 0.0f;

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		if(Input.GetKeyDown(KeyCode.A) && AKeyDown == false) {
			AKeyDown = true;
			time = 0.0f;
			Debug.Log("Auto Mode");
		} else if(AKeyDown == true) {
			if(ObjectMotion.SpaceKeyDown == false && GetResp.resp == false) {
				time += Time.deltaTime;
				if(time > pushTime) {
					AutoSpaceKeyDown = true;
					time = 0.0f;
				}
			}
		}
	}
}
