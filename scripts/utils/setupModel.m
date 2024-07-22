function model = setupModel(simcase, varargin)
    opt = struct();
    [opt, extra] = merge_options(opt, varargin{:});
    
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

    if ~isempty(simcase.pdisc) && contains(simcase.pdisc, 'cc')
        if contains(simcase.pdisc, 'loc')
            K_system = 'loc_xyz';
        else
            K_system = 'xyz';
        end
        model = setCCTransmissibility(model, K_system);
    end
    if ~isempty(simcase.pdisc) && strcmp(simcase.pdisc, 'p')
        model = setPEBITransmissibility(model);
    end

    if contains(simcase.tagcase, 'upscale')
        partition = PartitionByTag(G);
        model = upscaleModelTPFA(model, partition);
        [~, CGcellToGCell] = unique(partition, 'first');
        model.G.cells.tag = G.cells.tag(CGcellToGCell);

        simcase.G = model.G;
    end


    if ~isempty(simcase.pdisc) && contains(simcase.pdisc, 'hybrid')
        if contains(simcase.pdisc, 'indicator')
           

            [err, errvect, fwerr] = simcase.computeStaticIndicator();
            pdiscParts = split(simcase.pdisc, '-');
            indicatorPart = pdiscParts{1};
            percentConsistent = str2double(indicatorPart(end-1:end));
            if ~isnan(percentConsistent) && ~percentConsistent == 0
                faceBlocks = getFaceBlocksFromIndicator(simcase.G, 'cellError', fwerr, ...
                    'percentConsistent', percentConsistent);
            else
                faceBlocks = getFaceBlocksFromIndicator(simcase.G, 'cellError', fwerr);
            end
        elseif ~startsWith(simcase.pdisc, 'hybrid')
            hybridType = split(simcase.pdisc, '-');
            hybridType = hybridType{1};
            cellblocks = spe11CellblockBoxes(simcase.G, 'box', hybridType);
            faceBlocks = getFaceBlocks(G, cellblocks, extra{:});
        else
            cellblocks = getCellblocks(simcase, varargin{:});
            faceBlocks = getFaceBlocks(G, cellblocks, extra{:});%faces
        end
        nameParts = split(simcase.pdisc, '-');
        discname = nameParts{end};
        
        model = getHybridDisc(simcase, model, discname, ...
            faceBlocks, varargin{:});
    elseif ~isempty(simcase.pdisc) && strcmp(simcase.pdisc, 'ntpfa')%for testing new NTPFA
        model = setNTPFADiscretization(model);
    end
    if ~isempty(simcase.uwdisc) && contains(simcase.uwdisc, 'WENO')
        model = setWENODiscretization(model);
    end
    
    if ~isempty(simcase.pdisc) && contains(simcase.pdisc, 'CPPD')
        model = setCombinedPhasePotentialDifference(model);
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
