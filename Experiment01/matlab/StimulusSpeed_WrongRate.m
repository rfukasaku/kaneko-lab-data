%
% StimulusSpeed_WrongRate.m
%
% 1つのファイル名を引数として与えて使用
% 刺激速度-誤答率のグラフを表示する
%
function StimulusSpeed_WrongRate(filename)

% parameters
nPracTrials = 3;
nTrials = 132;
nRepeat = 12;
speedRatio = [-0.4 -0.32 -0.24 -0.16 -0.08 0 0.08 0.16 0.24 0.32 0.4];

fileName = filename;
delimiterIn = ' ';
headerlinesIn = 1 + nPracTrials;
A = importdata(fileName,delimiterIn,headerlinesIn);

% Number of wrong answer
wrong = zeros(1, length(speedRatio));

for i = 1 : nTrials
  for j = 1 : length(speedRatio)
    if A.data(i, 4) == speedRatio(j)
      if A.data(i, 4) > 0
        if (A.data(i, 5) == 0 & A.data(i, 6) == 1) | (A.data(i, 5) == 1 & A.data(i, 6) == 0)
          wrong(j) = wrong(j) + 1;
        end
      else
        if (A.data(i, 5) == 0 & A.data(i, 6) == 0) | (A.data(i, 5) == 1 & A.data(i, 6) == 1)
          wrong(j) = wrong(j) + 1;
        end
      end
      break;
    end
  end
end

x = speedRatio;
y = wrong./nRepeat;
bar(x, y);
ylim([0.0 1.05]);
xlabel('leftwards faster                                    rightwards faster');
ylabel('wrong answer rate');
