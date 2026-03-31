function plot_mpc_distributions(mpc1, w1, mpc2, w2, mpc3, w3, save_dir)
% plot_mpc_distributions.m
% Plot weighted cross-sectional MPC distributions for three economies.

if nargin < 7
    save_dir = pwd;
end

edges = linspace(0, 1.2, 50);
centers = 0.5 * (edges(1:end-1) + edges(2:end));

h1 = histcounts(mpc1, edges, 'Normalization', 'probability', 'Weights', w1);
h2 = histcounts(mpc2, edges, 'Normalization', 'probability', 'Weights', w2);
h3 = histcounts(mpc3, edges, 'Normalization', 'probability', 'Weights', w3);

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
