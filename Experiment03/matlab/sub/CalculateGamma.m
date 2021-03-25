%
% CalculateGamma.m
%
% 前庭動眼反射係数γを計算する。詳しくは修士論文の考察を参照。
%
function CalculateGamma(average_head_speed, pse)
  average_eye_speed = average_head_speed * 0.8;
  gamma1 = (6 / average_eye_speed) * (1/sqrt(2.^pse) - sqrt(2.^pse)) + 1;
  disp("Gamma: " + gamma1);
end
