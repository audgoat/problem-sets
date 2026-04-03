% main_part_h_to_j.m
% Huggett problem set extension:
%   Part (h): Counterfactual equilibria (phi=6, sigma=3) + distribution comparison
%   Part (i): MPC distribution comparison
%   Part (j): Welfare gain from complete markets (consumption equivalent)

clear;
clc;

save_dir = pwd;

%% Baseline economy
beta = 0.9932;
sigma0 = 1.5;
phi0 = 4;
params0 = setup_huggett_params(beta, sigma0, phi0);
[res0, hist0] = solve_equilibrium_r(params0, -0.01, 0.04, 1e-5, 1e-6, 50); %#ok<NASGU>
ok0 = isfield(res0, 'converged') && res0.converged;
if ~ok0
    warning('Baseline equilibrium did not converge: %s', res0.message);
end

%% Counterfactual 1: phi = 6 (all else fixed)
params_phi6 = setup_huggett_params(beta, sigma0, 6);
params_phi6.a_max = 45;
params_phi6.A = linspace(params_phi6.a_min, params_phi6.a_max, params_phi6.N_a)';
[res_phi6, hist_phi6] = solve_equilibrium_r(params_phi6, -0.01, 0.04, 1e-5, 1e-6, 50); %#ok<NASGU>
ok_phi6 = isfield(res_phi6, 'converged') && res_phi6.converged;
if ~ok_phi6
    warning('phi=6 equilibrium did not converge: %s', res_phi6.message);
end

%% Counterfactual 2: sigma = 3 (all else fixed)
params_sig3 = setup_huggett_params(beta, 3.0, phi0);
[res_sig3, hist_sig3] = solve_equilibrium_r(params_sig3, -0.01, 0.04, 1e-5, 1e-6, 50); %#ok<NASGU>
ok_sig3 = isfield(res_sig3, 'converged') && res_sig3.converged;
if ~ok_sig3
    warning('sigma=3 equilibrium did not converge: %s', res_sig3.message);
end

%% Part (h): Print table-style moments and plot stationary distributions
fprintf('\n================ PART (h): Counterfactual Comparison ================\n');
if ok0
    print_case_moments('Baseline', params0, res0);
else
    fprintf('\n[Baseline]\n  Skipped moments (no convergence).\n');
end

if ok_phi6
    print_case_moments('phi = 6', params_phi6, res_phi6);
else
    fprintf('\n[phi = 6]\n  Skipped moments (no convergence).\n');
end

if ok_sig3
    print_case_moments('sigma = 3', params_sig3, res_sig3);
else
    fprintf('\n[sigma = 3]\n  Skipped moments (no convergence).\n');
end
fprintf('=====================================================================\n');

if ok0 && ok_phi6 && ok_sig3
    psiA0 = sum(res0.psi_mat, 2);
    psiA_phi6 = sum(res_phi6.psi_mat, 2);
    psiA_sig3 = sum(res_sig3.psi_mat, 2);
    plot_stationary_asset_distributions(params0.A, psiA0, params_phi6.A, psiA_phi6, params_sig3.A, psiA_sig3, save_dir);
else
    fprintf('Skipping stationary-distribution comparison plot: at least one case did not converge.\n');
end

%% Part (i): MPC distributions
if ok0 && ok_phi6 && ok_sig3
    da0 = 0.5 * (params0.A(2) - params0.A(1));
    da1 = 0.5 * (params_phi6.A(2) - params_phi6.A(1));
    da2 = 0.5 * (params_sig3.A(2) - params_sig3.A(1));

    mpc0 = compute_mpcs(params0.A, res0.C, res0.r_model, da0);
    mpc_phi6 = compute_mpcs(params_phi6.A, res_phi6.C, res_phi6.r_model, da1);
    mpc_sig3 = compute_mpcs(params_sig3.A, res_sig3.C, res_sig3.r_model, da2);

    plot_mpc_distributions(mpc0(:), res0.psi_vec(:), mpc_phi6(:), res_phi6.psi_vec(:), mpc_sig3(:), res_sig3.psi_vec(:), save_dir);

    fprintf('\n================ PART (i): MPC Moments ================\n');
    print_mpc_diagnostics('Baseline', mpc0, res0.psi_vec, params0.A, params0.phi);
    print_mpc_diagnostics('phi = 6', mpc_phi6, res_phi6.psi_vec, params_phi6.A, params_phi6.phi);
    print_mpc_diagnostics('sigma = 3', mpc_sig3, res_sig3.psi_vec, params_sig3.A, params_sig3.phi);
    fprintf('=======================================================\n');
