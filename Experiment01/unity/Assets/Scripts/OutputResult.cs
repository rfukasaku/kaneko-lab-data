using System;
using System.IO;
using System.Text;
using UnityEngine;

public class OutputResult {

    static int nowTrial = 0;
    static string fileName = "test";
    
    public static void output(int mode, int resp) {
        Encoding enc = Encoding.GetEncoding("Shift_JIS");
        nowTrial = ObjectMotion.nowTrial;

        if (mode == 0) {
            StreamWriter writer = new StreamWriter(@"Results/" + fileName + ".txt", false, enc);
            writer.WriteLine("trial right left ratio whichRight resp time");
            writer.Close();
            Debug.Log("Complete Writing Header");
        } else {
            StreamWriter writer = new StreamWriter(@"Results/" + fileName + ".txt", true, enc);
            writer.WriteLine(nowTrial.ToString() + " " + ObjectMotion.rightwardsSpeed[nowTrial].ToString() + " " + ObjectMotion.leftwardsSpeed[nowTrial].ToString() + " " +  ObjectMotion.speedRatio[nowTrial].ToString() + " " + ObjectMotion.whichRight[nowTrial].ToString() + " " + resp.ToString() + " " + ObjectMotion.appearTime.ToString());
            writer.Close();
            Debug.Log("Complete Writing Parameter");
        }
    }
}
