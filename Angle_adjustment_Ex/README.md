# Angle adjustment Ex

## 概要
これは2019年3月に作成した心理物理学実験のプログラムです。
左右の眼球それぞれにバーを提示し、観察者はこの2本のバーを水平になるように角度を調節します。
2本のバーは左右を独立して動かすことも、同時に動かすこともできます。
このプログラムは、観察者が回転椅子に座り、回転中に各トライアルを行うことを想定しています。

## 動作環境
- PC
  - Alienware M14XR2(CPU: IntelCore i7-3630QM CPU @2.4GHz, Memory: 8.0GB, Graphics: GeForce GT650M, OS: Windows8 64bit)
- エンジン
  - Unity 2018.2.14f1 (64-bit)
- ヘッドマウントディスプレイ
  - HTC VIVE
- ワイヤレスアダプター
  - TPCAST wireless adapter for VIVE

## 仕様
- 固定点の周りを棒が回転する
- 棒は固定点の左右に1つずつ
- 左の棒は左目に、右の棒は右目にレンダリングする(固定点は両眼にレンダリング)
- 実験プラグラム開始直後に以下を選択できる
  - 片方のコントローラーで片方の棒を動かす(mode: 1)
  - 片方のコントローラーで両方の棒を動かす(mode: 2)
- modeを選択後、回転開始から等速回転になるまでStartTextを表示する
- 回転椅子のスタートと同時にキーボードのSキーを押すことで秒数カウントスタート。加速時間終了後、自動でStartTextが消え、トライアルがスタートする
- キーボードのRキーで秒数をリセットする
- 棒の開始角度はランダム
- コントローラのトリガーを引くことで応答確定、次のトライアルへ進む
- 応答が確定して次のトライアルへ進む際に残りのトライアル数を表示する

## 使用方法
### Step1 プログラムをダウンロードする
画像の赤矢印のボタンから、Angle adjustment ExのUnityプログラムをダウンロードする。

![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img001.png)

### Step2 Unityを起動する
ダウンロードしたZIPファイルを展開した後、Unityを起動し、展開されたフォルダー"Angle-adjustment-Ex-master"を選択する。

![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img002.png)
![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img003.png)

### Step3 出力されるファイル名を変更する
Assets内のScriptsフォルダの中にある"OutputResult.cs"を開き、8行目のfileNameを書き換える。

![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img004.png)
![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img005.png)

### Step4 各種パラメータを変更する
Assets内のScriptsフォルダの中にある"Main.cs"を開き、各種パラメータを書き換える。
- 18行目の"ConsVelTime"は、回転開始から等速回転までの時間(3秒に設定するなら"3.0f")
- 20行目の"nTrials"は、実行するトライアル数

![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img006.png)

### Step5 HMDを起動する。
ヘッド・マウント・ディスプレイを起動する。

※HTC VIVE以外のHMDでは正しく動作しない可能性があります。

### Step6 実験を開始する
画像の赤矢印のボタンで、プログラムを開始する。

![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img007.png)

### Step7 モードを選択する
キーボードの"1"または"2"のキーを押してモードを選択する。

※もし、キーを押しても反応しないときは、プログラム開始ボタンの横にある一時停止ボタンを押して数秒待つ。その後再び一時停止ボタンを押してプログラムを再開すると反応するようになる。

### Step8 トライアルを開始する
モードを選択すると、画像のような状態になる。キーボードの"S"キーを押すことで、数秒後にトライアルが開始される。

※もし、キーを押しても反応しないときは、プログラム開始ボタンの横にある一時停止ボタンを押して数秒待つ。その後再び一時停止ボタンを押してプログラムを再開すると反応するようになる。

※トライアル開始までの秒数はStep4の"ConsVelTime"で設定した値になる。回転椅子を用いる場合、回転椅子のスタートスイッチとキーボードの"S"キーを同時に押すことで、非同期に回転開始からの秒数を記録することができる。

![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img008.png)

### Step9 トライアルを進行する
トライアルは以下2つを交互に行いながら進行する。
1. トライアルの進行状況が"●●/●●"の形式で表示される。 → 観察者はトリガーを引いて次へ進む。
2. 固視点と、その左右にバーが表示される。 → 観察者はコントローラでバーの角度を調節し、トリガーを引いて応答を確定する。

![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img009.png)

### Step10 実験を終了する
画像のように「すべてのトライアルが終了しました。」と表示されれば実験終了です。赤矢印のボタンを押してプログラムを終了してください。実験結果は"Angle-adjustment-Ex-master"内の"Results"フォルダにtxtファイル形式で出力されています。結果の見方については後述の「詳細」をご覧ください。

![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/usage_img010.png)

## 詳細
![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/detail_img001.png)
![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/detail_img002.png)
![](https://github.com/Fukky21/kaneko-lab-data/blob/images/Angle_adjustment_Ex/detail_img003.png)
