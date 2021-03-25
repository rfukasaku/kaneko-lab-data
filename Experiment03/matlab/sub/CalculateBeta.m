%
% CalculateBeta.m
%
% 頭部運動係数βを計算する。詳しくは修士論文の考察を参照。
%
function CalculateBeta(average_head_speed, pse)
  beta = 6 * (sqrt(2.^pse) - 1/sqrt(2.^pse)) / average_head_speed;
  disp("Beta: " + beta);
end
