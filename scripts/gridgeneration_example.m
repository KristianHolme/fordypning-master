%% Generate cut-cell grid with cartesian background grid and using pre-splitting instead of nudging
G = generateCutCellGrid(130, 62, 'type', 'cartesian', 'presplit', true);
figure;
plotCellData(G, G.cells.tag);
view(0,0);

%% Generate PEBI-grid
G = generatePEBIGrid(819, 117);

%% Generate lower resolution PEBI-grid (not recomended) 
G = generatePEBIGrid(350, 50, 'FCFactor', 0.4);
plotCellData(G, G.cells.tag);
view(0,0);
set(gca, 'xlim', [3600, 4400], 'zlim', [250, 900]);
% Observe that the resolution is very high along faults and horizons