function [G, partition] = generateCutCellGrid(nx, ny, varargin)
    opt = struct('save', true, ...
        'savedir', 'data/grid-files/cutcell', ...
        'verbose', true, ...
        'waitbar', false, ...
        'cut', true,...
        'presplit', false, ...
        'recombine', true, ...
        'bufferVolumeSlice', true, ...
        'type', 'horizon', ...
        'removeInactive', false, ...
        'partitionMethod', 'convexity', ...
        'round', true,...
        'SPEcase', 'B', ...
        'Cdepth', 50);
    [opt, extra] = merge_options(opt, varargin{:});
    opt.nudgeGeom = ~opt.presplit;
    totstart = tic();
    switch opt.type
        case 'cartesian'
            [G, geodata] = makeCartesianCut(nx, ny, opt, extra);
        case 'horizon'
            [G, geodata] = makeHorizonCut(nx, ny, opt, extra);
    end
    if opt.removeInactive
        G = removeCells(G, G.cells.tag == 7); %remove here, RemoveCells doesnt work on CG
        keepCells = G.cells.tag ~= 7;
        G.cells.tag = G.cells.tag(keepCells);
        if isfield(G,'bufferCells')
            G = getBufferCells(G);
        end
        G.cells.indexMap = (1:G.cells.num)';
    end
    if opt.recombine
        [G, partition] = Recombine(G, opt, nx, ny, geodata);
    end    

    assert(checkGrid(G));
    ttot = toc(totstart);
    dispif(opt.verbose, sprintf('Generated cut-cell grid in %f s\n', round(ttot,2)));
end

function [G, geodata] = makeCartesianCut(nx, ny, opt, extra)
    configFile = fileread('config.JSON');
    config = jsondecode(configFile);
    fn = fullfile(config.geo_folder, 'spe11a.geo');
    %fn = 'C:\Users\holme\Documents\Prosjekt\Prosjektoppgave\src\11thSPE-CSP\geometries\spe11a.geo';
    geodata = readGeo(fn, 'assignExtra', true); 


    Lx = 2.8;
    Ly = 1.2;
    G = cartGrid([nx ny 1], [Lx, Ly 0.01]);
    G = computeGeometry(G);
    if ~strcmp(opt.SPEcase, 'A')
        geodata = stretchGeo(rotateGrid(geodata));
        G = stretchGrid(rotateGrid(G));
        depthIx = 2;
        dir = [0 1 0];
    else
        depthIx = 3;
        dir = [0 0 1];
    end
    vertIx = 5-depthIx;
    if opt.nudgeGeom
        if opt.round %&& false
            dispif(opt.verbose, 'Rounding grid points before nudging...\n')
            roundprecision = 10;
            G.nodes.coords = round(G.nodes.coords, roundprecision);
            G = computeGeometry(G);
        end
        cellpoints = geodata.Point;
        points = vertcat(cellpoints{:});
        numPoints = size(points, 1);
        targetpoints = G.nodes.coords(G.nodes.coords(:,depthIx)==0,:);
        if strcmp(opt.SPEcase, 'C')
            newPointsPerFace = 10;
            targetpoints = expandTargetPoints(G, targetpoints, depthIx, newPointsPerFace);
        end
        [points, ~, ~] = nudgePoints(targetpoints, points, extra{:});
        cellpoints = mat2cell(points, ones(numPoints, 1), 3);
        geodata.Point = cellpoints;
        assert(opt.presplit == false, 'nudge and presplitting should not both be enabled!')
    end

    if opt.bufferVolumeSlice
        %slicing close to sides to create buffer volume cells
        if strcmp(opt.SPEcase, 'A')
            G = sliceGrid(G, {[0.000333333333, 0.5, 0], [2.79966666666, 0.5, 0]}, 'normal', [1 0 0]);
            G = tagbyFacies(G, geodata);
            G = getBufferCells(G);
        else
            G = sliceGrid(G, {[1, 0.5, 0], [8399, 0.5, 0]}, 'normal', [1 0 0]);
            G = tagbyFacies(G, geodata, 'vertIx', 3);
            G = getBufferCells(G);
        end

    end
     
    if opt.presplit
        G = pointSplit(G, geodata.Point, 'verbose', opt.verbose, 'waitbar', opt.waitbar, ...
            'save', opt.save, 'savedir', fullfile(opt.savedir, 'presplit'), ...
            'bufferVolumeSlice', opt.bufferVolumeSlice, ...
            'SPEcase', opt.SPEcase, ...
            'dir', dir);
    end
    if opt.cut %option to not cut, to return presplit grid if wanted
        G = cutCellGeo(G, geodata, 'verbose', opt.verbose, ...
            'save', opt.save, ...
            'savedir', opt.savedir, ...
            'presplit', opt.presplit, ...
            'bufferVolumeSlice', opt.bufferVolumeSlice, ...
            'nudgeGeom', opt.nudgeGeom, ...
            'SPEcase', opt.SPEcase, ...
            'dir', dir, ...
            'vertIx', vertIx);
    end
