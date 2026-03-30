function run_sanity_checks(A, g, C, phi, r, tol_mono)
% run_sanity_checks.m
% Basic diagnostics for policy-function quality and feasibility.

if nargin < 6
    tol_mono = 1e-8;
end

fprintf('\n----- Sanity Checks -----\n');
fprintf('Model-period interest rate used: r = %.8f\n', r);

N_y = size(g, 2);

% 1) Consumption feasibility at computed optimum
min_c = min(C(:));
fprintf('Minimum consumption across all states: %.6e\n', min_c);
if min_c < -1e-10
    fprintf('WARNING: Negative consumption detected below tolerance.\n');
else
    fprintf('Consumption feasibility check passed (no materially negative c).\n');
end

% 2) Monotonicity of savings policy in assets
for iy = 1:N_y
    dg = diff(g(:, iy));
    bad_idx = find(dg < -tol_mono);
    if isempty(bad_idx)
        fprintf('Policy monotonicity passed for income state %d.\n', iy);
    else
        fprintf('WARNING: Policy monotonicity violations in income state %d: %d points.\n', iy, length(bad_idx));
        fprintf('  First few violating asset indices: ');
        n_show = min(5, length(bad_idx));
        fprintf('%d ', bad_idx(1:n_show));
        fprintf('\n');
        fprintf('  Corresponding asset levels (a): ');
        fprintf('%.4f ', A(bad_idx(1:n_show)));
        fprintf('\n');
    end
end

% 3) Borrowing constraint binding locations
bind_tol = 1e-8;
for iy = 1:N_y
    bind_idx = find(abs(g(:, iy) + phi) < bind_tol);
    if isempty(bind_idx)
        fprintf('Borrowing constraint does not bind (within tolerance) for income state %d.\n', iy);
    else
        fprintf('Borrowing constraint binds for income state %d at %d grid points.\n', iy, length(bind_idx));
        fprintf('  Lowest a where it binds: %.4f\n', A(bind_idx(1)));
        fprintf('  Highest a where it binds: %.4f\n', A(bind_idx(end)));
    end
end

fprintf('-------------------------\n\n');

end
