function [eq_res, history] = solve_equilibrium_r(params, r_low, r_high, tol_assets, tol_r, max_iter)
% solve_equilibrium_r.m
% Solve for equilibrium annual real interest rate with bisection:
%   find r such that aggregate asset demand is approximately zero.

if nargin < 6
    max_iter = 60;
end

fprintf('\n=== Bisection for equilibrium annual interest rate ===\n');
fprintf('Initial bracket: [%.4f%%, %.4f%%]\n', 100 * r_low, 100 * r_high);

[res_low, V_low] = evaluate_rate(r_low, params, []);
[res_high, V_high] = evaluate_rate(r_high, params, []);

f_low = res_low.agg_assets_policy;
f_high = res_high.agg_assets_policy;

if f_low * f_high > 0
    error('Bisection bracket does not straddle zero aggregate assets. Try wider bounds.');
end

history.r_annual = zeros(max_iter, 1);
history.asset_demand = zeros(max_iter, 1);
history.bracket_low = zeros(max_iter, 1);
history.bracket_high = zeros(max_iter, 1);

% Warm-start guess from endpoint closer to midpoint.
V_guess = V_low;
if abs(f_high) < abs(f_low)
    V_guess = V_high;
end

eq_res = [];

for it = 1:max_iter
    r_mid = 0.5 * (r_low + r_high);
    [res_mid, V_guess] = evaluate_rate(r_mid, params, V_guess);
    f_mid = res_mid.agg_assets_policy;

    history.r_annual(it) = r_mid;
    history.asset_demand(it) = f_mid;
    history.bracket_low(it) = r_low;
    history.bracket_high(it) = r_high;

    fprintf('Iter %2d | r_mid = %8.5f%% | A_d = %+ .4e | bracket width = %.3e\n', ...
        it, 100 * r_mid, f_mid, r_high - r_low);

    if abs(f_mid) < tol_assets || (r_high - r_low) < tol_r
        eq_res = res_mid;
        eq_res.bisect_iter = it;
        fprintf('Bisection converged at iter %d.\n', it);
        break;
    end

    if f_low * f_mid <= 0
        r_high = r_mid;
        f_high = f_mid;
        V_high = V_guess;
    else
        r_low = r_mid;
        f_low = f_mid;
        V_low = V_guess;
    end
end

if isempty(eq_res)
    % Return the last midpoint if max_iter reached
    eq_res = res_mid;
    eq_res.bisect_iter = max_iter;
    fprintf('WARNING: Bisection hit max_iter = %d\n', max_iter);
end

% Trim history vectors to used length
n_used = eq_res.bisect_iter;
history.r_annual = history.r_annual(1:n_used);
history.asset_demand = history.asset_demand(1:n_used);
history.bracket_low = history.bracket_low(1:n_used);
history.bracket_high = history.bracket_high(1:n_used);

fprintf('Equilibrium annual rate: %.5f%%\n', 100 * eq_res.r_annual);
fprintf('Equilibrium model-period rate: %.8f\n', eq_res.r_model);
fprintf('Residual aggregate assets: %.4e\n', eq_res.agg_assets_policy);
fprintf('====================================================\n\n');

end
