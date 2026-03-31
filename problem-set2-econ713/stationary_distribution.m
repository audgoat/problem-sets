function [psi_vec, psi_mat, stats] = stationary_distribution(P, N_a, N_y, tol, max_iter, print_every)
% stationary_distribution.m
% Compute invariant distribution psi over joint states (a,y):
%   psi = psi * P
%
% Inputs:
%   P          - transition matrix over joint states, size (N_state x N_state)
%   N_a, N_y   - dimensions to reshape psi into (N_a x N_y)
%   tol        - convergence tolerance for sup norm on psi updates
%   max_iter   - max iterations in power method
%   print_every- print diagnostics frequency
%
% Outputs:
%   psi_vec    - stationary distribution as COLUMN vector (N_state x 1)
%   psi_mat    - stationary distribution reshaped to (N_a x N_y)

if nargin < 6
    print_every = 200;
end

N_state = N_a * N_y;
psi_old = ones(1, N_state) / N_state;

stats.iter = 0;
stats.supnorm = Inf;
stats.converged = false;

for it = 1:max_iter
    psi_new = psi_old * P;
    supnorm = max(abs(psi_new - psi_old));

    if mod(it, print_every) == 0 || it == 1
        fprintf('Stationary dist iter %5d | sup norm = %.3e\n', it, supnorm);
    end

    psi_old = psi_new;

    if supnorm < tol
        stats.iter = it;
        stats.supnorm = supnorm;
        stats.converged = true;
        break;
    end
end

if ~stats.converged
    stats.iter = max_iter;
    stats.supnorm = supnorm;
    fprintf('WARNING: Stationary distribution did not fully converge. sup norm = %.3e\n', supnorm);
else
    fprintf('Stationary distribution converged at iter %d with sup norm %.3e\n', stats.iter, stats.supnorm);
end

% Normalize explicitly to guard against machine drift.
% Return psi_vec as a COLUMN vector over joint states (a,y).
psi_vec = (psi_old / sum(psi_old))';

% Reshape to (N_a x N_y) using the same state-indexing convention.
psi_mat = zeros(N_a, N_y);
for iy = 1:N_y
    idx1 = 1 + (iy - 1) * N_a;
    idx2 = iy * N_a;
    psi_mat(:, iy) = psi_vec(idx1:idx2);
end

end
