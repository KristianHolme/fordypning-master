clear all
close all
%%
SPEcase = 'B';
if strcmp(SPEcase, 'A') 
    xscaling = hour; unit = 'h';
    steps = 720;
    totsteps = 720;
else 
    xscaling = speyear;unit='y';
    steps = 301;
    totsteps = 301;
end

resetData = true;
saveplot = false;
legendpos = 'best';
plottitle = true;
xtxt = ['Time [', unit, ']'];
% chose what mrst simulations to show
[mrstgridcases, mrstgridnames] = getRSCGridcases(["C"], [10]);
for i = 1:numel(mrstgridnames)
    parts = split(mrstgridnames{i}, '_');
    mrstgridnames{i} = parts{2};
end
% chose what jutul simulations to show
[~, jutulgridcases] = getRSCGridcases(["C"], [10]);
jutulgridnames = {};
for i = 1:numel(jutulgridcases)
    parts = split(jutulgridcases{i}, '_');
    jutulgridnames{i} = parts{2};
end

%% Load simcases compThermal
simcases = {};
colors = {};
gridcasecolors = containers.Map({'C', 'HC', 'CC', 'QT', 'T', 'PEBI'}, {'#0072BD', "#77AC30", "#D95319", "#7E2F8E", '#FFBD43', '#02bef7'});
for igrid = 1:numel(mrstgridcases)
    gridcase = mrstgridcases{igrid};
    colors{end+1} = gridcasecolors(mrstgridnames{igrid});
    simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', 'B_ISO_C', 'usedeck', true, 'gridcase', gridcase);
end
for igrid = 1:numel(jutulgridcases)
    gridcase = jutulgridcases{igrid};
    colors{end+1} = gridcasecolors(jutulgridnames{igrid});
    simcases{end+1} = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'jutulThermal', true, 'tagcase', 'allcells');
end

discstyles = {'-', '--'};
plotStyles = {};

for isim = 1:numel(simcases)
    simcase = simcases{isim};
    color = colors{isim};
    if simcase.jutulThermal
        style = discstyles{1};
    else
        style = discstyles{2};
    end
    plotStyles{end+1} = struct('Color', color, 'LineStyle', style, 'Marker','none');
end
%% data function
plotTypes = {'sealing', ...%1
             'buffer', ...%2
             'pop1', ...%3
             'pop2', ...%4
             'p21', ...%5
             'p22', ...%6
             'p23', ...%7
             'p24', ...%8
             'p31', ...%9
             'p32', ...%10
             'p33', ...%11
             'p34'};%12

type = plotTypes{5};
[getData, plotTitle, ytxt, ~, filetag] = initMeasurablePlots(type, resetData);



%% Load data compThermal

xdata = cumsum(simcases{1}.schedule.step.val)/xscaling;
xdata = xdata(1:steps);
xdata_thermal = load('/media/kristian/HDD/Jutul/output/csp11/thermal_dt.mat').dt/xscaling;
xdatasets = {xdata, xdata_thermal};
data = nan(steps, numel(simcases));
twosteps = [steps, numel(xdata_thermal)];
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    if simcase.jutulThermal
        step = twosteps(2);
    else
        step = twosteps(1);
    end
    data(1:step,isim) = getData(simcase, step);
end
disp("Loading done.");

%% Plot compThermal

set(groot, 'defaultLineLineWidth', 2);
figure('Position', [100,200, 800, 600], 'Name',plotTitle)
hold on;
scale = floor(log10(max(data, [], 'all')));
axfix = false;
if scale ~=1 && ~contains(ytxt, 'bar') && axfix
    figscaling = 3*floor(scale/3);
    figytxt = replace(ytxt, '[', ['[10^{', num2str(figscaling), '} ']);
    figdata = data ./ 10^figscaling;
else
    figdata = data;
    figytxt = ytxt;
end
for i=1:numel(simcases)
    simcase = simcases{i};
    if simcase.jutulThermal
        step = twosteps(2);
        x = xdatasets{2};
    else
        step = twosteps(1);
        x = xdatasets{1};
    end

    y = figdata(1:step, i);
    plot(x, y, 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle);
end
% Create dummy plots for legend
gridcases = unique([mrstgridnames, jutulgridnames]);
h_grid = [];
for igrid = 1:numel(gridcases)
    gridcase = gridcases{igrid};
    color = gridcasecolors(gridcase);
    h_grid(igrid) = plot(NaN,NaN, 'Color', color, 'LineStyle', '-', 'LineWidth', 2); % No data, just style
end
h_disc = [];
for isim = [find(cellfun(@(x) ~x.jutulThermal, simcases), 1), find(cellfun(@(x) x.jutulThermal, simcases), 1)]
    style = discstyles{isim};
    h_disc(isim) = plot(NaN,NaN, 'Color', 'k', 'LineStyle', style, 'LineWidth', 2); % No data, just style
end

% Combine handles and labels
handles = [h_grid, h_disc];
simlabels = {'Black-oil', 'Compositional'}; 
labels = [gridcases, simlabels];

% Create the legend
lgd = legend(handles, labels,'NumColumns', 2);
set(lgd, 'Interpreter', 'none', 'Location', legendpos);
hold off
if plottitle
    title(plotTitle);
end
fontsize(16, 'points'); 
xlabel(xtxt);
ylabel(figytxt);
grid on;

% if insetPlot
%     %plot inside plot
%     insetPosition = [0.19 0.15 0.25 0.25];
%     insetAxes = axes('Position',insetPosition);
%     insetsteps = 201;
%     insetxdata = xdata(1:insetsteps);
%     for i=1:numel(simcases)
%         plot(insetAxes, insetxdata, data(1:insetsteps, i), 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle, 'Marker', plotStyles{i}.Marker, 'MarkerSize',4, 'MarkerIndices',1:10:numel(insetxdata));
%         hold on;
%     end
%     grid(insetAxes);
% end
tightfig()
if saveplot
    % folder = './plots/sealingCO2';
    filename = [SPEcase, '_', filetag,'_', strjoin(gridcases, '_'), '-', strjoin(simlabels, '_')];
    % saveas(gcf, fullfile(folder, [filename, '.svg']))%for color
    % print(fullfile(folder, [filename, '.pdf']), '-dpdf')
    saveas(gcf, fullfile(folder, [filename, '.png']))
    saveas(gcf, fullfile(folder, [filename,'.eps']), 'epsc');
end
% pause(0.5)
% close gcf
