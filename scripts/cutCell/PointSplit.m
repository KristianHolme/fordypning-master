function [G, t] = PointSplit(G, points, varargin)
% Splits grid at given points, in order to circumvent that sliceGrid cant
% handle curves changing direction inside an element
% Performs one call to sliceGrid per point, so can be slow for large
% grids/many points
    opt = struct('dir', [0 0 1], ...
        'verbose', false, ...
        'waitbar', true, ...
        'save', false, ...
        'savedir', 'grid-files/cutcell/presplit', ...
        'bufferVolumeSlice', false);
    opt = merge_options(opt, varargin{:});

    dispif(opt.verbose, "Presplitting grid the old way.\nEstimated time: %0.2f s\n", 0.004*prod(G.cartDims));
    tic();
    eps = 1e-10; %to make sure points are not inside cell. Maybe not necessary
    numpoints = numel(points);
    f = waitbar(0, 'Starting');
    dir = opt.dir;
    for ipoint = 1:numpoints
        waitbar(ipoint/numpoints, f, sprintf('Splitting progress: %d %%. (%d/%d).', floor(ipoint/numpoints*100), ipoint, numpoints))
        point = points{ipoint};
        cell = findEnclosingCell(G, point);
        if cell == 0
            if ipoint == numpoints
                break
            else
                continue
            end
        end
        faceCentroids = G.faces.centroids(G.cells.faces(G.cells.facePos(cell):G.cells.facePos(cell+1)-1), :);
        faceymax = max(faceCentroids(:, 2));
        faceymin = min(faceCentroids(:, 2));
        facexmax = max(faceCentroids(:, 1));
        facexmin = min(faceCentroids(:, 1));
    
        ydist = min(faceymax - point(2), point(2)-faceymin);
        xdist = min(facexmax - point(1), point(1)-facexmin);
        [dist, splitdir] = min([xdist, ydist]);
        if dist ~= 0
            %Split cell
            if splitdir == 1
                splitpoints = [facexmin-eps point(2) 0; 
                               facexmax+eps point(2) 0];
            elseif splitdir == 2
                splitpoints = [point(1) faceymin-eps 0; 
                               point(1) faceymax+eps 0];
            end
            G = sliceGrid(G, splitpoints, 'cutDir', dir);
        end
    end
    close(f);
    t = toc();
    dispif(opt.verbose, sprintf("Done in %0.2f s\n", t));
    G.type{end+1} = 'PointSplit';
    if opt.save
        nx = G.cartDims(1);
        ny = G.cartDims(2);
        fn = sprintf('presplit_%dx%d.mat', nx, ny);
        if opt.bufferVolumeSlice
            fn = ['buff_', fn];
        end
        savepth = fullfile(opt.savedir, fn);
        save(savepth, 'G');
    end
end