clear all;close all;
%% Plotting parameters
set(groot, 'defaultLineLineWidth', 2);

%% Cases to get data from
gridcases = {'tetRef2'};
schedulecases = {''};
deckcases = {'RS'};
discmethods = {'', 'hybrid-avgmpfa-oo'};
tagcase = '';

datatypeShort = 'CTM';
labels = {'TPFA', 'hybrid-avgMPFA'};
title = [datatypeShort, ' at PoP 1.', ' Grid: ', gridcases{1}];
ylabel = datatypeShort;
xlabel = 'time [h]';
% datatypes: PVTProps.Density, Pressure, FlowProps.ComponentTotalMass, 

steps = 720;
xscaling = hour;
%% Load simcases


simcases = {};
for ideck = 1:numel(deckcases)
    deckcase = deckcases{ideck};
    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        for ischedule = 1:numel(schedulecases)
            schedulecase = schedulecases{ischedule};
            for idisc = 1:numel(discmethods)
                discmethod = discmethods{idisc};
                simcases{end+1} = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                'schedulecase', schedulecase, 'tagcase', tagcase, ...
                                'discmethod', discmethod);
            end
        end
    end
end
%% Load data
dataTypesShort = {'CTM', 'Pressure', 'Density'};
dataTypesLong = {'FlowProps.ComponentTotalMass', 'Pressure', 'PVTProps.Density'};
shortToLongDatatype = containers.Map(dataTypesShort, dataTypesLong);
datatype = shortToLongDatatype(datatypeShort);

xdata = cumsum(600*ones(720, 1))/xscaling;
data = nan(720, numel(simcases));
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    popcells = simcase.getPoPCells;
    data(:,isim) = simcase.getCellData(datatype, popcells(1));
end

%% Plot
xdataTruncated = xdata(1:steps,:);
dataTruncated = data(1:steps, :);
plotData(labels, dataTruncated, 'title', title, 'xlabel', xlabel, 'ylabel', ylabel, ...
    'xdata', xdataTruncated);

