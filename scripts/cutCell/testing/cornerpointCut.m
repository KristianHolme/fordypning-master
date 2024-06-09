clear all
close all
%%
set(groot, 'defaultAxesView', [0, 90]);
set(groot, 'DefaultLineLineWidth', 0.5);


%% Load CP grid (from deck)
simcase = Simcase('deckcase', 'B_ISO_SMALL', 'usedeck', true);
Gdeck = simcase.G;
geodata = readGeo('./geo-files/spe11a-faults.geo', 'assignExtra', true);
geodata = rotateGrid(geodata);
geodata = stretchGeo(geodata);
%% Process points
frontpoints = vertcat(geodata.Point{:});
backpoints = frontpoints;
backpoints(:,2) = 1.0;

gridpoints = Gdeck.nodes.coords;
gridFrontPointIxs = find(gridpoints(:,2) == 0.0);
gridBackPointIxs = find(gridpoints(:,2) == 1.0);

frontDists = pdist2(gridpoints(gridFrontPointIxs,:), frontpoints, 'euclidean');
backDists = pdist2(gridpoints(gridBackPointIxs,:), backpoints, 'euclidean');
[frontMinDists, frontMinIxs] = min(frontDists, [], 2);
[backMinDists, backMinIxs] = min(backDists, [], 2);

distLimit = 1.0;
closePoints = frontMinDists < distLimit;
gridpoints(gridFrontPointIxs( closePoints)) = frontpoints(frontMinIxs(closePoints));
closePoints = backMinDists < distLimit;
gridpoints(gridBackPointIxs( closePoints)) = backpoints(backMinIxs(closePoints));

Ground = Gdeck;
Ground.nodes.coords = gridpoints;

% plotGrid(G, 'facecolor', 'none');view(0,0);
% plotGrid(Ground, 'facecolor', 'none', 'edgecolor', 'red', 'edgealpha', 0.3);view(0,0);
G = computeGeometry(Ground);
%% Presplit fault points
G = Gdeck;
cellpoints = arrayfun(@(curve)curveToPoints(curve, geodata), geodata.includeLines, UniformOutput=false);
points = unique(vertcat(cellpoints{:}), 'rows');
numPoints = size(points, 1);
cellpoints = mat2cell(points, ones(numPoints, 1), 3);

Gpre = pointSplit(G, cellpoints, 'dir', [0 1 0], 'verbose', true, 'waitbar', false);
%% Cut
Gcut = cutCellGeo(Gpre, geodata, 'dir', [0 1 0], 'verbose', true, ...
    'extendSliceFactor', 0.01, ...
    'topoSplit', false);
Gcut = tagbyFacies(Gcut, geodata, 'vertIx', 3);

%% Save
G = computeGeometry(Gcut);
save('grid-files/cutcell/cp_pre_cut_130x62', "G");
%% Get Gcut with removed cells
simcase = Simcase('gridcase', 'cp_pre_cut_130x62', 'deckcase', 'B_ISO_SMALL', 'usedeck', true);
Gcut = simcase.G;
%%
plotCellData(Gcut, Gcut.cells.tag, 'edgealpha', 0.2);view(0,0);
%% Histogram
bins = 30;
T = tiledlayout(2,1);

nexttile;
h1 = histogram(log10(Gcut.cells.volumes));
title(sprintf('Cut-cell. Total cells:%d', Gcut.cells.num));
xlabel('log10(cell columes)');

nexttile;
h2 = histogram(log10(G.cells.volumes));
title(sprintf('Original. Total cells:%d', G.cells.num));
xlabel('log10(cell columes)');


% Set the same Y-axis limits for both plots
maxY = max([h1.Values, h2.Values]);
nexttile(1);
ylim([0 maxY]);
nexttile(2);
ylim([0 maxY]);

% Set the same X-axis limits for both plots
maxval = max([Gcut.cells.volumes; G.cells.volumes]);
minval = min([Gcut.cells.volumes; G.cells.volumes]);
xMin = log10(minval);
xMax = log10(maxval);
nexttile(1);
xlim([xMin, xMax]);
nexttile(2);
xlim([xMin, xMax]);

%% Without presplitting
Gcutnopre = cutCellGeo(Ground, geodata, 'dir', [0 1 0], 'verbose', true, ...
    'extendSliceFactor', 0.01, ...
    'topoSplit', false);
Gcutnopre = tagbyFacies(Gcutnopre, geodata, 'vertIx', 3);
%%
plotCellData(Gcutnopre, Gcutnopre.cells.tag, 'edgealpha', 0.2);view(0,0);
