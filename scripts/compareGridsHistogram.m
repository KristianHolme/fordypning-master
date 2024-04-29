clear all
close all
%%
nx = 130;
ny = 62;
buffer = false;
G1 = GenerateCutCellGrid(nx, ny, 'save', true, 'bufferVolumeSlice', buffer, 'type', 'cartesian', 'presplit', true, 'nudgeGeom', false);
G2 = GenerateCutCellGrid(nx, ny, 'save', true, 'bufferVolumeSlice', buffer, 'type', 'cartesian');
% G3 = GeneratePEBIGrid(nx, ny, 'save', true, 'bufferVolumeSlice', buffer, 'FCFactor', 1.0);
%%
G1 = load('grid-files/cutcell/buff_horizon_nudge_cutcell_PG_50x50x50_C.mat').G;
G2 = load('grid-files/cutcell/buff_cartesian_nudge_cutcell_PG_50x50x50_C.mat').G;
% G3 = load('grid-files/PEBI/buff_cPEBI_220x110_B.mat').G;
%%
grids = {G1, G2};
names = {'HNCP-50', 'CNCP-50'};
plotname = 'horz-vs-cart-SPE11C';
%%
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
exportgraphics(T, sprintf('./../plotsMaster/histograms/%s-volumes.pdf', plotname));
exportgraphics(T, sprintf('./../plotsMaster/histograms/%s-volumes.png', plotname));

%%

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
exportgraphics(T, sprintf('./../plotsMaster/histograms/%s-neighbors.pdf', plotname));
exportgraphics(T, sprintf('./../plotsMaster/histograms/%s-neighbors.png', plotname));
%%
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
exportgraphics(T, sprintf('./../plotsMaster/histograms/%s-faceA.pdf', plotname));
exportgraphics(T, sprintf('./../plotsMaster/histograms/%s-faceA.png', plotname));