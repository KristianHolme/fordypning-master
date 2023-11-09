function simpleTest(simcase, varargin)
    opt = struct('uniformK', true, ...
        'type', 'linear', ... %linear or src
        'direction', 'tb', ...
        'title', '', ...
        'paddingLayers', 1, ...
        'myRatio', [], ...
        'saveplot', false);%direction of linear test, "tp" (top-bottom), lr (left-right)
    if isempty(simcase.pdisc)
        pdisc = 'tpfa';
    else
        pdisc = simcase.pdisc;
    end
    opt.title = ['grid: ', simcase.gridcase, ' , disc: ', pdisc];
    opt = merge_options(opt, varargin{:});
    
    myRatio = opt.myRatio;
    G = simcase.G;
    if opt.uniformK
        rock = makeRock(G, 100*milli*darcy, 0.2);
    else
        rock = setupRock(simcase);
    end
    simcase.rock = rock;

    % fluid = initSimpleADIFluid('phases', 'W', 'mu', 1*centi*poise, 'rho', 1000);
    fluid = initSimpleADIFluid('phases', 'WO', 'rho', [1000, 100]);
    gravity off
    tpfamodel = GenericBlackOilModel(G, rock, fluid, 'water', true, 'oil', true, 'gas', false);
    % state0 = initResSol(G, 0.0);
    state0 = initResSol(G, 1*barsa, [1,0]);
    
    df = struct('W', [], 'bc', [], 'src', []);

    if strcmp(opt.type, 'linear')
        bc = linearPressureBC(G, opt.direction);
        df.bc = bc;
    end
    schedule = simpleSchedule(1, 'W', df.W, 'bc', df.bc, 'src', df.src);
    simcase.schedule = schedule;

    pdisc = replace(simcase.pdisc, 'hybrid-', '');
    cellblocks = getCellblocks(simcase, 'paddingLayers', opt.paddingLayers);
    if isempty(pdisc)
        model = tpfamodel;
    else
        model = getHybridDisc(simcase, tpfamodel, pdisc, cellblocks, 'resetAssembly', true, ...
            'saveAssembly', false, 'myRatio', myRatio);

        % model2 = setAvgMPFADiscretization(model);
        % faceblocks{1} = [];faceblocks{2} = 1:G.faces.num;
        % models{1} = model;models{2} = model2;
        % model = setHybridDiscretization(model, models, faceblocks);
        
        % model = setNTPFADiscretization(tpfamodel);


    end

    [wellSols, state, report]  = simulateScheduleAD(state0, model, schedule);
    % state{1}.error = G.cells.centroids(:,3) - state{1}.pressure;
    % state{1}.CTMnorm = state{1}.FlowProps.ComponentTotalMass ./G.cells.volumes;
    fig = figure('Visible','on');
    plotToolbar(G, state);
    title(opt.title);
    view(0,0);axis tight;colorbar;
    if strcmp(opt.direction, 'lr')
        maxp = 2.8;
    else
        maxp = 1.2;
    end
    clim([0 maxp]);
    if opt.saveplot
        filename = [simcase.gridcase, '_', shortDiscName(pdisc), '_', opt.direction, '.eps'];
        filename = fullfile('plots/linearPressuretest', filename);
        saveas(fig, filename);
    end
end

function bc = linearPressureBC(G, dir)
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
        bc = addBC(bc, minFaces, 'pressure', minVal, 'sat', [1,0]);
        bc = addBC(bc, maxFaces, 'pressure', maxVal, 'sat', [1,0]);
end