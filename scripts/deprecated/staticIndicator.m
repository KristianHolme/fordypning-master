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

%%
SPEcase = 'A';
% gridcase = '5tetRef1-stretch';
% gridcase = '5tetRef0.4';
% gridcase = '6tetRef0.4';
% gridcase = 'semi263x154_0.3';
gridcase = 'skewed3D';

simcase = Simcase('gridcase', gridcase, 'SPEcase', SPEcase);

% simcase = Simcase('deckcase', 'RS', 'usedeck',true);
%%
G = simcase.G;

[ortherr, errvec, fwerr] = simcase.computeStaticIndicator;
disp(['fwerr: ', num2str(sum(fwerr))])
disp(['ortherr: ', num2str(sum(ortherr))])
%%
plot_fwerr = false;
saveplot = true;

if plot_fwerr
    data = fwerr;
else
    data = ortherr;
end

h = figure;
plotCellData(G, data, 'edgealpha', 0);view(0,0);

if isempty(simcase.gridcase)
    gridname = 'deckGrid';
else
    gridname = simcase.gridcase;
end
% title(displayNameGrid(gridname, SPEcase));
title('K-orthogonality error indicator')
axis tight;
axis equal;
colorbar;
fontsize(20, "points")

if saveplot
    statPlotFolder = fullfile(simcase.dataOutputDir, '..\plots\StaticIndicator');
    if plot_fwerr
        savefolder = fullfile(statPlotFolder, 'fwerr');
        saveName = [SPEcase, '_', gridname, '_fwerr.eps'];
    else
        savefolder = fullfile(statPlotFolder, 'ortherr');
        saveName = [SPEcase, '_', gridname, '_ortherr.eps'];
    end
    % exportgraphics(h, fullfile(savefolder, saveName));
    exportgraphics(h, fullfile(savefolder, replace(saveName, '.eps', '.pdf')), ContentType="auto");

end