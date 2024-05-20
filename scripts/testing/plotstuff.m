%%
clear all
close all

%%
p = rand([8,2]);

Gt = triangleGrid(p);
Gp = pebi(Gt);
%%
clf
plotGrid(Gp, 'facealpha', 0, 'EdgeColor', 'm', 'LineWidth', 4)
plotGrid(Gt, 'facealpha', 0, 'EdgeColor', 'k', 'LineStyle', '--', 'LineWidth', 2);hold on;
plot(p(:,1), p(:,2), 'ro', 'MarkerSize',10, 'MarkerFaceColor','r');

axis equal tight