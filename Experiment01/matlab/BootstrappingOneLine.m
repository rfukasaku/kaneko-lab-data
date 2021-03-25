%
% BootstrappingOneLine.m
%
% ブートストラップ法によってフィッティングを行う
% Fitting.mのアルゴリズムをもって、1本のグラフを描く
% 以下4つのパラメータを計算して表示する
% Threshold estimate
% Slope estimate
% Standard error of Threshold
% Standard error of Slope
%
function [paramsValues,SD] = BootstrappingOneLine(StimLevels,NumPos,OutOfNum)
%PAL_PFML_Demo  Demonstrates use of Palamedes functions to (1) fit a
%Psychometric Function to some data using a Maximum Likelihood criterion,
%(2) determine standard errors of free parameters using a bootstrap
%procedure and (3) determine the goodness-of-fit of the fit.
%
%Demonstrates basic usage of Palamedes functions:
%-PAL_PFML_Fit
%-PAL_PFML_BootstrapParametric
%-PAL_PFML_BootstrapNonParametric
%-PAL_PFML_GoodnessOfFit
%secondary:
%-PAL_Logistic
%
%More information on any of these functions may be found by typing
%help followed by the name of the function. e.g., help PAL_PFML_Fit
%
%NP (08/23/2009)

warning off all

tic
%
% message = 'Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2): ';
% ParOrNonPar = input(message);
ParOrNonPar = 1;

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

%Use the Logistic function
PF =  @PAL_CumulativeNormal; %Alternatives: PAL_Gumbel, PAL_Weibull,
                     %PAL_Quick, PAL_logQuick,
                     %PAL_CumulativeNormal, PAL_HyperbolicSecant

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = -10:.1:10;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0.0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.02;  %ditto

%Perform fit
disp('Fitting function.....');
[paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos, ...
    OutOfNum,searchGrid,paramsFree,PF);

disp('done:')
message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
disp(message);
message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
disp(message);

%Number of simulations to perform to determine standard error
B=10000;

disp('Determining standard errors.....');

if ParOrNonPar == 1
    [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(...
        StimLevels, OutOfNum, paramsValues, paramsFree, B, PF, ...
        'searchGrid', searchGrid);
else
    [SD paramsSim LLSim converged] = PAL_PFML_BootstrapNonParametric(...
        StimLevels, NumPos, OutOfNum, [], paramsFree, B, PF,...
        'searchGrid',searchGrid);
end

disp('done:');
message = sprintf('Standard error of Threshold: %6.4f',SD(1));
disp(message);
message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
disp(message);

%Distribution of estimated slope parameters for simulations will be skewed
%(type: hist(paramsSim(:,2),40) to see this). However, distribution of
%log-transformed slope estimates will be approximately symmetric
%[type: hist(log10(paramsSim(:,2),40)]. This might motivate using
%log-scale for slope values (uncomment next three lines to put on screen):
% SElog10slope = std(log10(paramsSim(:,2)));
% message = ['Estimate for log10(slope): ' num2str(log10(paramsValues(2))) ' +/- ' num2str(SElog10slope)];
% disp(message);

% %Number of simulations to perform to determine Goodness-of-Fit
% B=1000;
%
% disp('Determining Goodness-of-fit.....');
%
% [Dev pDev] = PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, ...
%     paramsValues, paramsFree, B, PF, 'searchGrid', searchGrid);
%
% disp('done:');
%
% %Put summary of results on screen
% message = sprintf('Deviance: %6.4f',Dev);
% disp(message);
% message = sprintf('p-value: %6.4f',pDev);
% disp(message);
%
SD =[0 0];
%Create simple plot
ProportionCorrectObserved=NumPos./OutOfNum;
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);

figure('name','Maximum Likelihood Psychometric Function Fitting');
axes
hold on
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[1 0 0],'linewidth',4);
plot(StimLevels,ProportionCorrectObserved,'k.','markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) 0 1]);
xlabel('leftwards faster                                    rightwards faster');
ylabel('proportion rightwards reported faster');

toc
