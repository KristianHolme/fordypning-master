function G = GenerateCutCellGrid(nx, ny, varargin)
    opt = struct('save', true, ...
        'savedir', 'grid-files/cutcell', ...
        'verbose', false, ...
        'waitbar', false, ...
        'presplit', true, ...
        'recombine', true, ...
        'bufferVolumeSlice', true, ...
        'type', 'cartesian', ...
        'removeInactive', true, ...
        'partitionMethod', 'convexity');
    opt = merge_options(opt, varargin{:});

    switch opt.type
        case 'cartesian'
            G = makeCartesianCut(nx, ny, opt);
            
        case 'horizon'
            G = makeHorizonCut(nx, ny, opt);
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
        G = Recombine(G, opt, nx, ny);
    end

    assert(checkGrid(G));
end

function G = makeCartesianCut(nx, ny, opt)
    configFile = fileread('config.JSON');
    config = jsondecode(configFile);
    fn = fullfile(config.geo_folder, 'spe11a.geo');
    %fn = 'C:\Users\holme\Documents\Prosjekt\Prosjektoppgave\src\11thSPE-CSP\geometries\spe11a.geo';
    geodata = readGeo(fn, 'assignExtra', true); 

    Lx = 2.8;
    Ly = 1.2;
    G = cartGrid([nx ny 1], [Lx, Ly 0.01]);
    G = computeGeometry(G);       

    if opt.bufferVolumeSlice
        %slicing close to sides to create buffer volume cells
        G = sliceGrid(G, {[0.000333333333, 0.5, 0], [2.79966666666, 0.5, 0]}, 'normal', [1 0 0]);
        G = TagbyFacies(G, geodata);
        G = getBufferCells(G);
    end
    if opt.presplit
        G = PointSplit(G, geodata.Point, 'verbose', opt.verbose, 'waitbar', opt.waitbar, ...
            'save', opt.save, 'savedir', fullfile(opt.savedir, 'presplit'), 'bufferVolumeSlice', opt.bufferVolumeSlice);
    end
    G = CutCellGeo(G, geodata, 'verbose', opt.verbose, 'save', opt.save, 'savedir', opt.savedir, ...
        'presplit', opt.presplit, 'bufferVolumeSlice', opt.bufferVolumeSlice);

end

function Gcut = makeHorizonCut(nx, totys, opt)
    geodata = readGeo('./scripts/cutCell/geo/spe11a-faults.geo', 'assignExtra', true);
    geodata = RotateGrid(geodata);
    geodata = StretchGeo(geodata);
    gridfractions = [0.1198 0.0612 0.0710 0.0783 0.1051 0.0991 0.1255 0.1663 0.1737]; %scaled by region size

    nys = max(round(totys*gridfractions), 1);
    
    G = makeHorizonGrid(nx, nys, 'save', false);
    if opt.bufferVolumeSlice
        %slicing close to sides to create buffer volume cells
        G = sliceGrid(G, {[1, 0.5, 0], [8399, 0.5, 0]}, 'normal', [1 0 0]);
        G = TagbyFacies(G, geodata, 'vertIx', 3);
        G = getBufferCells(G);
    end
    
    if opt.presplit
        % Presplit fault points
        cellpoints = arrayfun(@(curve)curveToPoints(curve, geodata), geodata.includeLines, UniformOutput=false);
        points = unique(vertcat(cellpoints{:}), 'rows');
        numPoints = size(points, 1);
        cellpoints = mat2cell(points, ones(numPoints, 1), 3);
        
        Gpre = PointSplit(G, cellpoints, 'dir', [0 1 0], 'verbose', opt.verbose, 'waitbar', false, ...
            'save', opt.save, 'type', opt.type);
    end
    % Cut
    Gcut = CutCellGeo(Gpre, geodata, 'dir', [0 1 0], 'verbose', opt.verbose, ...
        'extendSliceFactor', 0.0, ...
        'topoSplit', true, 'save', opt.save, ...
        'type', opt.type, ...
        'bufferVolumeSlice', opt.bufferVolumeSlice, ...
        'vertIx', 3);
end

function G = Recombine(G, opt, nx, ny)
    if max(G.nodes.coords(:,2)) > 1.1
        vertIx = 2;
    else
        vertIx = 3;
    end
    if max(G.nodes.coords(:,1))>1000
        Bscale = true;
    else
        Bscale = false;
    end
    geodata = readGeo('~/Code/prosjekt-master/src/scripts/cutCell/geo/spe11a-faults.geo', 'assignExtra', true);
    if Bscale
        geodata = RotateGrid(geodata);
        geodata = StretchGeo(geodata);
    end
    t = tic();
    [partition, failed] = PartitionByTag(G, 'method', opt.partitionMethod, ...
            'avoidBufferCells', opt.bufferVolumeSlice);

    partitionIterations = 0;
    maxPartitionIterations = 5;
    while max(partition) < G.cells.num && partitionIterations <= maxPartitionIterations
        partitionIterations = partitionIterations +1;

        Gp = makePartitionedGrid(G, partition);
        Gp = TagbyFacies(Gp, geodata, 'vertIx', vertIx);
        G = Gp;
        partition = PartitionByTag(G, 'method', opt.partitionMethod, ...
            'avoidBufferCells', opt.bufferVolumeSlice);

    end

    t = toc(t);
    dispif(opt.verbose, "Partition and coarsen(%d iterations) in %0.2f s\n", partitionIterations, t);


    
    if opt.save
        if opt.presplit
            fn = sprintf('%s_presplit_cutcell_PG_%dx%d.mat', opt.type, nx, ny);
        else
            fn = sprintf('%s_cutcell_PG_%dx%d.mat', opt.type, nx, ny);
        end
        if opt.bufferVolumeSlice
            fn = ['buff_', fn];
        end
        
        save(fullfile(opt.savedir, fn), "G");
    end
end
