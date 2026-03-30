function plot_huggett_policies(A, g, C, save_dir)
% plot_huggett_policies.m
% Creates and saves:
%   (i) savings policy a' = g(a,y) with 45-degree line
%   (ii) consumption policy c(a,y)

if nargin < 4
    save_dir = pwd;
end

% ---------- Figure 1: Savings policy ----------
fig1 = figure('Color', 'w');
hold on;

plot(A, g(:, 1), 'LineWidth', 2.0, 'Color', [0.10 0.35 0.75]);
plot(A, g(:, 2), 'LineWidth', 2.0, 'Color', [0.85 0.33 0.10]);
plot(A, A, '--', 'LineWidth', 1.5, 'Color', [0.25 0.25 0.25]); % 45-degree line

xlabel('Current assets, a', 'FontSize', 12);
ylabel('Next-period assets, a''', 'FontSize', 12);
title('Huggett Savings Policy at Fixed Interest Rate', 'FontSize', 13);
legend({'Low income', 'High income', '45-degree line'}, 'Location', 'northwest');
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);

hold off;

saveas(fig1, fullfile(save_dir, 'savings_policy_fixed_r.png'));
saveas(fig1, fullfile(save_dir, 'savings_policy_fixed_r.pdf'));

% ---------- Figure 2: Consumption policy ----------
fig2 = figure('Color', 'w');
hold on;

plot(A, C(:, 1), 'LineWidth', 2.0, 'Color', [0.10 0.35 0.75]);
plot(A, C(:, 2), 'LineWidth', 2.0, 'Color', [0.85 0.33 0.10]);

xlabel('Current assets, a', 'FontSize', 12);
ylabel('Consumption, c', 'FontSize', 12);
title('Huggett Consumption Policy at Fixed Interest Rate', 'FontSize', 13);
legend({'Low income', 'High income'}, 'Location', 'northwest');
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);

hold off;

saveas(fig2, fullfile(save_dir, 'consumption_policy_fixed_r.png'));
saveas(fig2, fullfile(save_dir, 'consumption_policy_fixed_r.pdf'));

fprintf('Saved figures to:\n');
fprintf('  %s\n', fullfile(save_dir, 'savings_policy_fixed_r.png'));
fprintf('  %s\n', fullfile(save_dir, 'consumption_policy_fixed_r.png'));

end
