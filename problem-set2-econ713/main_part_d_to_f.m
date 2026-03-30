% main_part_d_to_f.m
% Huggett problem set extension:
%   Part (d): Aggregate assets at annual rate 2.3%
%   Part (e): Asset demand curve and stationary asset distribution at equilibrium
%   Part (f): Endogenous equilibrium annual interest rate via bisection

clear;
clc;

%% Shared parameters (baseline)
beta = 0.9932;
sigma = 1.5;
phi = 4;
params = setup_huggett_params(beta, sigma, phi);

save_dir = pwd;

%% Part (d): Aggregate assets at annual rate 2.3%
r_annual_baseline = 0.023;
fprintf('\n========== PART (d): Fixed annual rate 2.3%% ==========\n');
[res_d, V_guess] = evaluate_rate(r_annual_baseline, params, []);

fprintf('Annual rate: %.4f%%\n', 100 * r_annual_baseline);
fprintf('Model-period rate: %.8f\n', res_d.r_model);
fprintf('Aggregate assets (sum g*psi): %+ .6e\n', res_d.agg_assets_policy);
fprintf('Consistency check (sum a*psi): %+ .6e\n', res_d.agg_assets_current);
fprintf('|Difference|: %.3e\n', res_d.agg_assets_difference);
fprintf('Row-sum max error in P: %.3e\n', res_d.checks.max_abs_row_sum_error);
fprintf('Distribution sum error: %.3e\n', res_d.checks.psi_sum_error);
fprintf('Minimum consumption: %.3e\n', res_d.checks.min_consumption);
fprintf('=======================================================\n');

%% Part (e): Asset demand curve over annual-rate grid
fprintf('\n========== PART (e): Asset demand curve ==========\n');
r_grid_annual = linspace(-0.01, 0.04, 21)';
asset_demand = zeros(length(r_grid_annual), 1);

for ir = 1:length(r_grid_annual)
    fprintf('\nRate-grid point %d/%d | annual r = %.4f%%\n', ir, length(r_grid_annual), 100 * r_grid_annual(ir));
    [res_tmp, V_guess] = evaluate_rate(r_grid_annual(ir), params, V_guess);
    asset_demand(ir) = res_tmp.agg_assets_policy;
    fprintf('Aggregate assets: %+ .6e\n', asset_demand(ir));
end

%% Part (f): Solve equilibrium rate by bisection
fprintf('\n========== PART (f): Endogenous equilibrium r ==========\n');
tol_assets = 1e-5;
tol_r = 1e-6;
max_bisect_iter = 50;
[eq_res, bisect_history] = solve_equilibrium_r(params, -0.01, 0.04, tol_assets, tol_r, max_bisect_iter);

fprintf('\nEquilibrium annual rate (bisection): %.6f%%\n', 100 * eq_res.r_annual);
fprintf('Equilibrium model-period rate: %.8f\n', eq_res.r_model);
fprintf('Residual aggregate assets: %+ .6e\n', eq_res.agg_assets_policy);

% Plot demand curve with equilibrium marker
plot_asset_demand_curve(r_grid_annual, asset_demand, eq_res.r_annual, save_dir);

% Stationary asset distribution at equilibrium (part e output)
psi_a_eq = sum(eq_res.psi_mat, 2);
fig_eq = figure('Color', 'w');
plot(params.A, psi_a_eq, 'LineWidth', 2.0, 'Color', [0.10 0.35 0.75]);
xlabel('Assets, a', 'FontSize', 12);
ylabel('Stationary density (mass on grid)', 'FontSize', 12);
title('Stationary Asset Distribution at Equilibrium Rate', 'FontSize', 13);
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);
saveas(fig_eq, fullfile(save_dir, 'stationary_asset_distribution_equilibrium.png'));
saveas(fig_eq, fullfile(save_dir, 'stationary_asset_distribution_equilibrium.pdf'));

% Save baseline objects for parts (g), (h), (i), (j)
save(fullfile(save_dir, 'baseline_equilibrium.mat'), ...
    'params', 'res_d', 'eq_res', 'r_grid_annual', 'asset_demand', 'bisect_history');

fprintf('\nSaved baseline objects to baseline_equilibrium.mat\n');
fprintf('Saved figures:\n');
fprintf('  asset_demand_curve.png\n');
fprintf('  stationary_asset_distribution_equilibrium.png\n');

