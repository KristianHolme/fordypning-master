clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa Jutul
mrstVerbose off
%% Setup Cealing CO2 plotting
saveplot = true;

gridcases = {'6tetRef2', '5tetRef2'};
deckcase = 'RS';
pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa'};

steps = 720;
xscaling = hour;

labels = gridcases;
plotTitle = 'CO2 in Cealing units';
ytxt = 'CO2 [kg]';
xtxt = 'time [h]';

%% Load simcases
gridcasecolors = {'#0072BD', "#77AC30", "#D95319", "#7E2F8E"};
pdiscstyles = {'-', '--', '-.', ':'};
simcases = {};
plotStyles = {};
numcases = numel(gridcases) * numel(pdiscs);
for igrid = 1:numel(gridcases)
    gridcase = gridcases{igrid};
    color = gridcasecolors{igrid};
    for idisc = 1:numel(pdiscs)
        pdisc = pdiscs{idisc};
        style = pdiscstyles{idisc};
        simcases{end+1} = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                       'pdisc', pdisc);
        plotStyles{end+1} = struct('Color', color, 'LineStyle', style);
    end
end
%%
xdata = cumsum(600*ones(720, 1))/xscaling;
data = nan(720, numel(simcases));
%% Load data
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    data(:,isim) = getCealingCO2(simcase, steps);
end
%% Plot
set(groot, 'defaultLineLineWidth', 2);
figure
hold on;
for i=1:numel(simcases)
    plot(xdata, data(:, i), 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle);
end
% Create dummy plots for legend
for igrid = 1:numel(gridcases)
    color = gridcasecolors{igrid};
    h_grid(igrid) = plot(NaN,NaN, 'Color', color, 'LineStyle', '-', 'LineWidth', 2); % No data, just style
end

for idisc = 1:numel(pdiscs)
    style = pdiscstyles{idisc};
    h_disc(idisc) = plot(NaN,NaN, 'Color', 'k', 'LineStyle', style, 'LineWidth', 2); % No data, just style
end

% Combine handles and labels
handles = [h_grid, h_disc];
gridcasesDisp = gridcases;
gridcasesDisp = cellfun(@displayNameGrid, gridcases, 'UniformOutput', false);
pdiscsDisp = cellfun(@shortDiscName, pdiscs, 'UniformOutput', false); 
labels = [gridcasesDisp, pdiscsDisp];

% Create the legend
lgd = legend(handles, labels, 'NumColumns', 2);
set(lgd, 'Interpreter', 'none');
hold off
title(plotTitle);
xlabel(xtxt);
ylabel(ytxt);
grid on;
if saveplot
    folder = 'plots/CealingCO2';
    filename = [strjoin(gridcases, '_'), '-', strjoin(pdiscsDisp, '_')];
    % exportgraphics(gcf, fullfile(folder, [filename, '.eps']))%for color
    saveas(gcf, fullfile(folder, [filename, '.png']))
end

