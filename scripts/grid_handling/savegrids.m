clear all
close all
%% python env with gmsh and numpy
pythonpath = char(fullfile("scripts/gridgeneration/ggvenv/bin/python"));
%% Generate and save grids for SPE11B
% Ca 10K celler
% nx = 140; nz = 75; refinementFactorQT = 1.2; refinementFactorT = 1.3; sigdigits = 1;
% ca. 50k celler
% nx = 500; nz = 100; refinementFactorQT = 0.38; refinementFactorT = 0.54; sigdigits = 2;
% ca 100K celler
nx = 840; nz = 120; refinementFactorQT = 0.25; refinementFactorT = 0.37; sigdigits = 2;
% ca 200K celler
% nx = 1180; nz = 170; refinementFactorQT = 0.17; refinementFactorT = 0.26; sigdigits = 2;
% ca 500K celler
% nx = 1870; nz = 270; refinementFactorQT = 0.103; refinementFactorT = 0.160; sigdigits = 3;
% ca 1M celler
% nx = 2640; nz = 380; refinementFactorQT = 0.071; refinementFactorT = 0.112; sigdigits = 3;

generateStructuredGrid(nx, 1, nz, 'SPEcase', 'B', 'save', true);
generateCutCellGrid(nx, nz, 'SPEcase', 'B', 'save', true);
generateCutCellGrid(nx, nz, 'SPEcase', 'B', 'save', true, 'type', 'cartesian');
generateQTorTGridMatlab('refinementFactor', refinementFactorQT, 'gridType', 'QT', 'SPEcase', 'B', 'pythonPath', pythonpath);
generateQTorTGridMatlab('refinementFactor', refinementFactorT, 'gridType', 'T', 'SPEcase', 'B', 'pythonPath', pythonpath);
generatePebiGrid(nx, nz, 'SPEcase', 'B', 'save', true); %likely wont work for cell counts below 100K

gridcases = {sprintf('struct%dx%d', nx, nz),...
             sprintf('horz_ndg_cut_PG_%dx%d', nx, nz),...
             sprintf('cart_ndg_cut_PG_%dx%d', nx, nz),...
             sprintf('gq_pb%.*f', sigdigits, refinementFactorQT),...
             sprintf('5tetRef%.*f', sigdigits, refinementFactorT),...
             sprintf('cPEBI%dx%d', nx, nz)
             };
names = {sprintf('b_C_%dx%d', nx, nz),...
         sprintf('b_HC_%dx%d', nx, nz),...
         sprintf('b_CC_%dx%d', nx, nz),...
         strrep(sprintf('b_QT%.*f', sigdigits, refinementFactorQT), '.', '_'),...
         strrep(sprintf('b_T%.*f', sigdigits, refinementFactorT), '.', '_'),...
         sprintf('b_PEBI%dx%d', nx, nz)
         };

folder = '~/Code/CSP11_JutulDarcy.jl/data/';
saveGridRocks(gridcases, names, folder, 'B');
%% 
% Plot cell tags for each grid case
for i = 1:numel(gridcases)
    gridcase = gridcases{i};
    tagcase = 'allcells-bufferMult';
    simcase = Simcase('SPEcase', 'B', 'gridcase', gridcase, 'tagcase', tagcase, 'deckcase', 'B_ISO_C', 'usedeck', true);
    G = simcase.G;
    
    figure
    plotCellData(G, G.cells.tag);
    title(['Cell tags for ' gridcase]);
    colorbar;
    view(0,0);
    axis tight
end


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
gridcase = 'struct310x160'; name = "b_C_310x160"; SPEcase = 'B';


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