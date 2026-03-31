function q = weighted_quantile(x, w, p)
% weighted_quantile.m
% Weighted quantile at probability p in [0,1].

[x_sorted, order] = sort(x(:));
w_sorted = w(order);
w_sorted = w_sorted / sum(w_sorted);

cdf = cumsum(w_sorted);
idx = find(cdf >= p, 1, 'first');

if isempty(idx)
    q = x_sorted(end);
else
    q = x_sorted(idx);
end

end
