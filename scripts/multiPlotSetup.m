clear all;
close all;
%% Setup
% gridcases = {'5tetRef2', 'semi203x72_0.3', 'struct193x83'}; filename = 'gridtypeComp';
% gridcases = {'5tetRef1', '5tetRef2', '5tetRef3'}; filename ='UU_refine_disc';
% gridcases = {'6tetRef2', '5tetRef2'}; filename = 'meshAlgComparisonRef2';
gridcases = {'5tetRef2', '5tetRef2-2D'}; filename = 'UUgriddimComp';
pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};
deckcase = 'RS';
tagcase = '';

saveplot = true;

savefolder="plots\multiplot";

steps = [30, 144, 720];
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
for istep = 1:numel(steps)
    step = steps(istep);
    plottitle = ['rs at t=', num2str(step/6), 'h'];
    multiplot(data(:, :, istep), 'title', plottitle, 'savefolder', savefolder, ...
        'savename', [filename, '_step', num2str(step)], ...
        'saveplot', saveplot, 'cmap', '');   
end
