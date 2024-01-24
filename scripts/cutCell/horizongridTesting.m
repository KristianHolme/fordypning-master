clear all
close all
%%
gridfractions = [0.1198 0.0612 0.0710 0.0783 0.1051 0.0991 0.1255 0.1663 0.1737];
nx = 130;
totys = 62;
nys = round(totys*gridfractions);

G = makeHorizonGrid(nx, nys, 'save', false);
%%
plotGrid(G);view(0,0);


%%
geodata = readGeo('~/Code/prosjekt-master/src/scripts/cutCell/geo/spe11a-faults.geo', 'assignExtra', true);
geodata = RotateGrid(geodata);
geodata = StretchGeo(geodata);
%% Presplit fault points
cellpoints = arrayfun(@(curve)curveToPoints(curve, geodata), geodata.includeLines, UniformOutput=false);
points = unique(vertcat(cellpoints{:}), 'rows');
numPoints = size(points, 1);
cellpoints = mat2cell(points, ones(numPoints, 1), 3);

Gpre = PointSplit(G, cellpoints, 'dir', [0 1 0], 'verbose', true, 'waitbar', false);
%%
plotGrid(Gpre);view(0,0);
%% Cut
Gcut = CutCellGeo(Gpre, geodata, 'dir', [0 1 0], 'verbose', true, ...
    'extendSliceFactor', 0.0, ...
    'topoSplit', true);
Gcut = TagbyFacies(Gcut, geodata, 'vertIx', 3);
%%
plotCellData(Gcut, Gcut.cells.tag);view(0,0);

%%
Gcut = GenerateCutCellGrid(130, 62, 'type', 'horizon', 'recombine', false, 'save', true, ...
    'bufferVolumeSlice', true, 'removeInactive', true);
%% Test partitioning
load("grid-files/cutcell/horizon_presplit_cutcell_130x62.mat");
[G, cellmap] = removeCells(G, G.cells.tag == 7);%try to remove 0 perm cells
G.cells.tag = G.cells.tag(G.cells.tag ~= 7);
G.cells.indexMap = (1:G.cells.num)';
Gcut = G;
t = tic();
partition = PartitionByTag(Gcut);
compressedPartition = compressPartition(partition);
CG = generateCoarseGrid(Gcut, compressedPartition);
CG = coarsenGeometry(CG);
[~, CGcellToGcutCell] = unique(partition, 'first');
CG.cells.tag = Gcut.cells.tag(CGcellToGcutCell);
t = toc(t);
fprintf("Partition and coarsen in %0.2f s\n", t);

%% Histogram
bins = 30;

T = tiledlayout(2,1);

nexttile;
h1 = histogram(log10(G.cells.volumes));
title(sprintf('Background grid. Total cells:%d', G.cells.num));
xlabel('log10(cell volumes)');

nexttile;
h2 = histogram(log10(Gcut.cells.volumes));
title(sprintf('Cut-cell. Total cells:%d', Gcut.cells.num));
xlabel('log10(cell volumes)');

%% Save hist
exportgraphics(T, './../plotsMaster/histograms/horizon_cut_orig_28x12.pdf');


%%
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