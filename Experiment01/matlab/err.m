%
% err.m
%
% S-curveFitting.m内で使用される関数
%
function ret = err(x,cs,p)

sigma = x(1);

mu = x(2);

a = p - 0.5 - 0.5*erf((cs - mu)/(sqrt(2)*sigma));

ret = sum(a.*a);
