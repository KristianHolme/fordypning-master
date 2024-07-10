function measurablePlot(data, xdata, plottingInfo, discs, varargin)
opt = struct(...
    'plotTitle', 'missing title',...
    'axfix', false, ...
    'folder', '.', ...
    'plotbars', false, ...
    'ytxt', '', ...
    'xtxt', '',...
    'filetag', '', ...
    'numGrids', 1, ...
    'uwComp', false, ...
    'legendpos', 'best', ...
    'insetPlot', false, ...
    'saveplot', true, ...
    'SPEcase', 'B', ...
    'gridcases', {''});
opt = merge_options(opt, varargin{:});
folder = opt.folder;
ytxt = opt.ytxt;
xtxt = opt.xtxt;
filetag = opt.filetag;
plotTitle = opt.plotTitle;
plotbars = opt.plotbars;
axfix = opt.axfix;
legendpos = opt.legendpos;
SPEcase = opt.SPEcase;
gridcases = opt.gridcases;

[gridcasecolors, discstyles, markers, plotStyles] = plottingInfo{:};
set(groot, 'defaultLineLineWidth', 2);
f1 = figure('Position', [100,200, 800, 600], 'Name',plotTitle);
hold on;
scale = floor(log10(max(data, [], 'all')));

if scale ~=1 && ~contains(ytxt, 'bar') && axfix
    figscaling = 3*floor(scale/3);
    figytxt = replace(ytxt, '[', ['[10^{', num2str(figscaling), '} ']);
    figdata = data ./ 10^figscaling;
else
    figdata = data;
    figytxt = ytxt;
end
for i=1:size(data, 2)
    plot(xdata, figdata(:, i), 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle, 'Marker', plotStyles{i}.Marker, 'MarkerSize',6, 'MarkerIndices',1:10:numel(xdata));
end
if opt.numGrids > 1
    % Create dummy plots for legend
    h_grid = [];
    for igrid = 1:numel(gridcases)
        color = gridcasecolors{igrid};
        h_grid(igrid) = plot(NaN,NaN, 'Color', color, 'LineStyle', '-', 'LineWidth', 2); % No data, just style
    end
    h_disc = [];
    for idisc = 1:numel(discs)
        if isscalar(discs)
            break
        end
        style = discstyles{idisc};
        marker = markers{idisc};
        h_disc(idisc) = plot(NaN,NaN, 'Color', 'k', 'LineStyle', style, 'LineWidth', 2, 'Marker',marker); % No data, just style
    end
    % Combine handles and labels
    handles = [h_grid, h_disc];
    gridcasesDisp = cellfun(@(gridcase) displayNameGrid(gridcase, SPEcase), gridlabels,  'UniformOutput', false);
    if numel(uwdiscs)>1
        discs{1} = 'SPU';
    end
    discsDisp = cellfun(@shortDiscName, discs, 'UniformOutput', false); 
    labels = [gridcasesDisp, discsDisp];
else
    h_disc = [];
    for idisc = 1:numel(discs)
        if isscalar(discs)
            break
        end
        style = discstyles{idisc};
        marker = markers{idisc};
        color = gridcasecolors{1};
        h_disc(idisc) = plot(NaN,NaN, 'Color', color, 'LineStyle', style, 'LineWidth', 2, 'Marker',marker); % No data, just style
    end
    % Combine handles and labels
    handles = h_disc;
    if opt.uwComp
        discs{1} = 'SPU';
    end
    discsDisp = cellfun(@shortDiscName, discs, 'UniformOutput', false); 
    labels = discsDisp;
end

% Create the legend
lgd = legend(handles, labels, 'NumColumns', 2);
set(lgd, 'Interpreter', 'none', 'Location', legendpos);
hold off
if ~isempty(plotTitle)
    title(plotTitle);
end
fontsize(16, 'points'); 
xlabel(xtxt);
ylabel(figytxt);
grid on;

if opt.insetPlot
    %plot inside plot
    insetPosition = [0.19 0.15 0.25 0.25];
    insetAxes = axes('Position',insetPosition);
    insetsteps = 201;
    insetxdata = xdata(1:insetsteps);
    for i=1:numel(simcases)
        plot(insetAxes, insetxdata, data(1:insetsteps, i), 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle, 'Marker', plotStyles{i}.Marker, 'MarkerSize',4, 'MarkerIndices',1:10:numel(insetxdata));
        hold on;
    end
    grid(insetAxes);
end
tightfig();
if plotbars
    f2 = plotbar3(data, gridcasesDisp, discsDisp, gridcasecolors, plotTitle, ytxt);
    tightfig();
end
if opt.saveplot
    % folder = './../plots/sealingCO2';
    filename = [SPEcase, '_', filetag,'_', strjoin(gridcases, '_'), '-', strjoin(discsDisp, '_')];
    % exportgraphics(gcf, fullfile(folder, [filename, '.svg']))%for color
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    saveas(f1, fullfile(folder, [filename, '.png']));
    saveas(f1, fullfile(folder, [filename,'.eps']), 'epsc');
    if plotbars
        filename = [SPEcase, '_', filetag,'_', strjoin(gridcases, '_'), '-', strjoin(discsDisp, '_'), '_bar3'];
        set(f2, 'Renderer', 'painters');
        saveas(f2, fullfile(folder, 'bars', [filename, '.png']));
        saveas(f2, fullfile(folder, 'bars', [filename,'.pdf']), 'pdf');
    end
end