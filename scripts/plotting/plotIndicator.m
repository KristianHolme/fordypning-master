clear all
close all
%% Prepare simcases
SPEcase = 'C';
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', 'gq_pb0.19', '5tetRef0.31'};
gridcases = {'struct50x50x50', 'horz_ndg_cut_PG_50x50x50', 'cart_ndg_cut_PG_50x50x50'};

numgrids = numel(gridcases);
simcases = {};
maxNumCells = 0;
maxNumRegFaces = 0;
regBdryfaces = {};
for igrid = 1:numgrids
    simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcases{igrid});
    simcases{igrid} = simcase;
    maxNumCells = max(maxNumCells, simcase.G.cells.num);
    regBdryfaces{igrid} = LayerCrossingFaces(simcase.G);
    maxNumRegFaces = max(maxNumRegFaces, numel(regBdryfaces{igrid})); 
end

%% Load data
errdata = nan(maxNumCells, igrid);
fwerrdata = nan(maxNumCells, igrid);
errvectdata = nan(maxNumRegFaces, igrid);
names = {};
gridcasecolors = {'#0072BD', '#77AC30', '#D95319', '#7E2F8E', '#FFBD43',  '#02bef7', '#AC30C6',  '#19D9E6', '#ffff00'};
for igrid = 1:numgrids
    simcase = simcases{igrid};
    [err, errvect, fwerr] = simcase.computeStaticIndicator;
    errdata(1:numel(err),igrid) = err;
    fwerrdata(1:numel(err),igrid) = fwerr;
    isRegBdry = regBdryfaces{igrid};
    faceerr = sqrt(sum(reshape(errvect,3, []).^2))';
    errvectdata(1:sum(isRegBdry), igrid) = faceerr(isRegBdry);


    names{igrid} = displayNameGrid(simcase.gridcase, simcase.SPEcase);
    colors{igrid} = hex2rgb(gridcasecolors{igrid});
end
%% Plot
% figure('Position', [100, 100, 800, 600]);
% distributionPlot(errdata+mn, 'color', colors, 'xnames', names, 'showMM', 0, 'addboxes', true);
boxplot(errdata, 'Colors', vertcat(colors{:}), 'Labels',names, 'Whisker',Inf);
% ylims = ylim;
% ylims(1) = ylims(1)*0.2;
% ylim(ylims);
xlim([0.5, numgrids+0.5]);
ax = gca;
ax.YScale = 'log';
grid();
tightfig();
saveas(gcf, fullfile('../plotsMaster/staticIndicator', ['err', SPEcase,'.eps']), 'epsc');
%% bad experimentation
maxVal = max(errdata, [], 'all');
transformFunc = @(x) log(x+1) + (x/maxVal) * 10;
%%
newticks = [logspace(-30, -18, 5),linspace(1e-17, 1e-9, 5)];
yticks(newticks)