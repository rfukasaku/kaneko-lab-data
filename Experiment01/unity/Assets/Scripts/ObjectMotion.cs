using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class ObjectMotion : MonoBehaviour {

    public GameObject AboveSphere;
    public GameObject BelowSphere;
    public GameObject FixedCrossPart1;
    public GameObject FixedCrossPart2;
    public GameObject PracStartText;
    public GameObject StartText;
    public GameObject EndText;

    public static int phase = 0;
    public static int nowTrial = 0;
    int nPracTrials = 3;
    int nTrials = 132; // 11speed ratio * 12repeats
    public static bool SpaceKeyDown = false;
    float baseposition = 2.0f;
    float hAbove = 6.5f;
    float hBelow = 3.5f;
    float distance = 10.0f;
    float[] aboveShift;
    float[] belowShift;
    public static int[] whichRight;
    public static float[] rightwardsSpeed;
    public static float[] leftwardsSpeed;
    public static double[] speedRatio;
    float lifeTime = 1.0f;
    float elapsedTime = 0.0f;
    public static float appearTime = 0.0f;

    float Tan(float x) {
        return (float)Math.Tan(x * (Math.PI / 180));
    }

    void createSpeed() {
        int repeat = 12;
        double baseSpeed = 12.0;
        double[] ratio = new double[] { -0.4, -0.32, -0.24, -0.16, -0.08, 0.0, 0.08, 0.16, 0.24, 0.32, 0.4 };
        // ratioをランダムに並び替えたものを代入する
        double[] rand_ratio = new double[repeat * ratio.Length];
        float[] rightwardsSpeed = new float[repeat * ratio.Length];
        float[] leftwardsSpeed = new float[repeat * ratio.Length];
        int tmp = 0;
        for (int i = 0; i < ratio.Length; i++) {
            for (int j = 0; j < repeat; j++) {
                rand_ratio[tmp++] = ratio[i];
            }
        }
        // Fisher-Yatesアルゴリズムでシャッフルする
        rand_ratio = FisherYates(rand_ratio);
        for (int i = 0; i < rand_ratio.Length; i++) {
            double fast = baseSpeed * Math.Sqrt(Math.Pow(2, Math.Abs(rand_ratio[i])));
            double slow = baseSpeed / Math.Sqrt(Math.Pow(2, Math.Abs(rand_ratio[i])));
            if (rand_ratio[i] > 0) {
                rightwardsSpeed[i] = (float)Math.Round(fast, 1);
                leftwardsSpeed[i] = (float)Math.Round(slow, 1);
            }
            else {
                rightwardsSpeed[i] = (float)Math.Round(slow, 1);
                leftwardsSpeed[i] = (float)Math.Round(fast, 1);
            }
        }
        // 練習トライアルで使用する数値
        float[] pracSpeedRatio = new float[] { 0.0f, 0.0f, 0.0f };
        float[] pracRightwardsSpeed = new float[] { 12.8f, 24.0f, 10.0f };
        float[] pracLeftwardsSpeed = new float[] { 11.2f, 18.0f, 17.0f};

        ObjectMotion.speedRatio = new double[nPracTrials + nTrials];
        ObjectMotion.rightwardsSpeed = new float[nPracTrials + nTrials];
        ObjectMotion.leftwardsSpeed = new float[nPracTrials + nTrials];
        Array.Copy(pracSpeedRatio, ObjectMotion.speedRatio, nPracTrials);
        Array.Copy(rand_ratio, 0, ObjectMotion.speedRatio, nPracTrials, nTrials);
        Array.Copy(pracRightwardsSpeed, ObjectMotion.rightwardsSpeed, nPracTrials);
        Array.Copy(rightwardsSpeed, 0, ObjectMotion.rightwardsSpeed, nPracTrials, nTrials);
        Array.Copy(pracLeftwardsSpeed, ObjectMotion.leftwardsSpeed, nPracTrials);
        Array.Copy(leftwardsSpeed, 0, ObjectMotion.leftwardsSpeed, nPracTrials, nTrials);
    }

    float[] createShift() {
        double shiftAmount = 0.15;
        float[] shift = new float[nPracTrials + nTrials];

        System.Random rnd = new System.Random();
        for (int i = 0; i < nPracTrials + nTrials; i++)
        {
            double rndNum = rnd.NextDouble();
            if (rndNum < 0.333)
            {
                shift[i] = (float)(1.0 - shiftAmount);
            }
            else if (rndNum < 0.666)
            {
                shift[i] = 1.0f;
            }
            else
            {
                shift[i] = (float)(1.0 + shiftAmount);
            }
        }

        return shift;
    }

    void createWhichRight() {
        int[] whichRight = new int[nPracTrials + nTrials];

        System.Random rnd = new System.Random();
        for (int i = 0; i < nPracTrials + nTrials; i++)
        {
            if (rnd.NextDouble() < 0.5)
            {
                whichRight[i] = 0;
            }
            else
            {
                whichRight[i] = 1;
            }
        }
        ObjectMotion.whichRight = new int[nPracTrials + nTrials];
        Array.Copy(whichRight, ObjectMotion.whichRight, nPracTrials + nTrials);
    }

    double[] FisherYates(double[] arr) {
        System.Random rnd = new System.Random();
        int n = arr.Length;
        for (int i = n - 1; i > 0; i--) {
            int j = (int)Math.Floor(rnd.NextDouble() * (i + 1));
            double tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
        }
        return arr;
    }

    void DoTrial() {
        if(AutoPusher.AutoSpaceKeyDown && SpaceKeyDown == false && GetResp.resp == false) {
            SpaceKeyDown = true;
            appearTime = Timer.nowTime;
            if(whichRight[nowTrial] == 0) {
                AboveSphere.transform.position = new Vector3(-baseposition * aboveShift[nowTrial], hAbove, distance);
                BelowSphere.transform.position = new Vector3(baseposition * belowShift[nowTrial], hBelow, distance);
            } else {
                AboveSphere.transform.position = new Vector3(baseposition * aboveShift[nowTrial], hAbove, distance);
                BelowSphere.transform.position = new Vector3(-baseposition * belowShift[nowTrial], hBelow, distance);
            }
            AboveSphere.SetActive(true);
            BelowSphere.SetActive(true);
            elapsedTime = 0.0f;
        } else if(SpaceKeyDown == true && GetResp.resp == false) {
            if(whichRight[nowTrial] == 0) {
                AboveSphere.transform.position += new Vector3(distance * Tan(rightwardsSpeed[nowTrial]) * Time.deltaTime, 0f, 0f);
                BelowSphere.transform.position -= new Vector3(distance * Tan(leftwardsSpeed[nowTrial]) * Time.deltaTime, 0f, 0f);
            } else {
                AboveSphere.transform.position -= new Vector3(distance * Tan(leftwardsSpeed[nowTrial]) * Time.deltaTime, 0f, 0f);
                BelowSphere.transform.position += new Vector3(distance * Tan(rightwardsSpeed[nowTrial]) * Time.deltaTime, 0f, 0f);
            }
            elapsedTime += Time.deltaTime;
            if(elapsedTime > lifeTime) {
                AboveSphere.SetActive(false);
                BelowSphere.SetActive(false);
                FixedCrossPart1.SetActive(false);
                FixedCrossPart2.SetActive(false);
            }
        } else if(GetResp.resp == true) {
            GetResp.resp = false;
            FixedCrossPart1.SetActive(true);
            FixedCrossPart2.SetActive(true);
            AutoPusher.AutoSpaceKeyDown = false;
            nowTrial++;
        }
    }
    // Use this for initialization 
    void Start () {
        createSpeed();
        aboveShift = new float[nPracTrials + nTrials];
        Array.Copy(createShift(), aboveShift, nPracTrials + nTrials);
        belowShift = new float[nPracTrials + nTrials];
        Array.Copy(createShift(), belowShift, nPracTrials + nTrials);
        createWhichRight();
		Debug.Log("Complete Setting");
	}
	
	// Update is called once per frame
	void Update () {
        if(phase == 0) {
            if(Input.GetKeyDown(KeyCode.N)) {
                PracStartText.SetActive(false);
                OutputResult.output(0, 0);
                FixedCrossPart1.SetActive(true);
                FixedCrossPart2.SetActive(true);
                phase++;
            }
        } else if(phase == 1) {
            if(nowTrial != nPracTrials) {
                DoTrial();
            } else {
                FixedCrossPart1.SetActive(false);
                FixedCrossPart2.SetActive(false);
                AutoPusher.AKeyDown = false;
                StartText.SetActive(true);
                phase++;
            }
        } else if(phase == 2) {
            if(Input.GetKeyDown(KeyCode.N)) {
                StartText.SetActive(false);
                FixedCrossPart1.SetActive(true);
                FixedCrossPart2.SetActive(true);
                phase++;
            }
        } else if(phase == 3) {
            if(nowTrial != nPracTrials + nTrials) {
                DoTrial();
            } else {
                FixedCrossPart1.SetActive(false);
                FixedCrossPart2.SetActive(false);
                EndText.SetActive(true);
                phase++;
            }
        }
	}
}
