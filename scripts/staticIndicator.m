clear all
close all
%%


simcase = Simcase('gridcase', 'tetRef1');
% simcase = Simcase('deckcase', 'RS', 'usedeck',true);
%%
G = simcase.G;

[ortherr, errvec, fwerr] = simcase.computeStaticIndicator;
%%
plot_fwerr = false;
saveplot = true;

if plot_fwerr
    data = fwerr;
else
    data = ortherr;
end

h = figure;
plotCellData(G, data);view(0,0);

if isempty(simcase.gridcase)
    gridname = 'deckGrid';
else
    gridname = simcase.gridcase;
end
title(gridname);
axis tight;
colorbar;

if saveplot
    statPlotFolder = fullfile(simcase.dataOutputDir, '..\plots\StaticIndicator');
    if plot_fwerr
        savefolder = fullfile(statPlotFolder, 'fwerr');
        saveName = [gridname, '_fwerr.eps'];
    else
        savefolder = fullfile(statPlotFolder, 'ortherr');
        saveName = [gridname, '_ortherr.eps'];
    end
    exportgraphics(h, fullfile(savefolder, saveName));
end