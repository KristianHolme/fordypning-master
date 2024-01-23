function model = setupModel(simcase, varargin)
    opt = struct();
    opt = merge_options(opt, varargin{:});
    
    G = simcase.G;
    rock = simcase.rock;
    fluid = simcase.fluid;

    usedeck = simcase.usedeck;
    deck = simcase.deck;
    
    if simcase.griddim == 3
        gravity([0, 0, 9.81]);
    else
        gravity([0,-9.81])
    end
    gravity on


    if ~usedeck || strcmp(simcase.fluidcase, 'experimental')
        water = strcmp(simcase.fluidcase, 'experimental');
        oil = true;
        gas = true;
        model = GenericBlackOilModel(G, rock, fluid, 'water', water, 'oil', oil, 'gas', gas);
    else
        model = selectModelFromDeck(G, rock, fluid, deck);
    end

    if ~isempty(simcase.pdisc) && contains(simcase.pdisc, 'hybrid')
        cellblocks = getCellblocks(simcase, varargin{:});
        model = getHybridDisc(simcase, model, replace(simcase.pdisc, 'hybrid-', ''), ...
            cellblocks, varargin{:});
    end
    if ~isempty(simcase.uwdisc) && contains(simcase.uwdisc, 'WENO')
        model = setWENODiscretization(model);
    end
    if contains(simcase.tagcase, 'upscale')
        partition = PartitionByTag(G);
        model = upscaleModelTPFA(model, partition);
        [~, CGcellToGCell] = unique(partition, 'first');
        model.G.cells.tag = G.cells.tag(CGcellToGCell);

        simcase.G = model.G;
    end

    model.OutputStateFunctions{end+1} = 'CapillaryPressure';
    model.OutputStateFunctions{end+1} = 'ComponentMobility';
    model.OutputStateFunctions{end+1} = 'ComponentPhaseDensity';
    model.OutputStateFunctions{end+1} = 'ComponentPhaseMass';
    model.OutputStateFunctions{end+1} = 'Mobility';
    model.OutputStateFunctions{end+1} = 'PhasePressures';
    model.OutputStateFunctions{end+1} = 'RelativePermeability';
    % model.outputFluxes = false;
    model.AutoDiffBackend = DiagonalAutoDiffBackend('useMex', true);% safe to use with hybrid-method?
    model = model.validateModel();
    model.dpMaxRel = 0.2; %copied from initEclipseProblem
end