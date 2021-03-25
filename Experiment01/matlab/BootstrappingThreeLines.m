%
% BootstrappingThreeLines.m
%
% Fitting.mのアルゴリズムをもって、3本のグラフを描く
% 3条件それぞれについて、以下2つのパラメータを計算して表示する
% Threshold estimate
% Slope estimate
%
function [paramsValues,SD] = BootstrappingThreeLines(StimLevels,NumPos,OutOfNum)

warning off all
tic
ParOrNonPar = 1;

% Right Rotation
if nargin == 0
    %Stimulus intensities
    StimLevels = [-0.40 -0.32 -0.24 -0.16 -0.08 0 0.08 0.16 0.24 0.32 0.40];
    %Number of positive responses (e.g., 'yes' or 'correct' at each of the
    %   entries of 'StimLevels'
    NumPos = [0     0     1     2     5    11    12    12    12    12    12] ...
           + [0     0     1     3    10    11    12    12    12    12    12];
    %Number of trials at each entry of 'StimLevels'
    OutOfNum = ones(1, length(StimLevels)) * 12 * 2;
end
PF =  @PAL_CumulativeNormal;
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
searchGrid.alpha = -10:.1:10;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0.0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.02;  %ditto
disp('Fitting function.....');
[paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos, ...
    OutOfNum,searchGrid,paramsFree,PF);
disp('done:')
message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
disp(message);
message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
disp(message);
SD =[0 0];
%Create simple plot
ProportionCorrectObserved=NumPos./OutOfNum;
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
axes
hold on
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[1 0 0],'linewidth',4);

% Flat Rotation
if nargin == 0
    %Stimulus intensities
    StimLevels = [-0.40 -0.32 -0.24 -0.16 -0.08 0 0.08 0.16 0.24 0.32 0.40];
    %Number of positive responses (e.g., 'yes' or 'correct' at each of the
    %   entries of 'StimLevels'
    NumPos = [0     0     0     4     6    10    10    12    12    12    12] ...
           + [0     1     0     0     8     7     8    11    12    12    12];
    %Number of trials at each entry of 'StimLevels'
    OutOfNum = ones(1, length(StimLevels)) * 12 * 2;
end
PF =  @PAL_CumulativeNormal;
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
searchGrid.alpha = -10:.1:10;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0.0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.02;  %ditto
disp('Fitting function.....');
[paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos, ...
    OutOfNum,searchGrid,paramsFree,PF);
disp('done:')
message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
disp(message);
message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
disp(message);
SD =[0 0];
%Create simple plot
ProportionCorrectObserved=NumPos./OutOfNum;
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0 1 0],'linewidth',4);

% Left Rotation
if nargin == 0
    %Stimulus intensities
    StimLevels = [-0.40 -0.32 -0.24 -0.16 -0.08 0 0.08 0.16 0.24 0.32 0.40];
    %Number of positive responses (e.g., 'yes' or 'correct' at each of the
    %   entries of 'StimLevels'
    NumPos = [1     0     1     3     6     5    10     9    11    12    12] ...
           + [0     0     3     4     9    12    12    11    12    12    12];
    %Number of trials at each entry of 'StimLevels'
    OutOfNum = ones(1, length(StimLevels)) * 12 * 2;
end
PF =  @PAL_CumulativeNormal;
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
searchGrid.alpha = -10:.1:10;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0.0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.02;  %ditto
disp('Fitting function.....');
[paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos, ...
    OutOfNum,searchGrid,paramsFree,PF);
disp('done:')
message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
disp(message);
message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
disp(message);
SD =[0 0];
%Create simple plot
ProportionCorrectObserved=NumPos./OutOfNum;
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0 0 1],'linewidth',4);

set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) 0 1]);
xlabel('leftwards faster                                    rightwards faster');
ylabel('proportion rightwards reported faster');
toc
