function out = aggregate_assets(A, g, psi_vec)
% aggregate_assets.m
% Aggregate assets using stationary distribution weights.
%
% Required measure:
%   A_d = sum_{a,y} g(a,y) * psi(a,y)
%
% Also compute consistency object:
%   E[a] = sum_{a,y} a * psi(a,y)

N_a = length(A);
N_y = size(g, 2);

psi_mat = zeros(N_a, N_y);
for iy = 1:N_y
    idx1 = 1 + (iy - 1) * N_a;
    idx2 = iy * N_a;
    psi_mat(:, iy) = psi_vec(idx1:idx2);
end

agg_assets_policy = sum(sum(g .* psi_mat));

agg_assets_current = 0;
for iy = 1:N_y
    agg_assets_current = agg_assets_current + sum(A .* psi_mat(:, iy));
end

out.agg_assets_policy = agg_assets_policy;
out.agg_assets_current = agg_assets_current;
out.abs_difference = abs(agg_assets_policy - agg_assets_current);
out.psi_mat = psi_mat;

end
