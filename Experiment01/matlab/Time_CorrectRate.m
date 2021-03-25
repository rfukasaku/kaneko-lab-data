%
% Time_CorrectRate.m
%
% 1つのファイル名を引数として与えて使用
% 時間-正答率のグラフを表示する
%
function Time_CorrectRate(filename)

% parameters
nPracTrials = 3;
nTrials = 132;

fileName = filename;
delimiterIn = ' ';
headerlinesIn = 1 + nPracTrials;
A = importdata(fileName,delimiterIn,headerlinesIn);

% time
time = [20 40 60 80 100 120 140 160 180 200 220 240 260 280];

% Number of response
nResp = zeros(1, length(time));
% Number of correct answer
correct = zeros(1, length(time));

for i = 1 : nTrials
  for j = 1 : length(time)
    if A.data(i, 7) < time(j)
      nResp(j) = nResp(j) + 1;
      if A.data(i, 4) > 0
        if (A.data(i, 5) == 0 & A.data(i, 6) == 0) | (A.data(i, 5) == 1 & A.data(i, 6) == 1)
          correct(j) = correct(j) + 1;
        end
      else
        if (A.data(i, 5) == 0 & A.data(i, 6) == 1) | (A.data(i, 5) == 1 & A.data(i, 6) == 0)
          correct(j) = correct(j) + 1;
        end
      end
      break;
    end
  end
end

x = time;
y = correct./nResp;
plot(x, y);
ylim([0.0 1.05]);
xlabel('time [s]');
ylabel('correct answer rate')
