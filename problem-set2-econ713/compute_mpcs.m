function mpc = compute_mpcs(A, C, r, da)
% compute_mpcs.m
% Compute state-level MPC using finite differences in cash-on-hand.
%
% For each (a,y):
%   mpc(a,y) ~= [c(a+da,y) - c(a,y)] / [(1+r)*da]
%
% This is a transparent approximation to dc/dm, where
% m = y + (1+r)a is cash-on-hand before choosing a'.

if nargin < 4 || isempty(da)
    da = 0.5 * (A(2) - A(1));
end

N_a = length(A);
N_y = size(C, 2);
mpc = zeros(N_a, N_y);

for iy = 1:N_y
    for ia = 1:N_a
        a_now = A(ia);
        c_now = C(ia, iy);
        c_plus = interp_value(a_now + da, A, C(:, iy));
        mpc(ia, iy) = (c_plus - c_now) / ((1 + r) * da);
    end
end

end
