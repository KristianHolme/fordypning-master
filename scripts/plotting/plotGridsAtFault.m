% Specify grid case and load simcase
% [gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC', 'PEBI', 'QT', 'T'}, [100]);
[gridcases, gridnames] = getRSCGridcases({'CC'}, [2000]);
i = 1;
gridcase = gridcases{i}; % Change this to use different grids
SPEcase = 'B';
deckcase = 'B_ISO_C';
simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase);

% Define custom colors for tags 1-7
customColors = [
    200,150,39;  
    124,149,189;    
    200,134,103;  
    190,81,62;  
    70,122,33;  
    110,33,172;  
    167,166,163  
]/255;

% Create plot
close all;
figure
plotCellData(simcase.G, simcase.G.cells.tag);
view(0,0);

% Customize the plot
ax = gca;
set(ax, 'Color', [167,166,163]/255); % Set background color to light gray
set(ax, 'xlim', [1050, 1650], 'zlim', [440, 1050]);

% Apply custom colormap for the integer tags
colormap(customColors);
caxis([1 7]); % Set color axis limits to match our tag range
savepath = ['./plots/RSC/grids-fault/', gridcase_to_RSCname(gridcase), '_fault.png']
if false
    exportgraphics(gcf, savepath, 'ContentType','Auto', Resolution=500);
end