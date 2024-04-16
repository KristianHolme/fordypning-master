function [G, G2Ds, G2D, Pts, F] = GeneratePEBIGrid(nx, ny, varargin)
    opt = struct('SPEcase', 'B',...
                 'FCFactor', 1.0, ...
                 'circleFactor', 0.6, ...
                 'verbose', true, ...
                 'bufferVolumeSlice', true, ...
                 'save', true, ...
                 'useMrstPebi', false, ...
                 'earlyReturn', false, ...
                 'removeShortEdges', true, ...
                 'aspect', 'true', ...
                 'Cdepth', 50);
    [opt, extra] = merge_options(opt, varargin{:});
    dispif(opt.verbose, 'Generating PEBI grid...\n');
    tstart = tic();
    
    geodata = readGeo('scripts/cutcell/geo/spe11a-V2.geo', 'assignextra', true);

    % make cells so well are in center
    if ~strcmp(opt.SPEcase, 'C')
        [~, ~, well1Coords, well2Coords] = getinjcells(computeGeometry(cartGrid([1,1], [2.8, 1.2])), opt.SPEcase);
    else
        well1Coords = [];
        well2Coords = [];
    end

    if strcmp(opt.aspect, 'true')
        switch opt.SPEcase
            case 'A'
                matPoints = vertcat(geodata.Point{:});
                matPoints(:,1) = matPoints(:,1)/2.8; %correct aspect ratio
                matPoints(:,2) = matPoints(:,2)/2.8;
                geodata.Point = mat2cell(matPoints, ones(numel(geodata.Point),1), 3)';
                pdims = [1*meter, 1.2/2.8*meter];
                depth = 1*centi*meter;
    
                well1Coords = well1Coords/2.8;
                well2Coords = well2Coords/2.8;
            otherwise
                matPoints = vertcat(geodata.Point{:});
                matPoints(:,1) = matPoints(:,1)/2.8; %correct aspect ratio
                matPoints(:,2) = matPoints(:,2)/8.4;
                geodata.Point = mat2cell(matPoints, ones(numel(geodata.Point),1), 3)';
                pdims = [1*meter, 1.2/8.4*meter];
                depth = 1*meter;
    
                well1Coords = well1Coords/8400;
                well2Coords = well2Coords/8400;
        end
    elseif strcmp(opt.aspect, 'square')
        matPoints = vertcat(geodata.Point{:});
        maxx = max(matPoints(:,1));
        maxz = max(matPoints(:,2));
        matPoints(:,1) = matPoints(:,1)/maxx; 
        matPoints(:,2) = matPoints(:,2)/maxz;
        geodata.Point = mat2cell(matPoints, ones(numel(geodata.Point),1), 3)';
        pdims = [1*meter, 1*meter];
        if strcmp(opt.SPEcase, 'A'),depth = 1*centi*meter;else, depth = 1*meter;end

        well1Coords(1) = well1Coords(1)/8400;
        well1Coords(2) = well1Coords(2)/1200;
        well2Coords(1) = well2Coords(1)/8400;
        well2Coords(2) = well2Coords(2)/1200;
    end

    data = geodata.V;
    for i = 1:size(data,1)
        fault = data{i,2};
        points = curveToPoints(abs(fault), geodata);
        points2D = points(:,1:2);
        faults{i} = points2D;
    end
    % pdims = [2.8, 1.2];
    targetsRes = [nx, ny];
    gs = pdims ./ targetsRes;

    if strcmp(opt.SPEcase, 'C')
        wellConstraints = {};
    else
        wellConstraints = {well1Coords, well2Coords};
    end
    

    [G, Pts,F] = compositePebiGrid2D(gs, pdims, ...
        'cellConstraints', wellConstraints,...
        'mlqtMaxLevel', 1,...
        'protLayer', false,...
        'faceConstraints', faults, ...
        'FCFactor', opt.FCFactor, ...
        'circleFactor', opt.circleFactor, ...
        'interpolateFC', false, ...
        'useMrstPebi', opt.useMrstPebi,...
        'earlyReturn', opt.earlyReturn);

    
    
    if opt.earlyReturn
        fn = sprintf('scripts/PEBI/pointData/points_%dx%d.mat', nx, ny);
        save(fn, "Pts");
        fprintf("Early return! saving points to %s.\n", fn)
        G2D = [];
        G2Ds = [];
        return
    end
    

    G = computeGeometry(G);

    % plotGrid(G);axis tight equal;
    % 
    % set(gca, 'xlim', currxlim, 'ylim', currylim);
    % currxlim = xlim;
    % currylim = ylim;
    
    G = TagbyFacies(G, geodata);
    G2D = G;

    if opt.removeShortEdges
        dispif(opt.verbose, 'Binary search for short edge tolerance...')
        t = tic();
        sortedAreas = sort(G2D.faces.areas);
        maxdepth = 10;
        recdepth = 1;
        numfaces = G2D.faces.num;
        biggest = sortedAreas(round(numfaces/5));
        smallest = sortedAreas(1);
        tol = (biggest + smallest)/2;
        stopCriterion = false;
        dontStop = false;
        while (recdepth <= maxdepth && ~stopCriterion) || dontStop
            G2Ds = removeShortEdges(G2D, tol);
            if G2Ds.cells.num < G2D.cells.num
                %too big tol, removed too much
                biggest = tol;
                dontStop = true;
            else
                smallest = tol;
                dontStop = false;
            end
            tol = (biggest + smallest)/2;
            recdepth = recdepth + 1;
        end
        % G2Ds = removeShortEdges(G2D, tol);
        G2Ds = computeGeometry(G2Ds);
        t = toc(t);
        dispif(opt.verbose, 'Removed %d edges in %0.2f s.\n', G2D.faces.num - G2Ds.faces.num, t);
        dispif(opt.verbose, 'Smallest edge before: %0.2e.\nSmallest edge now: %0.2e\n', min(G2D.faces.areas), min(G2Ds.faces.areas));
        
        G = G2Ds;
    end

    if ~checkGrid(G)
        warning('Grid does not pass checkgrid!');
    end
    %Try to fix wrong internal boundary faces
    G = fixGrid(G);

    
    if strcmp(opt.SPEcase, 'C')
        layerthicknesses = [1; repmat(5000/opt.Cdepth, opt.Cdepth,1); 1]; %one meter thickness for buffer volume in front and back
        G = makeLayeredGrid(G, layerthicknesses);
        G = mcomputeGeometry(G);
    else
        G = makeLayeredGrid(G, 1);
        G.faces.tag = zeros(G.faces.num, 1);
        k = G.nodes.coords(:,3) > 0;
        G.nodes.coords(k,3) = depth;
    end

    switch opt.aspect
        case 'true'
            switch opt.SPEcase
                case 'A' 
                    xscale = 2.8;
                    zscale = 2.8;
                otherwise
                    xscale = 8400;%correct size
                    zscale = 8400;
            end
        case 'square'
            switch opt.SPEcase
                case 'A' 
                    xscale = 2.8;
                    zscale = 1.2;
                otherwise
                    xscale = 8400;
                    zscale = 1200;
            end
    end
    matPoints = vertcat(geodata.Point{:});
    matPoints(:,1) = matPoints(:,1)*xscale;
    matPoints(:,2) = matPoints(:,2)*zscale;
    geodata.Point = mat2cell(matPoints, ones(numel(geodata.Point),1), 3)';
    G.nodes.coords(:,1) = G.nodes.coords(:,1)*xscale;
    G.nodes.coords(:,2) = G.nodes.coords(:,2)*zscale; %z is coord 2 since grid is not yet rotated

    
    if mrstSettings('get', 'useMEX')
        G = mcomputeGeometry(G);
    else
        G = computeGeometry(G);
    end 


    if strcmp(opt.SPEcase, 'B') || strcmp(opt.SPEcase, 'C')
        G = RotateGrid(G);
        G = mcomputeGeometry(G);%maybe not necessary
        geodata = RotateGrid(geodata);
        if opt.bufferVolumeSlice
            G = sliceGrid(G, {[1, 0.5, 0], [8399, 0.5, 0]}, 'normal', [1 0 0]);
            G = TagbyFacies(G, geodata, 'vertIx', 3);
            G = getBufferCells(G);
        end
    end

    if ~isfield(G.cells, 'tag') || ( isfield(G.cells, 'tag') && all(G.cells.tag == 0) )
        G = TagbyFacies(G, geodata, 'vertIx', 3);
    end

    if strcmp(opt.SPEcase, 'C')
        G.nodes.coords = SPE11CBend(G.nodes.coords);
        G = mcomputeGeometry(G);
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
            filename = sprintf('cPEBI_%dx%dx%d_%s.mat', nx, opt.Cdepth, ny, opt.SPEcase);
        else
            filename = sprintf('cPEBI_%dx%d_%s.mat', nx, ny, opt.SPEcase);
        end
        if opt.bufferVolumeSlice
            filename = ['buff_', filename];
        end
        dispif(opt.verbose, 'Saving Grid to %s\n', filename)
        save(fullfile("grid-files/PEBI", filename), "G");
    end
    t = toc(tstart);
    dispif(opt.verbose, 'Done! (%0.2fs)\n', t);
end