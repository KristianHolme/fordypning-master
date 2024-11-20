clear all
close all
%%
pythonpath = char(fullfile("scripts/gridgeneration/ggvenv/bin/python"));
%%
nx = 130; nz = 62; refinementFactorQT = 1.2; refinementFactorT = 1.2; sigdigits = 1;
% nx = 819; nz = 117; refinementFactorQT = 0.19; refinementFactorT = 0.1; sigdigits = 2;
generateStructuredGrid(nx, 1, nz, 'SPEcase', 'B', 'save', true);
generateCutCellGrid(nx, nz, 'SPEcase', 'B', 'save', true);
generateCutCellGrid(nx, nz, 'SPEcase', 'B', 'save', true, 'type', 'cartesian');
generateQTorTGridMatlab('refinementFactor', refinementFactorQT, 'gridType', 'QT', 'SPEcase', 'B', 'pythonPath', pythonpath);
generateQTorTGridMatlab('refinementFactor', refinementFactorT, 'gridType', 'T', 'SPEcase', 'B', 'pythonPath', pythonpath);
% generatePebiGrid(nx, nz, 'SPEcase', 'B', 'save', true); %optional

gridcases = {sprintf('struct%dx%d', nx, nz),...
             sprintf('horz_ndg_cut_PG_%dx%d', nx, nz),...
             sprintf('cart_ndg_cut_PG_%dx%d', nx, nz),...
             sprintf('gq_pb%.*f', sigdigits, refinementFactorQT),...
             sprintf('5tetRef%.*f', sigdigits, refinementFactorT),...
             % sprintf('cPEBI%dx%d', nx, nz)
             };
names = {sprintf('b_C_%dx%d', nx, nz),...
         sprintf('b_HC_%dx%d', nx, nz),...
         sprintf('b_CC_%dx%d', nx, nz),...
         strrep(sprintf('b_QT%.*f', sigdigits, refinementFactorQT), '.', '_'),...
         strrep(sprintf('b_T%.*f', sigdigits, refinementFactorT), '.', '_'),...
         % sprintf('b_PEBI%dx%d', nx, nz)
         };

folder = '~/Code/CSP11_JutulDarcy.jl/data/';
saveGridRocks(gridcases, names, folder, 'B');
%%
nx = 100;
ny = 50;
% gridcase = sprintf('horz_ndg_cut_PG_%dx%d', nx, ny);
% gridcase = 'struct50x50x50'; name = "c_C_50x50x50"; SPEcase = 'C';
% gridcase = 'cart_ndg_cut_PG_50x50x50'; name = "c_CC_50x50x50"; SPEcase = 'C';
% gridcase = 'horz_ndg_cut_PG_50x50x50'; name = "c_HC_50x50x50"; SPEcase = 'C';
% gridcase = 'struct819x117'; name = "b_C_819x117"; SPEcase = 'B';
% gridcase = 'horz_ndg_cut_PG_819x117'; name = "b_HC_819x117"; SPEcase = 'B';
% gridcase = 'cart_ndg_cut_PG_819x117'; name = "b_CC_819x117"; SPEcase = 'B';
gridcase = 'struct130x62'; name = "b_C_130x62"; SPEcase = 'B';


folder = 'data/grid-files/gridrock_simready';

%%

tagcase = 'allcells-bufferMult';
% tagcase = 'bufferMult';
simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'tagcase', tagcase, 'deckcase', 'B_ISO_C', 'usedeck', true);
% name = sprintf('horizon-cut_%dx%d', nx, ny);
%name = gridcase;
simcase.saveGridRock(name, 'folder', folder);
% %%
% load(['data/grid-files/gridrock_simready/', name]);
% 
% %% 
% plotToolbar(G, G);view(10,10);
% axis tight %equal;