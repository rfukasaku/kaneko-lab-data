using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Timer : MonoBehaviour {

    public static float nowTime = 0.0f;
    float equalSpeedTime = 12.0f;
    float fiveSecBeforeDownSpeed = 427.0f;
    float downSpeedTime = 432.0f;
    float endTime = 444.0f;
    bool sKeyDown = false;
    int phase = 0;

	// Use this for initialization
	void Start () {	
	}
	
	// Update is called once per frame
	void Update () {
        if(Input.GetKeyDown(KeyCode.S) && sKeyDown == false) {
            sKeyDown = true;
            nowTime = 0.0f;
            phase = 0;
            Debug.Log("Rotation Start");
        } else if(Input.GetKeyDown(KeyCode.R) && sKeyDown == true) {
            sKeyDown = false;
            nowTime = 0.0f;
            Debug.Log("Emergency Reset Timer!");
        } else if(sKeyDown == true) {
            nowTime += Time.deltaTime;
            if(nowTime > equalSpeedTime && phase == 0) {
                Debug.Log("Equal Speed");
                phase++;
            } else if(nowTime > fiveSecBeforeDownSpeed && phase == 1) {
                Debug.Log("5sec before DownSpeed");
                phase++;
            } else if(nowTime > downSpeedTime && phase == 2) {
                Debug.Log("Down Speed");
                phase++;
            } else if(nowTime > endTime && phase == 3) {
                Debug.Log("Rotation End");
                sKeyDown = false;
                nowTime = 0.0f;
            }
        }
	}
}
