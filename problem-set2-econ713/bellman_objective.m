function obj = bellman_objective(ap, a, y_s, y, Pi_row, V_old, A, beta, sigma, r, phi)
% bellman_objective.m
% Evaluates the Bellman RHS at candidate next-period assets ap, then returns
% the negative (for use with fminbnd minimization).
%
% Bellman RHS:
%   u(c) + beta * E[V(ap, y')]
% with c = y + (1+r)a - ap

% Penalize infeasible choices heavily so optimizer avoids them.
penalty = 1e12;

if ap < -phi
    obj = penalty;
    return;
end

c = y_s + (1 + r) * a - ap;
if c <= 0
    obj = penalty;
    return;
end

% CRRA utility (sigma ~= 1 in this exercise)
u = c^(1 - sigma) / (1 - sigma);

% Expected continuation value with interpolation for off-grid ap
N_y = length(y);
EV = 0;
for iy_next = 1:N_y
    V_interp = interp_value(ap, A, V_old(:, iy_next));
    EV = EV + Pi_row(iy_next) * V_interp;
end

bellman_rhs = u + beta * EV;

% fminbnd minimizes, so pass negative of Bellman RHS
obj = -bellman_rhs;

end
