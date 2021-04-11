using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Timer : MonoBehaviour {

	public static float nowTime = 0.0f;
	bool sKeyDown = false;

	// Use this for initialization
	void Start () {}
	
	// Update is called once per frame
	void Update () {
		if(!sKeyDown & Input.GetKeyDown(KeyCode.S)) {
			sKeyDown = true;
			Debug.Log("Start Timer");
		} else if(sKeyDown) {
			if(Input.GetKeyDown(KeyCode.R)) {
				nowTime = 0.0f;
				sKeyDown = false;
				Debug.Log("Reset Timer");
			} else {
				nowTime += Time.deltaTime;
			}
		}
	}
}
