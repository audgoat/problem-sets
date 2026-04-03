function plot_stationary_asset_distributions(A1, psiA1, A2, psiA2, A3, psiA3, save_dir)
% plot_stationary_asset_distributions.m
% Plot stationary marginal distribution of assets for up to 3 economies.

if nargin < 7
    save_dir = pwd;
end

fig = figure('Color', 'w');
hold on;

% Handle potentially different asset grids safely:
% each case is plotted against its own (A, psiA) pair.
A1 = A1(:); psiA1 = psiA1(:);
A2 = A2(:); psiA2 = psiA2(:);
A3 = A3(:); psiA3 = psiA3(:);

valid1 = ~isnan(A1) & ~isnan(psiA1);
valid2 = ~isnan(A2) & ~isnan(psiA2);
valid3 = ~isnan(A3) & ~isnan(psiA3);

% Distinct colored lines for visual comparison.
h1 = plot(A1(valid1), psiA1(valid1), '-o', 'LineWidth', 2.2, 'MarkerSize', 4, ...
    'Color', [0.00 0.4470 0.7410]);
h2 = plot(A2(valid2), psiA2(valid2), '--s', 'LineWidth', 2.2, 'MarkerSize', 4, ...
    'Color', [0.8500 0.3250 0.0980]);
h3 = plot(A3(valid3), psiA3(valid3), '-.^', 'LineWidth', 2.2, 'MarkerSize', 4, ...
    'Color', [0.4660 0.6740 0.1880]);

xlabel('Assets, a', 'FontSize', 12);
ylabel('Stationary mass', 'FontSize', 12);
title('Stationary Asset Distributions Across Cases', 'FontSize', 13);
legend([h1, h2, h3], {'Baseline', '\phi = 6', '\sigma = 3'}, 'Location', 'best');
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);

hold off;

saveas(fig, fullfile(save_dir, 'stationary_asset_distributions_comparison.png'));
saveas(fig, fullfile(save_dir, 'stationary_asset_distributions_comparison.pdf'));

end
