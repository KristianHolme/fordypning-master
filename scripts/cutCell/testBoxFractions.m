clear all
close all
%%
set(groot, 'defaultAxesView', [0, 0]);
%%
G = cartGrid([20,1,20], [8400,1, 1200]);
G = computeGeometry(G);
plotGrid(G)
%%


