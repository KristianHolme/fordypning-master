function plotMatrixWithLabels(matrixData, simcases, batchname, figtitle, filetag, varargin)
    % Parse options
    opt = struct('dir', 'plots/RSC/Measures', ...
                'save', true, ...
                'graybackground', true, ...
                'titleInPlot', false);
    opt = merge_options(opt, varargin{:});
    
    % Normalize the matrix data
    matrixData = matrixData';
    
    % Add NaN row to create space for labels
    matrixData = [NaN(1, size(matrixData, 2)); matrixData];
    
    % Create labels combining grid and discretization info
    labels = cell(numel(simcases), 1);
    gridnames = cell(numel(simcases), 1);
    for i = 1:numel(simcases)
        gridnames{i} = gridcase_to_RSCname(simcases{i}.gridcase);
        discname = shortDiscName(simcases{i}.pdisc);
        labels{i} = sprintf('%s\n%s', gridnames{i}, discname);
    end
    
    % Create plot
    figure('Position', [100 100 1000 800], 'Name', sprintf('%s, %s', figtitle, batchname));
    h = imagesc(matrixData);
    
    % Add title at the top if option is enabled
    if opt.titleInPlot
        title(figtitle, 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    gray = [167,166,163]/255;
    if opt.graybackground
        set(gca, 'Color', gray); % Set background color to light gray
    end
    
    % Set missing data to white
    cdata = get(gca, 'Children');
    set(cdata, 'AlphaData', ~isnan(matrixData));
    
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
    
    % Add padding to make room for labels
    axis([0.5 length(labels)+0.5 0.5 length(labels)+1.5]);
    
    % Add grid lines and labels
    for i = 1:length(uniqueGrids)
        if i < length(uniqueGrids)
            idx = gridSections(i,2);
            % Draw vertical and horizontal lines
            line([idx+0.5 idx+0.5], [idx+1.5 length(labels)+1.5], 'Color', gray, 'LineWidth', 2);
            line([0.5 idx+0.5], [idx+1.5 idx+1.5], 'Color', gray, 'LineWidth', 2);
        end
        
        % Calculate center position for the label
        start_idx = gridSections(i,1);
        end_idx = gridSections(i,2);
        center_x = (start_idx + end_idx) / 2;
        
        % Position label above diagonal
        offset = 1.2; % Increased offset for more space
        text(center_x, center_x + 1 - offset, uniqueGrids{i}, ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'bottom', ...
             'FontSize', 12, 'Rotation', -45, 'Color', 'k');
    end
    
    % Add extra padding at the top and left for labels
    ax = gca;
    ax.Position(1) = ax.Position(1) + 0.02; % Move right
    ax.Position(2) = ax.Position(2) + 0.02; % Move up
    
    % Add discretization labels on diagonal
    for i = 1:length(simcases)
        discname = upper(shortDiscName(simcases{i}.pdisc));
        if ~isempty(discname)
            text(i, i+1, discname(1), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', ...
                 'FontSize', 10, 'Color', 'k');
        end
    end
    
    % Add legend for discretization labels
    h1 = scatter(NaN,NaN, 'w'); % invisible scatter
    h2 = scatter(NaN,NaN, 'w');
    h3 = scatter(NaN,NaN, 'w');
    h4 = scatter(NaN,NaN, 'w');
    
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
        % Ensure figure is rendered properly before saving
        drawnow
        
        % Save as PNG using exportgraphics
        exportgraphics(gcf, fullfile(opt.dir, [batchname, '_', filetag, '.png']), 'Resolution', 300);
        exportgraphics(gcf, fullfile(opt.dir, [batchname, '_', filetag, '.png']), 'Resolution', 300);
        % Save as FIG
        savefig(gcf, fullfile(opt.dir, [batchname, '_', filetag, '.fig']));
    end
end