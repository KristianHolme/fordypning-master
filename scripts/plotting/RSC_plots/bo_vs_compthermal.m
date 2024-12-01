clear all
close all
%%
SPEcase = 'B';


resetData = true;
saveplot = false;
legendpos = 'best';
plottitle = true;

% chose what mrst simulations to show
[mrstgridcases, mrstgridnames] = getRSCGridcases({'C', 'HC', 'CC', 'QT', 'T'}, [100]);
% chose what jutul simulations to show
comptype = 'isothermal';
[~, jutulgridcases] = getRSCGridcases({'C', 'HC', 'CC', 'QT', 'T'}, [100]);

pdiscs = {'', 'avgmpfa'};

plotTypes = {
    % 'sealing', ...%1
    % 'buffer', ...%2
    % 'pop1', ...%3
    % 'pop2', ...%4
    'p21', ...%5
    % 'p22', ...%6
    % 'p23', ...%7
    % 'p24', ...%8
    % 'p31', ...%9
    % 'p32', ...%10
    % 'p33', ...%11
    % 'p34' ...%12
    };
%% make all desired plots
% tic()
for i = 1:numel(plotTypes)
    type = plotTypes{i};
    plotBOvsCompThermal(type, mrstgridcases, mrstgridnames, comptype, jutulgridcases, pdiscs, resetData, saveplot, plottitle, legendpos, SPEcase);
end
% toc();
%%

