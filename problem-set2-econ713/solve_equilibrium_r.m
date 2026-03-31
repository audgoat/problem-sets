function [eq_res, history] = solve_equilibrium_r(params, r_low, r_high, tol_assets, tol_r, max_iter)
% solve_equilibrium_r.m
% Solve for equilibrium annual real interest rate with bisection:
%   find annualized r such that aggregate asset demand is approximately zero.
%
% Important rate convention:
%   Inputs r_low and r_high are ANNUAL net rates.
%   Internally, each annual rate is converted to model-period (2-month) net rate:
%       r_model = (1 + r_annual)^(1/6) - 1

if nargin < 6
    max_iter = 60;
end

fprintf('\n=== Bisection for equilibrium annual interest rate ===\n');
fprintf('Initial bracket: [%.4f%%, %.4f%%]\n', 100 * r_low, 100 * r_high);
fprintf('Rate convention: inputs are annual net rates; model period is two months.\n');
initial_r_low = r_low;
initial_r_high = r_high;

% ---------------------------------------------------------------------
% 1) Pre-bisection scan(s) on annual-rate grids to detect a sign change.
%    If needed, expand lower bound as requested:
%      first [-5%, 4%], then [-10%, 4%] (annualized).
% ---------------------------------------------------------------------
n_scan = 21;
scan_bounds = [r_low, r_high];
scan_labels = {'Initial scan interval'};

if r_low > -0.05
    scan_bounds = [scan_bounds; -0.05, r_high];
    scan_labels{end + 1} = 'Rescan interval (expanded lower bound)';
end
if r_low > -0.10
    scan_bounds = [scan_bounds; -0.10, r_high];
    scan_labels{end + 1} = 'Rescan interval (further expanded lower bound)';
end

left_idx = [];
right_idx = [];
sign_change_found = false;
scan_used = struct();
history.scan_attempts = cell(size(scan_bounds, 1), 1);

V_guess = [];
for iscan = 1:size(scan_bounds, 1)
    r_scan_low = scan_bounds(iscan, 1);
    r_scan_high = scan_bounds(iscan, 2);

    % Skip redundant scans if interval did not actually expand.
    if iscan > 1 && abs(r_scan_low - scan_bounds(iscan - 1, 1)) < 1e-14
        continue;
    end

    fprintf('\n%s: [%.4f%%, %.4f%%] annualized\n', scan_labels{iscan}, 100 * r_scan_low, 100 * r_scan_high);
    fprintf('Pre-bisection diagnostics on candidate annual rates:\n');
    fprintf('%12s %16s %16s %18s\n', 'r_annual(%)', 'r_model(net)', 'R_model(gross)', 'A(r)');

    r_scan = linspace(r_scan_low, r_scan_high, n_scan)';
    A_scan = zeros(n_scan, 1);
    r_model_scan = zeros(n_scan, 1);
    r_gross_scan = zeros(n_scan, 1);

    for i = 1:n_scan
        [res_i, V_guess] = evaluate_rate(r_scan(i), params, V_guess);
        A_scan(i) = res_i.agg_assets_policy;
        r_model_scan(i) = res_i.r_model;
        r_gross_scan(i) = 1 + res_i.r_model;

        fprintf('%12.6f %16.8f %16.8f %18+.6e\n', ...
            100 * r_scan(i), r_model_scan(i), r_gross_scan(i), A_scan(i));
    end

    % Store each scan attempt in history.
    scan_info = struct();
    scan_info.r_annual = r_scan;
    scan_info.r_model_net = r_model_scan;
    scan_info.R_model_gross = r_gross_scan;
    scan_info.asset_demand = A_scan;
    scan_info.interval = [r_scan_low, r_scan_high];
    history.scan_attempts{iscan} = scan_info;

    % Search adjacent points for sign change.
    left_idx = [];
    right_idx = [];
    for i = 1:(n_scan - 1)
        f_i = A_scan(i);
        f_ip1 = A_scan(i + 1);

        if f_i == 0
            left_idx = i;
            right_idx = i;
            break;
        end

        if f_i * f_ip1 < 0 || f_ip1 == 0
            left_idx = i;
            right_idx = i + 1;
            break;
        end
    end

    if ~isempty(left_idx)
        sign_change_found = true;
        scan_used.r_scan = r_scan;
        scan_used.A_scan = A_scan;
        scan_used.r_model_scan = r_model_scan;
        scan_used.r_gross_scan = r_gross_scan;
        scan_used.interval = [r_scan_low, r_scan_high];
        scan_used.attempt = iscan;
        break;
    end
end

