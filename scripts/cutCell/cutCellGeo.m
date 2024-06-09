function [Gcut, t] = cutCellGeo(G, geodata, varargin)
%cuts grid by using sliceGrid. one slice for each line segment. Slow.
    opt = struct('dir', [0 0 1], ...
                 'verbose', false, ...
                 'save', true, ...
                 'savedir', 'grid-files/cutcell', ...
                 'presplit', true, ...
                 'bufferVolumeSlice', false, ...
                 'extendSliceFactor', 0.0, ...
                 'type', 'cartesian', ...
                 'vertIx', 2, ...
                 'nudgeGeom', false, ...
                 'SPEcase', 'B');
    [opt, extra] = merge_options(opt, varargin{:});
    if ~isfield(G, 'minOrgVol')
        G.minOrgVol = min(G.cells.volumes);
        G.maxOrgVol = max(G.cells.volumes);
    end
    dir = opt.dir;
    dispif(opt.verbose, "Main splitting...\n");
    tic();
    numlines = numel(geodata.Line);
    pp = {};
    Gcut = G;
    isCut = false(1, numlines);
    for iline = 1:numlines
        if isCut(iline)
            continue
        elseif ismember(iline, geodata.BoundaryLines)%skip boundarylines
            continue
        elseif isfield(geodata, 'includeLines') && ~ismember(iline, geodata.includeLines)
            continue
        else
            isCut(iline) = true;
        end
        line = geodata.Line{iline};
        points = geodata.Point(line);
        points = cell2mat(points(:));
        for i=1:2
            vec =  points(i, :) - points(end+1-i, :);
            vec = vec/norm(vec);
            points(i,:) = points(i,:) + opt.extendSliceFactor* vec;
        end
        % numpts = 1;
        % lambdas = (0:numpts)' / numpts;
        % pts = cell2mat(arrayfun(@(l)points(1,:)*(1-l) + points(2,:)*l, lambdas, UniformOutput=false));
        % cellsInLine = findEnclosingCell(Gcut, pts);
        % cellsInLine = unique(cellsInLine);
        % plotGrid(G, cellsInLine);view(0,0);hold on;
        % plot3(points(:,1), points(:,2), points(:,3), 'r-o');
        % fprintf('Line %d/%d\n', iline, numlines)
        try
            [Gcut, gix] = sliceGrid(Gcut, points, 'cutDir', dir, extra{:});
        catch
            warning('sliceGrid failed slicing line %d', iline);
        end

        pp{end+1} = points;
    end
    dd = repmat({dir}, 1, numel(pp));
    % Gcut = sliceGrid(Gcut, pp, 'cutDir', dd, extra{:});
    t = toc();
    dispif(opt.verbose, sprintf("Done in %0.2f s\n", t));
    
    Gcut = tagbyFacies(Gcut, geodata, 'verbose', opt.verbose, 'vertIx', opt.vertIx);%Tag facies
    Gcut = getBufferCells(Gcut); %find buffercells
    
    if opt.save
        nx = G.cartDims(1);
        ny = G.cartDims(opt.vertIx);
        fn = sprintf('%s_cutcell_%dx%d_%s.mat', opt.type, nx, ny, opt.SPEcase);
        if opt.nudgeGeom
            fn = sprintf('%s_nudge_cutcell_%dx%d.mat', opt.type, nx, ny);
        end
        if opt.presplit
            fn = sprintf('%s_presplit_cutcell_%dx%d.mat', opt.type, nx, ny);
        end
        if opt.bufferVolumeSlice
            fn = ['buff_', fn];
        end
        G = Gcut;
        save(fullfile(opt.savedir, fn), "G");
    end
end
