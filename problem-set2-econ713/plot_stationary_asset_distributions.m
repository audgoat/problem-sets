function plot_stationary_asset_distributions(A1, psiA1, A2, psiA2, A3, psiA3, save_dir)
% plot_stationary_asset_distributions.m
% Plot stationary marginal distribution of assets for up to 3 economies.

if nargin < 7
    save_dir = pwd;
end

fig = figure('Color', 'w');
hold on;

plot(A1, psiA1, 'LineWidth', 2.0, 'Color', [0.10 0.35 0.75]);
plot(A2, psiA2, 'LineWidth', 2.0, 'Color', [0.85 0.33 0.10]);
plot(A3, psiA3, 'LineWidth', 2.0, 'Color', [0.20 0.60 0.20]);

xlabel('Assets, a', 'FontSize', 12);
ylabel('Stationary density (mass on grid)', 'FontSize', 12);
title('Stationary Asset Distributions', 'FontSize', 13);
legend({'Baseline', '\phi = 6', '\sigma = 3'}, 'Location', 'best');
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);

hold off;

saveas(fig, fullfile(save_dir, 'stationary_asset_distributions_comparison.png'));
saveas(fig, fullfile(save_dir, 'stationary_asset_distributions_comparison.pdf'));

end
