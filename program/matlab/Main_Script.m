% US only
close all; clear all; clc;

aux.MainPath = [pwd,'/'];
cd(aux.MainPath)

% aux.MainPath = [pwd,'\'];
% cd(aux.MainPath)
aux.MainPath = 'V:\jcheng\liang_GaR\'; %Add main file path to aux-structure
aux.MatlabPath = [aux.MainPath,'program\matlab\']; %Add matlab file path to aux-structure
cd(aux.MatlabPath) %Change pwd to matlab folder

ENVIROMENT;

aux.InputFileName = 'InputData.xlsx'; 
aux.OutputFileName = 'Result.xlsx';
% do not need to change unless other specification(s) needed
aux.OldRange = timerange(datetime('1/1/1975', 'InputFormat', 'MM/dd/uuuu'), ...
    datetime('10/1/2014', 'InputFormat', 'MM/dd/uuuu'), 'closed');	
% Model specification
aux.Model = {'dlgdp', 'infl', 'fci', 'CredGr', 'interact', 'cons'};	

% Option(s) for GaR update
aux.CaliDataName = 'OldData';   % Data used for calibration: Select between "OldData" and "UpdateData"
aux.HH = [4 8];                 % Horizons to project

% Option(s) for Coefficients with Bootstrap
aux.SampleDataName = 'OldData'; % Select between "OldData" and "UpdateData"
aux.QQ = [0.05 0.5];            % Specify which coefficients of percentiles will report
aux.N_bs = 100;                 % Specify the number of bootstrap resamplings
aux.W_bs = 4;                   % Specify the width of bootstrap block

%% Update
% 1. Read data
[Params.NewData, Params.OldData, Params.UpdateData] = DataProcess(aux);

% 2. Growth-at-Risk: Time Series
get_gar_timeseries(aux, Params);

% 3. Coefficient with Bootstrap
get_gar_coefficient(aux, Params);

disp('End of Code! :)')


