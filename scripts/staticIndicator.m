clear all
close all
%%
aspectRatio = 2.7;

% Calculate the width and height to maintain the aspect ratio
width = 900;  % Choose an appropriate value for the width
height = width / aspectRatio;

% Set the default figure position
set(0, 'DefaultFigurePosition', [100, 100, width, height]);
%%
gridcases = {'5tetRef3', '6tetRef3', 'struct340x150', 'struct220x90', 'semi263x154_0.3',...
    'semi188x38_0.3', 'struct180x40'};
simcase = Simcase('gridcase', gridcases{2});
% simcase = Simcase('deckcase', 'RS', 'usedeck',true);
%%
G = simcase.G;

[ortherr, errvec, fwerr] = simcase.computeStaticIndicator;
%%
plot_fwerr = true;
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
title(displayNameGrid(gridname));
axis tight;axis equal;
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
    % exportgraphics(h, fullfile(savefolder, saveName));
    exportgraphics(h, fullfile(savefolder, replace(saveName, '.eps', '.png')));

end