clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa
mrstVerbose off
%% SPEcase
SPEcase = 'C';
if strcmp(SPEcase, 'A') 
    xscaling = hour; unit = 'h';
    steps = 720;
    totsteps = 720;
else 
    xscaling = SPEyear;unit='y';
    steps = 301;
    totsteps = 301;
end
resetData = false;
%% P5: Set Sealing-CO2
getData = @(simcase, steps)getSealingCO2(simcase, steps, 'resetData', resetData);
plotTitle='CO2 in sealing units';
ytxt = 'CO2 [kg]';
folder = './../plotsMaster/sealingCO2';
filetag = 'sealingCO2';
%% Set-Faultfluxes
getData = @(simcase, steps)getFaultFluxes(simcase, steps, 'resetData', resetData);
plotTitle='Fluxes over region bdrys (sum(abs(flux)))';
ytxt = 'sum(abs(Fluxes))';
folder = './../plotsMaster/faultfluxes';
filetag = 'faultflux';
steps = 206;
%% P6: Set Buffer CO2
getData = @(simcase, steps)getBufferCO2(simcase, steps, 'resetData', resetData);
plotTitle='CO2 in buffer volumes';
ytxt = 'CO2 [kg]';
folder = './../plotsMaster/bufferCO2';
filetag = 'bufferCO2';
%% PoP
popcell = 2;
getData = @(simcase, steps)getPoP(simcase, steps, popcell, 'resetData', resetData) ./barsa;
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
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
%% P2.2 immobile

