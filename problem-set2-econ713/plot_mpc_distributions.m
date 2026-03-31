function plot_mpc_distributions(mpc1, w1, mpc2, w2, mpc3, w3, save_dir)
% plot_mpc_distributions.m
% Plot weighted cross-sectional MPC distributions for three economies.

if nargin < 7
    save_dir = pwd;
end

edges = linspace(0, 1.2, 50);
centers = 0.5 * (edges(1:end-1) + edges(2:end));

% Weighted histogram masses computed manually for compatibility:
% 1) assign bins with discretize
% 2) sum stationary weights in each bin
% 3) normalize masses to sum to 1
h1 = weighted_bin_masses(mpc1, w1, edges);
h2 = weighted_bin_masses(mpc2, w2, edges);
h3 = weighted_bin_masses(mpc3, w3, edges);

fig = figure('Color', 'w');
hold on;

plot(centers, h1, 'LineWidth', 2.0, 'Color', [0.10 0.35 0.75]);
plot(centers, h2, 'LineWidth', 2.0, 'Color', [0.85 0.33 0.10]);
plot(centers, h3, 'LineWidth', 2.0, 'Color', [0.20 0.60 0.20]);

xlabel('MPC', 'FontSize', 12);
ylabel('Weighted cross-sectional probability', 'FontSize', 12);
title('Cross-Sectional MPC Distributions', 'FontSize', 13);
legend({'Baseline', '\phi = 6', '\sigma = 3'}, 'Location', 'best');
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);

hold off;

saveas(fig, fullfile(save_dir, 'mpc_distribution_comparison.png'));
saveas(fig, fullfile(save_dir, 'mpc_distribution_comparison.pdf'));

end

function h = weighted_bin_masses(x, w, edges)
% weighted_bin_masses
% Returns normalized weighted masses across bins defined by edges.
% NaN observations (in x or w) are safely ignored.

x = x(:);
w = w(:);
n_bins = length(edges) - 1;
h = zeros(1, n_bins);

valid = ~isnan(x) & ~isnan(w);
x = x(valid);
w = w(valid);

if isempty(x)
    return;
end

bin_idx = discretize(x, edges);

for b = 1:n_bins
    in_bin = (bin_idx == b);
    if any(in_bin)
        h(b) = sum(w(in_bin));
    end
end

mass = sum(h);
if mass > 0
    h = h / mass;
end

end
