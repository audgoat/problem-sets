function [V, g, stats] = solve_household_fixed_r(A, y, Pi, beta, sigma, r, phi, tol, max_iter, print_every)
% solve_household_fixed_r.m
% Solves the household Bellman problem in Huggett (1993) for a fixed interest rate.
%
% Inputs:
%   A          - asset grid, size (N_a x 1)
%   y          - income states, size (N_y x 1)
%   Pi         - transition matrix, size (N_y x N_y), row = current y
%   beta,sigma - preference parameters
%   r          - model-period net interest rate
%   phi        - borrowing-limit parameter (a' >= -phi)
%   tol        - VFI sup norm tolerance
%   max_iter   - max number of VFI iterations
%   print_every- print diagnostics every print_every iterations
%
% Outputs:
%   V          - converged value function, size (N_a x N_y)
%   g          - savings policy a' = g(a,y), size (N_a x N_y)
%   stats      - struct with convergence diagnostics

N_a = length(A);
N_y = length(y);

V = zeros(N_a, N_y);      % Initial guess: transparent and simple
V_new = zeros(N_a, N_y);
g = zeros(N_a, N_y);

stats.iter = 0;
stats.supnorm = Inf;
stats.converged = false;

for it = 1:max_iter
    for iy = 1:N_y
        y_now = y(iy);
        Pi_row = Pi(iy, :);

        for ia = 1:N_a
            a_now = A(ia);

            % Feasible upper bound from c >= 0:
            % c = y + (1+r)a - a'  =>  a' <= y + (1+r)a
            ap_lower = -phi;
            ap_upper = y_now + (1 + r) * a_now;

            obj_handle = @(ap) bellman_objective(ap, a_now, y_now, y, Pi_row, V, A, beta, sigma, r, phi);

            if ap_upper < ap_lower
                % If even a' = -phi implies negative c, keep borrowing-bound choice.
                % Objective function will apply infeasibility penalty to value.
                ap_star = ap_lower;
                obj_star = obj_handle(ap_star);
            else
                % Continuous choice via 1D optimization on feasible interval
                [ap_star, obj_star] = fminbnd(obj_handle, ap_lower, ap_upper);
            end

            g(ia, iy) = ap_star;
            V_new(ia, iy) = -obj_star;   % convert back from minimized negative value
        end
    end

    supnorm = max(abs(V_new(:) - V(:)));
    V = V_new;

    if mod(it, print_every) == 0 || it == 1
        fprintf('VFI iter %4d | sup norm = %.3e\n', it, supnorm);
    end

    if supnorm < tol
        stats.iter = it;
        stats.supnorm = supnorm;
        stats.converged = true;
        fprintf('VFI converged at iter %d with sup norm %.3e\n', it, supnorm);
        return;
    end
end

stats.iter = max_iter;
stats.supnorm = supnorm;
fprintf('WARNING: VFI hit max_iter = %d with sup norm %.3e\n', max_iter, supnorm);

end
