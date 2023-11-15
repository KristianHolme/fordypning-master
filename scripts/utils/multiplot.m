function multiplot(data, varargin)
    opt = struct('saveplot' , false, ...
                 'title'    , [], ...
                 'tight'    , true, ...
                 'equal'     , true, ...
                 'savefolder', [], ...
                 'savename'  , [], ...
                 'colorbar'  , true, ...
                 'cblabel'   , [], ...
                 'cmap'      , []);
    opt = merge_options(opt, varargin{:});

     % Get the screen size
    screenSize = get(0, 'ScreenSize');
    [numRows, numCols] = size(data);

    
    % Calculate the desired figure size (e.g., full screen or a fraction of it)
    figWidth = screenSize(3) * min(0.8*numCols/3, 0.80); % 80% of the screen width
    figHeight = screenSize(4) * min(0.81*numRows/4, 0.80); % 80% of the screen height
    
    % Create a figure with the desired size
    f = figure('Position', [screenSize(3)*0.05 screenSize(4)*0.05 figWidth figHeight]);
    t = tiledlayout(numRows, numCols, 'Padding', 'compact', 'TileSpacing', 'compact');
    if ~isempty(opt.title)
        title(t, opt.title)
    end

    for i = 1:numRows

        for j = 1:numCols
            frame = data{i, j};
            p = (i-1)*numCols + j;
            ax = nexttile(p);
            
            if ~isempty(frame)
                % Add title if supplied
                if isfield(frame, 'title') && ~isempty(frame.title)
                    title(frame.title);
                end

                % Add y-label if supplied
                if isfield(frame, 'ylabel') && ~isempty(frame.ylabel)
                    ylh = ylabel(ax, frame.ylabel, FontSize=12, FontWeight='bold');
                    set(ylh, 'Visible', 'on'); % Ensure the label is visible
                    % Adjust the position of the ylabel if necessary
                    set(ylh, 'Position', [-0.11, 0.5], 'Units', 'Normalized');
                end
                
                statedata   = frame.statedata;
                injcells    = frame.injcells;
                G           = frame.G;
                
                plotCellData(G, statedata, 'edgealpha', 0);
                plotGrid(G, injcells, 'facecolor', 'red');
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
                if ~isempty(opt.cmap)
                    colormap(ax, opt.cmap)
                end
                clim(ax, [0 1]);%comparable colors on all plots

            else
                delete(ax);
            end

        end
    end
    if opt.colorbar
        cb = colorbar;
        cb.Layout.Tile = 'east';
        if ~isempty(opt.cblabel)
            ylabel(cb, opt.cblabel);
        end
    end
    if opt.saveplot
        savepath = fullfile(opt.savefolder, opt.savename);
        savepath = replace(savepath, '.', '_');
        saveas(f, savepath, 'png');
        % exportgraphics(f, strcat(savepath, '.eps'));
    end
end