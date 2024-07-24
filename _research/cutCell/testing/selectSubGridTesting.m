G = load('./../../total-grids/flat_tetra/flat_tetra_gmshToMRST_flipped.mat').G;
G_full = G;
%%
ymin = 5000;
ymax = 7000;
subcells = G.cells.centroids(:,2) > ymin & G.cells.centroids(:,2) < ymax;

Gsub = extractSubgrid(G, subcells);
%%
ymin2 = 5500;
ymax2 = 6500;
Gsubcut = sliceGrid(Gsub, {[0 ymin2 0], [0 ymax2 0]}, 'normal', [0 1 0]);
%%
subsubcells = Gsubcut.cells.centroids(:,2) > ymin2 & Gsubcut.cells.centroids(:,2) < ymax2;
Gsubcutsub = extractSubgrid(Gsubcut, subsubcells);
%%
Gsubcutsub.cells.num
plotGrid(Gsubcutsub)
%%
G = Gsubcutsub;
save('~/Code/total-grids/flat_tetra/flat_tetra_sub.mat', "G")

%% New subgrid around well
xmin = 1.2e4;
xmax = 1.6e4;
ymin = 0.5e4;
ymax = 0.7e4;

%%
padding = 1000;
subcells = G_full.cells.centroids(:,2) > (ymin-padding) & G_full.cells.centroids(:,2) < (ymax+padding)...
           & G_full.cells.centroids(:,1) > (xmin-padding) & G_full.cells.centroids(:,1) < (xmax+padding);

Gsub = extractSubgrid(G, subcells);
%%

Gsubcuty = sliceGrid(Gsub, {[1.6e4 ymin 100], [1.6e4 ymax 100]}, 'normal', [0 1 0]);
Gsubcut = sliceGrid(Gsubcuty, {[xmin 0 0], [xmax 0 0]}, 'normal', [1 0 0]);
%%
subsubcells = Gsubcut.cells.centroids(:,2) > (ymin) & Gsubcut.cells.centroids(:,2) < (ymax)...
           & Gsubcut.cells.centroids(:,1) > (xmin) & Gsubcut.cells.centroids(:,1) < (xmax);

Gsubcutsub = extractSubgrid(Gsubcut, subsubcells);
%%
Gsubcutsub.cells.num
plotGrid(Gmsh);plotGrid(Gsub, 'facecolor', 'red');plotGrid(Gsubcutsub, 'facecolor', 'green')
%%
G = Gsubcutsub;
save('~/Code/total-grids/flat_tetra/flat_tetra_subwell.mat', "G")