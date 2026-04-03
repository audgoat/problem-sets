function plot_mpc_distributions(mpc1, w1, mpc2, w2, mpc3, w3, save_dir)
% plot_mpc_distributions.m
% Plot weighted cross-sectional MPC distributions for three economies.

if nargin < 7
    save_dir = pwd;
end

% Use finer binning in the low-MPC region where most mass typically sits.
edges_low = linspace(0, 0.2, 81);       % dense bins in [0, 0.2]
edges_high = linspace(0.205, 1.2, 31);  % coarser bins above 0.2
edges = [edges_low, edges_high];
centers = 0.5 * (edges(1:end-1) + edges(2:end));

% Weighted histogram masses computed manually for compatibility:
% 1) assign bins with discretize
% 2) sum stationary weights in each bin
% 3) normalize masses to sum to 1
h1 = weighted_bin_masses(mpc1, w1, edges);
h2 = weighted_bin_masses(mpc2, w2, edges);
h3 = weighted_bin_masses(mpc3, w3, edges);

% Weighted means (ignoring NaNs safely)
m1 = sum(mpc1 .* w1) / sum(w1);
m2 = sum(mpc2 .* w2) / sum(w2);
m3 = sum(mpc3 .* w3) / sum(w3);

fig = figure('Color', 'w');
hold on;

h1_line = plot(centers, h1, 'LineWidth', 2.0, 'Color', [0.10 0.35 0.75]);
h2_line = plot(centers, h2, 'LineWidth', 2.0, 'Color', [0.85 0.33 0.10]);
h3_line = plot(centers, h3, 'LineWidth', 2.0, 'Color', [0.20 0.60 0.20]);

% Mark weighted means on the histogram curves
y1m = interp_value(m1, centers(:), h1(:));
y2m = interp_value(m2, centers(:), h2(:));
y3m = interp_value(m3, centers(:), h3(:));
plot(m1, y1m, 'o', 'MarkerSize', 7, 'MarkerFaceColor', [0.10 0.35 0.75], 'MarkerEdgeColor', 'k');
plot(m2, y2m, 's', 'MarkerSize', 7, 'MarkerFaceColor', [0.85 0.33 0.10], 'MarkerEdgeColor', 'k');
plot(m3, y3m, '^', 'MarkerSize', 7, 'MarkerFaceColor', [0.20 0.60 0.20], 'MarkerEdgeColor', 'k');

xlabel('MPC', 'FontSize', 12);
ylabel('Weighted cross-sectional probability', 'FontSize', 12);
title('Cross-Sectional MPC Distributions', 'FontSize', 13);
legend([h1_line, h2_line, h3_line], {'Baseline', '\phi = 6', '\sigma = 3'}, 'Location', 'best');
xlim([0, 0.2]);
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);

text(0.98, 0.95, sprintf('Weighted means: %.3f, %.3f, %.3f', m1, m2, m3), ...
    'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
    'FontSize', 10, 'BackgroundColor', 'w');

hold off;

saveas(fig, fullfile(save_dir, 'mpc_distribution_comparison.png'));
saveas(fig, fullfile(save_dir, 'mpc_distribution_comparison.pdf'));

% Optional second figure: weighted CDFs
cdf1 = cumsum(h1);
cdf2 = cumsum(h2);
cdf3 = cumsum(h3);

fig_cdf = figure('Color', 'w');
hold on;
plot(centers, cdf1, 'LineWidth', 2.0, 'Color', [0.10 0.35 0.75]);
plot(centers, cdf2, 'LineWidth', 2.0, 'Color', [0.85 0.33 0.10]);
plot(centers, cdf3, 'LineWidth', 2.0, 'Color', [0.20 0.60 0.20]);
xlabel('MPC', 'FontSize', 12);
ylabel('Weighted CDF', 'FontSize', 12);
title('Weighted CDF of MPCs', 'FontSize', 13);
legend({'Baseline', '\phi = 6', '\sigma = 3'}, 'Location', 'best');
xlim([0, 0.2]);
ylim([0, 1]);
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);
hold off;

saveas(fig_cdf, fullfile(save_dir, 'mpc_cdf_comparison.png'));
saveas(fig_cdf, fullfile(save_dir, 'mpc_cdf_comparison.pdf'));

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

function m = weighted_mean(x, w)
% weighted_mean
% Weighted mean with safe NaN handling.

x = x(:);
w = w(:);
valid = ~isnan(x) & ~isnan(w);
x = x(valid);
w = w(valid);

if isempty(x)
    m = NaN;
    return;
end

wsum = sum(w);
if wsum <= 0
    m = NaN;
else
    m = sum(x .* w) / wsum;
end

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
