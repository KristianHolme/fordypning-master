%%
clear all
close all

%% For plotting pebi grid in thesis
p = rand([6,2]);
bnd = [0,0;
    1,0;
    1,1;
    0,1];
    

Gt = triangleGrid([p;bnd]);
Gp = clippedPebi2D(p, bnd);
%
pts = [p;bnd];
clf
plotGrid(Gp, 'facealpha', 0, 'EdgeColor', '#77AC30', 'LineWidth', 4)
plotGrid(Gt, 'facealpha', 0, 'EdgeColor', 'k', 'LineStyle', '--', 'LineWidth', 2);hold on;
plot(p(:,1), p(:,2), 'ro', 'MarkerSize',10, 'MarkerFaceColor','#D95319');

axis equal tight
tightfig()

%% break point in line 34 in nudgePoints
GenerateCutCellGrid(130,62, 'save', false, 'type', 'cartesian')
%% Plot nudging
clf
plot(targetpoints(:,1), targetpoints(:,3), '.', 'MarkerSize',30)
hold on
plot(origMovPts(:,1), origMovPts(:,3), '.', 'MarkerSize',15)
set(gca, 'YDir', 'reverse', 'xlim', [3065, 3400], 'ylim', [325, 585]);
plot(moveablepoints(:,1), moveablepoints(:,3), '.', 'MarkerSize',15)
u = moveablepoints(:,1) - origMovPts(:,1);
v = moveablepoints(:,3) - origMovPts(:,3);
quiver(origMovPts(:,1), origMovPts(:,3), u, v, 'off');
legend({'Background grid points', 'Original geometry points', 'Nudged geometry points'}, 'FontSize',10)
