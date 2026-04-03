function mpc = compute_mpcs(A, C, r, da)
% compute_mpcs.m
% Compute state-level MPC using finite differences on the asset grid.
%
% Definition used here:
%   MPC(a,y) = d c(a,y) / d a
% where a is beginning-of-period assets on grid A (model-period units).
%
% Finite-difference scheme:
%   - interior points: centered difference
%   - boundaries: one-sided difference
%
% Note:
%   If you want dc/dm with m = y + (1+r)a, then dc/dm = (dc/da)/(1+r).

% Keep input signature unchanged for compatibility with existing calls.
% r and da are not used by this implementation.
if nargin < 3 %#ok<STISA>
    r = [];
end
if nargin < 4 %#ok<STISA>
    da = [];
end

N_a = length(A);
N_y = size(C, 2);
mpc = zeros(N_a, N_y);

if N_a == 1
    mpc(:) = NaN;
    return;
end

for iy = 1:N_y
    % Lower boundary: forward (one-sided) difference
    mpc(1, iy) = (C(2, iy) - C(1, iy)) / (A(2) - A(1));

    % Interior points: centered difference
    for ia = 2:(N_a - 1)
        dc = C(ia + 1, iy) - C(ia - 1, iy);
        da_local = A(ia + 1) - A(ia - 1);
        mpc(ia, iy) = dc / da_local;
    end

    % Upper boundary: backward (one-sided) difference
    mpc(N_a, iy) = (C(N_a, iy) - C(N_a - 1, iy)) / (A(N_a) - A(N_a - 1));
end

end
