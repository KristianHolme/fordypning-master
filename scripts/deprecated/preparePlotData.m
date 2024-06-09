clear all;close all;
%% Plotting parameters
set(groot, 'defaultLineLineWidth', 2);
%%
SPEcase = 'B';
if strcmp(SPEcase, 'A') 
    xscaling = hour; unit = 'h';
    steps = 40;
    maxsteps = 720;
else 
    xscaling = speyear;unit='y';
    % steps = 60;
    % totsteps = 360;
    totsteps = 4;
    steps = 4;
end
%% Cases to get data from
gridcases = {'5tetRef1', 'semi263x154_0.3', 'struct340x150'};
gridcases = {'5tetRef1', '5tetRef2', '5tetRef3'};

schedulecases = {''};
deckcases = {'B_ISO_SMALL'};
pdiscs = {''};
tagcase = '';


popcell = 2;

datatypeShort = 'Pressure';
labels = gridcases;
% plotTitle = [datatypeShort, ' at PoP ', num2str(popcell), '. Grid: ', gridcases{1}];
plotTitle = [datatypeShort, ' at PoP ' num2str(popcell)];
ytxt = 'Pressure [bar]';
xtxt = ['time [', unit, ']'];
%% Load simcases
gridcasecolors = {'#0072BD', "#77AC30", "#D95319", "#7E2F8E"};
pdiscstyles = {'-', '--', '-.', ':'};
simcases = {};
plotStyles = {};
numcases = numel(gridcases) * numel(pdiscs);
for ideck = 1:numel(deckcases)
    deckcase = deckcases{ideck};
    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        color = gridcasecolors{igrid};
        for ischedule = 1:numel(schedulecases)
            schedulecase = schedulecases{ischedule};
            for idisc = 1:numel(pdiscs)
                pdisc = pdiscs{idisc};
                style = pdiscstyles{idisc};
                simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                'schedulecase', schedulecase, 'tagcase', tagcase, ...
                                'pdisc', pdisc);
                plotStyles{end+1} = struct('Color', color, 'LineStyle', style);
            end
        end
    end
end
%% Misc
dataTypesShort = {'CTM', 'Pressure', 'Density'};
dataTypesLong = {'FlowProps.ComponentTotalMass', 'pressure', 'PVTProps.Density'};
shortToLongDatatype = containers.Map(dataTypesShort, dataTypesLong);
datatype = shortToLongDatatype(datatypeShort);
%%
timesteps = cumsum(simcases{1}.schedule.step.val);
timesteps = timesteps(1:steps);
xdata = timesteps/xscaling;
data = nan(steps, numel(simcases));
%% Load data Cealing CO2
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    popcells = simcase.getPoPCells;
    data(:,isim) = simcase.getCellData(datatype, 'cellIx', popcells(popcell));
end

%% Load data pop
popcell  = 1;
for isim = 1:numel(simcases)
    disp(['Dataset ', num2str(isim) ' of ' , num2str(numel(simcases))]);  
    simcase = simcases{isim};
    % popcells = simcase.getPoPCells;
    data(:,isim) = getPoP(simcase, steps, popcell) ./barsa;
end

%% Load data totalmass
for isim = 1:numel(simcases)
                  
    simcase = simcases{isim};
    data(:,isim) = simcase.getCellData(datatype);
end


%% Plot
xdataTruncated = xdata(1:steps,:);
dataTruncated = data(1:steps, :);
plotData(labels, dataTruncated, 'title', plotTitle, 'xlabel', xlabel, 'ylabel', ylabel, ...
    'xdata', xdataTruncated);

%%
saveplot = false;
%% Plot NEW FOR POP
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
set(lgd, 'Interpreter', 'none', 'Location', 'northeast');
hold off
title(plotTitle);
fontsize(14, 'points'); 
xlabel(xtxt);
ylabel(ytxt);
grid on;

if saveplot
    folder = fullfile('plots/PoP', SPEcase);
    filename = [SPEcase, '_', strjoin(gridcases, '_'), '-', strjoin(pdiscsDisp, '_')];
    exportgraphics(gcf, fullfile(folder, [filename, '.pdf']))%for color
    saveas(gcf, fullfile(folder, [filename, '.png']))
end


