clear all
close all
%%
gridfractions = [0.1198 0.0612 0.0710 0.0783 0.1051 0.0991 0.1255 0.1663 0.1737];
nx = 28;
totys = 12;
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

Gpre = PointSplit(G, cellpoints, 'dir', [0 1 0], 'verbose', false, 'waitbar', false);
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
nx = 130;
ny = 62;
buffer = true;
G = GenerateCutCellGrid(nx, ny, 'type', 'horizon', ...
    'recombine', true, 'save', true, ...
    'bufferVolumeSlice', true, 'removeInactive', true, ...
    'partitionMethod', 'convexity', ...
    'verbose', true);
%%
plotCellData(G, G.cells.tag);view(0,0)
%% Test partitioning
% load("grid-files/cutcell/horizon_presplit_cutcell_130x62.mat");
% [G, cellmap] = removeCells(G, G.cells.tag == 7);%try to remove 0 perm cells
% G.cells.tag = G.cells.tag(G.cells.tag ~= 7);
% G.cells.indexMap = (1:G.cells.num)';
% Gcut = G;
t = tic();
method = 'convexity';
partition = PartitionByTag(Gcut, 'method', method, ...
    'avoidBufferCells', buffer);
compressedPartition = compressPartition(partition);
Gp = makePartitionedGrid(Gcut, compressedPartition);
Gp = TagbyFacies(Gp, geodata, 'vertIx', 3);
t = toc(t);
fprintf("Partition and coarsen %dx%d grid using %s in %0.2f s\n", nx, ny, method, t);
%%
% figure
plotCellData(Gp, Gp.cells.tag);view(0,0);
%% Histogram
bins = 30;

T = tiledlayout(3,1);

nexttile;
h1 = histogram(log10(G.cells.volumes));
title(sprintf('Background grid. Total cells:%d', G.cells.num));
xlabel('log10(cell volumes)');

nexttile;
h2 = histogram(log10(Gcut.cells.volumes));
title(sprintf('Cut-cell. Total cells:%d', Gcut.cells.num));
xlabel('log10(cell volumes)');

nexttile;
h3 = histogram(log10(Gp.cells.volumes));
title(sprintf('Coarsened Cut-cell. Total cells:%d', Gp.cells.num));
xlabel('log10(cell volumes)');

%% Save hist
exportgraphics(T, './../plotsMaster/histograms/horizon_orig_cut_part_28x12.pdf');

%% Plot partitions
tot = 0;
for ip=1:numel(unique(compressedPartition))
    cells = find(compressedPartition == ip);
    if numel(cells)==1
        continue
    end
    tot = tot +1;
    clf;
    % plotGrid(Gcut, 'facealpha', 0);
    plotGrid(Gcut, cells);view(0,0);
    ;
end



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