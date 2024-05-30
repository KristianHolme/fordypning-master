clear all
close all
%%
gridfractions = [0.1198 0.0612 0.0710 0.0783 0.1051 0.0991 0.1255 0.1663 0.1737];
nx = 130;
ny = 62;
totys = ny;
nys = round(totys*gridfractions);
totys = sum(nys);

G = makeHorizonGrid(nx, nys, 'save', false);
%%
plotGrid(G, 'facealpha', 0);view(0,0);


%%
geodata = readGeo('./geo-files/spe11a-faults.geo', 'assignExtra', true);
geodata = RotateGrid(geodata);
geodata = StretchGeo(geodata);
%% Nudge geometry points
inds = arrayfun(@(curve)curveToPoints(curve, geodata,'indices', true), geodata.includeLines, UniformOutput=false);
inds = unique(vertcat(inds{:}));
cellpoints = geodata.Point;
points = vertcat(cellpoints{:});
numPoints = size(points, 1);
targetpoints = G.nodes.coords(G.nodes.coords(:,2)==0,:);
[points(inds,:), nudged, notnudged] = nudgePoints(targetpoints, points(inds,:), ...
    'targetOccupation', true);
cellpoints = mat2cell(points, ones(numPoints, 1), 3);
geodata.Point = cellpoints;

%% Presplit fault points
cellpoints = arrayfun(@(curve)curveToPoints(curve, geodata), geodata.includeLines, UniformOutput=false);
points = unique(vertcat(cellpoints{:}), 'rows');
numPoints = size(points, 1);
cellpoints = mat2cell(points, ones(numPoints, 1), 3);

[Gpre, tpre, skippedpre] = PointSplit(G, cellpoints, 'dir', [0 1 0],...
    'verbose', true,...
    'waitbar', false,...
    'save', false);
%%
plotGrid(Gpre);view(0,0);
%% Cut
Gcut = CutCellGeo(G, geodata, 'dir', [0 1 0], 'verbose', true, ...
    'extendSliceFactor', 0.00, ...
    'topoSplit', true, ...
    'save', false);
Gcut = TagbyFacies(Gcut, geodata, 'vertIx', 3);
%%
plotCellData(Gcut, Gcut.cells.tag);view(0,0);


%%
plotCellData(Gcut, Gcut.cells.tag, 'edgealpha', 0.5, 'LineWidth', 0.1);view(0,0)
% set(gca, 'xlim',[2800,3200], 'zlim', [100,180]);
% plotCellData(Gcut, Gcut.cells.tag, 'facealpha', 0);plotGrid(Gcut, failed);
%%
bigLoad = load("grid-files/cutcell/buff_horizon_nudge_cutcell_898x120.mat");
Gcut = bigLoad.G;
%%
bigLoad = load("grid-files/cutcell/buff_horizon_nudge_cutcell_PG_130x62.mat");
Gp = bigLoad.G;
%% Test partitioning

t = tic();
buffer = true;
method = 'convexity';
[partition, failed] = PartitionByTag(Gcut, 'method', method, ...
    'avoidBufferCells', buffer);
Gp = makePartitionedGrid(Gcut, partition);
Gp = TagbyFacies(Gp, geodata, 'vertIx', 3);
t = toc(t);
fprintf("Partition and coarsen %dx%d grid using %s in %0.2f s\n", nx, ny, method, t);
%%
% figure
plotCellData(Gp, Gp.cells.tag,'edgealpha', 0.5, 'LineWidth', 0.1);view(0,0)
%%
nx = 100;
ny = 50;
buffer = true;
save = true;
recombine = true;
% Gpold = GenerateCutCellGrid(nx, ny, 'type', 'horizon', ...
%     'recombine', true, 'save', save, ...
%     'bufferVolumeSlice', buffer, 'removeInactive', true, ...
%     'partitionMethod', 'convexity', ...
%     'verbose', true, ...
%     'presplit', true, ...
%     'nudgeGeom', false);
Gp = GenerateCutCellGrid(nx, ny, 'type', 'horizon', ...
    'recombine', true, 'save', save, ...
    'bufferVolumeSlice', buffer, 'removeInactive', false, ...
    'partitionMethod', 'convexity', ...
    'verbose', true, ...
    'presplit', false, ...
    'nudgeGeom', true);
%% Histogram
bins = 30;

T = tiledlayout(3,1);

nexttile;
h1 = histogram(log10(G.cells.volumes));
title(sprintf('Background grid. Total cells:%d', G.cells.num));
xlabel('Log10(cell volumes)');
ylabel('Frequency');

nexttile;
h2 = histogram(log10(Gcut.cells.volumes));
title(sprintf('Cut-cell. Total cells:%d', Gcut.cells.num));
xlabel('Log10(cell volumes)');
ylabel('Frequency');

nexttile;
h3 = histogram(log10(Gp.cells.volumes));
title(sprintf('Coarsened Cut-cell. Total cells:%d', Gp.cells.num));
xlabel('Log10(cell volumes)');
ylabel('Frequency');
%%
T = tiledlayout(2,1);

nexttile;
h1 = histogram(log10(Gpold.cells.volumes));
title(sprintf('Presplitting. Total cells:%d', Gpold.cells.num));
xlabel('Log10(cell volumes)');
ylabel('Frequency');

nexttile;
h2 = histogram(log10(Gp.cells.volumes));
title(sprintf('Nudging. Total cells:%d', Gp.cells.num));
xlabel('Log10(cell volumes)');
ylabel('Frequency');



%% Save hist
exportgraphics(T, sprintf('./../plotsMaster/histograms/horizon_orig_cut_PG_%dx%d.pdf', nx, ny));

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
xMin = Log10(minval);
xMax = Log10(maxval);
nexttile(1);
xlim([xMin, xMax]);
nexttile(2);
xlim([xMin, xMax]);