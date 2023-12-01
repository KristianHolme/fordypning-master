clear all;close all;
%% Plotting parameters
set(groot, 'defaultLineLineWidth', 2);

%% Cases to get data from
SPEcase = 'B';
gridcases = {'semi263x154_0.3'};
schedulecases = {''};
deckcases = {'RS'};
pdiscs = {'hybrid-mpfa'};
tagcase = '';

steps = 60;
maxsteps = 360;
xscaling = year;
popcell = 2;

datatypeShort = 'CTM';
labels = gridcases;
% plotTitle = [datatypeShort, ' at PoP ', num2str(popcell), '. Grid: ', gridcases{1}];
plotTitle = datatypeShort;
ylabel = datatypeShort;
xlabel = 'time [y]';
%% Load simcases
simcases = {};
for ideck = 1:numel(deckcases)
    deckcase = deckcases{ideck};
    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        for ischedule = 1:numel(schedulecases)
            schedulecase = schedulecases{ischedule};
            for idisc = 1:numel(pdiscs)
                pdisc = pdiscs{idisc};
                simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                'schedulecase', schedulecase, 'tagcase', tagcase, ...
                                'pdisc', pdisc);
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
xdata = timesteps/xscaling;
data = nan(maxsteps, numel(simcases));
%% Load data Cealing CO2
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    popcells = simcase.getPoPCells;
    data(:,isim) = simcase.getCellData(datatype, 'cellIx', popcells(popcell));
end

%% Load data pop
popcell  = 1;
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

