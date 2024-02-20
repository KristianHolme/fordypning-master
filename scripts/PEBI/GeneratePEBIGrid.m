function G = GeneratePEBIGrid(nx, ny, varargin)
    opt = struct('SPEcase', 'B',...
                 'FCFactor', 0.44, ...
                 'circleFactor', 0.6, ...
                 'verbose', true, ...
                 'bufferVolumeSlice', true, ...
                 'save', true);
    dispif(opt.verbose, 'Generating PEBI grid...\n');
    tstart = tic();
    [opt, extra] = merge_options(opt, varargin{:});
    geodata = readGeo('scripts/cutcell/geo/spe11a-V2.geo', 'assignextra', true);

    data = geodata.V;
    for i = 1:size(data,1)
        fault = data{i,2};
        points = curveToPoints(abs(fault), geodata);
        points2D = points(:,1:2);
        faults{i} = points2D;
    end
    pdims = [2.8, 1.2];
    targetsRes = [nx, ny];
    gs = pdims ./ targetsRes;

    G = compositePebiGrid2D(gs, pdims, 'faceConstraints', faults, ...
        'FCFactor', opt.FCFactor, ...
        'circleFactor', opt.circleFactor, ...
        'interpolateFC', false);

    G = makeLayeredGrid(G, 1);
    G.faces.tag = zeros(G.faces.num, 1);
    k = G.nodes.coords(:,3) > 0;
    G.nodes.coords(k,3) = 0.01;
    
    if mrstSettings('get', 'useMEX')
        G = mcomputeGeometry(G);
    else
        G = computeGeometry(G);
    end 

    if strcmp(opt.SPEcase, 'B')
        G = StretchGrid(RotateGrid(G));
        geodata = StretchGeo(RotateGrid(geodata));
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
        dispif(opt.verbose, 'Saving Grid...\n')
        filename = sprintf('cPEBI_%dx%d_%s.mat', nx, ny, opt.SPEcase);
        if opt.bufferVolumeSlice
            filename = ['buff_', filename];
        end
        save(fullfile("grid-files/PEBI", filename), "G");
    end
    t = toc(tstart);
    dispif(opt.verbose, 'Done! (%0.2fs)\n', t);
end