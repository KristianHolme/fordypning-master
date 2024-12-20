clear all
close all
%%
nx = 130;
ny = 62;
buffer = false;
G1 = generateCutCellGrid(nx, ny, 'save', true, 'bufferVolumeSlice', buffer, 'type', 'horizon', 'presplit', true, 'nudgeGeom', false);
G2 = generateCutCellGrid(nx, ny, 'save', true, 'bufferVolumeSlice', buffer, 'type', 'horizon');
% G3 = generatePEBIGrid(nx, ny, 'save', true, 'bufferVolumeSlice', buffer, 'FCFactor', 1.0);
%%
res = '28x12';
G1 = load(sprintf('data/grid-files/cutcell/cartesian_presplit_cutcell_%s_B.mat', res)).G;
% G2 = load(sprintf('data/grid-files/cutcell/buff_horizon_presplit_cutcell_PG_%s_C.mat', res)).G;
G3 = load(sprintf('data/grid-files/cutcell/cartesian_presplit_cutcell_28x1.mat', res)).G;
G4 = load(sprintf('data/grid-files/cutcell/buff_cartesian_presplit_cutcell_PG_%s_C.mat', res)).G;
% G3 = load('data/grid-files/PEBI/buff_cPEBI_220x110_B.mat').G;
%%
G1 = Simcase('gridcase', 'struct500x100', 'SPEcase', 'B').G
G2 = Simcase('gridcase', 'struct130x62', 'SPEcase', 'B').G

%%
grids = {G1, G2};
names = {'C50K', 'C10K'};
plotname = 'C: 50K vs 10K';
%%
figure()
T = tiledlayout(numel(grids), 1);

for ig = 1:numel(grids)
    G = grids{ig};
    name = names{ig};
    nexttile(ig);
    histogram(log10(G.cells.volumes));
    title(sprintf('Grid: %s, Cells: %d', name, G.cells.num));
    xlabel('Log10(cell volumes)');
    ylabel('Frequency');
end

%%
exportgraphics(T, sprintf('./plotsMaster/histograms/%s-volumes.pdf', plotname));
exportgraphics(T, sprintf('./plotsMaster/histograms/%s-volumes.png', plotname));

%%
figure
T = tiledlayout(numel(grids), 1);

for ig = 1:numel(grids)
    G = grids{ig};
    N = getNeighbourship(G);
    Conn = getConnectivityMatrix(N);
    [I, J] = find(Conn);
    sz = J(end);
    [~, nbs] = rlencode(J);

    name = names{ig};
    nexttile(ig);
    histogram(nbs);
    title(sprintf('Grid: %s, Cells: %d', name, G.cells.num));
    xlabel('Number of neighbors');
    ylabel('Frequency');
end

%%
exportgraphics(T, sprintf('./plotsMaster/histograms/%s-neighbors.pdf', plotname));
exportgraphics(T, sprintf('./plotsMaster/histograms/%s-neighbors.png', plotname));
%%
figure
T = tiledlayout(numel(grids), 1);

for ig = 1:numel(grids)
    G = grids{ig};
    name = names{ig};
    nexttile(ig);
    histogram(log10(G.faces.areas));
    title(sprintf('Grid: %s, Cells: %d, Faces: %d', name, G.cells.num, G.faces.num));
    xlabel('Log10(face areas)');
    ylabel('Frequency');
end

%%
exportgraphics(T, sprintf('./plotsMaster/histograms/%s-faceA.pdf', plotname));
exportgraphics(T, sprintf('./plotsMaster/histograms/%s-faceA.png', plotname));