function out = expected_trajectory(A, g, Pi, start_states_idx, start_states_prob, T, N_sim)
% expected_trajectory.m
% Compute expected asset trajectory by Monte Carlo averaging.
%
% Inputs:
%   start_states_idx  - vector of allowed initial joint-state indices
%   start_states_prob - probabilities over start_states_idx (sum to 1)
%
% Joint-state indexing convention:
%   idx = ia + (iy-1)*N_a

N_a = length(A);

all_paths = zeros(T, N_sim);

for n = 1:N_sim
    s0_pos = sample_discrete(start_states_prob);
    s0 = start_states_idx(s0_pos);

    iy0 = floor((s0 - 1) / N_a) + 1;
    ia0 = s0 - (iy0 - 1) * N_a;
    a0 = A(ia0);

    sim = simulate_individual_path(A, g, Pi, a0, iy0, T);
    all_paths(:, n) = sim.a_path;
end

out.mean_a = mean(all_paths, 2);
out.all_paths = all_paths;

end
