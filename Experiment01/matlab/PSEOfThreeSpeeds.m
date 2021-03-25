%
% PSEOfThreeSpeeds.m
%
% 3つの回転速度条件のPSEのグラフをまとめて表示する
%
function PSEOfThreeSpeeds

x = [1, 2, 3];

% 30deg
y_30deg = [0.0545 0.0156 -0.0433];
err_30deg = [0.0188 0.0192 0.0188];
hold on
errorbar(x, y_30deg, err_30deg, 'color', [50/255 255/255 255/255]);

% 60deg
y_60deg = [-0.0100 -0.0148 -0.0341];
err_60deg = [0.0190 0.0177 0.0179];
errorbar(x, y_60deg, err_60deg, 'color', [101/255 140/255 255/255]);

% 120deg
y_120deg = [-0.0319 -0.0156 -0.0729];
err_120deg = [0.0233 0.0148 0.0220];
errorbar(x, y_120deg, err_120deg, 'color', [0/255 25/255 101/255]);
hold off

xticks([1, 2, 3]);
xticklabels({'left','stationary','right'});
xlim([0 4])
ylim([-0.15 0.1])
ylabel('PSE')
