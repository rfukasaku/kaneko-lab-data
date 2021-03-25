%
% ShowCorrcoef.m
% 
% 1. 眼球変位の傾きが正または負のときの、傾きの平均値を取得する
% 2. 頭部変位の傾きが正または負のときの、傾きの平均値を算出する
% 3. 眼球変位と頭部変位の相関関係をプロットする
%
function ShowCorrcoef
  % File Index
  RF_fixline_filenames = [
    "RF/RF_fixline_20201219", ...
    "RF/RF_fixline_20201219_2", ...
    "RF/RF_fixline_20201219_3", ...
    "RF/RF_fixline_20201219_4", ...
    "RF/RF_fixline_20201219_5", ...
    "RF/RF_fixline_20201219_6", ...
    "RF/RF_fixline_20201219_7", ...
    "RF/RF_fixline_20201219_8"];
  RH_fixline_filenames = [
    "RH/RH_fixline_20201223", ...
    "RH/RH_fixline_20201218_2", ...
    "RH/RH_fixline_20201218_3", ...
    "RH/RH_fixline_20201218_4", ...
    "RH/RH_fixline_20201223_2", ...
    "RH/RH_fixline_20201223_3", ...
    "RH/RH_fixline_20201223_4", ...
    "RH/RH_fixline_20201223_5"];
  RA_fixline_filenames = [
    "RA/RA_fixline_20201221", ...
    "RA/RA_fixline_20201221_2", ...
    "RA/RA_fixline_20201221_3", ...
    "RA/RA_fixline_20201221_4", ...
    "RA/RA_fixline_20201222", ...
    "RA/RA_fixline_20201222_2", ...
    "RA/RA_fixline_20201223", ...
    "RA/RA_fixline_20201222_4"];
  AM_fixline_filenames = [
    "AM/AM_fixline_20201222", ...
    "AM/AM_fixline_20201222_2", ...
    "AM/AM_fixline_20201222_3", ...
    "AM/AM_fixline_20201222_4", ...
    "AM/AM_fixline_20201223", ...
    "AM/AM_fixline_20201223_2", ...
    "AM/AM_fixline_20201223_3", ...
    "AM/AM_fixline_20201223_4"];
  HKo_fixline_filenames = [
    "HKo/HKo_fixline_20201225", ...
    "HKo/HKo_fixline_20201225_2", ...
    "HKo/HKo_fixline_20201225_3", ...
    "HKo/HKo_fixline_20201224", ...
    "HKo/HKo_fixline_20201224_2", ...
    "HKo/HKo_fixline_20201224_3", ...
    "HKo/HKo_fixline_20201224_4", ...
    "HKo/HKo_fixline_20201224_5"]; % 3回分のデータを修正
  
  % Settings
  conf_threshold = 0.6;
  fileNames = RF_fixline_filenames;
  
  tic

  all_fitting_eye_parameters = [];
  all_fitting_head_parameters = [];

  for fileName = fileNames
    filePath = strcat('Results/', fileName, '_exdata.txt');
    fileID = fopen(filePath);
    N = 5;
    C_header = textscan(fileID, '%s', N);
    C = textscan(fileID,'%d %f %f %f %f');
    % 5th onset_time
    onset_time = C{1,5};

    filePath = strcat('Results/', fileName, '_eyedata.txt');
    fileID = fopen(filePath);
    N = 11;
    C_header = textscan(fileID, '%s', N);
    C = textscan(fileID, '%f %f %f %f %f %f %f %f %f %f %f');
    % 3rd gaze_normal_left_x
    % 6th gaze_normal_right_x
    % 10th gaze_confidence
    % 11th time
    eyepos = C{1,6};
    eyeconf = C{1,10};
    eyetime = C{1,11};
    
    % gaze_confidenceがconf_threshold未満のときは、ひとつ前のデータをeyeposを引き継ぐようにする
    for i = 1:length(eyepos)
      if i ~= 1
        if eyeconf(i) < conf_threshold
          eyepos(i) = eyepos(i-1);
        end
      end
    end
    smooth_eyepos = movmean(eyepos, 100);

    filePath = strcat('Results/', fileName, '_headdata.txt');
    fileID = fopen(filePath);
    N = 2;
    C_header = textscan(fileID, '%s', N);
    C = textscan(fileID, '%f %f');
    % 1st ro_y
    % 2nd time
    headpos = C{1,1};
    headtime = C{1,2};
    smooth_headpos = movmean(headpos, 100);

    % 開始時点の眼球位置がトライアルによって違うので、刺激呈示前100msの平均をベースラインとして計算
    for i = 1:length(onset_time)
      [~, eyetime_index(i)] = min(abs(eyetime - onset_time(i)));
      eachtrial_baseline_eyepos(i) = mean(smooth_eyepos(eyetime_index(i)-9:eyetime_index(i))); % 90Hzサンプリングだと仮定して、100ms分
      eachtrial_eyedata(i,:) = smooth_eyepos(eyetime_index(i):eyetime_index(i)+45) - eachtrial_baseline_eyepos(i); % 90Hzサンプリングだと仮定して、500ms分
    end

    % 刺激オンセットから呈示時間500msの眼球位置データ(ベースラインから)を1次関数にフィッティング
    eachtrial_time = linspace(0, 0.5, length(eachtrial_eyedata(1,:)));
    for i = 1:length(onset_time)
      fitting_eye_parameters(i,:) = polyfit(eachtrial_time, eachtrial_eyedata(i,:), 1); % 1次関数でフィッティング
    end

    % 開始時点の頭部位置がトライアルによって違うので、刺激呈示前100msの平均をベースラインとして計算
    for i = 1:length(onset_time)
      [~, headtime_index(i)] = min(abs(headtime - onset_time(i)));
      eachtrial_baseline_headpos(i) = mean(smooth_headpos(headtime_index(i)-9:headtime_index(i))); % 90Hzサンプリングだと仮定して、100ms分
      eachtrial_headdata(i,:) = smooth_headpos(headtime_index(i):headtime_index(i)+45) - eachtrial_baseline_headpos(i); % 90Hzサンプリングだと仮定して、500ms分
    end

    % 刺激オンセットから呈示時間500msの頭部位置データ(ベースラインから)を1次関数にフィッティング
    eachtrial_time = linspace(0, 0.5, length(eachtrial_headdata(1,:)));
    for i = 1:length(onset_time)
      fitting_head_parameters(i,:) = polyfit(eachtrial_time, eachtrial_headdata(i,:), 1); % 1次関数でフィッティング
    end

    all_fitting_eye_parameters = [all_fitting_eye_parameters; fitting_eye_parameters(:,1)];
    all_fitting_head_parameters = [all_fitting_head_parameters; fitting_head_parameters(:,1)];
  end

  % ハズレ値(>2SD)を取り除く
  all_fitting_eye_parameters_in2sd = [];
  all_fitting_head_parameters_in2sd = [];
  exclusion_count = 0;
  sd = std(all_fitting_eye_parameters);
  for i = 1:length(all_fitting_eye_parameters)
    if abs(all_fitting_eye_parameters(i)) < 2 * sd
      all_fitting_eye_parameters_in2sd = [all_fitting_eye_parameters_in2sd; all_fitting_eye_parameters(i)];
      all_fitting_head_parameters_in2sd = [all_fitting_head_parameters_in2sd; all_fitting_head_parameters(i)];
    else
      exclusion_count = exclusion_count + 1;
    end
  end
  disp("exclusion_count: " + exclusion_count);

  % 単位をdeg/secに変更する
  all_fitting_eye_parameters_in2sd = rad2deg(atan(all_fitting_eye_parameters_in2sd));

  % 眼球変位の傾きが正または負のときの、傾きの平均値を取得する
  plus_slope_average = 0;
  plus_slope_count = 0;
  minus_slope_average = 0;
  minus_slope_count = 0;
  for i = 1:length(all_fitting_eye_parameters_in2sd)
    if all_fitting_eye_parameters_in2sd(i) > 0
      plus_slope_average = plus_slope_average + all_fitting_eye_parameters_in2sd(i);
      plus_slope_count = plus_slope_count + 1;
    else
      minus_slope_average = minus_slope_average + all_fitting_eye_parameters_in2sd(i);
      minus_slope_count = minus_slope_count + 1;
    end
  end
  plus_slope_average = plus_slope_average / plus_slope_count;
  minus_slope_average = minus_slope_average / minus_slope_count;
  disp('eye');
  disp("plus_slope_average: " + plus_slope_average + ", plus_slope_count: " + plus_slope_count);
  disp("minus_slope_average: " + minus_slope_average + ", minus_slope_count: " + minus_slope_count);

  % 頭部変位の傾きが正または負のときの、傾きの平均値を取得する
  plus_slope_average = 0;
  plus_slope_count = 0;
  minus_slope_average = 0;
  minus_slope_count = 0;
  for i = 1:length(all_fitting_head_parameters_in2sd)
    if all_fitting_head_parameters_in2sd(i) > 0
      plus_slope_average = plus_slope_average + all_fitting_head_parameters_in2sd(i);
      plus_slope_count = plus_slope_count + 1;
    else
      minus_slope_average = minus_slope_average + all_fitting_head_parameters_in2sd(i);
      minus_slope_count = minus_slope_count + 1;
    end
  end
  plus_slope_average = plus_slope_average / plus_slope_count;
  minus_slope_average = minus_slope_average / minus_slope_count;
  disp('head');
  disp("plus_slope_average: " + plus_slope_average + ", plus_slope_count: " + plus_slope_count);
  disp("minus_slope_average: " + minus_slope_average + ", minus_slope_count: " + minus_slope_count);

  % 相関係数を求める
  R = corrcoef(all_fitting_head_parameters_in2sd,all_fitting_eye_parameters_in2sd);
  disp("corrcoef: " + R(1, 2));

  figure('Name','Head & Eye Slope');
  hold on
  x = all_fitting_head_parameters_in2sd;
  y = all_fitting_eye_parameters_in2sd;
  b1 = x\y;
  yCalc1 = b1*x;
  scatter(x, y);
  plot(x,yCalc1);
  set(gca,'fontsize',16);
  xline(0);
  yline(0);
  xlabel('Head slope [deg/sec]');
  ylabel('Eye slope [deg/sec]');
  hold off

  toc
end
