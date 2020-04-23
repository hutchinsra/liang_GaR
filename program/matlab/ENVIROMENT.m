%This script sets all the environment variables and options for plotting

%% ========================== ENVIROMENT ==================================%%
%Paths
cd(aux.MainPath)

if exist('function','dir')==0
    mkdir function
end
addpath([aux.MainPath,'function'])

% if exist('data','dir')==0
%     mkdir data
% end
% aux.DataPath = [aux.MainPath, 'data\'];
%aux.DataPath = [aux.MainPath, 'data\']; %Add data file path to aux-structure
aux.DataPath = [aux.MainPath, 'data/']; %Add data file path to aux-structure
addpath(aux.DataPath) %Add data folder to search path

if exist('Output', 'dir') == 0
    mkdir('Output')
end
addpath('Output')
%aux.OutPath = [aux.MainPath, 'Output\'];
aux.OutPath = [aux.MainPath, 'Output/'];

% if exist(['output\', aux.OutFolderName],'dir')==0
%     mkdir(['output\', aux.OutFolderName])
% end
% aux.OutPath = strcat(aux.MainPath, 'output\', aux.OutFolderName, '\');

% addpath([aux.MainPath, 'function\MS_Regress-Matlab-master\m_Files'])

%Figure Settings
set(0,          'defaultAxesFontName', 'Times');
set(0,          'defaultLegendFontSize', 20)
set(0,          'defaultLegendBox', 'off')
set(0,          'defaultLineLineWidth',2)
set(0,          'defaultFigureposition',[208 70 1120 840])
set(0,          'defaultFigurepapersize',[9.8 7.8])
set(0,          'defaultScatterSizeData',400)
set(0,          'DefaultAxesColorOrder', [0 0.447 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.96 0.73 1]);
set(0,          'DefaultAxesLineStyleOrder', '-|--|:|-.');
setappdata(0,   'defaultAxesXTickFontSize', 15)
set(0,          'defaultAxesFontSize', 15)
setappdata(0,   'defaultAxesYTickFontSize', 15)
set(0,          'DefaultLineMarkerSize', 3);

% Set Color
aux.Navy        = [0.0000 0.4470 0.7410];
aux.Orange      = [0.8500 0.3250 0.0980];
aux.Yellow      = [0.9290 0.6940 0.1250];
aux.Purple      = [0.4940 0.1840 0.5560];
aux.Green       = [0.4660 0.6740 0.1880];
aux.Blue        = [0.3010 0.7450 0.9330];
aux.Rasberry	= [0.6350 0.0780 0.1840];

aux.Alphabet = 'ABCDEFGHIGKLMNOPQRSTUVWXYZ';
%%==================== END OF ENVIROMENT SETTING ==========================%%
