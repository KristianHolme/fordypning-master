clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa
mrstVerbose off
%%
SPEcase = 'B';
if strcmp(SPEcase, 'A') 
    xscaling = hour; unit = 'h';
    steps = 720;
    totsteps = 720;
else 
    xscaling = SPEyear;unit='y';
    steps = 4;
    totsteps = 4;
end
%% Type of plot
%CO2
getData = @(simcase, steps)getSealingCO2(simcase, steps);
plotTitle='CO2 in sealing units';
ytxt = 'CO2 [kg]';
folder = './../plotsMaster/sealingCO2';
%%
% faultfluxes
getData = @(simcase, steps)getFaultFluxes(simcase, steps);
plotTitle='Fluxes over region bdrys';
ytxt = 'sum(abs(Fluxes))';
folder = './../plotsMaster/faultfluxes';

%% Setup Sealing CO2 plotting
% A
% gridcases = {'6tetRef1', '5tetRef1'}; %RAPPORT 
% gridcases = {'5tetRef1', '5tetRef2', '5tetRef3'}; %RAPPORT
% gridcases = {'semi263x154_0.3','semi203x72_0.3','semi188x38_0.3'};%RAPPORT
% gridcases = {'5tetRef1', 'semi263x154_0.3', 'struct340x150'}; %RAPPORT
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa'};

% B
% gridcases = {'5tetRef2'};
% gridcases = {'6tetRef0.4', '5tetRef0.4', '5tetRef1-stretch'}; %RAPPORT
% gridcases = {'5tetRef0.4', 'semi263x154_0.3', 'struct420x141'};%RAPPORT
% gridcases = {'5tetRef0.4', '5tetRef0.8', '5tetRef2'}; %RAPPORT
% gridcases = {'semi188x38_0.3','semi203x72_0.3','semi263x154_0.3'}; %RAPPORT
% gridcases = {'6tetRef0.4', '5tetRef0.4', '5tetRef1-stretch', 'semi263x154_0.3','semi203x72_0.3',...
%     'semi188x38_0.3','5tetRef0.4', '5tetRef0.8', '5tetRef2', 'struct420x141'};
% gridcases = {'struct420x141'};

%Master B
gridcases = {'', 'struct130x62', 'horz_pre_cut_PG_130x62', 'cart_pre_cut_PG_130x62'};
gridcases = {'horz_pre_cut_130x62', 'cart_pre_cut_130x62'};
pdiscs = {''};



deckcase = 'B_ISO_SMALL';
tagcase = 'upscale';

labels = gridcases;
% plotTitle = 'CO2 in sealing units';
% ytxt = 'CO2 [kg]';
xtxt = ['time [', unit, ']'];
saveplot = false;

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
        simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                       'pdisc', pdisc, 'tagcase', tagcase);
        plotStyles{end+1} = struct('Color', color, 'LineStyle', style);
    end
end
%%

xdata = cumsum(simcases{1}.schedule.step.val)/xscaling;
data = nan(totsteps, numel(simcases));
%% Load data
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    data(:,isim) = getData(simcase, steps);
end
%% Plot
set(groot, 'defaultLineLineWidth', 2);
figure('Position', [100,100, 800, 600])
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
gridcasesDisp = cellfun(@(gridcase) displayNameGrid(gridcase, SPEcase), gridcases,  'UniformOutput', false);
pdiscsDisp = cellfun(@shortDiscName, pdiscs, 'UniformOutput', false); 
labels = [gridcasesDisp, pdiscsDisp];

% Create the legend
lgd = legend(handles, labels, 'NumColumns', 2);
set(lgd, 'Interpreter', 'none', 'Location', 'northwest');
hold off
title(plotTitle);
fontsize(14, 'points'); 
xlabel(xtxt);
ylabel(ytxt);
grid on;

if saveplot
    % folder = './../plotsMaster/sealingCO2';
    filename = [SPEcase, '_', strjoin(gridcases, '_'), '-', strjoin(pdiscsDisp, '_')];
    exportgraphics(gcf, fullfile(folder, [filename, '.pdf']))%for color
    saveas(gcf, fullfile(folder, [filename, '.png']))
end

