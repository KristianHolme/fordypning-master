clear all
close all
mrstVerbose off
%% SPEcase
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
resetData = false;

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
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', 'gq_pb0.19', '5tetRef0.31'};
% gridcases = {'5tetRef0.31', '5tetRef0.31', 'struct819x117'};
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117'};
% gridcases = {'cPEBI_819x117', 'cPEBI_812x118'};
gridcases = {'cart_ndg_cut_PG_819x117'};

%Master C
% gridcases = {'struct50x50x50', 'horz_ndg_cut_PG_50x50x50', 'cart_ndg_cut_PG_50x50x50'};
% gridcases = {'struct100x100x100', 'horz_ndg_cut_PG_100x100x100', 'cart_ndg_cut_PG_100x100x100'};
% gridcases = {'horz_ndg_cut_PG_50x50x50', 'horz_ndg_cut_PG_50x50x50'};
% gridcases = {'struct50x50x50', 'struct50x50x50'};


% Copmare with thermal
% gridcases = {'struct50x50x50', 'horz_ndg_cut_PG_50x50x50', 'cart_ndg_cut_PG_50x50x50'};
% gridcases = {'struct50x50x50', 'struct50x50x50'};


%grid vs res
% gridcases = {'struct', 'horz_ndg_cut_PG_', 'cart_ndg_cut_PG_', 'cPEBI_'};
% gridcases = {'struct', 'horz_ndg_cut_PG_', 'cart_ndg_cut_PG_'};
% ress = {'819x117', '1638x234', '2640x380'};
% ress = {'50x50x50', '100x100x100'};
% gridlabels = {'C', 'HNCP', 'CNCP', 'cPEBI'};
% gridlabels = {'C', 'HNCP', 'CNCP'};
% reslabels = {'F', 'F2', 'F3'};
% reslabels = {'50', '100'};
% ress = {''};


pdiscs = {'', 'hybrid-avgmpfa', 'indicator20-hybrid-avgmpfa', 'hybrid-ntpfa', 'indicator20-hybrid-ntpfa'};
% pdiscs = {'', 'cc', 'p', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
% pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa',};
% pdiscs = {''};
% pdiscs = {'', 'hybrid-avgmpfa', 'indicator-hybrid-avgmpfa', 'hybrid-ntpfa', 'indicator-hybrid-ntpfa'};

uwdiscs = {''};
deckcase = 'B_ISO_C';
% tagcases = {'gdz-shift', 'gdz-shift-big'};
tagcases = {''};
% tagcases = {''};
jutul = {false};

batchname = 'indicator20-CNCP-F';
folder = fullfile('./../plots', gridcases{1}, batchname);
gridlabels = gridcases; %DEFAULT
% labels = {'Triangles new', 'Triangles old', 'cartesian'};
% labels = {'Cartesian', 'Horizon-cut', 'Cartesian-cut', 'PEBI', 'Triangles'};
% gridlabels = {'Kartesisk', 'Horisont-kutt', 'Kartesisk-kutt', 'PEBI', 'Firkant/trekant'};
% labels = {'spe11-decks', '~pyopmspe11', 'correct(?)'};
% labels = {'MRST', 'Jutul'};
% plotTitle = 'CO2 in sealing units';
% ytxt = 'CO2 [kg]';
xtxt = ['Time [', unit, ']'];
saveplot = true;
plottitle = false;
insetPlot = false;
plotbars = false;
legendpos = 'best';

%% Load simcases
gridcasecolors = {'#0072BD', "#77AC30", "#D95319", "#7E2F8E", '#FFBD43',  '#02bef7', '#AC30C6',  '#19D9E6', '#ffff00'};
if ismember('cc', pdiscs)
    if ismember('p', pdiscs)
        discstyles = {'-', '-', '-', '--', '-.', ':'};
        markers = {'none','|','x', 'none','none','none'};
    else
        discstyles = {'-', '-', '--', '-.', ':'};
        markers = {'none','|', 'none','none','none'};
    end
elseif any(contains(pdiscs, '-hybrid'))
    discstyles = {'-', '--', '--', '-.', '-.', ':', ':'};
    markers = {'none','none','x','none', 'x', 'none', '|'};
else
    discstyles = {'-', '--', '-.', ':'};
    markers = {'none','none','none','none'};
end
simcases = {};
plotStyles = {};
numcases = numel(gridcases) * numel(pdiscs);
if isscalar(tagcases)
    tagcases = repmat(tagcases, 1, numel(gridcases));
end
if isscalar(jutul)
    jutul = repmat(jutul, 1, numel(gridcases));
end
for igrid = 1:numel(gridcases)
    gridcase = gridcases{igrid};
    color = gridcasecolors{igrid};
    for idisc = 1:numel(pdiscs)
        pdisc = pdiscs{idisc};
        style = discstyles{idisc};
        simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                       'pdisc', pdisc, 'tagcase', tagcases{igrid}, 'jutul', jutul{igrid});
        plotStyles{end+1} = struct('Color', color, 'LineStyle', style, 'Marker', markers{idisc});
    end
