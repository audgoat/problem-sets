function plot_asset_demand_curve(r_grid_annual, asset_demand, eq_r_annual, save_dir)
% plot_asset_demand_curve.m
% Plot aggregate asset demand as a function of annual real interest rate.

if nargin < 4
    save_dir = pwd;
end

fig = figure('Color', 'w');
hold on;

plot(100 * r_grid_annual, asset_demand, '-o', 'LineWidth', 1.8, 'MarkerSize', 5, ...
    'Color', [0.10 0.35 0.75]);
yline(0, '--', 'LineWidth', 1.4, 'Color', [0.30 0.30 0.30]);
xline(100 * eq_r_annual, ':', 'LineWidth', 1.8, 'Color', [0.85 0.33 0.10]);

xlabel('Annual real interest rate (%)', 'FontSize', 12);
ylabel('Aggregate asset demand', 'FontSize', 12);
title('Huggett Aggregate Asset Demand Curve', 'FontSize', 13);
legend({'A_d(r)', 'Zero net supply', 'Equilibrium r'}, 'Location', 'best');
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);

hold off;

saveas(fig, fullfile(save_dir, 'asset_demand_curve.png'));
saveas(fig, fullfile(save_dir, 'asset_demand_curve.pdf'));

end
