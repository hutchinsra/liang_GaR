function [] = get_gar_ts_brookings(aux, Params)
    % Extract aux and Params variables
    OutputFile = [aux.OutPath,aux.OutputFileName];
    Model = aux.Model;
    CaliDataName = aux.CaliDataName;
    eval(['CaliData = Params.', CaliDataName, ';'])
    NewData = Params.NewData;
    XData_old = CaliData{:, Model};

    %% 1. Calibrate with old data
    bb_mat_old = [];
    QQ = [0.05];
    for h = 1:12
        yname = ['yyy_', num2str(h)];
        YData = CaliData{:, yname};
        for i_q = 1:length(QQ)
            qq = QQ(i_q);
            b_q = rq(XData_old, YData, qq);
            bb_mat_old(h, :, i_q) = b_q'*100;
        end
    end

    XData_new = NewData{:, Model};
    % 3. Time Serie
    HH = aux.HH;
    VarNames = [];
    yhat_mat = NaN(length(XData_new) + max(HH), length(HH));
    for i_h = 1:length(HH)
        bb = bb_mat_old(HH(i_h), :, 1);
        yhat = [NaN(HH(i_h), 1); XData_new * bb'];
        yhat_mat(1:length(yhat), i_h) = yhat;
        VarNames{i_h} = ['GaR_h', num2str(HH(i_h))];
    end
    Date = NewData.Properties.RowTimes(1)+calquarters(0:length(yhat_mat)-1);

    Yhat_tt = timetable(Date', yhat_mat(:,1), yhat_mat(:,2));
    Yhat_tt.Properties.VariableNames = VarNames;
    Yhat_table = timetable2table(Yhat_tt, 'ConvertRowTimes', true);
    
    writetable(Yhat_table, OutputFile, 'sheet', 'GaR_TimeSeries');
    disp('End of update GaR!! :)')
end

