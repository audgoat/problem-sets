% main_part_g.m
% Huggett problem set extension:
%   Part (g): Sample paths and expected trajectories by initial asset quartile

clear;
clc;

save_dir = pwd;

% Load baseline equilibrium if available, otherwise compute it.
if exist(fullfile(save_dir, 'baseline_equilibrium.mat'), 'file')
    load(fullfile(save_dir, 'baseline_equilibrium.mat'), 'params', 'eq_res');
else
    beta = 0.9932;
    sigma = 1.5;
    phi = 4;
    params = setup_huggett_params(beta, sigma, phi);
    [eq_res, ~] = solve_equilibrium_r(params, -0.01, 0.04, 1e-5, 1e-6, 50);
end

A = params.A;
g = eq_res.g;
Pi = params.Pi;
psi_vec = eq_res.psi_vec;

N_a = length(A);
N_y = length(params.y);
N_state = N_a * N_y;

% Build state-wise asset values for weighted quartiles.
a_state = zeros(N_state, 1);
for iy = 1:N_y
    idx1 = 1 + (iy - 1) * N_a;
    idx2 = iy * N_a;
    a_state(idx1:idx2) = A;
end

q25 = weighted_quantile(a_state, psi_vec, 0.25);
q75 = weighted_quantile(a_state, psi_vec, 0.75);

% Operational definition:
% - bottom quartile initial states: all (a,y) with a <= q25
% - top quartile initial states: all (a,y) with a >= q75
idx_bottom = find(a_state <= q25);
idx_top = find(a_state >= q75);

p_bottom = psi_vec(idx_bottom);
p_bottom = p_bottom / sum(p_bottom);

p_top = psi_vec(idx_top);
p_top = p_top / sum(p_top);

T = 60;
rng(713);  % fixed seed for reproducibility

% One sample path from each quartile group
s0_bottom = idx_bottom(sample_discrete(p_bottom));
s0_top = idx_top(sample_discrete(p_top));

iy0_bottom = floor((s0_bottom - 1) / N_a) + 1;
ia0_bottom = s0_bottom - (iy0_bottom - 1) * N_a;
a0_bottom = A(ia0_bottom);

iy0_top = floor((s0_top - 1) / N_a) + 1;
ia0_top = s0_top - (iy0_top - 1) * N_a;
a0_top = A(ia0_top);

sim_bottom = simulate_individual_path(A, g, Pi, a0_bottom, iy0_bottom, T);
sim_top = simulate_individual_path(A, g, Pi, a0_top, iy0_top, T);

% Expected trajectories by Monte Carlo averaging from quartile-specific starts
N_sim = 1000;
exp_bottom = expected_trajectory(A, g, Pi, idx_bottom, p_bottom, T, N_sim);
exp_top = expected_trajectory(A, g, Pi, idx_top, p_top, T, N_sim);

tgrid = (0:(T - 1))';

fig = figure('Color', 'w');
hold on;
plot(tgrid, sim_bottom.a_path, '--', 'LineWidth', 1.5, 'Color', [0.15 0.45 0.85]);
plot(tgrid, sim_top.a_path, '--', 'LineWidth', 1.5, 'Color', [0.90 0.40 0.15]);
plot(tgrid, exp_bottom.mean_a, '-', 'LineWidth', 2.4, 'Color', [0.05 0.25 0.65]);
plot(tgrid, exp_top.mean_a, '-', 'LineWidth', 2.4, 'Color', [0.70 0.20 0.05]);

xlabel('Periods (2-month units)', 'FontSize', 12);
ylabel('Assets, a_t', 'FontSize', 12);
title('Part (g): Sample and Expected Asset Trajectories', 'FontSize', 13);
legend({'Sample path: bottom quartile start', ...
        'Sample path: top quartile start', ...
        'Expected path: bottom quartile start', ...
        'Expected path: top quartile start'}, ...
        'Location', 'best');
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);
hold off;

saveas(fig, fullfile(save_dir, 'part_g_paths_and_expected_trajectories.png'));
saveas(fig, fullfile(save_dir, 'part_g_paths_and_expected_trajectories.pdf'));

fprintf('\nPart (g) complete.\n');
fprintf('Weighted quartiles from stationary distribution:\n');
fprintf('  Q25 = %.4f, Q75 = %.4f\n', q25, q75);
fprintf('Saved figure: part_g_paths_and_expected_trajectories.png\n');
