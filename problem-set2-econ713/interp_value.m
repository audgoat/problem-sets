function v = interp_value(x, Xgrid, Vcol)
% interp_value.m
% Piecewise linear interpolation of value function V(a, y_fixed) at x = a'.
%
% Inputs:
%   x      - interpolation point (scalar)
%   Xgrid  - asset grid (N x 1), increasing
%   Vcol   - value function at fixed y, size (N x 1)
%
% Output:
%   v      - interpolated value at x

N = length(Xgrid);

% Clamp to endpoints if x is outside the grid.
if x <= Xgrid(1)
    v = Vcol(1);
    return;
elseif x >= Xgrid(N)
    v = Vcol(N);
    return;
end

% Find bracketing grid points: Xgrid(j) <= x <= Xgrid(j+1).
% The grid is small enough that a clear loop is fine and readable.
j = 1;
while j < N && Xgrid(j + 1) < x
    j = j + 1;
end

x0 = Xgrid(j);
x1 = Xgrid(j + 1);
v0 = Vcol(j);
v1 = Vcol(j + 1);

% Linear interpolation weight on upper node
w = (x - x0) / (x1 - x0);
v = (1 - w) * v0 + w * v1;

end
