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
G1 = load('grid-files/cutcell/horizon_nudge_cutcell_PG_130x62_B.mat').G;
G2 = load('grid-files/cutcell/horizon_presplit_cutcell_PG_130x62_B.mat').G;
G3 = load('grid-files/PEBI/buff_cPEBI_220x110_B.mat').G;
%%
grids = {G1, G2};
names = {'CPCP-C', 'CNCP-C'};
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
savepath = './../plotsMaster/histograms/nudge-v-pre-C';
exportgraphics(T, [savepath, '.pdf']);
exportgraphics(T, [savepath, '.png']);

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
exportgraphics(T, sprintf('./../plotsMaster/histograms/horz_ndg-cart_ndg-cPEBI-M-neighbors.pdf'));
exportgraphics(T, sprintf('./../plotsMaster/histograms/horz_ndg-cart_ndg-cPEBI-M-neighbors.png'));
%%
T = tiledlayout(numel(grids), 1);

for ig = 1:numel(grids)
    G = grids{ig};
    name = names{ig};
    nexttile(ig);
    histogram(log10(G.faces.areas));
    title(sprintf('Grid: %s, Cells: %d', name, G.cells.num));
    xlabel('Log10(face areas)');
    ylabel('Frequency');
end

%%
exportgraphics(T, sprintf('./../plotsMaster/histograms/horz_ndg-cart_ndg-cPEBI-M-faceA.pdf'));
exportgraphics(T, sprintf('./../plotsMaster/histograms/horz_ndg-cart_ndg-cPEBI-M-faceA.png'));