% BlandAltmanDemo - demonstrate calling BlandAltman.m
%
% By Ran Klein
% 2016-08-10  RK  Major overhull of Bland-Altman.m and new functionality is
%                 demonstrated.
% 2018-12-12  RK  Added support for correlation plot only
%                 (CorrelationPlot.m).
%                 Examples added for multiple analyses on a single figure.



%% Generate paramteres for data generation
clear;
noise = 10/100; % percent
npatients = 134; % number of patients
bias = 1; % slope bias

% Heart muscle territories per patient
% territories = {'LAD','LCx','RCA'};
territories = {'Indice'};
%nterritories = length(territories);
nterritories = 1;

% Patient states during measurement
states = {'Jaccard','Dice'};
nstates = length(states);

% Real flow values
% restFlow = 0.7*(1+0.2*randn(npatients,nterritories));
% stressFlow = 2*(1+0.2*randn(npatients,nterritories));
 
 G_CV_J = [0.8629;0.9710;0.9424;0.6136;0.7951;0.9741;0.9619;0.9830;0.9792;0.8173; 0.8150;0.9743;0.9128; ...
    0.8985;0.8870;0.8702;0.9960;0.9580;0.9516;0.8620;0.9691;0.9395;0.9688;0.9632;0.9241;0.9482;0.9513;0.9079;0.8140;0.9090;0.8744;0.9327;0.9971;0.9293;0.7721];

   G_CMA_J = [0.5500;0.6107;0.3785;0.1581;0.3482;0.9717;0.9604;0.9831;0.9781;0.7327;0.7707;0.8853;0.7940;0.7794;0.7283; ...
    0.7064;0.9982;0.9344;0.9217;0.8351;0.9698;0.9419;0.9284;0.9159;0.8451;0.8949;0.8997;0.9740;0.9408;0.9090;0.7975;0.9327;0.9890;0.3719;0.7291];

  G_CMA_D = [0.7404;0.7654;0.5616;0.3305;0.5357;0.9870;0.9812;0.9923;0.9893;0.8535;0.8861;0.9431;0.8902;0.8846;0.8649; ...
    0.8399;0.9991;0.9681;0.9638;0.9131;0.9850;0.9718;0.9664;0.9578;0.9185;0.9482;0.9506;0.9873;0.9706;0.9537;0.9016;0.9692;0.9948;0.5441;0.8522];

 G_CV_D = [0.9326;0.9859;0.9705;0.7963;0.8880;0.9882;0.9819;0.9922;0.9898;0.9054;0.9104;0.9875;0.9562;0.9497;0.9482; ...
    0.9352;0.9980;0.9796;0.9781;0.9279;0.9847;0.9706;0.9853;0.9817;0.9616;0.9748;0.9758;0.9580;0.9059;0.9537;0.9409;0.9692;0.9986;0.9638;0.8739];
%  
% disp(numel(M_CV_J));
% disp(numel(M_CMA_J));
% disp(numel(M_CMA_D));
% disp(numel(M_CV_D));

%  stressFlow =  [0.1256; 0.9545; 0.7643; 0.3454; 0.3511];

% Test support for nan values in the data
% if 0
% 	restFlow(3,1) = nan;
% end

%% Example 1
% Baseline data with noise
data1 = cat(2,G_CV_J, G_CV_D);
% data1 = P_CV_J;


% Follow-up data with noise and a bias
% data2 = bias * cat(3,  restFlow.*(1+noise*randn(npatients,nterritories)), stressFlow.*(1+noise*randn(npatients,nterritories)), stressFlow.*(1+noise*randn(npatients,nterritories)));
%  data2 = cat(2,  restFlow.*(1+noise*randn(npatients,nterritories)), stressFlow.*(1+noise*randn(npatients,nterritories)));
data2 = cat(2,G_CMA_J,G_CMA_D);


% BA plot paramters
tit = ''; % figure title
gnames = {territories, states}; % names of groups in data {dimension 1 and 2}
label = {'Curvedness & Shape Index','Central Media adaptive'}; % Names of data sets
corrinfo = {'eq'}; % stats to display of correlation scatter plot
BAinfo = {''}; % stats to display on Bland-ALtman plot
limits = 'auto'; % how to set the axes limits
if 1 % colors for the data sets may be set as:
	colors = 'br';      % character codes
else
	colors = [0 0 1;1 0 1; 1 0 0];
end

% Generate figure with symbols
[cr, fig, statsStruct] = BlandAltman(data1, data2, label,tit,gnames,'corrInfo',corrinfo,'baInfo',BAinfo,'axesLimits',limits, 'showFitCI',' on');

% Generate figure with numbers of the data points (patients) and fixed
% Bland-Altman difference data axes limits
BlandAltman(data1, data2, label,[tit ' (numbers, forced 0 intercept, and fixed BA y-axis limits)'],gnames,'corrInfo',corrinfo,'axesLimits',limits,'symbols','Num','baYLimMode','square','forceZeroIntercept','on')


% Generate figure with differences presented as percentages and confidence
% intervals on the correlation plot
BAinfo = {'RPC'};
BlandAltman(data1, data2, label,[tit ' (show fit confidence intervals and differences as percentages)'],gnames,'diffValueMode','percent', 'showFitCI','on','baInfo',BAinfo)


% Display statistical results that were returned from analyses
disp('Statistical results:');
disp(statsStruct);
% * Note that non-Gaussian warning may result for the first two analysis as
% the two data sets (rest and stress) make the difference data marginally
% Gaussian (two overlapping Gaussians). This should not be the case with
% the third analysis as it is in percent difference of the means.

% %% Example 2 - using non-Gaussian data and one figure with 2 analyses
% disp('Analysis with non-Gaussian distribution data')
% % Baseline data with non-Gaussian noise
% data1 = cat(3,  restFlow.*(1+noise*rand(npatients,nterritories)), stressFlow.*(1+noise*rand(npatients,nterritories)));
% % Follow-up data with non-Gaussian noise and a bias
% data2 = bias * cat(3,  restFlow.*(1+noise*rand(npatients,nterritories)), stressFlow.*(1+noise*rand(npatients,nterritories)));
% 
% figure('Color','w','Units','centimeters', 'Position',[2 2 20 20])
% ah1 = subplot(211);
% ah2 = subplot(212);
% 
% BAinfo = {'RPC(%)','ks'};
% 
% [cr, fig, statsStruct] = BlandAltman(ah1, data1, data2,label,[tit ' (inappropriate Gaussian stats)'],gnames,'corrInfo',corrinfo,'baInfo',BAinfo,'axesLimits',limits,'colors',colors);
% % A warning should appear indicating detection of non-Gaussian
% % distribution.
% 
% % Repeat analysis using non-parametric analysis, no warning should appear.
% BAinfo = {'RPCnp','ks'};
% [cr, fig, statsStruct] = BlandAltman(ah2, data1, data2,label,[tit ' (using non-parametric stats)'],gnames,'corrInfo',corrinfo,'baInfo',BAinfo,'axesLimits',limits,'colors',colors,'baStatsMode','non-parametric');
% % Keep in mind that alpha is set to 0.05 so there is a 1/20 chace of false
% % warnings.
% 
% 
% %% Example 3 - Repeat last analysis, but only with correlation
% [cr, fig, statsStruct] = correlationPlot(data1, data2,label,[tit ' (using non-parametric stats)'],gnames,'corrInfo',corrinfo,'colors',colors);