%% Show fault
close all;
figure
plotCellData(simcase.G, simcase.G.cells.tag);view(0,0);
set(gca, 'xlim', [1050, 1650], 'zlim', [440, 1050]);
%%
savepath = ['./../rapport/Figures/grids/', displayNameGrid(simcase.gridcase, simcase.SPEcase), '_fault.png']
exportgraphics(gcf, savepath, 'ContentType','Auto', Resolution=500);
%%
G = generateCutCellGrid(28,10, 'type', 'horizon', 'presplit', true, ...
    'recombine', false, 'bufferVolumeSlice', false, 'partitionMethod', 'facearea', ...
    'nudgeGeom', false, 'round', false, 'SPEcase', 'B');

%%
plotGrid(G);view(0,0);axis tight;
plotCellData(G, G.cells.tag);view(0,0);axis tight;
exportgraphics(gcf, './../rapport/Figures/grids/HPC-SC_cut.pdf', 'ContentType','vector', Resolution=500);

%%
CG = generateCoarseGrid(Gcut, compressedPartition);
CG = coarsenGeometry(CG);
[CGcellToGcutCell, IA] = unique(partition);
CG.cells.tag = Gcut.cells.tag(IA);
VizCoarse(CG)
axis tight
view(0,90)
set(gca, 'xlim', [2.1, 2.6], 'ylim', [0.97, 1.2])
exportgraphics(gcf, './../rapport/Figures/grids/CP-SC_part.png', 'ContentType','Image', Resolution=500);

%%
% G = generateCutCellGrid(898,120, 'type', 'horizon', 'presplit', false, ...
%     'recombine', true, 'bufferVolumeSlice', false, 'partitionMethod', 'convexity', ...
%     'nudgeGeom', true, 'round', false, 'SPEcase', 'B');
load('data/grid-files/cutcell/horizon_nudge_cutcell_898x120.mat')
plotCellData(G, G.cells.tag);view(0,0);
set(gca, 'xlim', [1085, 1170], 'zlim', [870, 940]); %more zoom in
% set(gca, 'xlim', [940, 1400], 'zlim', [750, 950]); %original for zoomout
exportgraphics(gcf, './../rapport/Figures/grids/HNCP-zoomfault.png', 'ContentType','image', Resolution=500);