clear all
close all
%%
SPEcase = 'B';
[gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC', 'PEBI', 'QT', 'T'}, [100]);
% [gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC','QT', 'T'}, [10]);
% pdiscs = {'', 'avgmpfa', 'ntpfa', 'mpfa'};
pdiscs = {'', 'avgmpfa', 'ntpfa'};
%%
% simcases = loadSimcases(gridcases, pdiscs); %for mrst
simcases = loadSimcases(gridnames, pdiscs, 'jutulComp', 'isothermal'); %for Jutul
simcases = removeSimcases(simcases, {'C'}, {'avgmpfa', 'ntpfa'});
%%
% name = 'mrst100k';
name = 'jutul100k';
titleInPlot = true;
%% Choose measures
measures = {
    'sealing', ...%1
    'buffer', ...%2
    'pop1', ...%3
    'pop2', ...%4
    'p21', ...%5
    'p22', ...%6
    'p23', ...%7
    'p24', ...%8
    'p31', ...%9
    'p32', ...%10
    'p33', ...%11
    'p34' ...%12
    };
%% Plotting
for im = 1:numel(measures)
    measure = measures{im};
    % plotMeasureMatrix(simcases, measure, name, titleInPlot);
    % Add option to create combined plot
    plotMeasureMatrixWithTimeSeries(simcases, measure, name, titleInPlot, 'save', true);
end
%%
function plotMeasureMatrix(simcases, measure, name, titleInPlot)
    [time_series_data, title, ~, filetag] = loadMeasureData(simcases, measure);
    similarity_matrix = calcSimilarityMatrix(time_series_data);
    plotMatrixWithLabels(similarity_matrix, simcases, name, title, filetag, 'titleInPlot', titleInPlot);
end

function [time_series_data, title, ytxt, filetag] = loadMeasureData(simcases, measure)
    [getData, title, ytxt, ~, filetag] = initMeasurablePlots(measure, false);

    time_series_data = cell(1, numel(simcases));
    if isempty(simcases{1}.jutulComp)
        xdata = cumsum(simcases{1}.schedule.step.val);
    else
        xdata = load('/media/kristian/HDD/Jutul/output/csp11/thermal_dt.mat').dt;
    end
    steps = numel(xdata);
    t_load = tic();
    for isim = 1:numel(simcases)
        simcase = simcases{isim};
        time_series_data{isim} = [xdata, getData(simcase, steps)];
    end
    t_load = toc(t_load);
    fprintf("Loading done in %s seconds.\n", num2str(t_load));
end

function similarity_matrix = calcSimilarityMatrix(time_series_data)
    n = numel(time_series_data);
    similarity_matrix = nan(n, n);
    
    for i = 1:n
        for j = i:n
            if i == j
                similarity_matrix(i,j) = 0;
                continue;  % set diagonal to 0
            end
            
            % Get data for both series
            data1 = time_series_data{i};
            data2 = time_series_data{j};
            
            % Extract x and y values
            x1 = data1(:,1);
            y1 = data1(:,2);
            x2 = data2(:,1);
            y2 = data2(:,2);
            
            % Create common x points (union of both series' x values)
            x_common = unique([x1; x2]);
            
            % Interpolate both series to common x points
            y1_interp = interp1(x1, y1, x_common, 'linear');
            y2_interp = interp1(x2, y2, x_common, 'linear');
            
            % Calculate L2 error
            diff = y1_interp - y2_interp;
            l2_error = sqrt(mean(diff.^2));
            
            similarity_matrix(i,j) = l2_error;
        end
    end
end

function plotMeasureMatrixWithTimeSeries(simcases, measure, name, titleInPlot, varargin)
    opt = struct('save', false, 'dir', './plots/RSC/measure_matrix-time_series');
    opt = merge_options(opt, varargin{:});
    % Load data (reuse existing function)
    [time_series_data, title, ytxt, filetag] = loadMeasureData(simcases, measure);
    similarity_matrix = calcSimilarityMatrix(time_series_data);
    
    % Create figure with enough space for both plots
    figure('Position', [100, 200, 1200, 900]);
    
    % Plot matrix in main area - make it slightly smaller to accommodate colorbar
    subplot('Position', [0.1, 0.1, 0.7, 0.8]);
    plotMatrixWithLabels(similarity_matrix, simcases, name, title, filetag, ...
        'titleInPlot', titleInPlot, ...
        'legendPosition', 'southwest', ...
        'createFigure', false, ...
        'save', false);
    
    % Set inset position based on name
    if contains(name, 'mrst')
        inset_position = [0.41, 0.60, 0.325, 0.30];  % Original position for MRST
    else
        inset_position = [0.40, 0.605, 0.325, 0.295];  % Different position for other cases (e.g., Jutul)
    end
    
    ax_inset = axes('Position', inset_position);  % [left bottom width height]
    hold(ax_inset, 'on');
    
    % Setup plotting styles
    gridcasecolors = containers.Map({'C', 'HC', 'CC', 'QT', 'T', 'PEBI'}, ...
        {'#0072BD', "#77AC30", "#D95319", "#7E2F8E", '#FFBD43', '#02bef7'});
    
    % Set x-axis scaling based on SPEcase
    if strcmp(simcases{1}.SPEcase, 'A')
        xscaling = 3600; % hours
    else
        xscaling = speyear; % years
    end
    % Plot time series
    for isim = 1:numel(simcases)
        simcase = simcases{isim};
        data = time_series_data{isim};
        
        % Get grid type from simcase name
        gridtype = gridcase_to_RSCname(simcase.gridcase);
        
        % Plot with appropriate style
        plot(ax_inset, data(:,1)/xscaling - 1000, data(:,2), ...
            'Color', gridcasecolors(gridtype), ...
            'LineStyle', disc2linestyle(simcase.pdisc), ...
            'LineWidth', 2);
    end
    
    % Format inset plot
    grid(ax_inset, 'on');
    if strcmp(simcases{1}.SPEcase, 'A')
        xlabel(ax_inset, 'Time [h]');
    else
        xlabel(ax_inset, 'Time [y]');
    end
    ylabel(ax_inset, ytxt);
    set(ax_inset, 'FontSize', 8);
    
    % Create dummy plots for legend
    % Get unique grid types
    gridtypes = unique(cellfun(@(x) gridcase_to_RSCname(x.gridcase), simcases, 'UniformOutput', false));
    h_grid = [];
    for igrid = 1:numel(gridtypes)
        gridtype = gridtypes{igrid};
        color = gridcasecolors(gridtype);
        h_grid(igrid) = plot(NaN, NaN, 'Color', color, 'LineStyle', '-', 'LineWidth', 2);
    end
    
    % Get unique discretization types
    disctypes = unique(cellfun(@(x) x.pdisc, simcases, 'UniformOutput', false));
    h_disc = [];
    disc_labels = {};
    for idisc = 1:numel(disctypes)
        pdisc = disctypes{idisc};
        disc_labels{idisc} = shortDiscName(pdisc);
        h_disc(idisc) = plot(NaN, NaN, 'Color', 'k', 'LineStyle', disc2linestyle(pdisc), 'LineWidth', 2);
    end
    
    % Combine handles and labels
    handles = [h_grid, h_disc];
    labels = [gridtypes, disc_labels];
    
    % Create the legend
    lgd = legend(handles, labels, 'NumColumns', 2, 'Location', 'best');
    set(lgd, 'Interpreter', 'none', 'FontSize', 8);

    % Save figure
    if opt.save
        % Create directory if it doesn't exist
        if ~exist(opt.dir, 'dir')
            mkdir(opt.dir);
        end
        
        % Generate filename
        filename = fullfile(opt.dir, [name, '_', filetag, '.fig']);
        % Save as PNG using exportgraphics
        pngname = fullfile(opt.dir, [name, '_', filetag, '.png']);
        exportgraphics(gcf, pngname, 'Resolution', 300);
        % Save as MATLAB .fig file
        savefig(gcf, filename);
    end
end

function linestyle = disc2linestyle(pdisc)
    if isempty(pdisc)
        linestyle = '-';  % Whole line
    elseif contains(pdisc, 'avgmpfa')
        linestyle = '--'; % Line with small breaks
    elseif contains(pdisc, 'ntpfa')
        linestyle = '-.'; % Line with dot
    elseif contains(pdisc, 'mpfa')
        linestyle = ':';  % Dotted line
    else
        linestyle = '-';  % Default to whole line
    end
end