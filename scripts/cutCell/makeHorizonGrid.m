function G = makeHorizonGrid(nx,nys, varargin)
    %make a grid following horizons
    opt = struct('save', false, ...
                 'savedir', './grid-files/cutcell/horizonGrids', ...
                 'geoH', []);
    opt = merge_options(opt, varargin{:});

    geoH = readHorizons('geoH', opt.geoH);
    % Add Top as first horizon
    horzInters = geoH.horz(:,4);
    horzInters = [{@(newxs)interp1([0.0, 2.8], [1.2, 1.2], newxs, 'linear')}; horzInters];
    numHorz = numel(horzInters)-1;

    nxs = repmat(nx, numHorz);
    if numel(nys) == 1
        nys = repmat(nys, numHorz);
    end
    assert(numel(nys)==numHorz, 'nys does not match number of horizons!');
    % Make subgrids
    Lx = 2.8;
    Ly = 1.2;
    Gcart = cartGrid([nx, sum(nys)], [Lx, Ly]);
    cartGrids = {};
    horizonYpos = cumsum([0, nys(end:-1:1)]);
    for ihorz = numel(horzInters)-1:-1:1
        top = horzInters{ihorz};
        bottom = horzInters{ihorz+1};
    
        nx = nxs(ihorz);
        ny = nys(ihorz);
        % Gcart = cartGrid([nx, ny], [Lx, Ly]);
        for j = 1:ny+1
            jpos = (j-1+ horizonYpos(numHorz-ihorz+1))*(nx+1) + 1 ;
            xs = Gcart.nodes.coords(jpos:jpos+nx, 1);
            topys = top(xs);
            botys = bottom(xs);
            lambda = (j-1)/(ny);
            ys = botys*(1-lambda) + lambda*topys;
            Gcart.nodes.coords(jpos:jpos+nx, 2) = ys;
        end
        % cartGrids{ihorz} = Gcart;
    end
    G = Gcart;
    %Glue grids together
    % G = cartGrids{1};
    % for i=2:numel(cartGrids)
    %     G = glue2DGrid(G, cartGrids{i});
    % end
    
    % G.type{end+1} = 'makeHorizonGrid';
    G = makeLayeredGrid(G, 0.01);%custom modified function;
    if mrstSettings('get', 'useMEX')
        G = mcomputeGeometry(G);
    else
        G = computeGeometry(G);
    end
    G = StretchGrid(RotateGrid(G));
    G.cartDims = [nx, 1, sum(nys)];
    G.faces.tag = zeros(G.faces.num, 1);

    if opt.save
        totys = sum(nys);
        
        fn = sprintf('horizongrid_%dx%d', nx, totys);
        savepath = fullfile(opt.savedir, fn);
        save(savepath, "G");
    end
    
end