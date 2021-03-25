using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using Valve.VR;

public class Main : MonoBehaviour
{
    public SteamVR_Input_Sources HandType;
    public SteamVR_Action_Boolean RespUp;
    public SteamVR_Action_Boolean RespDown;
    public SteamVR_Action_Boolean RespTrigger;
    public Text GuideText;
    public GameObject FixationPoint;
    public GameObject TopBelt;
    public GameObject BottomBelt;
    System.Random rnd;
    private Transform fixationPointTransform;
    private Transform topBeltTransform;
    private Transform bottomBeltTransform;
    private string filePath;
    private StreamWriter writer;
    private int phase = 0;
    private int step = 0;
    private int currentTrial = 1;
    private double currentRatio;
    private float currentBeltSpeedToRight;
    private float currentBeltSpeedToLeft;
    private bool currentRespUp;
    private int currentCorrect = 0;
    private bool topBeltMoveToRight;
    private bool fixationPointMoveToRight;
    private float time = 0;
    private float localTime = 0;
    private float onsetTime = 0;

    void Start()
    {
        rnd = new System.Random();
        fixationPointTransform = FixationPoint.transform;
        topBeltTransform = TopBelt.transform;
        bottomBeltTransform = BottomBelt.transform;
        PupilLabs.EyeTrackingDataManager.InitializeDataFile();
        InitializeExDataFile();
    }

    
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            PupilLabs.EyeTrackingDataManager.StopRecording();
            writer.Close();
            Application.Quit();
        }

        if (phase == 0) // キャリブレーション終了後～実験開始
        {
            if (RespUp.GetState(HandType) || RespDown.GetState(HandType))
            {
                PupilLabs.EyeTrackingDataManager.StartRecording();
                writer = new StreamWriter(filePath, true);
                GuideText.text = $"{currentTrial}/{Settings.trials}";
                GuideText.enabled = true;
                currentRatio = Settings.initialRatio;
                phase++;
            }
        }
        else if (phase == 1) // 実験中
        {
            DoExperiment();
            time += Time.deltaTime;
        }
        else if (phase == 2) // 実験終了直後
        {
            PupilLabs.EyeTrackingDataManager.StopRecording();
            writer.Close();
            GuideText.text = $"Finish!\n\nLast Ratio: {Math.Abs(currentRatio)}";
            GuideText.enabled = true;
            phase++;
        }
        // phase == 3 すべての処理が完了
    }

    int ConvertBoolToInt(bool b)
    {
        if (b)
        {
            return 1;
        }
        return 0;
    }

    float Tan(float x)
    {
        return (float)Math.Tan(x * (Math.PI / 180));
    }

    Type[] FisherYates<Type>(Type[] arr)
    {
        int n = arr.Length;
        for (int i = n - 1; i > 0; i--)
        {
            int j = (int)Math.Floor(rnd.NextDouble() * (i + 1));
            Type tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
        }
        return arr;
    }

    void InitializeExDataFile()
    {
        // Resultsフォルダが存在しないときは作成する
        string folderPath = Application.dataPath + "/Results";
        if (!Directory.Exists(folderPath))
        {
            DirectoryInfo di = new DirectoryInfo(folderPath);
            di.Create();
        }
        filePath = Application.dataPath + $"/Results/{Settings.fileName}_exdata.txt";
        FileInfo fi = new FileInfo(filePath);
        string header = "trial ratio fixpoint_movetoright topbelt_movetoright respup onsettime";
        using (StreamWriter sw = fi.CreateText())
        {
            sw.WriteLine(header);
            sw.Close();
        }
    }

    private async void WriteExData()
    {
        string data = "";
        data += $"{currentTrial} {currentRatio} {ConvertBoolToInt(fixationPointMoveToRight)}";
        data += $" {ConvertBoolToInt(topBeltMoveToRight)} {ConvertBoolToInt(currentRespUp)}";
        data += $" {onsetTime}";
        await writer.WriteLineAsync(data);
    }

    Dictionary<string, float> ConvertRatioToSpeed(double ratio)
    {

        double fast = Settings.beltBaseSpeed * Math.Sqrt(Math.Pow(2, Math.Abs(ratio)));
        double slow = Settings.beltBaseSpeed / Math.Sqrt(Math.Pow(2, Math.Abs(ratio)));

        if (ratio > 0)
        {
            return new Dictionary<string, float>() {
                {"speedToLeft", (float)Math.Round(slow, 1)},
                {"speedToRight", (float)Math.Round(fast, 1)}
            };
        }
        else
        {
            return new Dictionary<string, float>() {
                {"speedToLeft", (float)Math.Round(fast, 1)},
                {"speedToRight", (float)Math.Round(slow, 1)}
            };
        }
    }

    private void DoExperiment()
    {
        if (step == 0) // トライアル数を表示中
        {
            if (RespTrigger.GetState(HandType))
            {
                // 次のratio(絶対値)を決定する
                if (currentCorrect == Settings.consecutiveCorrentAnswers)
                {
                    // 規定回数連続で正答した場合は次のstepへ以降する
                    currentCorrect = 0;
                    currentRatio = Math.Round(Math.Abs(currentRatio) - Settings.ratioStep, 1);
                    if (!(currentRatio > 0))
                    {
                        currentRatio = Math.Round(Settings.ratioStep, 1);
                    }
                }
                // 次のratioの符号を決定する
                if (rnd.NextDouble() < 0.5)
                {
                    currentRatio = -currentRatio;
                }
                // 次のベルトの速度を決定する
                currentBeltSpeedToLeft = ConvertRatioToSpeed(currentRatio)["speedToLeft"];
                currentBeltSpeedToRight = ConvertRatioToSpeed(currentRatio)["speedToRight"];
                // fixationPointMoveToRightを決定する
                if (rnd.NextDouble() < 0.5)
                {
                    fixationPointMoveToRight = false;
                }
                else
                {
                    fixationPointMoveToRight = true;
                }
                // topBeltMoveToRightを決定する
                if (rnd.NextDouble() < 0.5)
                {
                    topBeltMoveToRight = false;
                }
                else
                {
                    topBeltMoveToRight = true;
                }
                // FixationPointの初期位置を決定する
                if (fixationPointMoveToRight)
                {
                    fixationPointTransform.localPosition = new Vector3(-Tan(Settings.fixationPointInitialPosition), 0, 1);
                }
                else
                {
                    fixationPointTransform.localPosition = new Vector3(Tan(Settings.fixationPointInitialPosition), 0, 1);
                }
                GuideText.enabled = false;
                FixationPoint.SetActive(true);
                step++;
            }
        }
        else if (step == 1) // 固視点移動中, ベルト未表示
        {
            if (fixationPointMoveToRight)
            {
                fixationPointTransform.Translate(Tan(Settings.fixationPointSpeed) * Time.deltaTime, 0, 0);
            }
            else
            {
                fixationPointTransform.Translate(-Tan(Settings.fixationPointSpeed) * Time.deltaTime, 0, 0);
            }

            localTime += Time.deltaTime;
            if (localTime > Settings.stimulusPresentationWaitingTime)
            {
                onsetTime = time;
                localTime = 0;
                TopBelt.SetActive(true);
                BottomBelt.SetActive(true);
                step++;
            }
        }
        else if (step == 2) // 固視点移動中, ベルト表示中
        {
            if (fixationPointMoveToRight)
            {
                fixationPointTransform.Translate(Tan(Settings.fixationPointSpeed) * Time.deltaTime, 0, 0);
            }
            else
            {
                fixationPointTransform.Translate(-Tan(Settings.fixationPointSpeed) * Time.deltaTime, 0, 0);
            }

            if (topBeltMoveToRight)
            {
                topBeltTransform.Translate(Tan(currentBeltSpeedToRight) * Time.deltaTime, 0, 0);
                bottomBeltTransform.Translate(-Tan(currentBeltSpeedToLeft) * Time.deltaTime, 0, 0);
            }
            else
            {
                topBeltTransform.Translate(-Tan(currentBeltSpeedToLeft) * Time.deltaTime, 0, 0);
                bottomBeltTransform.Translate(Tan(currentBeltSpeedToRight) * Time.deltaTime, 0, 0);
            }

            localTime += Time.deltaTime;
            if (localTime > Settings.stimulusPresentationTime)
            {
                FixationPoint.SetActive(false);
                TopBelt.SetActive(false);
                BottomBelt.SetActive(false);
                step++;
            }
        }
        else if (step == 3) // 応答待ち
        {
            if (RespUp.GetState(HandType))
            {
                currentRespUp = true;
                WriteExData();
                step++;
            }

            if (RespDown.GetState(HandType))
            {
                currentRespUp = false;
                WriteExData();
                step++;
            }
        }
        else if (step == 4) // トライアル終了判定 OR 階段法処理
        {
            if (currentTrial == Settings.trials) // 規定のトライアル数を終えたら終了
            {
                phase++;
            }
            else
            {
                // 応答が正解かどうかチェックする
                if (currentRatio > 0)
                {
                    // 右へ動く刺激の方が速いとき
                    if (topBeltMoveToRight == currentRespUp)
                    {
                        currentCorrect++;
                    }
                    else
                    {
                        // 間違えていたとき
                        currentCorrect = 0;
                        currentRatio = Math.Abs(currentRatio) + Settings.ratioStep;
                    }
                }
                else
                {
                    // 左へ動く刺激の方が速いとき
                    if (topBeltMoveToRight != currentRespUp)
                    {
                        currentCorrect++;
                    }
                    else
                    {
                        // 間違えていたとき
                        currentCorrect = 0;
                        currentRatio = Math.Abs(currentRatio) + Settings.ratioStep;
                    }
                }
                // 初期化処理
                topBeltTransform.localPosition = new Vector3(0, 0.1f, 1);
                bottomBeltTransform.localPosition = new Vector3(0, -0.1f, 1);
                localTime = 0;
                currentTrial++;
                GuideText.text = $"{currentTrial}/{Settings.trials}";
                GuideText.enabled = true;
                step = 0;
            }
        }
    }
}