end
discs = pdiscs;

%% Load simcases uwdisc
if ismember('cc', pdiscs)
    if ismember('p', pdiscs)
        discstyles = {'-', '-', '-', '--', '-.', ':'};
        markers = {'none','|','x', 'none','none','none'};
    else
        discstyles = {'-', '-', '--', '-.', ':'};
        markers = {'none','|', 'none','none','none'};
    end
else
    discstyles = {'-', '--', '-.', ':'};
    markers = {'none','none','none','none'};
end
simcases = {};
plotStyles = {};
numcases = numel(gridcases) * numel(uwdiscs);
if isscalar(tagcases)
    tagcases = repmat(tagcases, 1, numel(uwdiscs));
end
if isscalar(jutul)
    jutul = repmat(jutul, 1, numel(gridcases));
end
for igrid = 1:numel(gridcases)
    gridcase = gridcases{igrid};
    color = gridcasecolors{igrid};
    for idisc = 1:numel(uwdiscs)
        uwdisc = uwdiscs{idisc};
        style = discstyles{idisc};
        simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                       'uwdisc', uwdisc, 'tagcase', tagcases{igrid}, 'jutul', jutul{igrid});
        plotStyles{end+1} = struct('Color', color, 'LineStyle', style, 'Marker', markers{idisc});
    end
end
discs = uwdiscs;

%% Loading and plotting
initFuncs = {@(rd)initSealingPlot(rd), @(rd)initBufferPlot(rd), @(rd)initPoPPlot(1, rd), @(rd)initPoPPlot(2, rd),...
    @(rd)initP21Plot(rd), @(rd)initP22Plot(rd), @(rd)initP23Plot(rd), @(rd)initP24Plot(rd),...
    @(rd)initP31Plot(rd), @(rd)initP32Plot(rd), @(rd)initP33Plot(rd), @(rd)initP34Plot(rd)};
for ifunc =1:numel(initFuncs)
    func = initFuncs{ifunc};
    [getData, plotTitle, ytxt, ~, filetag] = func(resetData);
    xdata = cumsum(simcases{1}.schedule.step.val)/xscaling;
    xdata = xdata(1:steps);
    data = nan(steps, numel(simcases));
    disp(['Loading data for ', plotTitle]);
    for isim = 1:numel(simcases)
        simcase = simcases{isim};
        data(:,isim) = getData(simcase, steps);
        % fprintf('%s tot co2: %.3e\n', simcase.casename, sum(simcase.getSimData{250}.FlowProps.ComponentTotalMass{2}))
    end
    disp("Loading done.");
    measurablePlot(data, xdata, {gridcasecolors, discstyles, markers, plotStyles}, discs, ...
        'plotTitle', plotTitle, 'folder', folder, 'plotbars', plotbars, ...
        'ytxt', ytxt, 'filetag', filetag, 'numGrids', numel(gridcases), ...
        'xtxt', xtxt, 'SPEcase', SPEcase, 'gridcases', gridcases);
end
%% Plot

% pause(0.3)
% close all
%% Load simcases grid RES
gridcasecolors = {'#0072BD', "#77AC30", "#D95319", "#7E2F8E", '#FFBD43',  '#02bef7', '#AC30C6',  '#19D9E6', '#ffff00'};
if ismember('cc', pdiscs)
    discstyles = {'-', '-', '--', '-.', ':'};
    markers = {'none','|','none','none','none'};
else
    discstyles = {'-', '--', '-.', ':'};
    markers = {'none','none','none','none'};
end
simcases = {};
plotStyles = {};
numcases = numel(gridcases) * numel(pdiscs);
if numel(tagcases) == 1
    tagcases = repmat(tagcases, 1, numel(gridcases));
end
if numel(jutul) == 1
    jutul = repmat(jutul, 1, numel(ress));
end
pdisc = pdiscs{1};
for igrid = 1:numel(gridcases)
    color = gridcasecolors{igrid};
    for ires = 1:numel(ress)
        res = ress{ires};
        style = discstyles{ires};
        gridcase = [gridcases{igrid}, res];
        simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                       'pdisc', pdisc, 'tagcase', tagcases{igrid}, 'jutul', jutul{ires});
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
f1 = figure('Position', [100,200, 800, 600], 'Name',plotTitle)
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
    plot(xdata, figdata(:, i), 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle, 'Marker', plotStyles{i}.Marker, 'MarkerSize',6, 'MarkerIndices',1:10:numel(xdata));
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
    style = discstyles{ires};
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
ylabel(figytxt);
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
tightfig();
if plotbars
    f2 = plotbar3(data, gridlabels, reslabels, gridcasecolors, plotTitle, ytxt);
    tightfig();
