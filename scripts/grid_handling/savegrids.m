clear all
close all
%%
nx = 100;
ny = 50;
% gridcase = sprintf('horz_ndg_cut_PG_%dx%d', nx, ny);
gridcase = 'struct50x50x50';
% gridcase = 'struct819x117';
% gridcase = 'horz_ndg_cut_PG_819x117';
% gridcase = 'cart_ndg_cut_PG_819x117';
% gridcase = 'cart_ndg_cut_PG_50x50x50';
% gridcase = 'horz_ndg_cut_PG_50x50x50';


tagcase = 'allcells-bufferMult';
SPEcase = 'C';
simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'tagcase', tagcase, 'deckcase', 'B_ISO_C', 'usedeck', true);
% name = sprintf('horizon-cut_%dx%d', nx, ny);
name = gridcase;
simcase.saveGridRock(name);
% %%
% load(['data/grid-files/gridrock_simready/', name]);
% 
% %% 
% plotToolbar(G, G);view(10,10);
% axis tight %equal;