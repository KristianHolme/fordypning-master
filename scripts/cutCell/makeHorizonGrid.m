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
    %add bottom as last horizon
    horzInters = [horzInters;{@(newxs)interp1([0.0, 2.8], [0, 0], newxs, 'linear')}];
    % nys = nys(1:end-1);

    numHorz = numel(horzInters)-1;

    nxs = repmat(nx, numHorz);
    if numel(nys) == 1
        nys = repmat(nys, numHorz);
    end
    if ~numel(nys)==numHorz
        warning('nys does not match number of horizons!');
    end
    % Make subgrids
    Lx = 2.8;
    Ly = 1.2;
    Gcart = cartGrid([nx, sum(nys)], [Lx, Ly]);
    % cartGrids = {};
    horizonYpos = cumsum([0, nys(end:-1:1)]);
    for ihorz = numel(horzInters)-1:-1:1
        top = horzInters{ihorz};
        bottom = horzInters{ihorz+1};
    
        nx = nxs(ihorz);
        ny = nys(ihorz);
        % Gcart = cartGrid([nx, ny], [Lx, Ly]);
        for j = 1:ny%+1
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
    G = fixDegenerateFaces(G);
    % G = computeGeometry(G);
    % G = removePinch(G, 0.0);

    G = makeLayeredGrid(G, 1);
    k = G.nodes.coords(:,3) > 0;
    G.nodes.coords(k,3) = 0.01;

    % G = removePinch(G, 0.0);

    %readjust bc. workaround
    % k = G.nodes.coords(:,2) < 0;
    % G.nodes.coords(k,2) = -0.0010;

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

function G = fixDegenerateFaces(G)
    %from removePinch----------------
    % Uniquify nodes
   [G.nodes.coords, i, j] = unique(G.nodes.coords, 'rows');

   % Map face nodes
   G.faces.nodes    = j(G.faces.nodes);

   % Remove nodes with small difference
   if nargin == 2
      d = [inf; sqrt(sum(diff(G.nodes.coords,1) .^ 2, 2))];
      I = d < tol;
      G.nodes.coords = G.nodes.coords(~I,:);
      J = ones(size(I));
      J(I) = 0;  J = cumsum(J);
      G.faces.nodes = J(G.faces.nodes);
   end
   G.nodes.num = size(G.nodes.coords, 1);

   % remove repeated node numbers in faces (stored in adjacent positions
   faceno = rldecode(1:G.faces.num, diff(G.faces.nodePos), 2)';
   tmp    = rlencode([faceno, G.faces.nodes]);
   [n,n]  = rlencode(tmp(:,1));

   % remove nodes that coincide without being stored in adjacent positions
   pos    = cumsum([1;n]);
   ix     = tmp(pos(1:end-1), 2) == tmp(pos(2:end)-1, 2) & ...
               (pos(1:end-1)     ~=     pos(2:end)-1);
   tmp(pos(ix),:)  = [];

   G.faces.nodes   = tmp(:, 2);
   [fn,n]          = rlencode(tmp(:,1));
   G.faces.nodePos = cumsum([1; n]);
   G.faces.num     = numel(G.faces.nodePos)-1;


   % remove pinched faces
   G = removeFaces(G, find(diff(G.faces.nodePos)<G.griddim));
   %end from removePinch----------------------------------
   numFaces = diff(G.cells.facePos);
   flatCells = numFaces < 3;
   G = removeCells(G, flatCells);
   ;
end