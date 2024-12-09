clear all
close all
%% python env with gmsh and numpy
pythonpath = char(fullfile("scripts/gridgeneration/ggvenv/bin/python"));
%% Generate and save grids for SPE11B
% Ca 10K celler
% nx = 140; nz = 75; refinementFactorQT = 1.2; refinementFactorT = 1.25; sigdigits = [1, 2];
% ca. 50k celler
% nx = 500; nz = 100; refinementFactorQT = 0.54; refinementFactorT = 0.52; sigdigits = [2, 2];
% ca 100K celler
nx = 840; nz = 120; refinementFactorQT = 0.38; refinementFactorT = 0.36; sigdigits = [2, 2];
% ca 200K celler
% nx = 1180; nz = 170; refinementFactorQT = 0.28; refinementFactorT = 0.25; sigdigits = [2, 2];
% ca 500K celler
% nx = 1870; nz = 270; refinementFactorQT = 0.175; refinementFactorT = 0.16; sigdigits = [3, 2];
% ca 1M celler
% nx = 2640; nz = 380; refinementFactorQT = 0.12; refinementFactorT = 0.112; sigdigits = [3, 2];

%%
SPEcase = 'B';
% generateStructuredGrid(nx, 1, nz, 'SPEcase', SPEcase, 'save', true);
% generateCutCellGrid(nx, nz, 'SPEcase', SPEcase, 'save', true);
% generateCutCellGrid(nx, nz, 'SPEcase', SPEcase, 'save', true, 'type', 'cartesian');
generateQTorTGridMatlab('refinementFactor', refinementFactorQT, 'gridType', 'QT', 'SPEcase', SPEcase, 'pythonPath', pythonpath);
generateQTorTGridMatlab('refinementFactor', refinementFactorT, 'gridType', 'T', 'SPEcase', SPEcase, 'pythonPath', pythonpath);
% generatePEBIGrid(nx, nz, 'SPEcase', 'B', 'save', true); %likely wont work for cell counts below 100K

gridcases = {
             % sprintf('struct%dx%d', nx, nz),...
             % sprintf('horz_ndg_cut_PG_%dx%d', nx, nz),...
             % sprintf('cart_ndg_cut_PG_%dx%d', nx, nz),...
             sprintf('gq_pb%.*f', sigdigits(1), refinementFactorQT),...
             sprintf('5tetRef%.*f', sigdigits(2), refinementFactorT),...
            %  sprintf('cPEBI_%dx%d', nx, nz)
             };
names = {
         % sprintf('b_C_%dx%d', nx, nz),...
         % sprintf('b_HC_%dx%d', nx, nz),...
         % sprintf('b_CC_%dx%d', nx, nz),...
         strrep(sprintf('b_QT%.*f', sigdigits(1), refinementFactorQT), '.', '_'),...
         strrep(sprintf('b_T%.*f', sigdigits(2), refinementFactorT), '.', '_'),...
        %  sprintf('b_PEBI_%dx%d', nx, nz)
         };

folder = '~/Code/CSP11_JutulDarcy.jl/data/';
saveGridRocks(gridcases, names, folder, 'B');

%% SPE11C
SPEcase = 'C';
% ~10K cells
% nx = 49; ny = 25; nz = 29; 
% ~100K cells
nx = 61; ny = 36; nz = 44; refinementFactorQT = 10; refinementFactorT = 3.1; sigdigits = [1, 1];
%~1M cells
% nx = 133; ny = 78; nz = 96; refinementFactorQT = 1.06; refinementFactorT = 1.1; sigdigits = [2, 1];
%%
generateStructuredGrid(nx, ny, nz, 'SPEcase', SPEcase, 'save', true);
generateCutCellGrid(nx, nz, 'Cdepth', ny, 'SPEcase', SPEcase, 'save', true);
generateCutCellGrid(nx, nz, 'Cdepth', ny, 'SPEcase', SPEcase, 'save', true, 'type', 'cartesian');
generateQTorTGridMatlab('refinementFactor', refinementFactorQT, 'Cdepth', ny, 'gridType', 'QT', 'SPEcase', SPEcase, 'pythonPath', pythonpath);
generateQTorTGridMatlab('refinementFactor', refinementFactorT, 'Cdepth', ny, 'gridType', 'T', 'SPEcase', SPEcase, 'pythonPath', pythonpath);
%%
gridcases = {
             sprintf('struct%dx%dx%d', nx, ny, nz),...
             sprintf('horz_ndg_cut_PG_%dx%dx%d', nx, ny, nz),...
             sprintf('cart_ndg_cut_PG_%dx%dx%d', nx, ny, nz),...
             sprintf('gq_pb%.*fx%d', sigdigits(1), refinementFactorQT, ny),...
             sprintf('5tetRef%.*fx%d', sigdigits(2), refinementFactorT, ny),...
             };
names = {
         sprintf('b_C_%dx%dx%d', nx, ny, nz),...
         sprintf('b_HC_%dx%dx%d', nx, ny, nz),...
         sprintf('b_CC_%dx%dx%d', nx, ny, nz),...
         strrep(sprintf('b_QT%.*fx%d', sigdigits(1), refinementFactorQT, ny), '.', '_'),...
         strrep(sprintf('b_T%.*fx%d', sigdigits(2), refinementFactorT, ny), '.', '_'),...
         };
%% Save
folder = '~/Code/CSP11_JutulDarcy.jl/data/';
saveGridRocks(gridcases, names, folder, 'C');
disp("Done.")



%% 
% Plot cell tags for each grid case
for i = 1:numel(gridcases)
    gridcase = gridcases{i};
    tagcase = 'allcells-bufferMult';
    simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'tagcase', tagcase, 'deckcase', 'B_ISO_C', 'usedeck', true);
    G = simcase.G;
    fprintf('Grid case: %s, Number of cells: %d\n', gridcase, G.cells.num);
    
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
% plotToolbar(Ghc, Ghc);view(10,10);
% axis tight %equal;

