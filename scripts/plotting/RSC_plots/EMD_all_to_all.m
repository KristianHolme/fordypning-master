clear all
close all
%%
SPEcase = 'B';
[gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC', 'PEBI','QT', 'T'}, [100]);
% [gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC','QT', 'T'}, [10]);
pdiscs = {'', 'avgmpfa', 'ntpfa', 'mpfa'};
% pdiscs = {'', 'avgmpfa'};
%%
simcases = loadSimcases(gridcases, pdiscs); %for mrst
% simcases = loadSimcases(gridnames, pdiscs, 'jutulComp', 'isothermal'); %for Jutul
simcases = removeSimcases(simcases, {'C'}, {'avgmpfa', 'ntpfa'});
%%
name = 'mrst100k';
% name = 'jutul100k';
%%
energy = calcEMD(simcases, name, 'recalculate', false);
%%
plotEMD(energy, simcases, name);

%%

function EMD_energy = calcEMD(simcases, name, varargin)
    opt = struct('dir', './data/RSC/EMD',...
                 'save', true,...
                 'recalculate', false);
    opt = merge_options(opt, varargin{:});
    pth = fullfile(opt.dir, sprintf('%s.mat', name));
    if isfile(pth) && ~opt.recalculate
        load(pth)
        return
    end

    n = numel(simcases);
    EMD_energy = nan(n);

    tot_entries = n*(n-1)/2;

    indicesarray=zeros(round(tot_entries), 2);
    k = 0;
    for i = 1:n
        EMD_energy(i,i) = 0.0;
        for j = i+1:n
            k = k + 1;
            indicesarray(k,1) = i;
            indicesarray(k,2) = j;
        end
    end

    
    % Convert nested loops to single loop with linear indexing
    EMD_tmp = zeros(tot_entries, 1);  % Store results in a temporary vector
    
    for k = 1:tot_entries % can be made parallel, not recommended
        i = indicesarray(k,1);
        j = indicesarray(k,2);
        statesj = simcases{j}.getSimData;
        statesi = simcases{i}.getSimData;
        if ~isempty(simcases{i}.jutulComp)
            statej = statesj{numelData(statesj)}.TotalMasses(:,2);
            statei = statesi{numelData(statesi)}.TotalMasses(:,2);
        else
            statej = statesj{numelData(statesj)}.FlowProps.ComponentTotalMass{2};
            statei = statesi{numelData(statesi)}.FlowProps.ComponentTotalMass{2};
        end
        Gj = simcases{j}.G; 
        Gi = simcases{i}.G;
        Mj = simcases{j}.G.reductionMatrix;
        Mi = simcases{i}.G.reductionMatrix;
        Grj = simcases{j}.G.reductionGrid;
        Gri = simcases{i}.G.reductionGrid;
        EMD_tmp(k) = approxEMD(reduce(statei, Gi, Mi, Gri), reduce(statej, Gj, Mj, Grj), 'verbose', true);
    end
    
    % Convert back to matrix form after parallel loop
    for k = 1:tot_entries
        i = indicesarray(k,1);
        j = indicesarray(k,2);
        EMD_energy(i,j) = EMD_tmp(k);
    end
    
    if opt.save
        
        save(pth, 'EMD_energy');
    end
end

function plotEMD(EMD_energy, simcases, name, varargin)
    plotMatrixWithLabels(EMD_energy, simcases, name, 'EMD', 'EMD', varargin{:});
end
%{
function plotEMD(EMD_energy, simcases, name, varargin)
    % Parse options
    opt = struct('dir', 'plots/RSC/EMD', ...
                'save', true,...
                'graybackground', true);
    opt = merge_options(opt, varargin{:});
    
    % Normalize the EMD energy matrix
    EMD_energy = EMD_energy';
    
    % Create labels combining grid and discretization info
    labels = cell(numel(simcases), 1);
    gridnames = cell(numel(simcases), 1);
    for i = 1:numel(simcases)
        gridnames{i} = gridcase_to_RSCname(simcases{i}.gridcase);
        discname = shortDiscName(simcases{i}.pdisc);
        labels{i} = sprintf('%s\n%s', gridnames{i}, discname);
    end
    
    % Create plot
    figure('Position', [100 100 1000 800], 'Name', sprintf('EMD, %s', name));
    h = imagesc(EMD_energy);
    gray = [167,166,163]/255;
    if opt.graybackground
        set(gca, 'Color', gray); % Set background color to light gray
    end
    
    % Set missing data to white
    cdata = get(gca, 'Children');
    set(cdata, 'AlphaData', ~isnan(EMD_energy));
    
    % Find grid sections
    uniqueGrids = unique(gridnames, 'stable');
    gridSections = zeros(length(uniqueGrids), 2);  % [start, end] indices
    for i = 1:length(uniqueGrids)
        gridMask = strcmp(gridnames, uniqueGrids{i});
        gridSections(i,:) = [find(gridMask, 1, 'first'), find(gridMask, 1, 'last')];
    end
    
    % Add grid lines and centered grid labels
    hold on
    % Remove default ticks
    set(gca, 'XTick', [], 'YTick', []);
    
    % Add grid lines and labels
    for i = 1:length(uniqueGrids)
        if i < length(uniqueGrids)
            idx = gridSections(i,2);
            % Draw vertical and horizontal lines
            line([idx+0.5 idx+0.5], [idx+0.5 length(labels)+0.5], 'Color', gray, 'LineWidth', 2);
            line([0.5 idx+0.5], [idx+0.5 idx+0.5], 'Color', gray, 'LineWidth', 2);
        end
        
        % Add centered grid labels
        midPoint = mean(gridSections(i,:));
        % X-axis label
        text(midPoint, length(labels)+1, uniqueGrids{i}, ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
             'FontSize', 12);
        % Y-axis label
        text(-0.5, midPoint, uniqueGrids{i}, ...
             'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', ...
             'FontSize', 12);
    end
    
    % Add discretization labels on diagonal
    for i = 1:length(simcases)
        discname = upper(shortDiscName(simcases{i}.pdisc));
        if ~isempty(discname)
            text(i, i, discname(1), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', ...
                 'FontSize', 10, 'Color', 'k');
        end
    end
    
    % Add invisible scatter plots for legend
    h1 = scatter(NaN,NaN, 'w'); % invisible scatter
    h2 = scatter(NaN,NaN, 'w');
    h3 = scatter(NaN,NaN, 'w');
    h4 = scatter(NaN,NaN, 'w');
    
    % Add legend
    legend([h1,h2,h3,h4], {'T = TPFA', 'A = AvgMPFA', 'N = NTPFA', 'M = MPFA'}, ...
           'Location', 'northeast', ...
           'TextColor', 'k', ...
           'Color', 'w', ...
           'FontSize', 10);
    hold off
    
    % Customize appearance
    colorbar();
    C = hot(128); colormap(flipud(C(65:128,:)));
    axis square;
    
    % Save plots if requested
    if opt.save
        if ~exist(opt.dir, 'dir')
            mkdir(opt.dir);
        end
        saveas(gcf, fullfile(opt.dir, [name, '_EMD.png']));
        saveas(gcf, fullfile(opt.dir, [name, '_EMD.fig']));
    end
end
%}
function reducedData = reduce(statedata, G, M, Gr)
    fulldata = zeros(size(M, 2), 1);
    fulldata(G.cells.indexMap) = statedata ./ G.cells.volumes;
    reducedData = (M*fulldata) .* Gr.cells.volumes;
end

