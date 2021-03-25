using System.IO;
using UnityEngine;

namespace PupilLabs
{
    public class EyeTrackingDataManager : MonoBehaviour
    {
        public GazeController gazeController;
        public SubscriptionsController subscriptionsController;
        private PupilListener pupilListener;
        private bool isGazing = false;
        private static string filePath;
        private static StreamWriter writer;
        private static bool isRecording;
        private float pupilConfidence;
        private float pupilDiameter;
        private bool isBinocular;
        private Vector3 gazeNormalLeft;
        private Vector3 gazeNormalRight;
        private float gazeConfidence;
        private float time;

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
            if (pupilListener == null)
            {
                pupilListener = new PupilListener(subscriptionsController);
            }
            pupilListener.Enable();
            pupilListener.OnReceivePupilData += ReceivePupilData;

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
            pupilListener.Disable();
            pupilListener.OnReceivePupilData -= ReceivePupilData;

            if (!isGazing || !enabled)
            {
                Debug.Log("Nothing to stop.");
                return;
            }

            isGazing = false;
            gazeController.OnReceive3dGaze -= ReceiveGaze;
        }

        void ReceivePupilData(PupilData pupilData)
        {
            pupilConfidence = pupilData.Confidence;
            pupilDiameter = pupilData.Diameter;
        }

        void ReceiveGaze(GazeData gazeData)
        {   
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

        public static void InitializeDataFile()
        {
            // Resultsフォルダが存在しないときは作成する
            string folderPath = Application.dataPath + "/Results";
            if (!Directory.Exists(folderPath))
            {
                DirectoryInfo di = new DirectoryInfo(folderPath);
                di.Create();
            }
            filePath = Application.dataPath + $"/Results/{Settings.fileName}_eyedata.txt";
            FileInfo fi = new FileInfo(filePath);
            string header = "";
            header += "pupil_diameter pupil_confidence";
            header += " gaze_normal_left_x gaze_normal_left_y gaze_normal_left_z";
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
            data += $"{pupilDiameter} {pupilConfidence}";
            data += $" {gazeNormalLeft.x} {gazeNormalLeft.y} {gazeNormalLeft.z}";
            data += $" {gazeNormalRight.x} {gazeNormalRight.y} {gazeNormalRight.z}";
            data += $" {ConvertBoolToInt(isBinocular)} {gazeConfidence}";
            data += $" {time}";
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
            time = 0;
            isBinocular = false;
            isRecording = false;
        }

        void Update()
        {
            if (isRecording)
            {
                time += Time.deltaTime;
                WriteData();
            }
        }
    }
}