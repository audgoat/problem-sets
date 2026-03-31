function pi_y = stationary_income_distribution(Pi, tol, max_iter)
% stationary_income_distribution.m
% Compute stationary distribution for the income Markov chain Pi.

if nargin < 2
    tol = 1e-12;
end
if nargin < 3
    max_iter = 10000;
end

N_y = size(Pi, 1);
pi_old = ones(1, N_y) / N_y;

for it = 1:max_iter
    pi_new = pi_old * Pi;
    if max(abs(pi_new - pi_old)) < tol
        pi_y = pi_new / sum(pi_new);
        return;
    end
    pi_old = pi_new;
end

pi_y = pi_old / sum(pi_old);

end
