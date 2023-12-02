function multiplot(data, varargin)
    opt = struct('saveplot' , false, ...
                 'title'    , [], ...
                 'tight'    , true, ...
                 'equal'     , true, ...
                 'savefolder', [], ...
                 'savename'  , [], ...
                 'colorbar'  , true, ...
                 'cblabel'   , [], ...
                 'cmap'      , [],...
                 'plotgrid'  , false, ...
                 'diff'      , false, ...
                 'bigGrid'   , true);
    opt = merge_options(opt, varargin{:});
     

    % Get the screen size
    screenSize = get(0, 'ScreenSize');
    [numRows, numCols] = size(data);

    %get min and max value
    minV = 0; 
    maxV = 0;
    diagminV = 0;
    diagmaxV = 0;
    
    for i = 1:numRows
        if opt.diff
            jstart = i+1;
        else
            jstart = 1;
        end
        for j = jstart:numCols
            frame = data{i, j};
            if ~isempty(frame) && isfield(frame, 'statedata') 
                G = frame.G;
                if isfield(frame, 'cells')
                    cells = frame.cells;
                else
                    cells = 1:G.cells.num;
                end
                statedata   = frame.statedata(cells);
                stateMin    = min(statedata);
                stateMax    = max(statedata);
                minV        = min(minV, stateMin);
                maxV        = max(maxV, stateMax);
            end
        end
    end
    if opt.diff %diag
        for i = 1:numRows
            frame = data{i, i};
            if ~isempty(frame) && isfield(frame, 'statedata') 
                G = frame.G;
                if isfield(frame, 'cells')
                    cells = frame.cells;
                else
                    cells = 1:G.cells.num;
                end
                statedata   = frame.statedata(cells);
                stateMin    = min(statedata);
                stateMax    = max(statedata);
                diagminV    = min(diagminV, stateMin);
                diagmaxV    = max(diagmaxV, stateMax);
            end
        end
    end
    if strcmp(opt.cmap, "Seismic")
        opt.cmap = Seismic(minV, maxV);
    end
    
    
    % Calculate the desired figure size (e.g., full screen or a fraction of it)
    figWidth = screenSize(3) * min(0.8*numCols/3, 0.80); % 80% of the screen width
    figHeight = screenSize(4) * min(0.81*numRows/4, 0.80); % 80% of the screen height
    
    % Create a figure with the desired size
    f = figure('Position', [screenSize(3)*0.05 screenSize(4)*0.05 figWidth figHeight]);
    t = tiledlayout(numRows, numCols, 'Padding', 'compact', 'TileSpacing', 'loose');
    if ~isempty(opt.title)
        title(t, opt.title)
    end

    for i = 1:numRows

        for j = 1:numCols
            frame = data{i, j};
            p = (i-1)*numCols + j;
            if isfield(frame, 'span')
                if opt.bigGrid
                    h(p) = nexttile(p, frame.span);
                    plotGrid(frame.G, 'facealpha', 0);axis tight;
                    if G.griddim == 3 %change view if on 3D grid
                        view(0,0);
                    end
                    title(frame.title);
                    if opt.equal
                        axis equal;
                    end
                else
                    continue;
                end
            else
                if ~isempty(frame)
                    h(p) = nexttile(p);
                    % Add title if supplied
                    if isfield(frame, 'title') && ~isempty(frame.title)
                        title(frame.title);
                    end
    
                    % Add y-label if supplied
                    if isfield(frame, 'ylabel') && ~isempty(frame.ylabel)
                        ylh = ylabel(h(p), frame.ylabel, FontSize=12, FontWeight='bold');
                        set(ylh, 'Visible', 'on'); % Ensure the label is visible
                        % Adjust the position of the ylabel if necessary
                        set(ylh, 'Position', [-0.11, 0.5], 'Units', 'Normalized');
                    end
                    
                    statedata   = frame.statedata;
                    injcells    = frame.injcells;
                    G           = frame.G;
                    if isfield(frame, 'cells')
                        cells = frame.cells;
                    else
                        cells = 1:G.cells.num;
                    end
    
                    plotCellData(G, statedata, cells, 'edgealpha', 0);
                    injcells = intersect(injcells, find(cells));
                    plotGrid(G, injcells, 'facecolor', 'red');
                    if opt.plotgrid || (isfield(frame, 'plotgrid') && frame.plotGrid)
                        plotGrid(G, cells, 'facealpha', 0);
                    end
                    if G.griddim == 3 %change view if on 3D grid
                        view(0,0);
                    end
                    % xticks([]);
                    % yticks([]);
                    % zticks([]);
                    if opt.tight
                        axis tight;
                    end
                    if opt.equal
                        axis equal
                    end
                    if ~isempty(opt.cmap) && ~(opt.diff && j<=i)
                        colormap(h(p), opt.cmap)
                    end
                    if ~(opt.diff && j == i)
                        clim(h(p), [minV maxV]);%comparable colors on all plots
                    elseif opt.diff && j == i
                        clim(h(p), [diagminV, diagmaxV]);
                    end
    
                else
                    % delete(ax);
                end
            end

        end
    end
    if opt.colorbar
        cb = colorbar(h(2));
        cb.Layout.Tile = 'east';
        if ~isempty(opt.cblabel)
            ylabel(cb, opt.cblabel);
        end
        if opt.diff
            cb = colorbar(h(1));
            cb.Layout.Tile = 'east';
        end
    end
    if opt.saveplot
        if ~exist(opt.savefolder, 'dir')
            mkdir(opt.savefolder)
            disp(['Folder ', opt.savefolder, ' created.']);
        end
        savepath = fullfile(opt.savefolder, opt.savename);
        savepath = replace(savepath, '.', '_');
        saveas(f, savepath, 'png');
        % exportgraphics(f, strcat(savepath, '.eps'));
    end
end