else
    fprintf('\nSkipping PART (i): needs converged baseline, phi=6, and sigma=3 cases.\n');
    mpc0 = [];
    mpc_phi6 = [];
    mpc_sig3 = [];
end

%% Part (j): Welfare complete vs incomplete (baseline)
if ok0
    welfare = welfare_complete_vs_incomplete(res0.V, res0.psi_vec, params0.y, params0.Pi, params0.beta, params0.sigma);

    fprintf('\n================ PART (j): Welfare Comparison ================\n');
    fprintf('Incomplete-markets expected value W_IM: %.6f\n', welfare.W_IM);
    fprintf('Complete-markets expected value W_CM:   %.6f\n', welfare.W_CM);
    fprintf('Complete-markets constant consumption c_CM: %.6f\n', welfare.c_CM);
    fprintf('Consumption-equivalent welfare gain lambda: %.4f%%\n', 100 * welfare.lambda);
    fprintf('==============================================================\n');
else
    fprintf('\nSkipping PART (j): baseline equilibrium did not converge.\n');
    welfare = struct();
end

save(fullfile(save_dir, 'counterfactual_results_h_to_j.mat'), ...
    'params0', 'params_phi6', 'params_sig3', ...
    'res0', 'res_phi6', 'res_sig3', ...
    'mpc0', 'mpc_phi6', 'mpc_sig3', 'welfare');

fprintf('\nSaved outputs to counterfactual_results_h_to_j.mat\n');

function print_case_moments(label, params, res)
% Helper for part (h) table-like lines.

N_a = length(params.A);
N_y = length(params.y);
psi = res.psi_vec(:);

a_state = zeros(N_a * N_y, 1);
for iy = 1:N_y
    idx1 = 1 + (iy - 1) * N_a;
    idx2 = iy * N_a;
    a_state(idx1:idx2) = params.A;
end

mean_a = sum(a_state .* psi);
std_a = sqrt(sum(((a_state - mean_a).^2) .* psi));
mass_borrow = sum(psi(abs(res.g(:) + params.phi) < 1e-6));

fprintf('\n[%s]\n', label);
fprintf('  Equilibrium annual rate: %.6f%%\n', 100 * res.r_annual);
fprintf('  Model-period rate: %.8f\n', res.r_model);
fprintf('  Aggregate assets residual: %+ .6e\n', res.agg_assets_policy);
fprintf('  Mean assets: %.6f\n', mean_a);
fprintf('  Std assets: %.6f\n', std_a);
fprintf('  Mass at borrowing constraint: %.6f\n', mass_borrow);

end

function print_mpc_diagnostics(label, mpc, psi_vec, A, phi)
% Print MPC diagnostics requested for auditing part (i).

N_a = length(A);
N_y = size(mpc, 2);

weighted_mean = sum(mpc(:) .* psi_vec(:));
min_mpc = min(mpc(:));
max_mpc = max(mpc(:));

[~, ia_bc] = min(abs(A + phi));   % borrowing-constraint location a = -phi

fprintf('\n[%s MPC diagnostics]\n', label);
fprintf('  min MPC: %.6f\n', min_mpc);
fprintf('  max MPC: %.6f\n', max_mpc);
fprintf('  mean weighted MPC: %.6f\n', weighted_mean);

for iy = 1:N_y
    fprintf('  MPC at borrowing constraint (income state %d): %.6f\n', iy, mpc(ia_bc, iy));
end

end