end

function [G, geodata] = makeHorizonCut(nx, totys, opt, extra)
    geodata = readGeo('./data/geo-files/spe11a-faults.geo', 'assignExtra', true);
    geodata = rotateGrid(geodata);
    geodata = stretchGeo(geodata);
    % gridfractions = [0.1198 0.0612 0.0710 0.0783 0.1051 0.0991 0.1255 0.1663 0.1737]; 
    gridfractions = [0.1106, 0.0566, 0.0660, 0.0726, 0.0971, 0.0923, 0.1157, 0.1539, 0.1599, 0.0752]; %scaled by region size
    nys = max(round(totys*gridfractions), 1);
    dispif(opt.verbose, 'Constructing background grid...\n')
    G = makeHorizonGrid(nx, nys, 'save', false);
   
    if opt.nudgeGeom
        nudgeGridLimit = 1;
        if sum(nys)<nudgeGridLimit%too few points to get good nudging
            mult = nudgeGridLimit / sum(nys);
            newnys = round(nys*mult);
            Gnudge = makeHorizonGrid(nx, newnys);
        else
            Gnudge = G;         
        end
        if opt.round %&& false
            dispif(opt.verbose, 'Rounding grid points before nudging...\n')
            roundprecision = 10;
            G.nodes.coords = round(G.nodes.coords, roundprecision);
            Gnudge.nodes.coords = round(Gnudge.nodes.coords, roundprecision);
            G = computeGeometry(G);
            Gnudge = computeGeometry(Gnudge);
        end
        inds = arrayfun(@(curve)curveToPoints(curve, geodata,'indices', true), geodata.includeLines, UniformOutput=false);
        inds = unique(vertcat(inds{:}));
        cellpoints = geodata.Point;
        points = vertcat(cellpoints{:});
        numPoints = size(points, 1);
        targetpoints = Gnudge.nodes.coords(Gnudge.nodes.coords(:,2)==0,:);
        % 
        if strcmp(opt.SPEcase, 'C')
            newPointsPerFace = 10;
            targetpoints = expandTargetPoints(G, targetpoints, 2, newPointsPerFace);
        end
        [points(inds,:), ~, ~] = nudgePoints(targetpoints, points(inds,:), extra{:});
        cellpoints = mat2cell(points, ones(numPoints, 1), 3);
        geodata.Point = cellpoints;
        if opt.presplit == true
            warning('nudge and presplitting should not both be enabled!')
        end
    end

    if opt.bufferVolumeSlice
        dispif(opt.verbose, 'Slicing to get buffer cells...\n')
        %slicing close to sides to create buffer volume cells
        G = sliceGrid(G, {[1, 0.5, 0], [8399, 0.5, 0]}, 'normal', [1 0 0]);
        G = tagbyFacies(G, geodata, 'vertIx', 3);
        G = getBufferCells(G);
    end
    
    if opt.presplit
        % Presplit fault points
        cellpoints = arrayfun(@(curve)curveToPoints(curve, geodata), geodata.includeLines, UniformOutput=false);
        points = unique(vertcat(cellpoints{:}), 'rows');
        numPoints = size(points, 1);
        cellpoints = mat2cell(points, ones(numPoints, 1), 3);
        
        G = pointSplit(G, cellpoints, 'dir', [0 1 0], 'verbose', opt.verbose, 'waitbar', false, ...
            'save', opt.save, 'type', opt.type);
    end
    % Cut
    if opt.cut
        G = cutCellGeo(G, geodata, 'dir', [0 1 0], 'verbose', opt.verbose, ...
            'extendSliceFactor', 0.0, ...
            'topoSplit', true, 'save', opt.save, ...
            'type', opt.type, ...
            'bufferVolumeSlice', opt.bufferVolumeSlice, ...
            'vertIx', 3, ...
            'presplit', opt.presplit, ...
            'nudgeGeom', opt.nudgeGeom, ...
            'SPEcase', opt.SPEcase);
    end
