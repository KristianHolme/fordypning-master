function simpleTest(simcase, varargin)
    opt = struct('uniformK', true, ...
        'type', 'linear', ... %linear or src
        'direction', 'tb', ...
        'title', '', ...
        'paddingLayers', 1, ...
        'myRatio', []);%direction of linear test, "tp" (top-bottom), lr (left-right)
    if isempty(simcase.discmethod)
        discmethod = 'tpfa';
    else
        discmethod = simcase.discmethod;
    end
    opt.title = ['grid: ', simcase.gridcase, ' , disc: ', discmethod];
    opt = merge_options(opt, varargin{:});
    
    myRatio = opt.myRatio;
    G = simcase.G;
    if opt.uniformK
        rock = makeRock(G, 100*milli*darcy, 0.2);
    else
        rock = setupRock11A(simcase);
    end
    simcase.rock = rock;

    fluid = initSimpleADIFluid('phases', 'W', 'mu', 1*centi*poise, 'rho', 1000);
    gravity off
    tpfamodel = GenericBlackOilModel(G, rock, fluid, 'water', true, 'oil', false, 'gas', false);
    state0 = initResSol(G, 0.0);
    
    df = struct('W', [], 'bc', [], 'src', []);

    if strcmp(opt.type, 'linear')
        bc = linearPressureBC(G, opt.direction);
        df.bc = bc;
    end
    schedule = simpleSchedule(1, 'W', df.W, 'bc', df.bc, 'src', df.src);
    simcase.schedule = schedule;

    discmethod = replace(simcase.discmethod, 'hybrid-', '');
    cellblocks = getCellblocks(simcase, 'paddingLayers', opt.paddingLayers);
    if isempty(discmethod)
        model = tpfamodel;
    else
        model = getHybridDisc(simcase, tpfamodel, discmethod, cellblocks, 'resetAssembly', true, ...
            'saveAssembly', false, 'myRatio', myRatio);

        % model2 = setAvgMPFADiscretization(model);
        % faceblocks{1} = [];faceblocks{2} = 1:G.faces.num;
        % models{1} = model;models{2} = model2;
        % model = setHybridDiscretization(model, models, faceblocks);
        
        % model = setNTPFADiscretization(tpfamodel);


    end

    [wellSols, state, report]  = simulateScheduleAD(state0, model, schedule);
    state{1}.error = G.cells.centroids(:,3) - state{1}.pressure;
    state{1}.CTMnorm = state{1}.FlowProps.ComponentTotalMass ./G.cells.volumes;
    figure('Visible','on');
    plotToolbar(G, state);
    title(opt.title);
    view(0,0);axis tight;colorbar;
    if strcmp(opt.direction, 'lr')
        maxp = 2.8;
    else
        maxp = 1.2;
    end
    clim([0 maxp]);
    

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
        bc = addBC(bc, minFaces, 'pressure', minVal);
        bc = addBC(bc, maxFaces, 'pressure', maxVal);
end