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
    
    dir = opt.dir;
    if dir == [0 1 0]
        %we are in B and n xz-plane
        vertIx = 3;
    else
        vertIx = 2;
    end

    dispif(opt.verbose, "Presplitting grid the old way.\nEstimated time: %0.2f s\n", 0.004*prod(G.cartDims));
    tic();
    eps = 1e-10; %to make sure points are not inside cell. Maybe not necessary
    numpoints = numel(points);
    f = waitbar(0, 'Starting');
    
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
        faces = G.cells.faces(G.cells.facePos(cell):G.cells.facePos(cell+1)-1);
        faceCentroids = G.faces.centroids(faces, :);
        faceNormals = G.faces.normals(faces, :);
        faceAreas = G.faces.areas(faces,:);
        [faceymax, faceymaxIx] = max(faceCentroids(:, vertIx));
        [faceymin, faceyminIx] = min(faceCentroids(:, vertIx));
        [facexmax, facexmaxIx] = max(faceCentroids(:, 1));
        [facexmin, facexminIx] = min(faceCentroids(:, 1));
        
    
        
        offsetup = abs( dot(point-faceCentroids(faceymaxIx, vertIx), faceNormals(faceymaxIx,:)/faceAreas(faceymaxIx)) );
                offsetdown = faceCentroids(faceymaxIx, vertIx) - faceCentroids(faceyminIx, vertIx) - offsetup;
        ydist = min(offsetup, offsetdown);
        xdist = min(facexmax - point(1), point(1)-facexmin);
        [dist, splitdir] = min([xdist, ydist]);
        if dist ~= 0
            %Split cell
            if splitdir == 1
                offset = point(vertIx) - interp1([facexmin, facexmax], ...
                [faceCentroids(facexminIx, vertIx), faceCentroids(facexmaxIx, vertIx)], ...
                point(1), 'linear');
                splitpoints = [facexmin-eps 0 0; 
                               facexmax+eps 0 0];
                splitpoints(:, vertIx) = [faceCentroids(facexminIx, vertIx) + offset;faceCentroids(facexmaxIx, vertIx) + offset];
            elseif splitdir == 2
                splitpoints = [point(1), 0, 0; 
                               point(1), 0, 0];
                splitpoints(:, vertIx) = [point(vertIx)-offsetdown-eps;point(vertIx)+offsetup+eps];
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
        ny = G.cartDims(vertIx);
        fn = sprintf('presplit_%dx%d.mat', nx, ny);
        if opt.bufferVolumeSlice
            fn = ['buff_', fn];
        end
        savepth = fullfile(opt.savedir, fn);
        save(savepth, 'G');
    end
end