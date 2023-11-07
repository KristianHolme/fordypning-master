clear all;
close all;
%% Setup
gridcases = {'5tetRef2', 'semi203x72_0.3', 'struct220x90'};
discmethods = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};
deckcase = 'RS';
tagcase = '';
griddim = 3;

steps = [30, 144, 720];
numGrids = numel(gridcases);
numDiscs = numel(discmethods);
%% Loading data
data = cell(numDiscs, numGrids, numel(steps));
for istep = 1:numel(steps)
    step = steps(istep);
    for i = 1:numDiscs
        discmethod = discmethods{i};
        for j = 1:numGrids
            gridcase = gridcases{j};
            simcase = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                'tagcase', tagcase, ...
                                'discmethod', discmethod, 'griddim', griddim);
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
saveplot = true;
savefolder="plots\multiplot";
filename = @(step) ['Comp=', strjoin(gridcases, '_'), '_', strjoin(discmethods, '_'), '_step', num2str(step)];

for istep = 1:numel(steps)
    step = steps(istep);
    % Get the screen size
    screenSize = get(0, 'ScreenSize');
    
    % Calculate the desired figure size (e.g., full screen or a fraction of it)
    figWidth = screenSize(3) * 0.8; % 80% of the screen width
    figHeight = screenSize(4) * 0.8; % 80% of the screen height
    
    % Create a figure with the desired size
    f = figure('Position', [screenSize(3)*0.1 screenSize(4)*0.1 figWidth figHeight]);
    t = tiledlayout(numDiscs, numGrids, 'Padding', 'compact', 'TileSpacing', 'compact');
    title(t, ['rs at time=', num2str(step/6), 'h'])
    
    for i = 1:numDiscs
        discmethod = discmethods{i};
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
                    ylh = ylabel(ax, shortDiscName(discmethods{i}), FontSize=12, FontWeight='bold');
                    set(ylh, 'Visible', 'on'); % Ensure the label is visible
                    % Adjust the position of the ylabel if necessary
                    set(ylh, 'Position', [-0.11, 0.5], 'Units', 'Normalized');
                end
                
                statedata   = data{i, j, istep}.statedata;
                injcells    = data{i, j, istep}.injcells;
                G           = data{i, j, istep}.G;
                % subplot(numDiscs, numGrids, p)
                
                plotCellData(G, statedata, 'edgealpha', 0);view(0,0);
                plotGrid(G, injcells, 'facecolor', 'red');
                
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
        savepath = fullfile(savefolder, filename(step));
        saveas(f, savepath, 'png');
        saveas(f, savepath, 'eps');
    end
end
