using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Main : MonoBehaviour {

	public GameObject ModeSelectText;
	public GameObject StartText;
	public GameObject TrialText;
	public GameObject EndText;
	public GameObject FixedSphere;
	public GameObject RightBar;
	public GameObject LeftBar;

	public static int mode = 0;
	public static int phase = 0;
	float ConsVelTime = 3.0f; // 回転開始から等速回転までの時間
	public static int nowTrial = 0;
	int nTrials = 40; // 実験のトライアル数
	public static int stage = 0;
	public static float hight = 10.0f; // オブジェクト類を配置する高さ
	public static float depth = 1.0f; // オブジェクト類のカメラからの距離
	float Rightposition = 0.1227f; // FixedSphereからRightBarまでの距離 約3deg
	float Leftposition = -0.1227f; // FixedSphereからLeftBarまでの距離 約3deg
	public static double RightInitRo = 0.0; // RightBarの初期角度
	public static double LeftInitRo = 0.0; // LeftBarの初期角度
	public static bool permitResp = false; // 観察者の応答を許可する
	int rangeAngle = 45; // 初期角度の範囲

	System.Random rand = new System.Random();

	// Use this for initialization
	void Start () {}
	
	void ObjectSetActivate() {
		RightBar.transform.position = new Vector3(Rightposition, hight, depth);
		RightBar.transform.rotation = Quaternion.Euler(0, 0, 0);
		LeftBar.transform.position = new Vector3(Leftposition, hight, depth);
		LeftBar.transform.rotation = Quaternion.Euler(0, 0, 0);

		if(mode == 1) {
			if(rand.NextDouble() < 0.5) {
				RightInitRo = Math.Round(rand.NextDouble() * rangeAngle, 1);
			} else {
				RightInitRo = Math.Round(rand.NextDouble() * -rangeAngle, 1);
			}

			if(rand.NextDouble() < 0.5) {
				LeftInitRo = Math.Round(rand.NextDouble() * rangeAngle, 1);
			} else {
				LeftInitRo = Math.Round(rand.NextDouble() * -rangeAngle, 1);
			}
		} else if(mode == 2) {
			if(rand.NextDouble() < 0.5) {
				RightInitRo = Math.Round(rand.NextDouble() * rangeAngle, 1);
			} else {
				RightInitRo = Math.Round(rand.NextDouble() * -rangeAngle, 1);
			}
			LeftInitRo = -RightInitRo;
		}

		RightBar.transform.RotateAround(new Vector3(0, hight, depth), Vector3.forward, (float)RightInitRo);
		LeftBar.transform.RotateAround(new Vector3(0, hight, depth), Vector3.forward, (float)LeftInitRo);

		FixedSphere.SetActive(true);
		RightBar.SetActive(true);
		LeftBar.SetActive(true);
	}

	void ObjectOff() {
		FixedSphere.SetActive(false);
		RightBar.SetActive(false);
		LeftBar.SetActive(false);
	}

	void DoTrial() {
		if(stage == 0) {
			TrialText.GetComponent<TextMesh>().text = (nowTrial + 1).ToString() + " / " + nTrials.ToString();
			TrialText.SetActive(true);
			permitResp = true;
			stage++;
		} else if(stage == 1) {
			if(GetLeftResp.leftResp | GetRightResp.rightResp) {
				TrialText.SetActive(false);
				GetLeftResp.leftResp = false;
				GetRightResp.rightResp = false;
				ObjectSetActivate();
				stage++;
			}
		} else if(stage == 2) {
			if(GetLeftResp.leftResp | GetRightResp.rightResp) {
				GetLeftResp.leftResp = false;
				GetRightResp.rightResp = false;
				ObjectOff();
				permitResp = false;
				nowTrial++;
				stage = 0;
			}
		}
	}
	
	// Update is called once per frame
	void Update () {
		if(phase == 0) {
			if(mode == 0 & Input.GetKeyDown(KeyCode.Alpha1)) {
				mode = 1;
			} else if(mode == 0 & Input.GetKeyDown(KeyCode.Alpha2)) {
				mode = 2;
			} else if(mode != 0) {
				ModeSelectText.SetActive(false);
				StartText.SetActive(true);
				OutputResult.output(phase, 0, 0);
				phase++;
			}
		} else if(phase == 1) {
			if(Timer.nowTime > ConsVelTime) {
				StartText.SetActive(false);
				phase++;
			}
		} else if(phase == 2) {
			if(nowTrial != nTrials) {
				DoTrial();
			} else {
				EndText.SetActive(true);
				phase++;
			}
		}
	}
}
