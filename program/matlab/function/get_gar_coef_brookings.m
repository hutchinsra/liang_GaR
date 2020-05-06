function [] = get_gar_coef_brookings(aux, Params)
    % Extract aux and Params variables
    W_bs = aux.W_bs;
    N_bs = aux.N_bs;
    SampleDataName = aux.SampleDataName;
    Model = aux.Model;
    QQ = aux.QQ;
    OutputFile = [aux.OutPath,aux.OutputFileName];
    
    %% Read Data
    eval(['SampleData = Params.', SampleDataName, ';'])
    XData = SampleData{:, Model};

    %% Calculate benchmark
    BB_benchmark = [];
    for i_q = 1:length(QQ)
        qq = QQ(i_q);
        for h = 1:12
            yname = ['yyy_', num2str(h)];
            YData = SampleData{:, yname};
            bb = rq(XData, YData, qq)*100;
            BB_benchmark(h, :, i_q) = bb';
        end
    end

    %% bootstrap
    BB_bs = []; std_bs = [];
    for i_q = 1:length(QQ)
        qq = QQ(i_q);
        for n = 1:N_bs
            indices = [1:length(XData)]';
            index_bs = block_bootstrap(indices, 1, W_bs);
            XData_bs = XData(index_bs, :);
            for h = 1:12
                yname = ['yyy_', num2str(h)];
                YData = SampleData{:, yname};
                YData_bs = YData(index_bs, :);
                bb = rq(XData_bs, YData_bs, qq) * 100;
                BB_bs(h, :, n, i_q) = bb';
            end
        end
        std_bs(:, :, i_q) = std(BB_bs(:, :, :, i_q), 0, 3);
    end

    %% Write Result
    % create variable names
    HorizonNames = repmat([1:12]',[2,1]);
    PctName = flip(sort(repmat(["5th";"50th"],[12,1])));
%     for h = 1:12
%         HorizonNames{h} = ['H', num2str(h)];
%     end
    for i_var = 1%:length(Model)
        varname = char(Model{i_var});
        ext = {'_lb','_bb','_ub'};
        for i_q = 1%:length(QQ)
            qq = QQ(i_q);
%             line1_tt = cell2table([{[num2str(qq*100), 'th Percentile Coefficient: ', varname]}, repmat({''}, 1, 11)]);
            benchmark_val = transpose(BB_benchmark(:, i_var, i_q));
            std_val = transpose(std_bs(:, i_var, i_q));
            ub_val = benchmark_val + std_val;
            lb_val = benchmark_val - std_val;
            data_tt = array2table([ub_val; benchmark_val; lb_val]');
            data_tt.Properties.VariableNames = strcat(varname,ext);
%             data_tt.Properties.RowNames = {'ub', 'bb', 'lb'};
            writetable(data_tt, OutputFile, 'sheet', 'longCoefficient', 'WriteVariableNames', true);
%             writetable(line1_tt, OutputFile, 'sheet', 'Coefficient_underlying', ...
%                 'range', ['A', num2str((5*length(QQ)+1)*(i_var-1) + 5*(i_q-1)+1)], 'WriteRowNames', false, 'WriteVariableNames', false);
%             writetable(data_tt, OutputFile, 'sheet', 'Coefficient_underlying', ...
%                 'range', ['A', num2str((5*length(QQ)+1)*(i_var-1) + 5*(i_q-1)+1+1)], 'WriteRowNames', true, 'WriteVariableNames', true);
        end
    end  
    disp('End of update GaR Coefficients! :)')
end