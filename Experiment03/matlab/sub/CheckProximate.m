%
% CheckProximate.m
%
% 各トライアルの眼球データを1次関数に近似する
%
function CheckProximate(fileName)
  arguments
    fileName = 'test';
  end

  % Settings
  conf_threshold = 0.6;

  tic

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
  smooth_eyepos = rad2deg(atan(smooth_eyepos)); % 単位をdegに変換

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

  for i = 1:length(onset_time)
    figure('Name','Proximate');
    hold on
    set(gca,'fontsize',16);
    xlabel("time [sec]");
    ylabel('Eye Position [deg]');
    plot(eachtrial_time, eachtrial_eyedata(i,:),'k.','markersize',20);
    plot(eachtrial_time, fitting_eye_parameters(i,1) * eachtrial_time + fitting_eye_parameters(i,2));
    hold off
  end

  toc
end
