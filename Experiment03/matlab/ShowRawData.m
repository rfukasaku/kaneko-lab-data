%
% ShowRawData.m
% 
% 刺激提示タイミング・眼球変位・頭部変位の生データを確認する
%
function ShowRawData(fileName, x_min, x_max)
  arguments
    fileName = 'test';
    x_min = 0;
    x_max = 30;
  end

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
  % 11th time
  eyepos = C{1,6};
  eyetime = C{1,11};
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

  figure('Name','Raw Data');
  hold on
  set(gca,'fontsize',16);
  xlabel('time [sec]');
  yyaxis left
  plot(headtime, smooth_headpos);
  ylabel('Head Rotation [deg]');
  yyaxis right
  plot(eyetime, rad2deg(atan(smooth_eyepos))); % 単位をdegに変換
  ylabel('Eye Position [deg]');
  for i = 1:length(onset_time)
    xline(onset_time(i));
  end
  xlim([x_min x_max]);
  hold off

  disp("表示区間は" + x_min + "〜" + x_max + "秒です");

  toc
end
