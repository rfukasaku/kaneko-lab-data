%
% PSE.m
% Left, No, Rightの3条件でのPSEを表示する
%
function PSE

x = [1, 2, 3];
y = [-0.0912 -0.0610 -0.1109];
err = [0.0175 0.0158 0.0127];
errorbar(x,y,err);
xticks([1, 2, 3]);
xticklabels({'left','stationary','right'});
xlim([0 4])
ylim([-0.15 0.1])
ylabel('PSE')
