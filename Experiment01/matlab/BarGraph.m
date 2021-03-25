%
% BarGraph.m
%
% 1つのファイル名を引数として与えて使用
% 棒グラフを表示する
%
function BarGraph(filename)

% parameters
nPracTrials = 3;
nTrials = 132;
nRepeat = 12;
speedRatio = [-0.4 -0.32 -0.24 -0.16 -0.08 0 0.08 0.16 0.24 0.32 0.4];

fileName = filename;
delimiterIn = ' ';
headerlinesIn = 1 + nPracTrials;
A = importdata(fileName,delimiterIn,headerlinesIn);

% Response rightwards faster
rightFaster = zeros(1, length(speedRatio));

for i = 1 : nTrials
  for j = 1 : length(speedRatio)
    if A.data(i, 4) == speedRatio(j)
      if (A.data(i, 5) == 0 & A.data(i, 6) == 0) | (A.data(i, 5) == 1 & A.data(i, 6) == 1)
        rightFaster(j) = rightFaster(j) + 1;
        break;
      end
    end
  end
end

x = speedRatio;
y = rightFaster./nRepeat;
bar(x, y);
ylim([0.0 1.05]);
xlabel('leftwards faster                                    rightwards faster');
ylabel('proportion rightwards reported faster');

disp(rightFaster);
