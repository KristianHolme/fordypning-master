function model = setupModel11A(simcase, varargin)
    opt = struct('usedeck', true, 'deck', []);
    opt = merge_options(opt, varargin{:});
    
    G = simcase.G;
    rock = simcase.rock;
    fluid = simcase.fluid;

    usedeck = simcase.usedeck;
    deck = simcase.deck;
   
    water = false;
    oil = true;
    gas = true;
    

    gravity([0, 0, 9.81]);
    gravity on


    if ~usedeck
        water = true;
        oil = false;
        model = GenericBlackOilModel(G, rock, fluid, 'water', water, 'oil', oil, 'gas', gas);
        model.OutputStateFunctions{end+1} = 'CapillaryPressure'; %leads
        model.outputFluxes = false;
    else
        model = selectModelFromDeck(G, rock, fluid, deck);
        model.OutputStateFunctions{end+1} = 'CapillaryPressure'; %leads
        % to fatal error
        model.outputFluxes = false;
    end
    model.dpMaxRel = 0.2; %copied from initEclipseProblem
end