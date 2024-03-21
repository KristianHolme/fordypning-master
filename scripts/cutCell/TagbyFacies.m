function G = TagbyFacies(G, geodata, varargin)
%use inpolygon to find facies of each cell
    opt = struct('verbose', false, ...
                 'vertIx', 2, ...
                 'scale', [1, 1, 1]);
    opt = merge_options(opt, varargin{:});
    vertIx = opt.vertIx;
    tic()
    G.cells.tag = zeros(G.cells.num, 1);
    for ifacies = 1:7
        loops = geodata.Facies{ifacies};
        numLoops = numel(loops);
        for iLoop = 1:numLoops
            loop = loops(iLoop);
            pointsinds = cell2mat(geodata.Line(abs(geodata.Loop{loop})));
            pointsinds = unique(pointsinds(:), "stable");
            points = geodata.Point(pointsinds);
            points = cell2mat(points(:));
            points = points .* opt.scale;
            centroidxs = G.cells.centroids(:,1);
            centroidys = G.cells.centroids(:,vertIx);
            polyxs = points(:,1);
            polyys = points(:, vertIx);
            in = inpolygon(centroidxs, centroidys, polyxs, polyys);
            G.cells.tag(in) = ifacies;
        end
    end
    t = toc();
    dispif(opt.verbose, "Tagging facies done in %0.2f s\n", t);
end