plotTitle = 'P2.2 Immobile CO2';
folder = './../plotsMaster/composition/P2boxA';
submeasure = 2;
filetag = ['box', box, 'immob'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
%% P2.3 dissolved
plotTitle = 'P2.3 Dissolved CO2';
folder = './../plotsMaster/composition/P2boxA';
submeasure = 3;
filetag = ['box', box, 'diss'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
%% P2.4 seal
plotTitle = 'P2.4 Seal CO2';
folder = './../plotsMaster/composition/P2boxA';
submeasure = 4;
filetag = ['box', box, 'seal'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
%% P3 composition box B
box = 'B';
ytxt = 'CO2 [kg]';
%% P3.1 mobile
plotTitle = 'P3.1 Mobile CO2';
folder = './../plotsMaster/composition/P3boxB';
submeasure = 1;
filetag = ['box', box, 'mob'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
%% P3.2 immobile
plotTitle = 'P3.2 Immobile CO2';
folder = './../plotsMaster/composition/P3boxB';
submeasure = 2;
filetag = ['box', box, 'immob'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
%% P3.3 dissolved
plotTitle = 'P3.3 Dissolved CO2';
folder = './../plotsMaster/composition/P3boxB';
submeasure = 3;
filetag = ['box', box, 'diss'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
%% P3.4 seal
plotTitle = 'P3.4 Seal CO2';
folder = './../plotsMaster/composition/P3boxB';
submeasure = 4;
filetag = ['box', box, 'seal'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);

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
% gridcases = {'horz_ndg_cut_PG_130x62', 'horz_pre_cut_PG_130x62', 'cart_ndg_cut_PG_130x62', 'cart_pre_cut_PG_130x62'};
% gridcases = {'', 'struct130x62', 'horz_ndg_cut_PG_130x62', 'cart_ndg_cut_PG_130x62'};
% gridcases = {'horz_ndg_cut_PG_220x110', 'cart_ndg_cut_PG_220x110', 'cPEBI_220x110'};
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117'};
% gridcases = {'cPEBI_130x62', 'cPEBI_220x110', 'cPEBI_819x117'};
% gridcases = {'horz_ndg_cut_PG_130x62', 'horz_ndg_cut_PG_220x110', 'horz_ndg_cut_PG_819x117'};
% gridcases = {'cart_ndg_cut_PG_130x62', 'cart_ndg_cut_PG_220x110', 'cart_ndg_cut_PG_819x117', 'horz_ndg_cut_PG_130x62', 'horz_ndg_cut_PG_220x110', 'horz_ndg_cut_PG_819x117'};
% gridcases = {'horz_ndg_cut_PG_819x117', 'horz_ndg_cut_PG_819x117'};
% gridcases = {'', 'struct130x62', 'horz_ndg_cut_PG_130x62', 'cart_ndg_cut_PG_130x62'};
% gridcases = {'struct220x110', 'horz_ndg_cut_PG_220x110', 'cart_ndg_cut_PG_220x110', 'cPEBI_220x110'};
% gridcases = {'', '', ''};
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', '5tetRef0.31', 'gq_pb0.19'};
% gridcases = {'5tetRef0.31', '5tetRef0.31', 'struct819x117'};

%Master C
gridcases = {'cart_ndg_cut_PG_50x50x50'};

%grid vs res
% gridcases = {'struct', 'horz_ndg_cut_PG_', 'cart_ndg_cut_PG_'};
% ress = {'819x117', '1638x234', '2640x380'};
% gridlabels = {'C', 'HNCP', 'CNCP'};
% reslabels = {'100K', '400K', '1M'};
% ress = {''};


% pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa'};
% pdiscs = {'', 'cc', 'hybrid-avgmpfa'};
% pdiscs = {''};

deckcase = 'B_ISO_C';
tagcases = {''};
jutul = {false};

gridlabels = gridcases;
% labels = {'Triangles new', 'Triangles old', 'cartesian'};
% labels = {'Cartesian', 'Horizon-cut', 'Cartesian-cut', 'PEBI', 'Triangles'};
% labels = {'spe11-decks', '~pyopmspe11', 'correct(?)'};
% labels = {'MRST', 'Jutul'};
% plotTitle = 'CO2 in sealing units';
% ytxt = 'CO2 [kg]';
xtxt = ['Time [', unit, ']'];
saveplot = true;
plottitle = false;
insetPlot = false;

%% Load simcases
gridcasecolors = {'#0072BD', "#77AC30", "#D95319", "#7E2F8E", '#FFBD43',  '#02bef7', '#AC30C6',  '#19D9E6', '#ffff00'};
if ismember('cc', pdiscs)
    pdiscstyles = {'-', '-', '--', '-.', ':'};
    markers = {'none','|','none','none','none'};
else
    pdiscstyles = {'-', '--', '-.', ':'};
    markers = {'none','none','none','none'};
end
simcases = {};
plotStyles = {};
numcases = numel(gridcases) * numel(pdiscs);
if numel(tagcases) == 1
    tagcases = repmat(tagcases, 1, numel(gridcases));
end
if numel(jutul) == 1
    jutul = repmat(jutul, 1, numel(gridcases));
end
for igrid = 1:numel(gridcases)
    gridcase = gridcases{igrid};
    color = gridcasecolors{igrid};
    for idisc = 1:numel(pdiscs)
        pdisc = pdiscs{idisc};
        style = pdiscstyles{idisc};
        simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                       'pdisc', pdisc, 'tagcase', tagcases{igrid}, 'jutul', jutul{igrid});
        plotStyles{end+1} = struct('Color', color, 'LineStyle', style, 'Marker', markers{idisc});
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
figure('Position', [100,200, 800, 600], 'Name',plotTitle)
hold on;
for i=1:numel(simcases)
    plot(xdata, data(:, i), 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle, 'Marker', plotStyles{i}.Marker, 'MarkerSize',6, 'MarkerIndices',1:10:numel(xdata));
end
% Create dummy plots for legend
h_grid = [];
for igrid = 1:numel(gridcases)
    color = gridcasecolors{igrid};
    h_grid(igrid) = plot(NaN,NaN, 'Color', color, 'LineStyle', '-', 'LineWidth', 2); % No data, just style
end
h_disc = [];
for idisc = 1:numel(pdiscs)
    if numel(pdiscs) == 1
        break
    end
    style = pdiscstyles{idisc};
    marker = markers{idisc};
    h_disc(idisc) = plot(NaN,NaN, 'Color', 'k', 'LineStyle', style, 'LineWidth', 2, 'Marker',marker); % No data, just style
end

% Combine handles and labels
handles = [h_grid, h_disc];
gridcasesDisp = cellfun(@(gridcase) displayNameGrid(gridcase, SPEcase), gridlabels,  'UniformOutput', false);
pdiscsDisp = cellfun(@shortDiscName, pdiscs, 'UniformOutput', false); 
labels = [gridcasesDisp, pdiscsDisp];

% Create the legend
lgd = legend(handles, labels, 'NumColumns', 2);
set(lgd, 'Interpreter', 'none', 'Location', 'best');
hold off
if plottitle
    title(plotTitle);
end
fontsize(16, 'points'); 
xlabel(xtxt);
ylabel(ytxt);
grid on;

if insetPlot
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

if saveplot
    % folder = './../plotsMaster/sealingCO2';
    filename = [SPEcase, '_', filetag,'_', strjoin(gridcases, '_'), '-', strjoin(pdiscsDisp, '_')];
    exportgraphics(gcf, fullfile(folder, [filename, '.pdf']))%for color
    saveas(gcf, fullfile(folder, [filename, '.png']))
end
%% Load simcases grid RES
gridcasecolors = {'#0072BD', "#77AC30", "#D95319", "#7E2F8E", '#FFBD43',  '#02bef7', '#AC30C6',  '#19D9E6', '#ffff00'};
if ismember('cc', pdiscs)
    pdiscstyles = {'-', '-', '--', '-.', ':'};
    markers = {'none','|','none','none','none'};
else
    pdiscstyles = {'-', '--', '-.', ':'};
    markers = {'none','none','none','none'};
end
simcases = {};
plotStyles = {};
numcases = numel(gridcases) * numel(pdiscs);
if numel(tagcases) == 1
    tagcases = repmat(tagcases, 1, numel(gridcases));
end
if numel(jutul) == 1
    jutul = repmat(jutul, 1, numel(gridcases));
end
pdisc = pdiscs{1};
for igrid = 1:numel(gridcases)
    color = gridcasecolors{igrid};
    for ires = 1:numel(ress)
        res = ress{ires};
        style = pdiscstyles{ires};
        gridcase = [gridcases{igrid}, res];
        simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                       'pdisc', pdisc, 'tagcase', tagcases{igrid}, 'jutul', jutul{igrid});
        plotStyles{end+1} = struct('Color', color, 'LineStyle', style, 'Marker', markers{ires});
    end
end

%% Load data grid RES
xdata = cumsum(simcases{1}.schedule.step.val)/xscaling;
xdata = xdata(1:steps);
data = nan(steps, numel(simcases));
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    data(:,isim) = getData(simcase, steps);
end
%% Plot grid RES
set(groot, 'defaultLineLineWidth', 2);
figure('Position', [100,200, 800, 600], 'Name',plotTitle)
hold on;
for i=1:numel(simcases)
    plot(xdata, data(:, i), 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle, 'Marker', plotStyles{i}.Marker, 'MarkerSize',6, 'MarkerIndices',1:10:numel(xdata));
end
% Create dummy plots for legend
h_grid = [];
for igrid = 1:numel(gridcases)
    color = gridcasecolors{igrid};
    h_grid(igrid) = plot(NaN,NaN, 'Color', color, 'LineStyle', '-', 'LineWidth', 2); % No data, just style
end
h_res = [];
for ires = 1:numel(ress)
    if numel(ress) == 1
        break
    end
    style = pdiscstyles{ires};
    marker = markers{ires};
    h_res(ires) = plot(NaN,NaN, 'Color', 'k', 'LineStyle', style, 'LineWidth', 2, 'Marker',marker); % No data, just style
end

% Combine handles and labels
handles = [h_grid, h_res];
gridcasesDisp = cellfun(@(gridcase) displayNameGrid(gridcase, SPEcase), gridlabels,  'UniformOutput', false);
labels = [gridlabels, reslabels];

% Create the legend
lgd = legend(handles, labels, 'NumColumns', 2);
set(lgd, 'Interpreter', 'none', 'Location', 'best');
hold off
if plottitle
    title(plotTitle);
end
fontsize(16, 'points'); 
xlabel(xtxt);
ylabel(ytxt);
grid on;

if insetPlot
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

if saveplot
    % folder = './../plotsMaster/sealingCO2';
    filename = [SPEcase, '_', filetag,'_', strjoin(gridlabels, '_'), '-', strjoin(reslabels, '_')];
    exportgraphics(gcf, fullfile(folder, [filename, '.pdf']))%for color
    saveas(gcf, fullfile(folder, [filename, '.png']))
end