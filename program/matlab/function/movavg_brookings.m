function y = movavg_brookings(data,type,lag)
    
    y = nan(length(data),1);

    for i = lag:length(data)
        
        y(i,1) = nansum(data(i-7:i-1)) / (lag-1);
        
    end

end