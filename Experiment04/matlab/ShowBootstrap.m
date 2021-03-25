%
% ShowBootstrap.m
% 
% 眼球左方向追従時・コントロール条件・眼球左方向追従時のBootstrapの結果とPSEをチェックする関数
%
function ShowBootstrap
  warning off all

  % File Index
  RF_eyemove_filenames = [
    "RF/RF_20201226_2", ...
    "RF/RF_20201226_3"];
  RF_control_filenames = ["RF/RF_control_20201220"];
  RA_eyemove_filenames = [
    "RA/RA_20210104", ...
    "RA/RA_20210104_2"];
  RA_control_filenames = ["RA/RA_control_20201222"];
  AM_eyemove_filenames = [
    "AM/AM_20210104", ...
    "AM/AM_20210104_2"];
  AM_control_filenames = ["AM/AM_control_20201223"];

  % Settings
  min_range_x = -5.0;
  max_range_x = 5.0;
  color_red = [240/255 79/255 94/255]; % 赤
  color_green = [76/255 239/255 130/255]; % 緑
  color_blue = [76/255 163/255 239/255]; % 青
  eyemove_filenames = RF_eyemove_filenames;
  control_filenames = RF_control_filenames;

  tic

  ex_ratio = min_range_x:0.1:max_range_x; % 0.1刻みで範囲[min_range_x max_range_x]の配列
  eyetoleft_denominator = zeros(1, length(ex_ratio)); % 眼球左方向追従時の応答分母
  eyetoright_denominator = zeros(1, length(ex_ratio)); % 眼球右方向追従時の応答分母
  control_denominator = zeros(1, length(ex_ratio)); % コントロール条件の応答分母
  eyetoleft_numerator = zeros(1, length(ex_ratio)); % 眼球左方向追従時の応答分子(右向きに動く刺激の方が速いと応答した回数)
  eyetoright_numerator = zeros(1, length(ex_ratio)); % 眼球右方向追従時の応答分子(右向きに動く刺激の方が速いと応答した回数)
  control_numerator = zeros(1, length(ex_ratio)); % コントロール条件の応答分子(右向きに動く刺激の方が速いと応答した回数)

  for filename = eyemove_filenames
    filePath = strcat('Results/', filename, '_exdata.txt');
    fileID = fopen(filePath);
    N = 6;
    C_header = textscan(fileID, '%s', N);
    C = textscan(fileID,'%d %f %f %f %f %f');
    % 2nd ratio
    % 3rd fixpoint_movetoright
    % 4rd topbelt_movetoright
    % 5th respup
    % 6th onset_time
    ratio = C{1,2};
    fixpoint_movetoright = C{1,3};
    topbelt_movetoright = C{1,4};
    respup = C{1,5};
    onset_time = C{1,6};

    for i = 1:length(onset_time)
      if fixpoint_movetoright(i) == 1
        % 眼球右方向追従時
        [~,j] = min(abs(ex_ratio - ratio(i)));
        eyetoright_denominator(j) = eyetoright_denominator(j) + 1;
        if topbelt_movetoright(i) == respup(i)
          eyetoright_numerator(j) = eyetoright_numerator(j) + 1;
        end
      else
        % 眼球左方向追従時
        [~,j] = min(abs(ex_ratio - ratio(i)));
        eyetoleft_denominator(j) = eyetoleft_denominator(j) + 1;
        if topbelt_movetoright(i) == respup(i)
          eyetoleft_numerator(j) = eyetoleft_numerator(j) + 1;
        end
      end
    end
  end

  for filename = control_filenames
    % control条件のファイルは以前の形式であることに注意する
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
  
  % 頭部左回転時のFitting
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

  % 頭部右回転時のFitting
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
  %ylim([min_range_x-2 max_range_x+2]);
  ylim([-3 3]);
  ylabel('PSE');
  hold off

  toc
end
