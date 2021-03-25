%
% ShowBootstrap_Eye.m
% 
% 眼球左回転時・コントロール条件・眼球右回転時のBootstrapの結果とPSEをチェックする関数
%
function ShowBootstrap_Eye
  warning off all

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
  RF_control_filenames = ["RF/RF_control_20201220"];
  RH_fixline_filenames = [
    "RH/RH_fixline_20201223", ...
    "RH/RH_fixline_20201218_2", ...
    "RH/RH_fixline_20201218_3", ...
    "RH/RH_fixline_20201218_4", ...
    "RH/RH_fixline_20201223_2", ...
    "RH/RH_fixline_20201223_3", ...
    "RH/RH_fixline_20201223_4", ...
    "RH/RH_fixline_20201223_5"];
  RH_control_filenames = ["RH/RH_control_20201223"];
  RA_fixline_filenames = [
    "RA/RA_fixline_20201221", ...
    "RA/RA_fixline_20201221_2", ...
    "RA/RA_fixline_20201221_3", ...
    "RA/RA_fixline_20201221_4", ...
    "RA/RA_fixline_20201222", ...
    "RA/RA_fixline_20201222_2", ...
    "RA/RA_fixline_20201223", ...
    "RA/RA_fixline_20201222_4"];
  RA_control_filenames = ["RA/RA_control_20201222"];
  AM_fixline_filenames = [
    "AM/AM_fixline_20201222", ...
    "AM/AM_fixline_20201222_2", ...
    "AM/AM_fixline_20201222_3", ...
    "AM/AM_fixline_20201222_4", ...
    "AM/AM_fixline_20201223", ...
    "AM/AM_fixline_20201223_2", ...
    "AM/AM_fixline_20201223_3", ...
    "AM/AM_fixline_20201223_4"];
  AM_control_filenames = ["AM/AM_control_20201223"];
  HKo_fixline_filenames = [
  "HKo/HKo_fixline_20201225", ...
  "HKo/HKo_fixline_20201225_2", ...
  "HKo/HKo_fixline_20201225_3", ...
  "HKo/HKo_fixline_20201224", ...
  "HKo/HKo_fixline_20201224_2", ...
  "HKo/HKo_fixline_20201224_3", ...
  "HKo/HKo_fixline_20201224_4", ...
  "HKo/HKo_fixline_20201224_5"];
  HKo_control_filenames = ["HKo/HKo_control_20201224"];

  % Settings
  conf_threshold = 0.6;
  min_range_x = -6.0;
  max_range_x = 6.0;
  color_red = [240/255 79/255 94/255]; % 赤
  color_green = [76/255 239/255 130/255]; % 緑
  color_blue = [76/255 163/255 239/255]; % 青
  eyemove_filenames = RF_fixline_filenames;
  control_filenames = RF_control_filenames;

  tic

  all_fitting_eye_parameters = [];
  all_ratio = [];
  all_top_belt_move_to_right = [];
  all_resp_up = [];
  all_onset_time = [];

  for filename = eyemove_filenames
    filePath = strcat('Results/', filename, '_exdata.txt');
    fileID = fopen(filePath);
    N = 5;
    C_header = textscan(fileID, '%s', N);
    C = textscan(fileID,'%d %f %f %f %f');
    % 2nd ratio
    % 3rd top_belt_move_to_right
    % 4th resp_up
    % 5th onset_time
    ratio = C{1,2};
    top_belt_move_to_right = C{1,3};
    resp_up = C{1,4};
    onset_time = C{1,5};

    filePath = strcat('Results/', filename, '_eyedata.txt');
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

    % delayを考慮
    eyetime = eyetime + 1;

    % gaze_confidenceがconf_threshold未満のときは、ひとつ前のデータをeyeposを引き継ぐようにする
    for i = 1:length(eyepos)
      if i ~= 1
        if eyeconf(i) < conf_threshold
          eyepos(i) = eyepos(i-1);
        end
      end
    end
    smooth_eyepos = movmean(eyepos, 100);

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

    all_fitting_eye_parameters = [all_fitting_eye_parameters; fitting_eye_parameters(:,1)];
    all_ratio = [all_ratio; ratio];
    all_top_belt_move_to_right = [all_top_belt_move_to_right; top_belt_move_to_right];
    all_resp_up = [all_resp_up; resp_up];
    all_onset_time = [all_onset_time; onset_time];
  end

  % ハズレ値(>2SD)を取り除く
  all_fitting_eye_parameters_in2sd = [];
  all_ratio_in2sd = [];
  all_top_belt_move_to_right_in2sd = [];
  all_resp_up_in2sd = [];
  all_onset_time_in2sd = [];
  exclusion_count = 0;
  sd = std(all_fitting_eye_parameters);
  for i = 1:length(all_fitting_eye_parameters)
    if abs(all_fitting_eye_parameters(i)) < 2 * sd
      all_fitting_eye_parameters_in2sd = [all_fitting_eye_parameters_in2sd; all_fitting_eye_parameters(i)];
      all_ratio_in2sd = [all_ratio_in2sd; all_ratio(i)];
      all_top_belt_move_to_right_in2sd = [all_top_belt_move_to_right_in2sd; all_top_belt_move_to_right(i)];
      all_resp_up_in2sd = [all_resp_up_in2sd; all_resp_up(i)];
      all_onset_time_in2sd = [all_onset_time_in2sd; all_onset_time(i)];
    else
      exclusion_count = exclusion_count + 1;
    end
  end
  disp("exclusion_count: " + exclusion_count);

  ex_ratio = min_range_x:0.1:max_range_x; % 0.1刻みで範囲[min_range_x max_range_x]の配列
  eyetoleft_denominator = zeros(1, length(ex_ratio)); % 眼球左回転時の応答分母
  eyetoright_denominator = zeros(1, length(ex_ratio)); % 眼球右回転時の応答分母
  control_denominator = zeros(1, length(ex_ratio)); % コントロール条件の応答分母
  eyetoleft_numerator = zeros(1, length(ex_ratio)); % 眼球左回転時の応答分子(右向きに動く刺激の方が速いと応答した回数)
  eyetoright_numerator = zeros(1, length(ex_ratio)); % 眼球右回転時の応答分子(右向きに動く刺激の方が速いと応答した回数)
  control_numerator = zeros(1, length(ex_ratio)); % コントロール条件の応答分子(右向きに動く刺激の方が速いと応答した回数)

  for i = 1:length(all_onset_time_in2sd)
    if all_fitting_eye_parameters_in2sd(i,1) > 0
      % 眼球右回転時
      [~,j] = min(abs(ex_ratio - all_ratio_in2sd(i)));
      eyetoright_denominator(j) = eyetoright_denominator(j) + 1;
      if all_top_belt_move_to_right_in2sd(i) == all_resp_up_in2sd(i)
        eyetoright_numerator(j) = eyetoright_numerator(j) + 1;
      end
    else
      % 眼球左回転時
      [~,j] = min(abs(ex_ratio - all_ratio_in2sd(i)));
      eyetoleft_denominator(j) = eyetoleft_denominator(j) + 1;
      if all_top_belt_move_to_right_in2sd(i) == all_resp_up_in2sd(i)
        eyetoleft_numerator(j) = eyetoleft_numerator(j) + 1;
      end
    end
  end

  for filename = control_filenames
    filePath = strcat('Results/', filename, '_exdata.txt');
    fileID = fopen(filePath);
    N = 5;
    C_header = textscan(fileID, '%s', N);
    C = textscan(fileID,'%d %f %f %f %f');
    % 2nd ratio
    % 3rd top_belt_move_to_right
    % 4th resp_up
    % 5th onset_time
    ratio = C{1,2};
    top_belt_move_to_right = C{1,3};
    resp_up = C{1,4};
    onset_time = C{1,5};

    for i = 1:length(onset_time)
      [~,j] = min(abs(ex_ratio - ratio(i)));
      control_denominator(j) = control_denominator(j) + 1;
      if top_belt_move_to_right(i) == resp_up(i)
        control_numerator(j) = control_numerator(j) + 1;
      end
    end
  end

  % ここまででデータの読み込み&処理は完了
  
  % ここからBootstrap処理
  PF = @PAL_CumulativeNormal;
  paramsFree = [1 1 0 0];
  searchGrid.alpha = -10:.1:10;
  searchGrid.beta = logspace(0,3,101);
  searchGrid.gamma = 0.0;
  searchGrid.lambda = 0.02;
  StimLevels = ex_ratio;
  B=1000;
  StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
  
  % 眼球左回転時のFitting
  NumPos = eyetoleft_numerator;
  OutOfNum = eyetoleft_denominator;
  disp('Eye to Left');
  disp("trials: " + sum(OutOfNum));
  % ratioごとの内訳を確認したいときは下の部分をコメントオフする
  % for i = 1:length(OutOfNum)
  %   if OutOfNum(i) > 0
  %     disp(StimLevels(i) + ": " + NumPos(i) + "/" + OutOfNum(i));
  %   end
  % end
  disp('Fitting function.....');
  [paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos,OutOfNum,searchGrid,paramsFree,PF);
  eyetoleft_threshold = paramsValues(1);
  disp('done:');
  message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
  disp(message);
  message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
  disp(message);
  disp('Determining standard errors.....');
  [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(StimLevels,OutOfNum,paramsValues,paramsFree,B,PF,'searchGrid',searchGrid);
  eyetoleft_threshold_se = SD(1);
  disp('done:');
  message = sprintf('Standard error of Threshold: %6.4f',SD(1));
  disp(message);
  message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
  disp(message);
  ProportionCorrectObserved=NumPos./OutOfNum;
  EyeToLeftProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
  figure('Name','Eye to Left');
  axes
  hold on
  plot(StimLevelsFineGrain,EyeToLeftProportionCorrectModel,'-','color',color_blue,'linewidth',4);
  plot(ex_ratio,ProportionCorrectObserved,'k.','markersize',40);
  set(gca,'fontsize',16);
  set(gca,'Xtick',StimLevels);
  axis([min(StimLevels) max(StimLevels) 0 1]);
  xticks(min_range_x:1.0:max_range_x);
  xlabel({"Leftward faster" + blanks(20) + "Rightward faster", "log2 Speed Ratio"});
  ylabel('Ratio responsed rightward stimulus faster');
  hold off

  % コントロール条件のFitting
  NumPos = control_numerator;
  OutOfNum = control_denominator;
  disp('Control');
  disp("trials: " + sum(OutOfNum));
  % ratioごとの内訳を確認したいときは下の部分をコメントオフする
  % for i = 1:length(OutOfNum)
  %   if OutOfNum(i) > 0
  %     disp(StimLevels(i) + ": " + NumPos(i) + "/" + OutOfNum(i));
  %   end
  % end
  disp('Fitting function.....');
  [paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos,OutOfNum,searchGrid,paramsFree,PF);
  control_threshold = paramsValues(1);
  disp('done:');
  message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
  disp(message);
  message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
  disp(message);
  disp('Determining standard errors.....');
  [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(StimLevels,OutOfNum,paramsValues,paramsFree,B,PF,'searchGrid',searchGrid);
  control_threshold_se = SD(1);
  disp('done:');
  message = sprintf('Standard error of Threshold: %6.4f',SD(1));
  disp(message);
  message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
  disp(message);
  ProportionCorrectObserved=NumPos./OutOfNum;
  ControlProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
  figure('Name','Control');
  axes
  hold on
  plot(StimLevelsFineGrain,ControlProportionCorrectModel,'-','color',color_green,'linewidth',4);
  plot(ex_ratio,ProportionCorrectObserved,'k.','markersize',40);
  set(gca,'fontsize',16);
  set(gca,'Xtick',StimLevels);
  axis([min(StimLevels) max(StimLevels) 0 1]);
  xticks(min_range_x:1.0:max_range_x);
  xlabel({"Leftward faster" + blanks(20) + "Rightward faster", "log2 Speed Ratio"});
  ylabel('Ratio responsed rightward stimulus faster');
  hold off

  % 眼球右回転時のFitting
  NumPos = eyetoright_numerator;
  OutOfNum = eyetoright_denominator;
  disp('Eye to Right');
  disp("trials: " + sum(OutOfNum));
  % ratioごとの内訳を確認したいときは下の部分をコメントオフする
  % for i = 1:length(OutOfNum)
  %   if OutOfNum(i) > 0
  %     disp(StimLevels(i) + ": " + NumPos(i) + "/" + OutOfNum(i));
  %   end
  % end
  disp('Fitting function.....');
  [paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos,OutOfNum,searchGrid,paramsFree,PF);
  eyetoright_threshold = paramsValues(1);
  disp('done:');
  message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
  disp(message);
  message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
  disp(message);
  disp('Determining standard errors.....');
  [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(StimLevels,OutOfNum,paramsValues,paramsFree,B,PF,'searchGrid',searchGrid);
  eyetoright_threshold_se = SD(1);
  disp('done:');
  message = sprintf('Standard error of Threshold: %6.4f',SD(1));
  disp(message);
  message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
  disp(message);
  ProportionCorrectObserved=NumPos./OutOfNum;
  EyeToRightProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
  figure('Name','Eye to Right');
  axes
  hold on
  plot(StimLevelsFineGrain,EyeToRightProportionCorrectModel,'-','color',color_red,'linewidth',4);
  plot(ex_ratio,ProportionCorrectObserved,'k.','markersize',40);
  set(gca,'fontsize',16);
  set(gca,'Xtick',StimLevels);
  axis([min(StimLevels) max(StimLevels) 0 1]);
  xticks(min_range_x:1.0:max_range_x);
  xlabel({"Leftward faster" + blanks(20) + "Rightward faster", "log2 Speed Ratio"});
  ylabel('Ratio responsed rightward stimulus faster');
  hold off

  % 3条件のグラフを重ねてプロットする
  figure('Name','All Conditions');
  axes
  hold on
  plot(StimLevelsFineGrain,EyeToLeftProportionCorrectModel,'-','color',color_blue,'linewidth',4);
  plot(StimLevelsFineGrain,ControlProportionCorrectModel,'-','color',color_green,'linewidth',4);
  plot(StimLevelsFineGrain,EyeToRightProportionCorrectModel,'-','color',color_red,'linewidth',4);
  set(gca,'fontsize',16);
  set(gca,'Xtick',StimLevels);
  axis([min(StimLevels) max(StimLevels) 0 1]);
  xticks(min_range_x:1.0:max_range_x);
  xlabel({"Leftward faster" + blanks(20) + "Rightward faster", "log2 Speed Ratio"});
  ylabel('Ratio responsed rightward stimulus faster');
  legend('Left', 'Control', 'Right');
  hold off

  % PSEをプロットする
  figure('Name','PSE');
  hold on
  x = [1,2,3];
  y = [eyetoleft_threshold control_threshold eyetoright_threshold];
  err = [eyetoleft_threshold_se control_threshold_se eyetoright_threshold_se] * 2;
  errorbar(x,y,err);
  set(gca,'fontsize',16);
  xticks([1,2,3]);
  xticklabels({'Left','Control','Right'});
  xlim([0 4]);
  ylim([min_range_x-2 max_range_x+2]);
  ylabel('PSE');
  hold off

  toc
end
