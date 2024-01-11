function [Gcut, t] = CutCellGeo(G, geodata, varargin)
%cuts grid by using sliceGrid. one slice for each line segment. Slow.
    opt = struct('dir', [0 0 1], ...
                 'verbose', false, ...
                 'save', true, ...
                 'savedir', 'grid-files\cutcell');
    opt = merge_options(opt, varargin{:});
    dir = opt.dir;
    dispif(opt.verbose, "Main splitting...\n");
    tic();
    numlines = numel(geodata.Line);
    pp = {};
    Gcut = G;
    for iline = 1:numlines
        if ismember(iline, geodata.BoundaryLines)%skip boundarylines
            continue
        end
        line = geodata.Line{iline};
        points = geodata.Point(line);
        points = cell2mat(points(:));    
        pp{end+1} = points;
    end
    dd = repmat({dir}, 1, numel(pp));
    Gcut = sliceGrid(Gcut, pp, 'cutDir', dd);
    t = toc();
    Gcut = TagbyFacies(Gcut, geodata);%Tag facies
    dispif(opt.verbose, sprintf("Done in %0.2f s\n", t));
    if opt.save
        nx = G.cartDims(1);
        ny = G.cartDims(2);
        fn = sprintf('cutcell_%dx%d.mat', nx, ny);
        G = Gcut;
        save(fullfile(opt.savedir, fn), "G");
    end
end
