% clear all
% close all
% %%
% set(groot, 'defaultAxesView', [0, 0]);
% %%
% G = cartGrid([20,1,20], [8400,1, 1200]);
% G = computeGeometry(G);
% plotGrid(G)
%%
SPEcase = 'B';
fn = "grid-files/cutcell/buff_horizon_nudge_cutcell_PG_2640x380.mat";
bigLoad = load(fn);
G = bigLoad.G;
t = tic();
disp("Adding injection cells and box-volume-fractions...");
[w1, w2] = getinjcells(G, SPEcase);
G.cells.wellCells = [w1, w2];
G = addBoxWeights(G);
t = toc(t);
fprintf( "Done in %0.2d s.\n", t);
save(fn, "G");
%%
% plotToolbar(Gcut, Gcut.cells);view(0,0);
% 
% %%
% Gp = GenerateCutCellGrid(898, 120, 'save', false);

