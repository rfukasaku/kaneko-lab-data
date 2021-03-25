%
% ShowResponseAndStep.m
% 
% Step変化と、頭部変位がプラスまたはマイナス時の応答を確認する
%
function ShowResponseAndStep(fileName)
  arguments
    fileName = 'test';
  end

  tic

  filePath = strcat('Results/', fileName, '_exdata.txt');
  fileID = fopen(filePath);
  N = 5;
  C_header = textscan(fileID, '%s', N);
  C = textscan(fileID,'%d %f %f %f %f');
  % 1st trial
  % 2nd ratio
  % 3rd top_belt_move_to_right
  % 4th resp_up
  % 5th onset_time
  trial = C{1,1};
  ratio = C{1,2};
  top_belt_move_to_right = C{1,3};
  resp_up = C{1,4};
  onset_time = C{1,5};

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

  ex_ratio = -6:0.1:6; % 0.1刻みで[-6 6]の配列を作成
  headtoleft_denominator = zeros(1, length(ex_ratio)); % 頭部左回転時の応答分母
  headtoright_denominator = zeros(1, length(ex_ratio)); % 頭部右回転時の応答分母
  headtoleft_numerator = zeros(1, length(ex_ratio)); % 頭部左回転時の応答分子
  headtoright_numerator = zeros(1, length(ex_ratio)); % 頭部右回転時の応答分子

  for i = 1:length(onset_time)
    if fitting_head_parameters(i,1) > 0
      % 頭部右回転時
      for j = 1:length(ex_ratio)
        if ex_ratio(j) == ratio(i)
          headtoright_denominator(j) = headtoright_denominator(j) + 1;
          if top_belt_move_to_right(i) == resp_up(i)
            headtoright_numerator(j) = headtoright_numerator(j) + 1;
          end
          break;
        end
      end
    else
      % 頭部左回転時
      for j = 1:length(ex_ratio)
        if ex_ratio(j) == ratio(i)
          headtoleft_denominator(j) = headtoleft_denominator(j) + 1;
          if top_belt_move_to_right(i) == resp_up(i)
            headtoleft_numerator(j) = headtoleft_numerator(j) + 1;
          end
          break;
        end
      end
    end
  end

  for i = 1:length(ex_ratio)
    if headtoright_denominator(i) ~= 0
      headtoright_response(i) = headtoright_numerator(i) / headtoright_denominator(i);
    else
      headtoright_response(i) = -1;
    end
    if headtoleft_denominator(i) ~= 0
      headtoleft_response(i) = headtoleft_numerator(i) / headtoleft_denominator(i);
    else
      headtoleft_response(i) = -1;
    end
  end

  figure('Name','Head to Right');
  plot(ex_ratio,headtoright_response,'k.','markersize',20);
  xlabel('ratio');
  ylabel('response');
  ylim([0 1]);

  figure('Name','Head to Left');
  plot(ex_ratio,headtoleft_response,'k.','markersize',20);
  xlabel('ratio');
  ylabel('response');
  ylim([0 1]);

  figure('Name', 'Steps');
  plot(trial, abs(ratio));
  xlabel('trial');
  ylabel('ratio');
  
  toc
end
