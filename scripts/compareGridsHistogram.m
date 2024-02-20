clear all
close all
%%
nx = 460;
ny = 64;
G1 = GenerateCutCellGrid(nx, ny, 'save', false, 'bufferVolumeSlice', false);
G2 = GenerateCutCellGrid(nx, ny, 'save', false, 'bufferVolumeSlice', false, 'type', 'cartesian');
G3 = GeneratePEBIGrid(nx, ny, 'save', false, 'bufferVolumeSlice', false, 'FCFactor', 1.0);
%%
grids = {G1, G2, G3};
names = {'HNCP-M', 'CNCP-M', 'cPEBI-M'};
%%
T = tiledlayout(numel(gridcases), 1);

for ig = 1:numel(gridcases)
    G = grids{ig};
    name = names{ig};
    nexttile(ig);
    histogram(log10(G.cells.volumes));
    title(sprintf('Grid: %s, Cells: %d', name, G.cells.num));
    xlabel('Log10(cell volumes)');
    ylabel('Frequency');
end

%%
exportgraphics(T, sprintf('./../plotsMaster/histograms/horz_ndg-cart_ndg-cPEBI-M.pdf'));
exportgraphics(T, sprintf('./../plotsMaster/histograms/horz_ndg-cart_ndg-cPEBI-M.png'));

%%

T = tiledlayout(numel(grids), 1);

for ig = 1:numel(gridcases)
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
