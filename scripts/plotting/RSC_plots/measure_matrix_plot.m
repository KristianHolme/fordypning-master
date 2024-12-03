clear all
close all
%%
SPEcase = 'B';
[gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC', 'PEBI','QT', 'T'}, [100]);
% [gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC','QT', 'T'}, [10]);
% pdiscs = {'', 'avgmpfa', 'ntpfa', 'mpfa'};
pdiscs = {'', 'avgmpfa'};
%%
% simcases = loadSimcases(gridcases, pdiscs); %for mrst
simcases = loadSimcases(gridnames, pdiscs, 'jutulComp', 'isothermal'); %for Jutul
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
    plotMeasureMatrix(simcases, measure, name, titleInPlot);
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