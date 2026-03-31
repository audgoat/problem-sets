function [P, checks] = compute_transition_matrix(A, g, Pi)
% compute_transition_matrix.m
% Build the transition matrix P over joint states (a,y), induced by:
%   - savings policy a' = g(a,y)
%   - exogenous income transition Pi(y,y')
%
% State indexing convention:
%   idx = ia + (iy-1)*N_a,  where ia = 1..N_a and iy = 1..N_y

N_a = length(A);
N_y = size(g, 2);
N_state = N_a * N_y;

P = zeros(N_state, N_state);

for iy = 1:N_y
    for ia = 1:N_a
        row_idx = ia + (iy - 1) * N_a;
        ap = g(ia, iy);

        % Find interpolation nodes in asset grid for next-period assets.
        if ap <= A(1)
            j_low = 1;
            j_high = 1;
            w_low = 1;
            w_high = 0;
        elseif ap >= A(end)
            j_low = N_a;
            j_high = N_a;
            w_low = 1;
            w_high = 0;
        else
            j_low = 1;
            while j_low < N_a && A(j_low + 1) < ap
                j_low = j_low + 1;
            end
            j_high = j_low + 1;

            w_high = (ap - A(j_low)) / (A(j_high) - A(j_low));
            w_low = 1 - w_high;
        end

        % Combine policy interpolation with income transitions.
        for iy_next = 1:N_y
            p_y = Pi(iy, iy_next);

            col_low = j_low + (iy_next - 1) * N_a;
            P(row_idx, col_low) = P(row_idx, col_low) + w_low * p_y;

            if j_high ~= j_low
                col_high = j_high + (iy_next - 1) * N_a;
                P(row_idx, col_high) = P(row_idx, col_high) + w_high * p_y;
            end
        end
    end
end

row_sums = sum(P, 2);
checks.max_abs_row_sum_error = max(abs(row_sums - 1));
checks.min_row_sum = min(row_sums);
checks.max_row_sum = max(row_sums);

end
