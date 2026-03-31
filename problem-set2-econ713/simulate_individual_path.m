function sim = simulate_individual_path(A, g, Pi, a0, y0_idx, T)
% simulate_individual_path.m
% Simulate one individual path under policy rule g(a,y) and Markov chain Pi.
%
% Inputs:
%   A      - asset grid (N_a x 1)
%   g      - savings policy (N_a x N_y)
%   Pi     - income transition matrix (N_y x N_y)
%   a0     - initial assets (can be off-grid)
%   y0_idx - initial income-state index (1..N_y)
%   T      - number of periods
%
% Output struct:
%   sim.a_path      - assets path, length T
%   sim.y_idx_path  - income-state index path, length T

a_path = zeros(T, 1);
y_idx_path = zeros(T, 1);

a_path(1) = a0;
y_idx_path(1) = y0_idx;

for t = 1:(T - 1)
    iy = y_idx_path(t);
    a_now = a_path(t);

    % Policy is stored on asset grid, so interpolate to off-grid a_now.
    ap = interp_value(a_now, A, g(:, iy));
    a_path(t + 1) = ap;

    % Draw next income state from Markov chain.
    y_idx_path(t + 1) = sample_discrete(Pi(iy, :));
end

sim.a_path = a_path;
sim.y_idx_path = y_idx_path;

end
