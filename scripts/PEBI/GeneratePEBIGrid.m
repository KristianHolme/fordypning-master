function [G, G2D, Pts] = GeneratePEBIGrid(nx, ny, varargin)
    opt = struct('SPEcase', 'B',...
                 'FCFactor', 1.0, ...
                 'circleFactor', 0.6, ...
                 'verbose', true, ...
                 'bufferVolumeSlice', true, ...
                 'save', true, ...
                 'useMrstPebi', false, ...
                 'earlyReturn', false);
    dispif(opt.verbose, 'Generating PEBI grid...\n');
    tstart = tic();
    [opt, extra] = merge_options(opt, varargin{:});
    geodata = readGeo('scripts/cutcell/geo/spe11a-V2.geo', 'assignextra', true);
    switch opt.SPEcase
        case 'B'
            matPoints = vertcat(geodata.Point{:});
            matPoints(:,1) = matPoints(:,1)/2.8; %correct aspect ratio
            matPoints(:,2) = matPoints(:,2)/8.4;
            geodata.Point = mat2cell(matPoints, ones(numel(geodata.Point),1), 3)';
            pdims = [1*meter, 1.2/8.4*meter];
            depth = 1*meter;
        case 'A'
            matPoints = vertcat(geodata.Point{:});
            matPoints(:,1) = matPoints(:,1)/2.8; %correct aspect ratio
            matPoints(:,2) = matPoints(:,2)/2.8;
            geodata.Point = mat2cell(matPoints, ones(numel(geodata.Point),1), 3)';
            pdims = [1*meter, 1.2/2.8*meter];
            depth = 1*centi*meter;
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

    [G, Pts,~] = compositePebiGrid2D(gs, pdims, 'faceConstraints', faults, ...
        'FCFactor', opt.FCFactor, ...
        'circleFactor', opt.circleFactor, ...
        'interpolateFC', false, ...
        'useMrstPebi', opt.useMrstPebi,...
        'earlyReturn', opt.earlyReturn);
    
    G = computeGeometry(G);
    
    G = TagbyFacies(G, geodata);
    G2D = G;

    if opt.earlyReturn
        fn = sprintf('scripts/PEBI/pointData/points_%dx%d.mat', nx, ny);
        save(fn, "Pts");
        fprintf("Early return! saving points to %s.\n", fn)
        return
    end

    G = makeLayeredGrid(G, 1);
    G.faces.tag = zeros(G.faces.num, 1);
    k = G.nodes.coords(:,3) > 0;
    G.nodes.coords(k,3) = depth;

    switch opt.SPEcase
        case 'B'
            matPoints = vertcat(geodata.Point{:});
            matPoints(:,1) = matPoints(:,1)*8400; %correct size
            matPoints(:,2) = matPoints(:,2)*8400;
            geodata.Point = mat2cell(matPoints, ones(numel(geodata.Point),1), 3)';
            G.nodes.coords(:,1) = G.nodes.coords(:,1)*8400;
            G.nodes.coords(:,2) = G.nodes.coords(:,2)*8400;
        case 'A'
            matPoints = vertcat(geodata.Point{:});
            matPoints(:,1) = matPoints(:,1)*2.8; %correct size
            matPoints(:,2) = matPoints(:,2)*2.8;
            geodata.Point = mat2cell(matPoints, ones(numel(geodata.Point),1), 3)';
            G.nodes.coords(:,1) = G.nodes.coords(:,1)*2.8;
            G.nodes.coords(:,2) = G.nodes.coords(:,2)*2.8;            
    end
    
    if mrstSettings('get', 'useMEX')
        G = mcomputeGeometry(G);
    else
        G = computeGeometry(G);
    end 


    switch opt.SPEcase
        case 'B'
        G = RotateGrid(G);
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


    t = tic();
    dispif(opt.verbose, "Adding injection cells and box-volume-fractions...");
    G = addBoxWeights(G, 'SPEcase', opt.SPEcase);
    [w1, w2] = getinjcells(G, opt.SPEcase);
    G.cells.wellCells = [w1, w2];
    t = toc(t);
    dispif(opt.verbose, "Done in %0.2d s.\n", t);
    
    if opt.save
        filename = sprintf('cPEBI_%dx%d_%s.mat', nx, ny, opt.SPEcase);
        dispif(opt.verbose, 'Saving Grid to %s\n', filename)
        if opt.bufferVolumeSlice
            filename = ['buff_', filename];
        end
        save(fullfile("grid-files/PEBI", filename), "G");
    end
    t = toc(tstart);
    dispif(opt.verbose, 'Done! (%0.2fs)\n', t);
end