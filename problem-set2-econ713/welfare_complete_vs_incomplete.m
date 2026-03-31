function out = welfare_complete_vs_incomplete(V, psi_vec, y, Pi, beta, sigma)
% welfare_complete_vs_incomplete.m
% Compare baseline incomplete markets welfare to complete markets welfare.
%
% Implemented benchmark:
%   Complete markets with perfect insurance and no aggregate risk.
%   Consumption is constant at c_CM = E[y] each period, where expectation
%   uses the stationary income distribution.
%
% Consumption-equivalent gain lambda solves:
%   (1+lambda)^(1-sigma) * W_IM = W_CM
% where W_IM = E_psi[V_IM(a,y)].

W_IM = sum(psi_vec(:) .* V(:));

pi_y = stationary_income_distribution(Pi);
c_CM = sum(pi_y .* y(:)');

if c_CM <= 0
    error('Complete-markets consumption must be positive.');
end

if abs(sigma - 1) < 1e-12
    V_CM = log(c_CM) / (1 - beta);
    lambda = exp((V_CM - W_IM) * (1 - beta)) - 1;
else
    V_CM = (c_CM^(1 - sigma)) / ((1 - sigma) * (1 - beta));
    lambda = (V_CM / W_IM)^(1 / (1 - sigma)) - 1;
end

out.W_IM = W_IM;
out.W_CM = V_CM;
out.lambda = lambda;
out.pi_y = pi_y;
out.c_CM = c_CM;

end
