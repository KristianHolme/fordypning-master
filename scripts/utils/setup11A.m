function [state0, model, schedule, nls] = setup11A(simcase, varargin)
    opt = struct('direct_solver', true);
    opt = merge_options(opt, varargin{:});

    G           = simcase.G;
    model       = simcase.model;
    schedule    = simcase.schedule;
    deck        = simcase.deck;
    direct_solver = opt.direct_solver;

    if ~isempty(simcase.gridcase)%not grid from deck
        % state00 = initResSol(G, 1*atm, [1, 0]);
        % regions = getInitializationRegionsDeck(model, deck);
        % [state0, p] = initStateBlackOilAD(model, regions);
        sat = [1,0];
        p_ref = 1.1e5;
        g = model.gravity(3);
        p_res = p_ref + g*G.cells.centroids(:, 3).* model.fluid.rhoOS;
        state0 = initResSol(G, p_res, sat);
    elseif simcase.usedeck
        state0 = initStateDeck(model, deck);
    else
        state0 = initResSol(G, 1*atm, [1, 0]);
    end
    linearSolverArguments = {'BackslashThreshold', 2000};
    nls = getNonLinearSolver(model, 'LinearSolverArguments', linearSolverArguments);
    if direct_solver
        nls.LinearSolver = BackslashSolverAD();
    end
    nls.maxTimestepCuts = 20;
    nls.maxIterations = 12; %fra readEclipse
    nls.useRelaxation = true;

end