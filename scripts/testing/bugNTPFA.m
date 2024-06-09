%Standalone minimal example of an NTPFA bug
mrstModule add ad-core ad-blackoil ad-props mrst-gui nfvm ...
    mpfa
p0 = 1.0;
direction = 'lr'; % or 'tb'
grid = 'skewed3D';
% grid = 'unstructured';
% pdisc = 'tpfa';
% pdisc = 'ntpfa';
% pdisc = 'avgmpfa';
% pdisc = 'mpfa';
% LinTest('tpfa'   , direction, 'grid', grid, 'p0', p0);
LinTest('ntpfa'  , direction, 'grid', grid, 'p0', p0);
% LinTest('avgmpfa', direction, 'grid', grid, 'p0', p0);
% LinTest('mpfa'   , direction, 'grid', grid, 'p0', p0);


%%
function LinTest(pdisc, direction, varargin)
%linear pressure test where NTPFA is weird
%pdisc: 'tpfa', 'ntpfa', 'avgmpfa' or 'mpfa'. 
%direction: direction for linear pressure gradient. lr (left-right) or tb
%(top-bottom)
    opt = struct('title', '',...
        'grid', 'skewed3D', ...
        'p0', 1*barsa, ...
        'phases', 1);
    opt = merge_options(opt, varargin{:});
    
    switch opt.grid
        case 'skewed3D'
            G = makeSkewed3D();
        case 'unstructured'
            load('spe11a_ref10_alg5_grid.mat')
            G = makeLayeredGrid(G, 1);
            G = computeGeometry(G);

    end
    
    rock = makeRock(G, 100*milli*darcy, 0.2);
    

    fluid = initSimpleADIFluid('phases', 'W', 'rho', 1000);
    waterpresent = true;
    oilpresent = false;
    state0 = initResSol(G, opt.p0, 1);
    opt.title = ['p_0 = ', num2str(opt.p0)];

    gravity off
    tpfamodel = GenericBlackOilModel(G, rock, fluid, 'water', waterpresent, 'oil', oilpresent, 'gas', false);
    
    df = struct('W', [], 'bc', [], 'src', []);
    bc = linearPressureBC(G, direction, opt.phases);
    df.bc = bc;
    
    schedule = simpleSchedule(1, 'W', df.W, 'bc', df.bc, 'src', df.src);
    switch pdisc
        case 'tpfa'
            model = tpfamodel;
            opt.title = [opt.title, ', TPFA'];
        case 'ntpfa'
            model = setNTPFADiscretization(tpfamodel);
            opt.title = [opt.title, ', NTPFA'];
        case 'avgmpfa'
            model = setAvgMPFADiscretization(tpfamodel);
            opt.title = [opt.title, ', avgMPFA'];
        case 'mpfa'
            model = setMPFADiscretization(tpfamodel);
            opt.title = [opt.title, ', MPFA'];
    end
    
    [wellSols, state, report]  = simulateScheduleAD(state0, model, schedule);
    % state{1}.error = G.cells.centroids(:,3) - state{1}.pressure;
    % state{1}.CTMnorm = state{1}.FlowProps.ComponentTotalMass ./G.cells.volumes;
    fig = figure('Visible','on');
    plotToolbar(G, state, 'outline', true);
    title(opt.title);
    switch direction
        case 'lr'
            loc = 'southoutside';
            cbarDirection = 'normal';
        case 'tb'
            loc = 'eastoutside';
            cbarDirection = 'reverse';
    end
    axis tight;colorbar('location', loc, Direction=cbarDirection);
    if strcmp(direction, 'lr')
        maxp = 2.8;
    else
        maxp = 1.2;
    end
    clim([0 maxp]);
end
%%
function bc = linearPressureBC(G, dir, phases)
    if strcmp(dir, 'tb')
        dir = 3;
    elseif strcmp(dir, 'lr')
        dir = 1;
    end
    tol = 1e-12;
    minVal = min(G.faces.centroids(:, dir));
    maxVal = max(G.faces.centroids(:, dir));

    minFaces = find(abs(G.faces.centroids(:, dir)-minVal) < tol);
    if dir == 3
        downVector = [0,0,1];
        bf = boundaryFaces(G);
        bfCoords = G.faces.centroids(bf, :);

        lowFaces = bfCoords(:, 3) > 1;

        bf = bf(lowFaces);
        bfCoords = G.faces.centroids(bf, :);
        
        
        minside = min(G.faces.centroids(:, 1));
        maxside = max(G.faces.centroids(:, 1));
        bfCoords = G.faces.centroids(bf, :);
        notTop = abs(bfCoords(:, 3) - minVal) > tol;
        notLeft = abs(bfCoords(:, 1) - minside) > tol;
        notRight = abs(bfCoords(:, 1) - maxside) > tol;
        notFront = abs(bfCoords(:, 2)) > tol;
        notBack = abs(bfCoords(:, 2) - 0.01) > tol;
        candidates = notTop & notLeft & notRight & notFront &notBack;
        
        maxFaces = bf(candidates);
        maxVal = G.faces.centroids(maxFaces,3);
    else
        maxFaces = find(abs(G.faces.centroids(:, dir)-maxVal) < tol);
    end
    bc = [];
    if phases == 1
        sat = 1;
    else
        sat = [1,0];
    end
    bc = addBC(bc, minFaces, 'pressure', minVal, 'sat', sat);
    bc = addBC(bc, maxFaces, 'pressure', maxVal, 'sat', sat);
end
function G = makeSkewed3D()
    G = cartGrid([41,20],[2, 1]);
    makeSkew = @(c) c(:,1) + .4*(1-(c(:,1)-1).^2).*(1-c(:,2));
    G.nodes.coords(:,1) = 2*makeSkew(G.nodes.coords);
    G.nodes.coords(:,1) = G.nodes.coords(:,1)*(2.8/4);
    G.nodes.coords(:,2) = G.nodes.coords(:,2)*(1.2);
    % G.nodes.coords = twister(G.nodes.coords);
    % G.nodes.coords(:,1) = 2*G.nodes.coords(:,1);
    
    G = makeLayeredGrid(G, 1);
    G = computeGeometry(G);
    % G = rotateGrid(G); %custom function
    G = computeGeometry(G);
end
