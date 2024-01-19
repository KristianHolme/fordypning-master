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
    if all(dir == [0 1 0])
        %we are in B and n xz-plane
        vertIx = 3;
    else
        vertIx = 2;
    end

    dispif(opt.verbose, "Presplitting grid the old way.\nEstimated time: %0.2f s\n", 0.004*prod(G.cartDims));
    tic();
    eps = 1e-10; %to make sure points are not inside cell. Maybe not necessary
    epsfactor = 0.01;
    numpoints = numel(points);
    if opt.waitbar
        f = waitbar(0, 'Starting');
    end
    
    for ipoint = 1:numpoints
        if opt.waitbar
            waitbar(ipoint/numpoints, f, sprintf('Splitting progress: %d %%. (%d/%d).', floor(ipoint/numpoints*100), ipoint, numpoints))
        end
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

        upvector = [0 0 0];
        upvector(vertIx) = 1;
        sidefaces = dot(faceNormals, repmat(upvector, numel(faces), 1), 2) == 0;
        topbotfaces = find(~sidefaces);
        sidefaces = find(sidefaces);

        [faceymax, faceymaxIx] = max(faceCentroids(topbotfaces, vertIx));
        [faceymin, faceyminIx] = min(faceCentroids(topbotfaces, vertIx));
        [facexmax, facexmaxIx] = max(faceCentroids(sidefaces, 1));
        [facexmin, facexminIx] = min(faceCentroids(sidefaces, 1));

        faceymaxIx = topbotfaces(faceymaxIx);
        faceyminIx = topbotfaces(faceyminIx);
        facexmaxIx = sidefaces(facexmaxIx);
        facexminIx = sidefaces(facexminIx);
        
        offsetup = abs( dot(point-faceCentroids(faceymaxIx, :), faceNormals(faceymaxIx,:)/faceAreas(faceymaxIx)) );
        offsetdown = abs( dot(point-faceCentroids(faceyminIx, :), faceNormals(faceyminIx,:)/faceAreas(faceyminIx)) );
        % offsetdown = faceCentroids(faceymaxIx, vertIx) - faceCentroids(faceyminIx, vertIx) - offsetup;
        [ydist, closestydir] = min([offsetup, offsetdown]);
        xdist = min(facexmax - point(1), point(1)-facexmin);
        [dist, splitdir] = min([xdist, ydist]);
        if dist ~= 0
            dispif(opt.verbose, "point %d\n", ipoint);
            %Split cell
            if splitdir == 1
                eps = (facexmax - facexmin)*epsfactor;
                offset = point(vertIx) - interp1([facexmin, facexmax], ...
                [faceCentroids(facexminIx, vertIx), faceCentroids(facexmaxIx, vertIx)], ...
                point(1), 'linear');
                if closestydir == 1
                    closestnormal = faceNormals(faceymaxIx,:);
                else
                    closestnormal = faceNormals(faceyminIx,:);
                end
                closestnormal = closestnormal*sign(closestnormal(vertIx));
                slope = closestnormal(1)/closestnormal(vertIx);
                splitpoints = [facexmin-eps 0 0; 
                               facexmax+eps 0 0];
                splitpoints(:, vertIx) = [point(vertIx) + (point(1)-facexmin)*slope; point(vertIx) - (facexmax - point(1))*slope];
                % splitpoints(:, vertIx) = [faceCentroids(facexminIx, vertIx) + offset;faceCentroids(facexmaxIx, vertIx) + offset];
            elseif splitdir == 2
                eps = (faceymax - faceymin)*epsfactor;
                splitpoints = [point(1), 0, 0; 
                               point(1), 0, 0];
                splitpoints(:, vertIx) = [point(vertIx)-offsetdown-eps;point(vertIx)+offsetup+eps];
            end
            % clf;
            % plotGrid(G, [cell; getCellNeighbors(G, cell)]);
            % hold on;plot3(splitpoints(:,1), splitpoints(:,2), splitpoints(:,3));
            % plot3(point(1), point(2), point(3), 'ro');
            G = sliceGrid(G, splitpoints, 'cutDir', dir);
            % plotGrid(G, [cell; getCellNeighbors(G, cell)]);
        end
    end
    if opt.waitbar
        close(f);
    end
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