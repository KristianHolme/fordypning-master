clear all;
close all;
%% Setup data
% getData = @(states,step, G) CellVelocity(states, step, G, 'g');cmap='jet';
getData = @(states, step, G) states{step}.rs; cmap='';
%% Setup grid v disc
SPEcase = 'A';

% gridcases = {'5tetRef2', 'semi203x72_0.3', 'struct193x83'}; filename = 'gridtypeComp';
gridcases = {'5tetRef1', '5tetRef2', '5tetRef3}; filename = 'UU_refine_disc';
% gridcases = {'6tetRef2', '5tetRef2'}; filename = 'meshAlgComparisonRef2';
% gridcases = {'5tetRef2', '5tetRef2-2D'}; filename = 'UUgriddimComp';
pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};


SPEcase = 'A';

% gridcases = {'5tetRef2', 'semi203x72_0.3', 'struct193x83'}; filename = 'gridtypeComp';
gridcases = {'5tetRef0.4', '5tetRef0.8', '5tetRef2'}; filename = 'UU_refine_disc';
% gridcases = {'6tetRef0.8', '5tetRef0.8'}; filename = 'meshAlgComparisonRef2';
% gridcases = {'5tetRef2', '5tetRef2-2D'}; filename = 'UUgriddimComp';
pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};


deckcase = 'RS';
tagcase = '';

if strcmp(SPEcase, 'A') 
    scaling = hour; unit = 'h';
else 
    scaling = year;unit='y';
end
saveplot = false;

filename = [SPEcase, '_', filename];
savefolder="plots\multiplot";

if strcmp(SPEcase, 'A')
    steps = [30, 144, 720];
else
    steps = [40, 150, 360];
end
numGrids = numel(gridcases);
numDiscs = numel(pdiscs);
%% Loading data grid vs pdisc
data = cell(numDiscs, numGrids, numel(steps));
for istep = 1:numel(steps)
    step = steps(istep);
    for i = 1:numDiscs
        pdisc = pdiscs{i};
        for j = 1:numGrids
            gridcase = gridcases{j};
            simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                'tagcase', tagcase, ...
                                'pdisc', pdisc);
            [states, ~, ~] = simcase.getSimData;
            G = simcase.G;
            if numelData(states) >= step
                statedata = getData(states,step, G);
                [inj1, inj2] = simcase.getinjcells;
                data{i, j, istep}.statedata = statedata;
                data{i, j, istep}.injcells = [inj1, inj2];
                data{i, j, istep}.G = G;
                if i == 1
                    data{i, j, istep}.title = displayNameGrid(gridcase);
                end
                if j == 1
                    data{i, j, istep}.ylabel = shortDiscName(pdisc);
                end
            end
        end
    end
end

%% Plotting grid vs disc
times = cumsum(simcase.schedule.step.val);
for istep = 1:numel(steps)
    step = steps(istep);
    plottitle = ['rs at t=', num2str(times(step)/scaling), unit];
    multiplot(data(:, :, istep), 'title', plottitle, 'savefolder', savefolder, ...
        'savename', [filename, '_step', num2str(step)], ...
        'saveplot', saveplot, 'cmap', cmap);   
end
%% Setup full error plot
SPEcase = 'A';
gridcase = 'semi203x72_0.3';
filename =[SPEcase, '_diff_', gridcase];
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};
pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa'};
deckcase = 'RS';
tagcase = '';


saveplot = true;
savefolder = 'plots\differenceplots';
steps = [30, 144, 720];
numDiscs = numel(pdiscs);
%% Load data diff
data = cell(numDiscs, numDiscs, numel(steps));
for istep = 1:numel(steps)
    step = steps(istep);
    for i = 1:numDiscs
        for j = i:numDiscs
            pdisc = pdiscs{j};
            simcase = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                'tagcase', tagcase, ...
                                'pdisc', pdisc);
            [states, ~, ~] = simcase.getSimData;
            G = simcase.G;
            if numelData(states) >= step
                statedata = states{step}.rs;
                [inj1, inj2] = simcase.getinjcells;
                data{i, j, istep}.statedata = statedata;
                data{i, j, istep}.injcells = [inj1, inj2];
                data{i, j, istep}.G = G;
                if i == 1
                    data{i, j, istep}.title = shortDiscName(pdisc);
                end
                if j == i
                    data{i, j, istep}.ylabel = shortDiscName(pdisc);
                end
                %make diff
                if j ~=i
                    data{i, j, istep}.statedata = abs(data{i, j, istep}.statedata - data{i, i, istep}.statedata);
                end

            end
        end
    end
end
%% Plotting diff
for istep = 1:numel(steps)
    step = steps(istep);
    plottitle = ['absolute difference in rs at t=', num2str(step/6), 'h for grid: ', displayNameGrid(gridcase)];
    multiplot(data(:, :, istep), 'title', plottitle, 'savefolder', savefolder, ...
        'savename', [filename, '_step', num2str(step)], ...
        'saveplot', saveplot, 'cmap', '');   
end
%% Setup time evolution plot
SPEcase = 'A';
if strcmp(SPEcase, 'A') 
    scaling = hour; unit = 'h';
else 
    scaling = year;unit='y';
end
gridcases = {'5tetRef2', '6tetRef2'};
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};
pdiscs = {'', 'hybrid-avgmpfa'};%one for eavh grid
filename =[SPEcase, '_timeEvo_' strjoin(cellfun(@(x, y) [x '-' shortDiscName(y)], gridcases, pdiscs, 'UniformOutput', false), '_')];
assert(numel(pdiscs)==numel(gridcases))
deckcase = 'RS';
tagcase = '';


saveplot = false;
savefolder = 'plots\timeEvolution';
if strcmp(SPEcase, 'A')
    steps = [30, 144, 720];
else
    steps = [40, 150, 360];
end
numcases = numel(pdiscs);
%% Load timeEvo data
data = cell(numel(steps), numcases);
for i = 1:numcases
    gridcase = gridcases{i};
    pdisc = pdiscs{i};
    simcase = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                            'tagcase', tagcase, ...
                            'pdisc', pdisc);
    [states, ~, ~] = simcase.getSimData;
    G = simcase.G;
    if i == 1
        times = cumsum(simcase.schedule.step.val);
    end
    for istep = 1:numel(steps)
        step = steps(istep);
        if numelData(states) >= step
            statedata = getData(states, step, G);
            [inj1, inj2] = simcase.getinjcells;
            data{istep, i}.statedata = statedata;
            data{istep, i}.injcells = [inj1, inj2];
            data{istep, i}.G = G;
            if istep == 1
                data{istep, i}.title = [displayNameGrid(gridcase), ', ', shortDiscName(pdisc)];
            end
            if i == 1
                data{istep, i}.ylabel = [num2str(times(step)/scaling), ' ', unit];
            end
        end
    end
end
%% Plotting timeEvo

plottitle = 'time evolution of rs';
multiplot(data, 'title', plottitle, 'savefolder', savefolder, ...
        'savename', filename, 'saveplot', saveplot, 'cmap', ''); 

