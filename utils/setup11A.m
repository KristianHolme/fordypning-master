function [state0, model, schedule, nls] = setup11A(simcase, varargin)
    opt = struct('direct_solver', false);
    [opt, extra] = merge_options(opt, varargin{:});

    deck        = simcase.deck;
    G           = simcase.G;
    model       = setupModel11A(simcase, extra{:});
    simcase.model = model;
    schedule    = simcase.schedule;
    direct_solver = opt.direct_solver;

    if ~isempty(simcase.gridcase)%not grid from deck
        % state00 = initResSol(G, 1*atm, [1, 0]);
        % regions = getInitializationRegionsDeck(model, deck);
        % [state0, p] = initStateBlackOilAD(model, regions);
        % sat = [1,0];
        p_datum = 1.1e5;
        % g = model.gravity(3);
        % p_res = p_ref + g*G.cells.centroids(:, 3).* model.fluid.rhoOS;
        % state0 = initResSol(G, p_res, sat);

        rsvd = [0,0;100,0];
        depth_datum = 0.0;
        F = griddedInterpolant(rsvd(:, 1), rsvd(:, 2), 'linear', 'nearest');
        rs = @(p, z) F(z);
        rv = [];
        
        act = [model.water & model.oil, model.oil & model.gas];
        contacts = [1000, 0];
        contacts_pc = [0,0];
        numRegions = 6;
        regions = cell(numRegions, 1);
        for ireg = 1:numRegions
            cells = find(G.cells.tag == ireg);
            region = getInitializationRegionsBlackOil(model, contacts(act),...
                'cells', cells, 'datum_pressure', p_datum, ...
                'datum_depth', depth_datum, 'contacts_pc', contacts_pc(act), ...
                'rs', rs, 'rv', rv);
            regions{ireg} = region;
        end

        state0 = initStateBlackOilAD(model, regions);
    elseif simcase.usedeck
        state0 = initStateDeck(model, deck);
    else
        state0 = initResSol(G, 1*atm, [1, 0]);
    end
    linearSolverArguments = {'BackslashThreshold', 10000};
    nls = getNonLinearSolver(model, 'LinearSolverArguments', linearSolverArguments);
    if direct_solver
        nls.LinearSolver = BackslashSolverAD();
    end
    nls.maxTimestepCuts = 20;
    nls.maxIterations = 12; %fra readEclipse
    nls.useRelaxation = true;

end