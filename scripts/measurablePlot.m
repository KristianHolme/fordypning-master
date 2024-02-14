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
    steps = 31;
    totsteps = 31;
end
%% P5: Set Sealing-CO2
getData = @(simcase, steps)getSealingCO2(simcase, steps);
plotTitle='CO2 in sealing units';
ytxt = 'CO2 [kg]';
folder = './../plotsMaster/sealingCO2';
filetag = 'sealingCO2';
%% Set-Faultfluxes
getData = @(simcase, steps)getFaultFluxes(simcase, steps);
plotTitle='Fluxes over region bdrys (sum(abs(flux)))';
ytxt = 'sum(abs(Fluxes))';
folder = './../plotsMaster/faultfluxes';
filetag = 'faultflux';
steps = 22;
%% P6: Set Buffer CO2
getData = @(simcase, steps)getBufferCO2(simcase, steps);
plotTitle='CO2 in buffer volumes';
ytxt = 'CO2 [kg]';
folder = './../plotsMaster/bufferCO2';
filetag = 'bufferCO2';
%% PoP
popcell = 2;
getData = @(simcase, steps)getPoP(simcase, steps, popcell) ./barsa;
plotTitle = sprintf('Pressure at PoP %d', popcell);
ytxt = 'Pressure [bar]';
folder = './../plotsMaster/PoP';
filetag = sprintf('pop%d', popcell);
%% P2 composition box A
box = 'A';
ytxt = 'CO2 [kg]';
%% P2.1 mobile
plotTitle = 'P2.1 Mobile CO2';
folder = './../plotsMaster/composition/P2boxA';
submeasure = 1;
filetag = ['box', box, 'mob'];
%% P2.2 immobile
plotTitle = 'P2.2 Immobile Co2';
folder = './../plotsMaster/composition/P2boxA';
submeasure = 2;
filetag = ['box', box, 'immob'];
%% P2.3 dissolved
plotTitle = 'P2.3 Dissolved CO2';
folder = './../plotsMaster/composition/P2boxA';
submeasure = 3;
filetag = ['box', box, 'diss'];
%% P2.4 seal
plotTitle = 'P2.4 Seal CO2';
folder = './../plotsMaster/composition/P2boxA';
submeasure = 4;
filetag = ['box', box, 'seal'];
%% P3 composition box B
box = 'B';
ytxt = 'CO2 [kg]';
%% P3.1 mobile
plotTitle = 'P3.1 Mobile CO2';
folder = './../plotsMaster/composition/P3boxB';
submeasure = 1;
filetag = ['box', box, 'mob'];
%% P3.2 immobile
plotTitle = 'P3.2 Immobile CO2';
folder = './../plotsMaster/composition/P3boxB';
submeasure = 2;
filetag = ['box', box, 'immob'];
%% P3.3 dissolved
plotTitle = 'P3.3 Dissolved CO2';
folder = './../plotsMaster/composition/P3boxB';
submeasure = 3;
filetag = ['box', box, 'diss'];
%% P3.4 seal
plotTitle = 'P3.4 Seal CO2';
folder = './../plotsMaster/composition/P3boxB';
submeasure = 4;
filetag = ['box', box, 'seal'];
%% P2-3 get data
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box);
%% SETUP
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
gridcases = {'horz_ndg_cut_PG_130x62', 'horz_pre_cut_PG_130x62', 'cart_ndg_cut_PG_130x62', 'cart_pre_cut_PG_130x62'};
% gridcases = {'horz_pre_cut_PG_130x62', 'cart_pre_cut_PG_130x62'};
pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa'};



deckcase = 'B_ISO_SMALL';
tagcase = '';

labels = gridcases;
% plotTitle = 'CO2 in sealing units';
% ytxt = 'CO2 [kg]';
xtxt = ['time [', unit, ']'];
saveplot = true;

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

%% Load data
xdata = cumsum(simcases{1}.schedule.step.val)/xscaling;
xdata = xdata(1:steps);
data = nan(steps, numel(simcases));
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
set(lgd, 'Interpreter', 'none', 'Location', 'best');
hold off
title(plotTitle);
fontsize(14, 'points'); 
xlabel(xtxt);
ylabel(ytxt);
grid on;

if saveplot
    % folder = './../plotsMaster/sealingCO2';
    filename = [SPEcase, '_', filetag,'_', strjoin(gridcases, '_'), '-', strjoin(pdiscsDisp, '_')];
    exportgraphics(gcf, fullfile(folder, [filename, '.pdf']))%for color
    saveas(gcf, fullfile(folder, [filename, '.png']))
end

