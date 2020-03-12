function y = normalize_brookings(x)

    mu = nanmean(x);
    sigma = nanstd(x);
    y = (x - mu) ./ sigma;

end