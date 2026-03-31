function [res, V_out] = evaluate_rate(r_annual, params, V_init)
% evaluate_rate.m
% Evaluate one candidate annual interest rate:
%   annual rate -> model-period rate -> household solve -> invariant dist
%   -> aggregate assets and sanity checks.

if nargin < 3
    V_init = [];
end

% Annual real rate to model-period (2-month) net rate
r_model = (1 + r_annual)^(1 / 6) - 1;

[V, g, vfi_stats] = solve_household_fixed_r( ...
    params.A, params.y, params.Pi, params.beta, params.sigma, r_model, params.phi, ...
    params.vfi_tol, params.vfi_max_iter, params.vfi_print_every, V_init);

C = compute_consumption_policy(params.A, params.y, g, r_model);

[P, P_checks] = compute_transition_matrix(params.A, g, params.Pi);
[psi_vec, psi_mat, psi_stats] = stationary_distribution( ...
    P, length(params.A), length(params.y), ...
    params.dist_tol, params.dist_max_iter, params.dist_print_every);

agg = aggregate_assets(params.A, g, psi_vec);

res.r_annual = r_annual;
res.r_model = r_model;
res.V = V;
res.g = g;
res.C = C;
res.P = P;
res.psi_vec = psi_vec(:);   % Column vector over joint states (a,y)
res.mu = res.psi_vec;       % Backward-compatible alias
res.psi_mat = psi_mat;
res.vfi_stats = vfi_stats;
res.psi_stats = psi_stats;

res.agg_assets_policy = agg.agg_assets_policy;
res.agg_assets_current = agg.agg_assets_current;
res.agg_assets_difference = agg.abs_difference;

res.checks.max_abs_row_sum_error = P_checks.max_abs_row_sum_error;
res.checks.psi_sum_error = abs(sum(res.psi_vec) - 1);
res.checks.min_consumption = min(C(:));

V_out = V;

end