% Prepare summary scan diagnostics on the scan used (or last attempted).
if sign_change_found
    history.scan_r_annual = scan_used.r_scan;
    history.scan_r_model_net = scan_used.r_model_scan;
    history.scan_R_model_gross = scan_used.r_gross_scan;
    history.scan_asset_demand = scan_used.A_scan;
else
    % Last available scan attempt
    last_scan = history.scan_attempts{find(~cellfun(@isempty, history.scan_attempts), 1, 'last')};
    history.scan_r_annual = last_scan.r_annual;
    history.scan_r_model_net = last_scan.r_model_net;
    history.scan_R_model_gross = last_scan.R_model_gross;
    history.scan_asset_demand = last_scan.asset_demand;
end

if ~sign_change_found
    % 3) No sign change found: do not fail hard; return clear diagnostics.
    eq_res = struct();
    eq_res.converged = false;
    eq_res.message = '';
    eq_res.bisect_iter = 0;
    eq_res.r_annual = NaN;
    eq_res.r_model = NaN;
    eq_res.sign_change_found = false;
    eq_res.bracket_initial = [initial_r_low, initial_r_high];
    eq_res.bracket_used = [NaN, NaN];
    eq_res.scan_r_annual = history.scan_r_annual;
    eq_res.scan_r_model_net = history.scan_r_model_net;
    eq_res.scan_R_model_gross = history.scan_R_model_gross;
    eq_res.scan_asset_demand = history.scan_asset_demand;

    if all(eq_res.scan_asset_demand > 0)
        eq_res.message = 'No sign change: A(r) is strictly positive on tested interval.';
    elseif all(eq_res.scan_asset_demand < 0)
        eq_res.message = 'No sign change: A(r) is strictly negative on tested interval.';
    else
        eq_res.message = 'No adjacent sign change detected on scan grid (possible near-zero/touching case).';
    end

    fprintf('\n%s\n', eq_res.message);
    fprintf('Final tested annual interval: [%.4f%%, %.4f%%]\n', ...
        100 * history.scan_r_annual(1), 100 * history.scan_r_annual(end));
    fprintf('Bisection skipped. Consider widening interval or refining scan grid.\n\n');

    history.r_annual = [];
    history.asset_demand = [];
    history.bracket_low = [];
    history.bracket_high = [];
    return;
end

% 4) Use detected sign-change pair as bisection bracket.
if left_idx == right_idx
    % Exact grid root found.
    [eq_res, ~] = evaluate_rate(scan_used.r_scan(left_idx), params, V_guess);
    eq_res.converged = true;
    eq_res.bisect_iter = 0;
    eq_res.message = 'Exact zero found on pre-bisection grid.';
    eq_res.sign_change_found = true;
    eq_res.bracket_initial = [initial_r_low, initial_r_high];
    eq_res.bracket_used = [scan_used.r_scan(left_idx), scan_used.r_scan(left_idx)];
    eq_res.scan_r_annual = scan_used.r_scan;
    eq_res.scan_r_model_net = scan_used.r_model_scan;
    eq_res.scan_R_model_gross = scan_used.r_gross_scan;
    eq_res.scan_asset_demand = scan_used.A_scan;

    fprintf('\n%s\n', eq_res.message);
    fprintf('Equilibrium annual rate: %.5f%%\n', 100 * eq_res.r_annual);
    fprintf('Equilibrium model-period rate: %.8f\n', eq_res.r_model);
    fprintf('Residual aggregate assets: %.4e\n\n', eq_res.agg_assets_policy);

    history.r_annual = [];
    history.asset_demand = [];
    history.bracket_low = [];
    history.bracket_high = [];
    return;
end

r_low = scan_used.r_scan(left_idx);
r_high = scan_used.r_scan(right_idx);
fprintf('\nAuto-selected bisection bracket from scan: [%.5f%%, %.5f%%]\n', 100 * r_low, 100 * r_high);

[res_low, V_low] = evaluate_rate(r_low, params, []);
[res_high, V_high] = evaluate_rate(r_high, params, []);
f_low = res_low.agg_assets_policy;
f_high = res_high.agg_assets_policy;

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
    eq_res.converged = false;
    eq_res.message = 'Bisection hit max_iter before meeting tolerances.';
    fprintf('WARNING: Bisection hit max_iter = %d\n', max_iter);
else
    eq_res.converged = true;
    eq_res.message = 'Bisection converged.';
end

eq_res.sign_change_found = true;
eq_res.bracket_initial = [initial_r_low, initial_r_high];
eq_res.bracket_used = [history.bracket_low(end), history.bracket_high(end)];
eq_res.scan_r_annual = scan_used.r_scan;
eq_res.scan_r_model_net = scan_used.r_model_scan;
eq_res.scan_R_model_gross = scan_used.r_gross_scan;
eq_res.scan_asset_demand = scan_used.A_scan;

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
