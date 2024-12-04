function plotMatrixWithLabels(matrixData, simcases, batchname, figtitle, filetag, varargin)
    % Parse options
    opt = struct('dir', 'plots/RSC/Measures', ...
                'save', true, ...
                'graybackground', true, ...
                'titleInPlot', false, ...
                'legendPosition', 'northeast', ...
                'createFigure', true);
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
        labels{i} = gridnames{i};
    end
    
    % Create plot
    if opt.createFigure
        figure('Position', [100 100 1000 800], 'Name', sprintf('%s, %s', figtitle, batchname));
    end
    h = imagesc(matrixData);
    
    % Add title at the top if option is enabled
    if opt.titleInPlot
        title(figtitle, 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    % gray = [167,166,163]/255;
    gray = [250,250,250]/255;
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
    
    % Calculate center positions for each unique grid type
    gridCenters = zeros(length(uniqueGrids), 1);
    for i = 1:length(uniqueGrids)
        % Calculate center as midpoint between first and last index of each grid section
        start_idx = gridSections(i,1);
        end_idx = gridSections(i,2);
        gridCenters(i) = (start_idx + end_idx)/2;
    end
    
    % Set ticks and labels for axes
    labelFontSize = 16;
    % Adjust tick positions to be centered within each grid section
    set(gca, 'XTick', gridCenters, 'XTickLabel', uniqueGrids, 'FontSize', labelFontSize);
    set(gca, 'YTick', gridCenters + 1, 'YTickLabel', uniqueGrids, 'FontSize', labelFontSize);
    set(gca, 'TickLength', [0 0]);
    
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
        if start_idx == end_idx
            offset = 0.6; % Increased offset for more space
        else
            offset = 1.0; % Increased offset for more space
        end
        text(center_x, center_x + 1 - offset, uniqueGrids{i}, ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'bottom', ...
             'FontSize', labelFontSize, 'Rotation', -45, 'Color', 'k');
    end
    
    % Add extra padding at the top and left for labels
    ax = gca;
    ax.Position(1) = ax.Position(1) + 0.02; % Move right
    ax.Position(2) = ax.Position(2) + 0.02; % Move up
    
    % Add discretization labels on diagonal
    for i = 1:length(simcases)
        discname = upper(shortDiscName(simcases{i}.pdisc));
        if ~isempty(discname)
            text(i, i+1, discname(1), ... % Added +1 to account for NaN row
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
        'Location', opt.legendPosition, ...
        'TextColor', 'k', ...
        'Color', 'w', ...
        'FontSize', 10);
    hold off
    
    % Customize appearance
    colorbar();
    C = hot(128); colormap(flipud(C(65:128,:)));
    axis square;
    
    % Save plots if requested
    if opt.save && opt.createFigure
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