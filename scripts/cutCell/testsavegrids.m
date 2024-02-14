clear all
close all
%%
nx = 898;
ny = 120;
gridcase = sprintf('horz_ndg_cut_PG_%dx%d', nx, ny);
tagcase = 'allcells';
SPEcase = 'B';
simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'tagcase', tagcase);
name = sprintf('horizon-nudge_%dx%d', nx, ny);
simcase.saveGridRock(name);
%%
load(['grid-files/cutcell/gridrock_simready/', name]);

%% 
plotToolbar(G, G.cells.volumes);view(10,0)