end
if saveplot
    disp('saving...')
    % folder = './../plots/sealingCO2';
    filename = [SPEcase, '_', filetag,'_', strjoin(gridlabels, '_'), '-', strjoin(reslabels, '_')];
    % exportgraphics(gcf, fullfile(folder, [filename, '.svg']))%for color
    saveas(f1, fullfile(folder, [filename, '.png']));
    saveas(f1, fullfile(folder, filename), 'epsc');
     if plotbars
        filename = [SPEcase, '_', filetag,'_', strjoin(gridlabels, '_'), '-', strjoin(reslabels, '_'), '_bar3'];
        set(f2, 'Renderer', 'painters');
        saveas(f2, fullfile(folder, 'bars', [filename, '.png']));
        saveas(f2, fullfile(folder, 'bars', [filename,'.pdf']), 'pdf');
    end
end
%% Load simcases compThermal
gridcasecolors = {'#0072BD', "#77AC30", "#D95319", "#7E2F8E", '#FFBD43',  '#02bef7', '#AC30C6',  '#19D9E6', '#ffff00'};
discstyles = {'-', '--'};
simcases = {};
plotStyles = {};
numcases = numel(gridcases) * 2;
if isscalar(jutul)
    jutul = repmat(jutul, 1, numel(gridcases));
end
for igrid = 1:numel(gridcases)
    gridcase = gridcases{igrid};
    color = gridcasecolors{igrid};
    style = discstyles{1};
    simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, 'jutul', jutul{igrid});
    plotStyles{end+1} = struct('Color', color, 'LineStyle', style, 'Marker','none');

    style = discstyles{2};
    simcases{end+1} = Simcase('SPEcase', SPEcase,'gridcase', gridcase, 'jutul', jutul{igrid}, 'jutulThermal', true, 'tagcase', 'allcells');
    plotStyles{end+1} = struct('Color', color, 'LineStyle', style, 'Marker','none');
end
%% Load data compThermal

xdata = cumsum(simcases{1}.schedule.step.val)/xscaling;
xdata = xdata(1:steps);
xdata_thermal = cumsum(load('/media/kristian/HDD/Jutul/output/csp11/thermal_dt.mat').dt)/xscaling;
xdatasets = {xdata, xdata_thermal};
data = nan(steps, numel(simcases));
twosteps = [301, 210];
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    step = twosteps(2-mod(isim, 2));
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
    step = twosteps(2-mod(i, 2));
    x = xdatasets{2-mod(i, 2)};
    y = figdata(1:step, i);
    if mod(i, 2)==0
        x = x(10:end);
        y = y(10:210);
    end
    plot(x, y, 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle);
end
% Create dummy plots for legend
h_grid = [];
for igrid = 1:numel(gridcases)
    color = gridcasecolors{igrid};
    h_grid(igrid) = plot(NaN,NaN, 'Color', color, 'LineStyle', '-', 'LineWidth', 2); % No data, just style
end
h_disc = [];
for isim = 1:2
    style = discstyles{isim};
    h_disc(isim) = plot(NaN,NaN, 'Color', 'k', 'LineStyle', style, 'LineWidth', 2); % No data, just style
end

% Combine handles and labels
handles = [h_grid, h_disc];
gridcasesDisp = cellfun(@(gridcase) displayNameGrid(gridcase, SPEcase), gridlabels,  'UniformOutput', false);
simlabels = {'Black-oil', 'Compositional'}; 
labels = [gridcasesDisp, simlabels];

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
tightfig()
if saveplot
    % folder = './../plots/sealingCO2';
    filename = [SPEcase, '_', filetag,'_', strjoin(gridcases, '_'), '-', strjoin(simlabels, '_')];
    % saveas(gcf, fullfile(folder, [filename, '.svg']))%for color
    % print(fullfile(folder, [filename, '.pdf']), '-dpdf')
    saveas(gcf, fullfile(folder, [filename, '.png']))
    saveas(gcf, fullfile(folder, [filename,'.eps']), 'epsc');
end
% pause(0.5)
% close gcf

%% Plot reports
names = cellfun(@(name) shortDiscName(name), pdiscs, UniformOutput=false);
reports = cell(numel(simcases), 1);
for isim = 1:numel(simcases)
    [~, ~, rep] = simcases{isim}.getSimData;
    reports{isim} = rep;
