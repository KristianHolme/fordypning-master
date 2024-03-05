clear all
close all
%%
nx = 100;
ny = 50;
gridcase = sprintf('horz_ndg_cut_PG_%dx%d', nx, ny);
tagcase = 'allcells-bufferMult';
SPEcase = 'B';
simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'tagcase', tagcase);
name = sprintf('horizon-cut_%dx%d', nx, ny);
simcase.saveGridRock(name);
% %%
% load(['grid-files/gridrock_simready/', name]);
% 
% %% 
% plotToolbar(G, G);view(10,10);
% axis tight %equal;