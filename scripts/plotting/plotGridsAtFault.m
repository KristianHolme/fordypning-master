% Specify grid case and load simcase
gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', 'gq_pb0.19', '5tetRef0.31'};
gridcase = gridcases{6}; % Change this to use different grids
SPEcase = 'B';
deckcase = 'B_ISO_C';
simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase);

% Define custom colors for tags 1-7
customColors = [
    200,153,42;  % Red for 1
    117,141,189;  % Green for 2
    200,134,103;  % Blue for 3
    173,74,57;  % Yellow for 4
    84,111,61;  % Magenta for 5
    93,22,159;  % Cyan for 6
    171,166,164   % Gray for 7
]/255;

% Create plot
close all;
figure
plotCellData(simcase.G, simcase.G.cells.tag);
view(0,0);

% Customize the plot
ax = gca;
set(ax, 'Color', [171,166,164]/255); % Set background color to light gray
set(ax, 'xlim', [1050, 1650], 'zlim', [440, 1050]);

% Apply custom colormap for the integer tags
colormap(customColors);
caxis([1 7]); % Set color axis limits to match our tag range
savepath = ['./plots/RCS/grids-fault/', displayNameGrid(simcase.gridcase, simcase.SPEcase), '_fault.png']
exportgraphics(gcf, savepath, 'ContentType','Auto', Resolution=500);
