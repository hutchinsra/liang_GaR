% TVP_FAVAR - Time-varying parameters factor-augmented VAR using EWMA Kalman filters 
% SINGLE MODEL CASE
%-----------------------------------------------------------------------------------------
% Written by Dimitris Korobilis
% University of Glasgow
% This version: 04 July, 2012
%-----------------------------------------------------------------------------------------
function FCI_tt = get_fci_brookings(aux)
InputFileName = aux.InputFileName;
% 
% clear all; close all; clc;
% aux.MainPath = [pwd, '\'];
% aux.OutFolderName = 'Output_Mar03';
% ENVIROMENT;

%-------------------------------USER INPUT--------------------------------------
% Model specification
nfac = 1;         % number of factors
nlag = 1;         % number of lags of factors

% Control the amount of variation in the measurement and error variances
l_1 = 0.96;       % Decay factor for measurement error variance
l_2 = 0.96;       % Decay factor for factor error variance
l_3 = 0.99;       % Decay factor for loadings error variance
l_4 = 0.99;       % Decay factor for VAR coefficients error variance

% Select if y[t] should be included in the measurement equation (if it is
% NOT included, then the coefficient/loading L[y,t] is zero for all periods
y_true = 1;       % 1: Include y[t]; 0: Do not include y[t]

%% ----------------------------------LOAD DATA----------------------------------------
TempTable = readtable(InputFileName, 'Sheet', 'FCI_XData');
XTable = table2timetable(TempTable, 'RowTimes', 'qdate');
xdata = XTable{:, :};
xnames = XTable.Properties.VariableNames;

%**************************************************************************
%**************************************************************************
TempTable = readtable(InputFileName, 'Sheet', 'FCI_YData');
YTable = table2timetable(TempTable, 'RowTimes', 'qdate');
ydata = YTable{:, 1:end-1};
FSI = YTable{:, 'FCI'};
ynames = YTable.Properties.VariableNames(1:end-1);

namesXY = [ynames'; xnames'];
% Demean and standardize data (needed to extract Principal Components)
xdata = standardize_miss(xdata) + 1e-10 ;
xdata(isnan(xdata)) = 0;
ydata = standardize(ydata);

% Define X and Y matrices
X = xdata;
Y = ydata;

% Set dimensions of useful quantities
t = size(Y,1); % t time series observations
n = size(X,2); % n series from which we extract factors
p = size(Y,2); % and p macro series
r = nfac + p;  % number of factors and macro series
q = n + p;     % number of observed and macro series
m = nlag*(r^2);  % number of VAR parameters
k = nlag*r;      % number of sampled factors

%% =========================| PRIORS |================================
% Initial condition on the factors
factor_0.mean = zeros(k,1);
factor_0.var = 10*eye(k);
% Initial condition on lambda_t
lambda_0.mean = zeros(q,r);
lambda_0.var = 1*eye(r);
% Initial condition on beta_t
[b_prior,Vb_prior] = Minn_prior_KOOP(0.1,r,nlag,m); % Obtain a Minnesota-type prior
beta_0.mean = b_prior;
beta_0.var = Vb_prior;
% Initial condition on the covariance matrices
V_0 = 0.1*eye(q); V_0(1:p,1:p) = 0;
Q_0 = 0.1*eye(r);

% Put all decay/forgetting factors together in a vector
l = [l_1; l_2; l_3; l_4];

%% ----------------------------- END OF PRELIMINARIES ---------------------------
tic;
%======================= FAVAR ESTIMATION =======================
% Get PC estimate using xdata up to time t
X_st = standardize_miss(xdata);
X_st(isnan(X_st)) = 0;
[FPC2,LPC] = extract(X_st,nfac);
Y = standardize(ydata(1:end,:));      
FPC = [Y, FPC2];  % macro data and FCI          
YX = [Y, X_st];   % macro data and financial data
[L_OLS,B_OLS,beta_OLS,SIGMA_OLS,Q_OLS] = ols_pc_dfm(YX,FPC,LPC,y_true,n,p,r,nfac,nlag);

% 1/ Estimate the FCI using Principal Component:
FPCA = FPC2;

% 2/ Estimate the FCI using the method by Doz, Giannone and Reichlin (2011):  
B_doz = [beta_OLS'; eye(r*(nlag-1)) zeros(r*(nlag-1),r)];
Q_doz = [Q_OLS zeros(r,r*(nlag-1)); zeros(r*(nlag-1),k)];  
[Fdraw] = Kalman_companion(YX,0*ones(k,1),10*eye(k),L_OLS,(SIGMA_OLS + 1e-10*eye(q)),B_doz,Q_doz);
FDOZ = Fdraw;  

% 3/ Estimate the FCI using the method in Koop and Korobilis (2013):
% ====| STEP 1: Update Parameters Conditional on PC 
[beta_t,beta_new,lambda_t,V_t,Q_t] = KFS_parameters(YX,FPC,l,nfac,nlag,y_true,k,m,p,q,r,t,lambda_0,beta_0,V_0,Q_0);
% ====| STEP 1: Update Factors Conditional on TV-Parameters   
[factor_new,Sf_t_new] = KFS_factors(YX,lambda_t,beta_t,V_t,Q_t,nlag,k,r,q,t,factor_0);
toc
%% ======================== END FAVAR ESTIMATION ========================

%%%check correlation with FSI%%%

    ix = find(FSI>-100,1,'first');
    it = find(FSI>-100,1,'last');
    c1=corr(factor_new(r,ix:it)',FSI(ix:it));
    if c1<0 
        factor_new(r,:)=-factor_new(r,:);
        FPCA=-FPCA;
        c2 = corr(factor_new(r,ix:it)',FSI(ix:it));
    end

%%
% TempTable = splitvars(table([factor_new(r,:)' FPCA FSI]));
TempTable = array2table([factor_new(r,:)' FPCA FSI]);
ResultTable = table2timetable(TempTable, 'RowTimes', XTable.qdate);
ResultTable.Properties.VariableNames = {'FCI', 'FPCA', 'FCI_bench'};
FCI_tt = ResultTable(:, 'FCI');
end



