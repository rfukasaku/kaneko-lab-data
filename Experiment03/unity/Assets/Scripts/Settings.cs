using UnityEngine;

public class Settings
{
    public static Vector3 topBeltPosition = new Vector3(0, 0.1f, 1);
    public static Vector3 bottomBeltPosition = new Vector3(0, -0.1f, 1);
    public static float beltBaseSpeed = 12.0f; // [deg/s] Default: 12.0f
    public static float movingOneWayTime = 1.0f; // 片道の時間[sec] Default: 1.0f
    public static float stimulusPresentationTime = 0.5f; // 刺激提示時間[sec] Default: 0.5f
    public static double initialRatio = 2.5; // Default: 2.5
    public static double ratioStep = 0.1; // Default: 0.1
    public static int consecutiveCorrentAnswers = 2; // 次のratioへ移動するために必要な連続正解数
    public static int trials = 40; // Default: 40
    public static int shotCount = 4; // ベースとなる反復回数 Default: 4
}