function plotBOvsCompThermal(type, mrstgridcases, mrstgridnames, comptype, jutulgridcases, pdiscs, resetData, saveplot, plottitle, legendpos, SPEcase)
    if strcmp(SPEcase, 'A') 
        xscaling = hour; unit = 'h';
        steps = 720;
    else 
        xscaling = speyear;unit='y';
        steps = 301;
    end
    xtxt = ['Time [', unit, ']'];
    %% name formatting
    for i = 1:numel(mrstgridnames)
        parts = split(mrstgridnames{i}, '_');
        mrstgridnames{i} = regexprep(parts{2}, '\d+', '');
    end

    jutulgridnames = {};
    for i = 1:numel(jutulgridcases)
        parts = split(jutulgridcases{i}, '_');
        jutulgridnames{i} = regexprep(parts{2}, '\d+', '');
    end

    %% Load simcases 
    simcases = {};
    colors = {};
    plotStyles = {};
    linestyles = {'-', '--'};
    markers = containers.Map({'', 'avgmpfa', 'ntpfa'}, {'none', '^', 's'});
    gridcasecolors = containers.Map({'C', 'HC', 'CC', 'QT', 'T', 'PEBI'}, {'#0072BD', "#77AC30", "#D95319", "#7E2F8E", '#FFBD43', '#02bef7'});

    for igrid = 1:numel(mrstgridcases)
        gridcase = mrstgridcases{igrid};
        for idisc = 1:numel(pdiscs)
            pdisc = pdiscs{idisc};
            colors{end+1} = gridcasecolors(mrstgridnames{igrid});
            if ~strcmp(pdisc, '')
                simcasepdisc = ['hybrid-', pdisc];
            else
                simcasepdisc = pdisc;
            end
            simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', 'B_ISO_C', 'usedeck', true, 'gridcase', gridcase, 'pdisc', simcasepdisc);
            plotStyles{end+1} = struct('Color', colors{end}, 'LineStyle', linestyles{1}, 'Marker', markers(pdisc));
        end
    end

    for igrid = 1:numel(jutulgridcases)
        gridcase = jutulgridcases{igrid};
        for idisc = 1:numel(pdiscs) 
            pdisc = pdiscs{idisc};
            colors{end+1} = gridcasecolors(jutulgridnames{igrid});
            simcases{end+1} = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'jutulComp', comptype, 'tagcase', 'allcells', 'pdisc', pdisc);
            plotStyles{end+1} = struct('Color', colors{end}, 'LineStyle', linestyles{2}, 'Marker', markers(pdisc));
        end
    end

    %% data function

    [getData, plotTitle, ytxt, ~, filetag] = initMeasurablePlots(type, resetData);



    %% Load data compThermal

    xdata = cumsum(simcases{1}.schedule.step.val)/xscaling;
    xdata = xdata(1:steps);
    xdata_thermal = load('/media/kristian/HDD/Jutul/output/csp11/thermal_dt.mat').dt/xscaling;
    xdatasets = {xdata, xdata_thermal};
    data = nan(steps, numel(simcases));
    twosteps = [steps, numel(xdata_thermal)];
    t_load = tic();
    for isim = 1:numel(simcases)
        simcase = simcases{isim};
        if ~isempty(simcase.jutulComp)
            step = twosteps(2);
        else
            step = twosteps(1);
        end
        data(1:step,isim) = getData(simcase, step);
    end
    t_load = toc(t_load);
    fprintf("Loading done in %s seconds.\n", num2str(t_load));

    %% Plot compThermal

    set(groot, 'defaultLineLineWidth', 2);
    figure('Position', [100,200, 800, 600], 'Name',plotTitle)
    hold on;
    scale = floor(log10(max(data, [], 'all')));
    axfix = false;
    if scale ~=1 && ~contains(ytxt, 'bar') && axfix
        figscaling = 3*floor(scale/3);
        figytxt = replace(ytxt, '[', ['[10^{', num2str(figscaling), '} ']);
        figdata = data ./ 10^figscaling;
    else
        figdata = data;
        figytxt = ytxt;
    end
    for i=1:numel(simcases)
        simcase = simcases{i};
        if ~isempty(simcase.jutulComp)
            step = twosteps(2);
            x = xdatasets{2};
        else
            step = twosteps(1);
            x = xdatasets{1};
        end

        y = figdata(1:step, i);
        plot(x, y, 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle, ...
             'Marker', plotStyles{i}.Marker, 'MarkerSize', 8, 'MarkerIndices', 1:10:length(x));
    end
    % Create dummy plots for legend
    gridcases = unique([mrstgridnames, jutulgridnames]);
    h_grid = [];
    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        color = gridcasecolors(gridcase);
        h_grid(igrid) = plot(NaN,NaN, 'Color', color, 'LineStyle', '-', 'LineWidth', 2); % No data, just style
    end
    h_linestyle = [];
    simlabels = {'Black-oil', 'Compositional'}; % Define simulation labels
    for isim = 1:2
        style = linestyles{isim};
        h_linestyle(isim) = plot(NaN,NaN, 'Color', 'k', 'LineStyle', style, 'LineWidth', 2); % No data, just style
    end

    % Only add marker legend if multiple discretization types
    if numel(pdiscs) > 1
        h_markers = [];
        marker_labels = cellfun(@shortDiscName, pdiscs, 'UniformOutput', false);
        for imark = 1:numel(pdiscs)
            pdisc = pdiscs{imark};
            h_markers(imark) = plot(NaN,NaN, 'Color', 'k', 'Marker', markers(pdisc), ...
                'LineStyle', 'none', 'MarkerSize', 8); % No data, just marker
        end
        % Combine handles and labels with markers
        handles = [h_grid, h_linestyle, h_markers];
        labels = [gridcases, simlabels, marker_labels];
    else
        % Combine handles and labels without markers
        handles = [h_grid, h_linestyle];
        labels = [gridcases, simlabels];
    end

    % Create the legend
    lgd = legend(handles, labels, 'NumColumns', 2);
    set(lgd, 'Interpreter', 'none', 'Location', legendpos);
    hold off
    if plottitle
        title(plotTitle);
    end
    fontsize(16, 'points'); 
    xlabel(xtxt);
    ylabel(figytxt);
    grid on;

    % if insetPlot
    %     %plot inside plot
    %     insetPosition = [0.19 0.15 0.25 0.25];
    %     insetAxes = axes('Position',insetPosition);
    %     insetsteps = 201;
    %     insetxdata = xdata(1:insetsteps);
    %     for i=1:numel(simcases)
    %         plot(insetAxes, insetxdata, data(1:insetsteps, i), 'Color', plotStyles{i}.Color, 'LineStyle', plotStyles{i}.LineStyle, 'Marker', plotStyles{i}.Marker, 'MarkerSize',4, 'MarkerIndices',1:10:numel(insetxdata));
    %         hold on;
    %     end
    %     grid(insetAxes);
    % end
    tightfig()
    if saveplot
        % folder = './plots/sealingCO2';
        filename = [SPEcase, '_', filetag,'_', strjoin(gridcases, '_'), '-', strjoin(simlabels, '_')];
        % saveas(gcf, fullfile(folder, [filename, '.svg']))%for color
        % print(fullfile(folder, [filename, '.pdf']), '-dpdf')
        saveas(gcf, fullfile(folder, [filename, '.png']))
        saveas(gcf, fullfile(folder, [filename, '.fig']))
        saveas(gcf, fullfile(folder, [filename,'.eps']), 'epsc');
    end
    % pause(0.5)
    % close gcf
end