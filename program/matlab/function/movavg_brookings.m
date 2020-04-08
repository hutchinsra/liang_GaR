function y = movavg_brookings(data,type,lag)
    
    y = nan(length(data),1); %vector of NaN same length as input data

    nums = find(~isnan(data)); %position(s) of non-missing values
    
        st = nums(1); %position of first non-missing value
        ed = nums(end); %position of last non-missing value
    
    for i = st:ed-lag+1 %backward looking movavg, so no output for first lag-1 entries
        
        y(i+lag-1,1) = nansum(data(i:i+lag-1)) / lag;
        
    end

end