function G = GenerateCutCellGrid(nx, ny, varargin)
    opt = struct('save', true, ...
        'savedir', 'grid-files/cutcell', ...
        'verbose', true, ...
        'waitbar', false, ...
        'presplit', false, ...
        'recombine', true, ...
        'bufferVolumeSlice', true, ...
        'type', 'horizon', ...
        'removeInactive', true, ...
        'partitionMethod', 'convexity', ...
        'nudgeGeom', true, ...
        'round', true);
    opt = merge_options(opt, varargin{:});
    totstart = tic();
    switch opt.type
        case 'cartesian'
            [G, geodata] = makeCartesianCut(nx, ny, opt);
        case 'horizon'
            [G, geodata] = makeHorizonCut(nx, ny, opt);
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
        G = Recombine(G, opt, nx, ny, geodata);
    end

    assert(checkGrid(G));
    ttot = toc(totstart);
    dispif(opt.verbose, sprintf('Generated cut-cell grid in %f s\n', round(ttot,2)));
end

function [G, geodata] = makeCartesianCut(nx, ny, opt)
    configFile = fileread('config.JSON');
    config = jsondecode(configFile);
    fn = fullfile(config.geo_folder, 'spe11a.geo');
    %fn = 'C:\Users\holme\Documents\Prosjekt\Prosjektoppgave\src\11thSPE-CSP\geometries\spe11a.geo';
    geodata = readGeo(fn, 'assignExtra', true); 

    Lx = 2.8;
    Ly = 1.2;
    G = cartGrid([nx ny 1], [Lx, Ly 0.01]);
    G = computeGeometry(G);       
    if opt.nudgeGeom
        cellpoints = geodata.Point;
        points = vertcat(cellpoints{:});
        numPoints = size(points, 1);
        targetpoints = G.nodes.coords(G.nodes.coords(:,3)==0,:);
        [points, ~, ~] = nudgePoints(targetpoints, points, ...
            'targetOccupation', true);
        cellpoints = mat2cell(points, ones(numPoints, 1), 3);
        geodata.Point = cellpoints;
        assert(opt.presplit == false, 'nudge and presplitting should not both be enabled!')
    end

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
        'presplit', opt.presplit, 'bufferVolumeSlice', opt.bufferVolumeSlice, ...
        'nudgeGeom', opt.nudgeGeom);

end

function [G, geodata] = makeHorizonCut(nx, totys, opt)
    geodata = readGeo('./scripts/cutCell/geo/spe11a-faults.geo', 'assignExtra', true);
    geodata = RotateGrid(geodata);
    geodata = StretchGeo(geodata);
    gridfractions = [0.1198 0.0612 0.0710 0.0783 0.1051 0.0991 0.1255 0.1663 0.1737]; %scaled by region size

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
        [points(inds,:), ~, ~] = nudgePoints(targetpoints, points(inds,:), ...
            'targetOccupation', true);
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
        G = TagbyFacies(G, geodata, 'vertIx', 3);
        G = getBufferCells(G);
    end
    
    if opt.presplit
        % Presplit fault points
        cellpoints = arrayfun(@(curve)curveToPoints(curve, geodata), geodata.includeLines, UniformOutput=false);
        points = unique(vertcat(cellpoints{:}), 'rows');
        numPoints = size(points, 1);
        cellpoints = mat2cell(points, ones(numPoints, 1), 3);
        
        G = PointSplit(G, cellpoints, 'dir', [0 1 0], 'verbose', opt.verbose, 'waitbar', false, ...
            'save', opt.save, 'type', opt.type);
    end
    % Cut
    G = CutCellGeo(G, geodata, 'dir', [0 1 0], 'verbose', opt.verbose, ...
        'extendSliceFactor', 0.0, ...
        'topoSplit', true, 'save', opt.save, ...
        'type', opt.type, ...
        'bufferVolumeSlice', opt.bufferVolumeSlice, ...
        'vertIx', 3, ...
        'presplit', opt.presplit, ...
        'nudgeGeom', opt.nudgeGeom);
end

function G = Recombine(G, opt, nx, ny, geodata)
    if max(G.nodes.coords(:,2)) > 1.1
        vertIx = 2;
    else
        vertIx = 3;
    end
    % if max(G.nodes.coords(:,1))>1000
    %     Bscale = true;
    % else
    %     Bscale = false;
    % end
    % geodata = readGeo('~/Code/prosjekt-master/src/scripts/cutCell/geo/spe11a-faults.geo', 'assignExtra', true);
    % if Bscale
    %     geodata = RotateGrid(geodata);
    %     geodata = StretchGeo(geodata);
    % end
    t = tic();
    [partition, failed, tries] = PartitionByTag(G, 'method', opt.partitionMethod, ...
            'avoidBufferCells', opt.bufferVolumeSlice);
    G = makePartitionedGrid(G, partition);
    G = TagbyFacies(G, geodata, 'vertIx', vertIx);


    t = toc(t);
    dispif(opt.verbose, "Partition(%d iterations) and coarsen in %0.2f s\n%d cells failed to merge.\n", tries, t, numel(failed));


    
    if opt.save
        fn = sprintf('cutcell_PG_%dx%d.mat', nx, ny);
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
        save(fullfile(opt.savedir, fn), "G");
    end
end
