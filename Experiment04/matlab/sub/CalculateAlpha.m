%
% CalculateAlpha.m
%
% 追従眼球運動係数αを計算する。詳しくは修士論文の考察を参照。
%
function CalculateAlpha(pse)
  alpha = 0.6 * (1/sqrt(2.^pse) - sqrt(2.^pse)) + 1;
  disp("Alpha: " + alpha);
end
