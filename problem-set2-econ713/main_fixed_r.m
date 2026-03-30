% main_fixed_r.m
% Huggett (1993) household problem at a fixed interest rate.
% This script solves the household Bellman equation only (no market clearing loop).

clear;
clc;

%% 1) Parameters
sigma = 1.5;          % CRRA coefficient
beta = 0.9932;        % Discount factor (per model period)
phi = 4;              % Borrowing limit: a' >= -phi

% Income states and Markov transition matrix
y = [0.1; 1.0];       % y(1) = low income, y(2) = high income
Pi = [0.5,   0.5;
      0.075, 0.925];

% Convert annualized net rate (2.3%) into two-month net rate
r = (1.023)^(1/6) - 1;

%% 2) Asset grid
% Choice rationale:
% - Lower bound is exactly the borrowing limit.
% - Upper bound is set to 40 to reduce truncation at high assets for this calibration.
% - 400 points is a good clarity-first default that usually gives smooth policy curves.
a_min = -phi;
a_max = 40;
N_a = 400;
A = linspace(a_min, a_max, N_a)';   % Column vector (N_a x 1)

%% 3) Solver controls
tol = 1e-6;
max_iter = 2000;
print_every = 25;

%% 4) Solve household Bellman problem at fixed r
[V, g, stats] = solve_household_fixed_r(A, y, Pi, beta, sigma, r, phi, tol, max_iter, print_every);

%% 5) Compute consumption policy from budget constraint
C = compute_consumption_policy(A, y, g, r);

%% 6) Run diagnostics/sanity checks
tol_mono = 1e-8;
run_sanity_checks(A, g, C, phi, r, tol_mono);

%% 7) Plot and save policy figures
save_dir = pwd;  % Save into current project directory
plot_huggett_policies(A, g, C, save_dir);

%% 8) Print short run summary
fprintf('\n===== Fixed-r Huggett Household Solver Summary =====\n');
fprintf('Converged: %d\n', stats.converged);
fprintf('Iterations: %d\n', stats.iter);
fprintf('Final sup norm: %.3e\n', stats.supnorm);
fprintf('Model-period net interest rate r: %.8f\n', r);
fprintf('Asset grid: [%g, %g], N = %d\n', a_min, a_max, N_a);
fprintf('===================================================\n\n');
