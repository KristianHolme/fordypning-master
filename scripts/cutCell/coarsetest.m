clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa coarsegrid
%%
geodata = readGeo('~/Code/prosjekt-master/src/scripts/cutCell/geo/spe11a-faults.geo', 'assignExtra', true);
Lx = 2.8;
Ly = 1.2;
G = cartGrid([nx ny 1], [Lx, Ly 0.01]);
G = computeGeometry(G);
G = TagbyFacies(G, geodata);
n = neighboursByNodes(G);
outercells = arrayfun(@(c) all(G.cells.tag(getCellNeighborsByNode(G, c, 'n', n)) == 7) && G.cells.tag(c) == 7, 1:G.cells.num)';
G = removeCells(G, outercells);
G.cells.tag = G.cells.tag(~outercells);
%%
nx = 130;
ny = 62;
buffer = false;
save = false;
Gcut = GenerateCutCellGrid(nx, ny, 'type', 'cartesian', ...
    'recombine', false, 'save', save, ...
    'bufferVolumeSlice', buffer, 'removeInactive', true, ...
    'partitionMethod', 'convexity', ...
    'verbose', true);
Gp = GenerateCutCellGrid(nx, ny, 'type', 'cartesian', ...
    'recombine', true, 'save', save, ...
    'bufferVolumeSlice', buffer, 'removeInactive', true, ...
    'partitionMethod', 'convexity', ...
    'verbose', true);
%% Histogram
T = tiledlayout(3,1);
AtoBVolumeFactor = 3e8;
nexttile;
h1 = histogram(log10(G.cells.volumes*AtoBVolumeFactor));
title(sprintf('Background grid. Total cells:%d', G.cells.num));
xlabel('Log10(cell volumes)');
ylabel('Frequency');

nexttile;
h2 = histogram(log10(Gcut.cells.volumes*AtoBVolumeFactor));
title(sprintf('Cut-cell. Total cells:%d', Gcut.cells.num));
xlabel('Log10(cell volumes)');
ylabel('Frequency');

nexttile;
h3 = histogram(log10(Gp.cells.volumes*AtoBVolumeFactor));
title(sprintf('Coarsened Cut-cell. Total cells:%d', Gp.cells.num));
xlabel('Log10(cell volumes)');
ylabel('Frequency');


%% Save hist
exportgraphics(T, sprintf('./../plotsMaster/histograms/cartesian_orig_cut_part_%dx%d.pdf', nx, ny));

%%
% Set the same Y-axis limits for both plots
maxY = max([h1.Values, h2.Values]);
nexttile(1);
ylim([0 maxY]);
nexttile(2);
ylim([0 maxY]);

% Set the same X-axis limits for both plots
maxval = max([G1.cells.volumes; G2.cells.volumes]);
minval = min([G1.cells.volumes; G2.cells.volumes]);
xMin = log10(minval);
xMax = log10(maxval);
nexttile(1);
xlim([xMin, xMax]);
nexttile(2);
xlim([xMin, xMax]);
%%
t = tic();
partition = PartitionByTag(Gcut);
compressedPartition = compressPartition(partition);
CG = generateCoarseGrid(Gcut, compressedPartition);
CG = coarsenGeometry(CG);
CGcellToGcutCell = unique(partition);
CG.cells.tag = Gcut.cells.tag(CGcellToGcutCell);
t = toc(t);
fprintf("Partition and coarsen in %0.2f s\n", t);

%%
Gcut = GenerateCutCellGrid(28, 12, 'bufferVolumeSlice', false, 'verbose', true, ...
    'recombination', false, 'save', true);

%%
plotCellData(Gcut, Gcut.cells.tag)
outlineCoarseGrid(Gcut, compressedPartition);
%%
G = RegularizeCoarseGrid(CG);
%%
Gsub = extractSubgrid(Gcut, [78, 211, 210, 219]);
plotGrid(Gsub);
Gsub = TagbyFacies(Gsub, geodata);
subp = PartitionByTag(Gsub);
CGsub = generateCoarseGrid(Gsub, subp);
CGsub = coarsenGeometry(CGsub);
VizCoarse(CGsub);

%%
[u, ia, ic] = unique(partition);
numGroups = numel(u); % Find the number of groups
result = accumarray(partition(:), (1:numel(partition))', [], @(x) {sort(x')});
result = result(~cellfun(@isempty, result));
cellnumberdifference = Gcut.cells.num - numGroups;
%%
[~, sortorder] = sort(CG.cells.centroids(:,2));
vorg = volumeCartesian(Gcut.cartDims(1), Gcut.cartDims(2));
cla
for i = 1:CG.cells.num
    c = sortorder(i);
    if abs(CG.cells.volumes(c) - vorg) < 1e-10
        continue
    end
    faces = CG.cells.faces(CG.cells.facePos(c):CG.cells.facePos(c+1)-1);
    if isempty(faces)
        continue
    end
    VizCoarse(CG);
    plotFaces(CG, faces, 'facecolor', 'red');
    ;
end

%%
Lx = 2.8;
Ly = 1.2;
G = cartGrid([nx ny 1], [Lx, Ly 0.01]);
G = computeGeometry(G);
%%
VizCoarse(CG);
%%
plotCellData(CG, (1:CG.cells.num)', 'edgealpha', 0)

%%
plotCellData(CG, CG.cells.tag)

%%
function v = volumeCartesian(nx, ny)
    dx = 2.8/nx;
    dy = 1.2/ny;
    v = dx*dy*0.01;
end