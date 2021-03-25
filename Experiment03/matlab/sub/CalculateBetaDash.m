%
% CalculateBetaDash.m
%
% 頭部運動係数β'を計算する。詳しくは修士論文の考察を参照。
% case1: 前庭動眼反射速度には実測値を使用
% case2: 前庭動眼反射速度には理論値(頭部平均速度 * 0.8)を使用
% state1: 頭部右・眼球左
% state2: 頭部左・眼球右
%
function CalculateBetaDash(average_head_speed, average_eye_speed, gamma_dash, eye_left_pse, eye_right_pse, head_left_pse, head_right_pse)
  eye_theory_speed = average_head_speed * 0.8;
  pse = (abs(eye_left_pse) + abs(eye_right_pse) + abs(head_left_pse) + abs(head_right_pse)) / 4;

  disp("case1: 前庭動眼反射速度には実測値を使用");
  disp("case2: 前庭動眼反射速度には理論値(頭部平均速度 * 0.8)を使用");
  disp("state1: 頭部右・眼球左");
  disp("state2: 頭部左・眼球右");

  % case1 & state1
  stim_right_speed = 12 / sqrt(2.^pse);
  stim_left_speed = -12 * sqrt(2.^pse);
  beta_dash = ((gamma_dash * average_eye_speed) - ((stim_right_speed + stim_left_speed) / 2) - average_eye_speed) / average_head_speed;
  disp("BetaDash case1 & state1 : " + beta_dash);

  % case1 & state2
  stim_right_speed = 12 * sqrt(2.^pse);
  stim_left_speed = -12 / sqrt(2.^pse);
  beta_dash = ((gamma_dash * average_eye_speed) + ((stim_right_speed + stim_left_speed) / 2) - average_eye_speed) / average_head_speed;
  disp("BetaDash case1 & state2 : " + beta_dash);

  % case2 & state1
  stim_right_speed = 12 / sqrt(2.^pse);
  stim_left_speed = -12 * sqrt(2.^pse);
  beta_dash = ((gamma_dash * eye_theory_speed) - ((stim_right_speed + stim_left_speed) / 2) - eye_theory_speed) / average_head_speed;
  disp("BetaDash case2 & state1 : " + beta_dash);

  % case2 & state2
  stim_right_speed = 12 * sqrt(2.^pse);
  stim_left_speed = -12 / sqrt(2.^pse);
  beta_dash = ((gamma_dash * eye_theory_speed) + ((stim_right_speed + stim_left_speed) / 2) - eye_theory_speed) / average_head_speed;
  disp("BetaDash case2 & state2 : " + beta_dash);
end

% 前提
% 1. 計算に使用するPSEは眼球方向による場合分けによって得られたPSE2つと頭部方向による場合分けによって得られたPSE2つの計4つのPSEの平均値とする
% 2. gamma_dashは、追従眼球運動を用いた実験1で得られた値alphaの平均値とする
% 3. average_eye_speedは、正のときの平均眼球速度と負のときの平均眼球速度の絶対値の平均値とする

% Sub: RF
% >> CalculateBetaDash(98,3.4,0.66,-1.9240,4.8187,3.4942,-1.8884)
% case1: 前庭動眼反射速度には実測値を使用
% case2: 前庭動眼反射速度には理論値(頭部平均速度 * 0.8)を使用
% state1: 頭部右・眼球左
% state2: 頭部左・眼球右
% BetaDash case1 & state1 : 0.14185
% BetaDash case1 & state2 : 0.14185
% BetaDash case2 & state1 : -0.11835
% BetaDash case2 & state2 : -0.11835

% Sub: RA
% >> CalculateBetaDash(76,6.3,0.61,-2.6231,3.0524,5.6971,-2.6556)
% case1: 前庭動眼反射速度には実測値を使用
% case2: 前庭動眼反射速度には理論値(頭部平均速度 * 0.8)を使用
% state1: 頭部右・眼球左
% state2: 頭部左・眼球右
% BetaDash case1 & state1 : 0.21045
% BetaDash case1 & state2 : 0.21045
% BetaDash case2 & state1 : -0.069218
% BetaDash case2 & state2 : -0.069218

% Sub: AM
% >> CalculateBetaDash(70,4.1,0.46,-2.6157,4.1261,4.4287,-2.7483)
% case1: 前庭動眼反射速度には実測値を使用
% case2: 前庭動眼反射速度には理論値(頭部平均速度 * 0.8)を使用
% state1: 頭部右・眼球左
% state2: 頭部左・眼球右
% BetaDash case1 & state1 : 0.22899
% BetaDash case1 & state2 : 0.22899
% BetaDash case2 & state1 : -0.17138
% BetaDash case2 & state2 : -0.17138
