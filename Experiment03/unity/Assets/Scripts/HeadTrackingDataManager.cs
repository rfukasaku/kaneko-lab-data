using System.IO;
using UnityEngine;

public class HeadTrackingDataManager : MonoBehaviour
{
    public Transform MainCameraTransform;
    private static string filePath;
    private static StreamWriter writer;
    private static bool isRecording;

    public static void InitializeDataFile(string fileName)
    {
        // Resultsフォルダが存在しないときは作成する
        string folderPath = Application.dataPath + "/Results";
        if (!Directory.Exists(folderPath))
        {
            DirectoryInfo di = new DirectoryInfo(folderPath);
            di.Create();
        }
        filePath = Application.dataPath + $"/Results/{fileName}_headdata.txt";
        FileInfo fi = new FileInfo(filePath);
        string header = "ro_y time";
        using (StreamWriter sw = fi.CreateText())
        {
            sw.WriteLine(header);
            sw.Close();
        }
    }

    private async void WriteData()
    {
        string data = $"{TransformAngle180(MainCameraTransform.eulerAngles.y)} {Time.time}";
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

    // [0, 360]degから[-180, 180]degへ変換する
    private static float TransformAngle180(float angle)
    {
        if (angle > 180)
        {
            return angle - 360;
        }
        return angle;
    } 

    void Start()
    {
        isRecording = false;
    }


    void Update()
    {
        if (isRecording)
        {
            WriteData();
        }
    }
}
