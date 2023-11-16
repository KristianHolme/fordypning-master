clear all;
close all;
%% Setup
SPEcase = 'B';
% gridcases = {'5tetRef2', 'semi203x72_0.3', 'struct193x83'}; filename = 'gridtypeComp';
gridcases = {'5tetRef1', '5tetRef2', '5tetRef3', '5tetRef10'}; filename =[SPEcase, '_UU_refine_disc'];
% gridcases = {'6tetRef2', '5tetRef2'}; filename = 'meshAlgComparisonRef2';
% gridcases = {'5tetRef2', '5tetRef2-2D'}; filename = 'UUgriddimComp';
pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};
deckcase = 'RS';
tagcase = '';

saveplot = false;

savefolder="plots\multiplot";

if strcmp(SPEcase, 'A')
    steps = [30, 144, 720];
else
    steps = [40, 150, 360];
numGrids = numel(gridcases);
numDiscs = numel(pdiscs);
%% Loading data grid vs pdisc
data = cell(numDiscs, numGrids, numel(steps));
for istep = 1:numel(steps)
    step = steps(istep);
    for i = 1:numDiscs
        pdisc = pdiscs{i};
        for j = 1:numGrids
            pdisc = gridcases{j};
            simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', pdisc, ...
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
                    data{i, j, istep}.title = displayNameGrid(pdisc);
                end
                if j == 1
                    data{i, j, istep}.ylabel = shortDiscName(pdisc);
                end
            end
        end
    end
end

%% Plotting grid vs disc
for istep = 1:numel(steps)
    step = steps(istep);
    plottitle = ['rs at t=', num2str(step/6), 'h'];
    multiplot(data(:, :, istep), 'title', plottitle, 'savefolder', savefolder, ...
        'savename', [filename, '_step', num2str(step)], ...
        'saveplot', saveplot, 'cmap', '');   
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
%% Load data
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