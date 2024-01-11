function G = TagbyFacies(G, geodata)
%use inpolygon to find facies of each cell
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
            centroidxs = G.cells.centroids(:,1);
            centroidys = G.cells.centroids(:,2);
            polyxs = points(:,1);
            polyys = points(:, 2);
            in = inpolygon(centroidxs, centroidys, polyxs, polyys);
            G.cells.tag(in) = ifacies;
        end
    end
    t = toc();
end