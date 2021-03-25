using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace PupilLabs
{
    public class EyeTrackingDataManager : MonoBehaviour
    {
        public GazeController gazeController;
        public TimeSync timeSync;
        private bool isGazing = false;
        private static string filePath;
        private static StreamWriter writer;
        private static bool isRecording;
        private bool isBinocular;
        private Vector3 gazeNormalLeft;
        private Vector3 gazeNormalRight;
        private float gazeConfidence;
        private double unityTime;

        int ConvertBoolToInt(bool b)
        {
            if (b)
            {
                return 1;
            }
            return 0;
        }

        void OnEnable()
        {
            if (gazeController == null)
            {
                Debug.LogWarning("Required GazeController missing");
                enabled = false;
                return;
            }

            if (isGazing)
            {
                Debug.Log("Already gazing!");
                return;
            }

            gazeController.OnReceive3dGaze += ReceiveGaze;
            isGazing = true;
        }
        
        void OnDisable()
        {
            if (!isGazing || !enabled)
            {
                Debug.Log("Nothing to stop.");
                return;
            }

            isGazing = false;
            gazeController.OnReceive3dGaze -= ReceiveGaze;
        }

        void ReceiveGaze(GazeData gazeData)
        {   
            unityTime = timeSync.ConvertToUnityTime(gazeData.PupilTimestamp);

            if (gazeData.MappingContext != GazeData.GazeMappingContext.Binocular)
            {
                isBinocular = false;
            }
            else
            {
                isBinocular = true;
            }

            gazeConfidence = gazeData.Confidence;

            if (gazeData.IsEyeDataAvailable(0))
            {
                gazeNormalLeft = gazeData.GazeNormal0;
            }

            if (gazeData.IsEyeDataAvailable(1))
            {
                gazeNormalRight = gazeData.GazeNormal1;
            }
        }

        public static void InitializeDataFile(string fileName)
        {
            // Resultsフォルダが存在しないときは作成する
            string folderPath = Application.dataPath + "/Results";
            if (!Directory.Exists(folderPath))
            {
                DirectoryInfo di = new DirectoryInfo(folderPath);
                di.Create();
            }
            filePath = Application.dataPath + $"/Results/{fileName}_eyedata.txt";
            FileInfo fi = new FileInfo(filePath);
            string header = "";
            header += "gaze_normal_left_x gaze_normal_left_y gaze_normal_left_z";
            header += " gaze_normal_right_x gaze_normal_right_y gaze_normal_right_z";
            header += " is_binocular gaze_confidence";
            header += " time";
            using (StreamWriter sw = fi.CreateText())
            {
                sw.WriteLine(header);
                sw.Close();
            }
        }

        private async void WriteData()
        {
            string data = "";
            data += $"{gazeNormalLeft.x} {gazeNormalLeft.y} {gazeNormalLeft.z}";
            data += $" {gazeNormalRight.x} {gazeNormalRight.y} {gazeNormalRight.z}";
            data += $" {ConvertBoolToInt(isBinocular)} {gazeConfidence}";
            data += $" {unityTime}";
            await writer.WriteLineAsync(data);
        }

        public static void StartRecording()
        {
            writer = new StreamWriter(filePath, true);
            isRecording = true;
        }

        public static void StopRecording()
        {
            isRecording = false;
            writer.Close();
        }

        void Start()
        {
            isBinocular = false;
            isRecording = false;
            unityTime = 0;
        }

        void Update()
        {
            if (isRecording)
            {
                WriteData();
            }
        }
    }
}