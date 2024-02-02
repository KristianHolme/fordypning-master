function [Gcut, t] = CutCellGeo(G, geodata, varargin)
%cuts grid by using sliceGrid. one slice for each line segment. Slow.
    opt = struct('dir', [0 0 1], ...
                 'verbose', false, ...
                 'save', true, ...
                 'savedir', 'grid-files/cutcell', ...
                 'presplit', true, ...
                 'bufferVolumeSlice', false, ...
                 'extendSliceFactor', 0.0, ...
                 'type', 'cartesian', ...
                 'vertIx', 2);
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
        % [Gcut, gix] = sliceGrid(Gcut, points, 'cutDir', dir, extra{:});

        pp{end+1} = points;
    end
    dd = repmat({dir}, 1, numel(pp));
    Gcut = sliceGrid(Gcut, pp, 'cutDir', dd);
    t = toc();
    dispif(opt.verbose, sprintf("Done in %0.2f s\n", t));
    
    Gcut = TagbyFacies(Gcut, geodata, 'verbose', opt.verbose, 'vertIx', opt.vertIx);%Tag facies
    Gcut = getBufferCells(Gcut); %find buffercells
    
    if opt.save
        nx = G.cartDims(1);
        ny = G.cartDims(opt.vertIx);
        fn = sprintf('%s_cutcell_%dx%d.mat', opt.type, nx, ny);
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
