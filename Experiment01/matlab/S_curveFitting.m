%
% S_curveFitting.m
%
% 1つのファイル名を引数として与えて使用
% 恒常法のS字カーブフィッティングを行う
% http://kaji-lab.jp/kajimoto/ConstantMethodFitting.htm
%
function result = S_curveFitting(filename)

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

%恒常法によりデータをフィッティングし、閾値等を求める。
x1 = speedRatio;
y1 = rightFaster./nRepeat;

%データのプロット
p = y1;
hold off;
figure(1);plot(x1,p,'o','LineWidth',2,'MarkerSize',10);

%fminsearch関数により最小二乗法フィッティング
%σ，μとして，適当と思われる初期値1,mean(x1)を与える。
OPTION = [];
X = fminsearch('err',[1, mean(x1)],OPTION,x1,p);
sigma = X(1)
mu = X(2)

%75%弁別閾値を求める．
% bound025 = erfinv(0.25*2-1)*sqrt(2)*sigma + mu
bound075 = erfinv(0.75*2-1)*sqrt(2)*sigma + mu
hold on;

%フィッティングデータをプロット
x2 = [min(x1):(max(x1)-min(x1))/100:max(x1)];
p2 = 0.5 + 0.5 .* erf((x2 - mu)./(sqrt(2)*sigma));
plot(x2,p2,'LineWidth',2);

%75パーセント弁別閾を描画
% plot([min(x1),max(x1)],[0.25,0.25],'--');
plot([min(x1),max(x1)],[0.75,0.75],'--');

% plot([bound025,bound025],[-0.1,1.1],'--');
plot([mu,mu],[-0.1,1.1]);
plot([bound075,bound075],[-0.1,1.1],'--');
axis([min(x1),max(x1),-0.1,1.1]);

xlabel ('leftwards faster                    rightwards faster','FontSize',15);
ylabel ('proportion rightwards reported faster','FontSize',15);