end

function [G, partition] = Recombine(G, opt, nx, ny, geodata)
    if max(G.nodes.coords(:,2)) > 1.1
        vertIx = 2;
    else
        vertIx = 3;
    end

    t = tic();
    [partition, failed, tries] = PartitionByTag(G, 'method', opt.partitionMethod, ...
            'avoidBufferCells', opt.bufferVolumeSlice);
    G = makePartitionedGrid(G, partition);
    G = tagbyFacies(G, geodata, 'vertIx', vertIx);

    t = toc(t);
    dispif(opt.verbose, "Partition(%d iterations) and coarsen in %0.2f s\n%d cells failed to merge.\n", tries, t, numel(failed));

    if strcmp(opt.SPEcase, 'C')
        G = removeLayeredGrid(G);
        layerthicknesses = [1; repmat(4998/opt.Cdepth, opt.Cdepth,1); 1];%one meter thickness for buffer volume in front and back
        G = makeLayeredGrid(G, layerthicknesses);
        G = mcomputeGeometry(G);
        G = rotateGrid(G);
        G = mcomputeGeometry(G);
        G = tagbyFacies(G, geodata, 'vertIx', vertIx);
        G.nodes.coords = bendSPE11C(G.nodes.coords);
        G = mcomputeGeometry(G);
        G = getBufferCells(G);
    end

    t = tic();
    dispif(opt.verbose, "Adding injection cells and box-volume-fractions...");
    G = addBoxWeights(G, 'SPEcase', opt.SPEcase);
    [w1, w2] = getinjcells(G, opt.SPEcase);
    if strcmp(opt.SPEcase, 'C')
        G.cells.wellCells = {w1, w2};
    else
        G.cells.wellCells = [w1, w2];
    end
    t = toc(t);
    dispif(opt.verbose, "Done in %0.2d s.\n", t);

    
    if opt.save
        if strcmp(opt.SPEcase, 'C')
            fn = sprintf('%dx%dx%d_%s.mat', nx, opt.Cdepth, ny, opt.SPEcase);
        else
            fn = sprintf('%dx%d_%s.mat', nx, ny, opt.SPEcase);
        end
        if strcmp(opt.partitionMethod, 'facearea')
            fn = ['cutcell_FPG_', fn];
        elseif strcmp(opt.partitionMethod, 'convexity')
            fn = ['cutcell_PG_', fn];
        end
        if opt.presplit
            fn = ['presplit_', fn];
            % fn = sprintf('%s_presplit_cutcell_PG_%dx%d.mat', opt.type, nx, ny);
        end
        if opt.nudgeGeom
            fn = ['nudge_', fn];
            % fn = sprintf('%s_nudge_cutcell_PG_%dx%d.mat', opt.type, nx, ny);
        end
        fn = [opt.type, '_', fn];
        if opt.bufferVolumeSlice
            fn = ['buff_', fn];
        end
        savepath = fullfile(opt.savedir, fn);
        dispif(opt.verbose, sprintf('Saving to %s\n', savepath));
        save(savepath, "G");
    end
end

function targetPoints = expandTargetPoints(G, targetPoints, depthIx, np)
%np = number of new points per edge
tol = 1e-6;
upvec = [0;0;0];
upvec(depthIx) = 1;
lambda = linspace(0,1,np+2);
lambda = lambda(2:end-1);
backNodes = G.nodes.coords(:,depthIx)>0.007;
faceNodes = G.faces.nodes;
faceNodePos = G.faces.nodePos;
[faceNodes, faceNodePos] = removeFromPackedData(faceNodePos, faceNodes, backNodes);
sidefaces = G.faces.normals * upvec < tol;
numNodes = diff(faceNodePos);
assert(all(numNodes(sidefaces==2)));
nodes1 = faceNodes(faceNodePos(sidefaces));
nodes2 = faceNodes(faceNodePos(sidefaces)+1);
ndPts1 = G.nodes.coords(nodes1,:);
ndPts2 = G.nodes.coords(nodes2,:);

numSideFaces = sum(sidefaces);
totNewPoints = np*numSideFaces;
newPoints = zeros(totNewPoints,3);
for i = 1:np
    newPoints((i-1)*numSideFaces+1:i*numSideFaces,:) = ndPts1*lambda(i) + ndPts2*(1-lambda(i));
end

targetPoints = [targetPoints;newPoints];

end