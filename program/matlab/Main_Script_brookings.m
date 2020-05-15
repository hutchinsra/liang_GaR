% US only
close all; clear all; clc;
% aux.MainPath = '/Users/malcalakovalski/Documents/GitHub/liang_GaR/'; %Add main file path to aux-structure
aux.MainPath = 'V:/jcheng/liang_GaR/'; 
aux.MatlabPath = [aux.MainPath,'program/matlab/']; %Add matlab file path to aux-structure
cd(aux.MatlabPath) %Change pwd to matlab folder
ENVIROMENT_brookings; %Load in environment variables

aux.InputFileName = 'InputData_CISS.xlsx'; %Add the name of raw data file to aux-structure
aux.OutputFileName = 'Result.xlsx'; %Add the name of the desired output file to aux-structure
% do not need to change unless other specification(s) needed
aux.OldRange = timerange(datetime('1/1/1975', 'InputFormat', 'MM/dd/uuuu'), ...
    datetime('10/1/2014', 'InputFormat', 'MM/dd/uuuu'), 'closed');	%Time range
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
[Params.NewData, Params.OldData, Params.UpdateData] = DataProcess_brookings(aux);

% 2. Growth-at-Risk: Time Series
get_gar_ts_brookings(aux, Params);

% 3. Coefficient with Bootstrap
get_gar_coefficient(aux, Params);

disp('End of Code! :)')


