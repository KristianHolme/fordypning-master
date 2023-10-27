clear all;close all;
%% Plotting parameters
set(groot, 'defaultLineLineWidth', 2);

%% Cases to get data from
gridcases = {'5tetRef2', 'struct340x150', 'semi263x154_0.3'};
schedulecases = {''};
deckcases = {'RS'};
discmethods = {''};
tagcase = '';

steps = 40;
xscaling = hour;
popcell = 2;

datatypeShort = 'CTM';
labels = {'unstruct', 'struct', 'semi'};
% plotTitle = [datatypeShort, ' at PoP ', num2str(popcell), '. Grid: ', gridcases{1}];
plotTitle = datatypeShort;
ylabel = datatypeShort;
xlabel = 'time [h]';
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
%% Misc
dataTypesShort = {'CTM', 'Pressure', 'Density'};
dataTypesLong = {'FlowProps.ComponentTotalMass', 'pressure', 'PVTProps.Density'};
shortToLongDatatype = containers.Map(dataTypesShort, dataTypesLong);
datatype = shortToLongDatatype(datatypeShort);
xdata = cumsum(600*ones(720, 1))/xscaling;
data = nan(720, numel(simcases));
%% Load data pop
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    popcells = simcase.getPoPCells;
    data(:,isim) = simcase.getCellData(datatype, 'cellIx', popcells(popcell));
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

