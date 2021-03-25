%
% ShowResp.m
% 
% 眼球の追従方向(左・右)ごとに応答結果を出力する
%
function ShowResp(fileName)
  % Settings
  min_range_x = -6.0;
  max_range_x = 6.0;

  tic

  filePath = strcat('Results/', fileName, '_exdata.txt');
  fileID = fopen(filePath);
  N = 6;
  C_text = textscan(fileID, '%s', N);
  C = textscan(fileID,'%d %f %f %f %f %f');
  % 2nd ratio
  % 3rd fixpoint_movetoright
  % 4rd topbelt_movetoright
  % 5th respup
  % 6th onsettime
  ratio = C{1,2};
  fixpoint_movetoright = C{1,3};
  topbelt_movetoright = C{1,4};
  respup = C{1,5};
  onset_time = C{1,6};

  ex_ratio = min_range_x:0.1:max_range_x; % 0.1刻みで範囲[min_range_x max_range_x]の配列
  eyetoleft_denominator = zeros(1, length(ex_ratio)); % 眼球左方向追従時の応答分母
  eyetoright_denominator = zeros(1, length(ex_ratio)); % 眼球右方向追従時の応答分母
  eyetoleft_numerator = zeros(1, length(ex_ratio)); % 眼球左方向追従時の応答分子
  eyetoright_numerator = zeros(1, length(ex_ratio)); % 眼球右方向追従時の応答分子

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

  for i = 1:length(ex_ratio)
    if eyetoright_denominator(i) ~= 0
      eyetoright_result(i) = eyetoright_numerator(i) / eyetoright_denominator(i);
    else
      eyetoright_result(i) = -1;
    end
    if eyetoleft_denominator(i) ~= 0
      eyetoleft_result(i) = eyetoleft_numerator(i) / eyetoleft_denominator(i);
    else
      eyetoleft_result(i) = -1;
    end
  end

  figure('Name','Eye to Right');
  plot(ex_ratio,eyetoright_result,'k.','markersize',15);
  xlabel('ratio');
  ylabel('result');
  ylim([0 1]);

  figure('Name','Eye to Left');
  plot(ex_ratio,eyetoleft_result,'k.','markersize',15);
  xlabel('ratio');
  ylabel('result');
  ylim([0 1]);

  toc
end
