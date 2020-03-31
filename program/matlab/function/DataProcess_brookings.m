function [NewData, OldData, UpdateData] = DataProcess_brookings(aux)
    % Extract aux variables
    InputFileName = aux.InputFileName;
    OldRange = aux.OldRange;
    VarNames = aux.Model;

    %% Read Table
    TempTable = readtable(InputFileName, 'sheet', 'UseData'); %Read in raw data
    DataTable = table2timetable(TempTable, 'RowTimes', 'date'); %Convert to Matlab time-table
    % FCI
    TempTable = get_fci_brookings(aux);
    DataTable = synchronize(DataTable, TempTable);

    %% Transformation
    % GDPGr
    DataTable.lgdp = 4*log(DataTable.gdp); %Annualized log(GDP)
    DataTable{2:end, 'dlgdp'} = diff(DataTable.lgdp);
    DataTable.dlgdp(1) = NaN;
    for h = 1:12
        varname = ['yyy_', num2str(h)];
        tempdata = (DataTable.lgdp(h+1:end) - DataTable.lgdp(1:end-h))/h;
        DataTable{1:end-h, varname} = tempdata;
        DataTable{end-h+1:end, varname} = NaN;
    end
    % Credit GDP
    DataTable.creditGDP = DataTable.credGDP/100;
    DataTable{2:end, 'dcreditGDP'} = diff(DataTable.creditGDP);
    DataTable.dcreditGDP(1) = NaN;
    DataTable.CredGr = movavg_brookings(DataTable.dcreditGDP, 'simple', 8);

    % fci
    OldData = rmmissing(DataTable);
    OldData.fci = normalize_brookings(log(OldData.FCI + 1 - min(OldData.FCI)));
    DataTable = synchronize(DataTable, OldData(:, 'fci'));
    % read weekly NFCI
    TempTable = readtable(aux.InputFileName, 'sheet', 'NFCI_weekly');
    NFCI_w = table2timetable(TempTable, 'RowTimes', 'date');
    NFCI_q = retime(NFCI_w, 'quarterly', 'mean');
    DataTable = synchronize(DataTable, NFCI_q);
    tempfci = DataTable.fci(find(~isnan(DataTable.fci), 1, 'last')-1:end);
    tempnfci = DataTable.NFCI(find(~isnan(DataTable.fci), 1, 'last')-1:end);
    % append nfci to fci
    for i = 1:length(tempfci)
        if i == 1
            newfci(i) = tempfci(i);
        else
            newfci(i) = tempnfci(i)/tempnfci(i-1)*newfci(i-1);
        end
    end
    DataTable.fci(find(~isnan(DataTable.fci), 1, 'last')-1:end) = newfci;
    % Create Dummy
    OldData = OldData(OldRange, :);
    Treshold.high_credit = prctile(OldData.CredGr, 70);
    Treshold.loose_fci = prctile(OldData.fci, 30);
    % dummy
    OldData{:, 'interact'} = (OldData.fci < Treshold.loose_fci).*(OldData.CredGr > Treshold.high_credit); 
    DataTable{:, 'interact'} = (DataTable.fci < Treshold.loose_fci).*(DataTable.CredGr > Treshold.high_credit); 
    % cons
    OldData{:, 'cons'} = 1;
    DataTable{:, 'cons'} = 1;

    NewData = rmmissing(DataTable(:, VarNames));
    UpdateData = rmmissing(DataTable);

    disp('End of Data Processing!! :)')
end

