function idx = sample_discrete(prob_vec)
% sample_discrete.m
% Draw one index from a discrete distribution prob_vec.

u = rand;
cdf = cumsum(prob_vec(:));
idx = find(u <= cdf, 1, 'first');
if isempty(idx)
    idx = length(prob_vec);
end

end
