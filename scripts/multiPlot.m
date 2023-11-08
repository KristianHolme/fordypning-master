clear all;
close all;
%% Setup
% gridcases = {'5tetRef2', 'semi203x72_0.3', 'struct193x83'};
% gridcases = {'5tetRef1', '5tetRef2', '5tetRef3'};
% gridcases = {'6tetRef2', '5tetRef2'};
gridcases = {'5tetRef2', '5tetRef2-2D'};
pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};
deckcase = 'RS';
tagcase = '';

saveplot = true;
filename = 'UUgriddimComp';
savefolder="plots\multiplot";

steps = [30, 144, 720];
numGrids = numel(gridcases);
numDiscs = numel(pdiscs);
%% Loading data
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
            end
        end
    end
end

%% Plotting
for istep = 1:numel(steps)
    step = steps(istep);
    % Get the screen size
    screenSize = get(0, 'ScreenSize');
    
    % Calculate the desired figure size (e.g., full screen or a fraction of it)
    figWidth = screenSize(3) * 0.8*numGrids/3; % 80% of the screen width
    figHeight = screenSize(4) * 0.81*numDiscs/4; % 80% of the screen height
    
    % Create a figure with the desired size
    f = figure('Position', [screenSize(3)*0.05 screenSize(4)*0.05 figWidth figHeight]);
    t = tiledlayout(numDiscs, numGrids, 'Padding', 'compact', 'TileSpacing', 'compact');
    title(t, ['rs at time=', num2str(step/6), 'h'])
    
    for i = 1:numDiscs
        pdisc = pdiscs{i};
        for j = 1:numGrids
            gridcase = gridcases{j};
            p = (i-1)*numGrids + j;
            ax = nexttile(p);
            
            
            
            if ~isempty(data{i, j, istep})
                % Add title to the first row subplots for column labels
                if i == 1
                    title(['G: ' displayNameGrid(gridcase)]);
                end

                % Add y-label to the first column subplots for row labels
                if j == 1
                    ylh = ylabel(ax, shortDiscName(pdiscs{i}), FontSize=12, FontWeight='bold');
                    set(ylh, 'Visible', 'on'); % Ensure the label is visible
                    % Adjust the position of the ylabel if necessary
                    set(ylh, 'Position', [-0.11, 0.5], 'Units', 'Normalized');
                end
                
                statedata   = data{i, j, istep}.statedata;
                injcells    = data{i, j, istep}.injcells;
                G           = data{i, j, istep}.G;
                % subplot(numDiscs, numGrids, p)
                
                plotCellData(G, statedata, 'edgealpha', 0);
                plotGrid(G, injcells, 'facecolor', 'red');
                if G.griddim == 3 %change view if on 3D grid
                    view(0,0);
                end
                xticks([]);
                yticks([]);
                zticks([]);
                
                axis tight;axis equal;
                

                % % Add x-label to the last row subplots
                % if i == numDiscs
                %     xlabel(['Step ' num2str(step)]);
                % end
            else
                delete(ax);
            end

        end
    end
    if saveplot
        savepath = fullfile(savefolder, [filename, '_step', num2str(step)]);
        savepath = replace(savepath, '.', '_');
        saveas(f, savepath, 'png');
        saveas(f, savepath, 'eps');
    end
end
