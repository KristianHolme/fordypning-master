function plotData(labels, data, varargin)
    % Data in columns
    opt = struct('xlabel', [], ...
                 'ylabel', [], ...
                 'xdata', [], ...
                 'title', [], ...
                 'legend', true, ...
                 'interpreter', 'none', ...
                 'legendLoc', 'best');
    opt = merge_options(opt, varargin{:});
    
    figure;
    hold on;
    assert(size(labels, 2) == size(data,2)) %one label for each data column

    if isempty(opt.xdata)
        plot(data);
    else
        plot(opt.xdata, data);
    end
    
    if ~isempty(opt.xlabel)
        xlabel(opt.xlabel);
    end
    
    if ~isempty(opt.ylabel)
        ylabel(opt.ylabel);
    end
    
    if ~isempty(opt.title)
        title(opt.title);
    end
    
    if opt.legend
        legend(labels, 'Location', opt.legendLoc, 'interpreter', opt.interpreter);
    end
    grid;
    hold off;
end