end
savefolder = fullfile('./../plots/performance');
reportStats(reports, names, 'savefolder', savefolder, 'batchname', batchname)



%% P5: Set Sealing-CO2
function [getData, plotTitle, ytxt, folder, filetag] = initSealingPlot(resetData)
getData = @(simcase, steps)getSealingCO2(simcase, steps, 'resetData', resetData);
plotTitle='CO2 in sealing units';
ytxt = 'CO2 [kg]';
folder = './../plots/sealingCO2';
filetag = 'sealingCO2';
end
%% Set-Faultfluxes
function [getData, plotTitle, ytxt, folder, filetag] = initFaultFluxPlot(resetData)
getData = @(simcase, steps)getFaultFluxes(simcase, steps, 'resetData', resetData);
plotTitle='CO2 fluxes over region boundaries (sum(abs(flux)))';
ytxt = 'sum(abs(Fluxes))';
folder = './../plots/faultfluxes';
filetag = 'faultflux';
end
%% P6: Set Buffer CO2
function [getData, plotTitle, ytxt, folder, filetag] = initBufferPlot(resetData)
getData = @(simcase, steps)getBufferCO2(simcase, steps, 'resetData', resetData);
plotTitle='CO2 in buffer volumes';
ytxt = 'CO2 [kg]';
folder = './../plots/bufferCO2';
filetag = 'bufferCO2';
end
%% PoP
function [getData, plotTitle, ytxt, folder, filetag] = initPoPPlot(popcell, resetData)
getData = @(simcase, steps)getPoP(simcase, steps, popcell, 'resetData', resetData) ./barsa;
plotTitle = sprintf('Pressure at PoP %d', popcell);
ytxt = 'Pressure [bar]';
folder = './../plots/PoP';
filetag = sprintf('pop%d', popcell);
end
%% P2 composition box A

%% P2.1 mobile
function [getData, plotTitle, ytxt, folder, filetag] = initP21Plot(resetData)
box = 'A';
ytxt = 'CO2 [kg]';
plotTitle = 'P2.1 Mobile CO2';
folder = './../plots/composition/P2boxA';
submeasure = 1;
filetag = ['box', box, 'mob'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end
%% P2.2 immobile
function [getData, plotTitle, ytxt, folder, filetag] = initP22Plot(resetData)
box = 'A';
ytxt = 'CO2 [kg]';
plotTitle = 'P2.2 Immobile CO2';
folder = './../plots/composition/P2boxA';
submeasure = 2;
filetag = ['box', box, 'immob'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end
%% P2.3 dissolved
function [getData, plotTitle, ytxt, folder, filetag] = initP23Plot(resetData)
box = 'A';
ytxt = 'CO2 [kg]';
plotTitle = 'P2.3 Dissolved CO2';
folder = './../plots/composition/P2boxA';
submeasure = 3;
filetag = ['box', box, 'diss'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end
%% P2.4 seal
function [getData, plotTitle, ytxt, folder, filetag] = initP24Plot(resetData)
box = 'A';
ytxt = 'CO2 [kg]';
plotTitle = 'P2.4 Seal CO2';
folder = './../plots/composition/P2boxA';
submeasure = 4;
filetag = ['box', box, 'seal'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end
%% P3 composition box B

%% P3.1 mobile
function [getData, plotTitle, ytxt, folder, filetag] = initP31Plot(resetData)
box = 'B';
ytxt = 'CO2 [kg]';
plotTitle = 'P3.1 Mobile CO2';
folder = './../plots/composition/P3boxB';
submeasure = 1;
filetag = ['box', box, 'mob'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end
%% P3.2 immobile
function [getData, plotTitle, ytxt, folder, filetag] = initP32Plot(resetData)
box = 'B';
ytxt = 'CO2 [kg]';
plotTitle = 'P3.2 Immobile CO2';
folder = './../plots/composition/P3boxB';
submeasure = 2;
filetag = ['box', box, 'immob'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end
%% P3.3 dissolved
function [getData, plotTitle, ytxt, folder, filetag] = initP33Plot(resetData)
box = 'B';
ytxt = 'CO2 [kg]';
plotTitle = 'P3.3 Dissolved CO2';
folder = './../plots/composition/P3boxB';
submeasure = 3;
filetag = ['box', box, 'diss'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end
%% P3.4 seal
function [getData, plotTitle, ytxt, folder, filetag] = initP34Plot(resetData)
box = 'B';
ytxt = 'CO2 [kg]';
plotTitle = 'P3.4 Seal CO2';
folder = './../plots/composition/P3boxB';
submeasure = 4;
filetag = ['box', box, 'seal'];
getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end
