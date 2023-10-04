function [state0, model, schedule, nls] = setup11A(simcase, varargin)
    

    G           = simcase.G;
    model       = simcase.model;
    schedule    = simcase.schedule;
    deck        = simcase.deck;

    if ~isempty(deck)
        state00 = initResSol(G, 1*atm, [1, 0]);
        regions = getInitializationRegionsDeck(model, deck);
        [state0, p] = initStateBlackOilAD(model, regions);
    elseif simcase.usedeck
        state0 = initStateDeck(model, deck);
    else
        state0 = initResSol(G, 1*atm, [1, 0]);
    end
    nls = getNonLinearSolver(model);
    nls.maxTimestepCuts = 20;
end