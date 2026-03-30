function C = compute_consumption_policy(A, y, g, r)
% compute_consumption_policy.m
% Computes consumption policy from budget constraint:
%   c(a,y) = y + (1+r)a - g(a,y)

N_a = length(A);
N_y = length(y);

C = zeros(N_a, N_y);

for iy = 1:N_y
    for ia = 1:N_a
        C(ia, iy) = y(iy) + (1 + r) * A(ia) - g(ia, iy);
    end
end

end
