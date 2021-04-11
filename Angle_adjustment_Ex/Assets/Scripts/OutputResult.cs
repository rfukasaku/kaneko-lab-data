using UnityEngine;
using System;
using System.IO;
using System.Text;

public class OutputResult {

	static string fileName = "hogehoge";

	public static double AngleConversion(double RespRo) {
		if(RespRo > 180.0) {
			return Math.Round(RespRo - 360.0, 1);
		} else {
			return RespRo;
		}
	}

	public static void output(int phase, double LeftRespRo, double RightRespRo) {
		Encoding enc = Encoding.GetEncoding("Shift_JIS");
		
		if(phase == 0) {
			StreamWriter writer = new StreamWriter(@"Results/" + fileName + ".txt", false, enc);
			writer.WriteLine("trial LeftInitRo RightInitRo LeftRespRo RightRespRo time");
			writer.Close();
			Debug.Log("Make a file");
		} else if(phase == 2) {
			StreamWriter writer = new StreamWriter(@"Results/" + fileName + ".txt", true, enc);
			writer.WriteLine(Main.nowTrial.ToString() + " "
							 + Main.LeftInitRo.ToString() + " "
							 + Main.RightInitRo.ToString() + " "
							 + AngleConversion(LeftRespRo).ToString() + " "
							 + AngleConversion(RightRespRo).ToString() + " "
							 + Math.Round(Timer.nowTime, 1).ToString());
			writer.Close();
		}
	}
}
