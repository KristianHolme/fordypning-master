function [state0, model, schedule, nls] = setupSim(simcase, varargin)
    opt = struct('direct_solver', false);
    [opt, extra] = merge_options(opt, varargin{:});

    deck        = simcase.deck;
    G           = simcase.G;
    model       = setupModel(simcase, extra{:});
    simcase.model = model;
    schedule    = simcase.schedule;
    direct_solver = opt.direct_solver;
    
    if strcmp(simcase.SPEcase, 'A')

        if ~isempty(simcase.fluidcase) && contains(simcase.fluidcase, 'experimental')
            if contains(simcase.fluidcase, 'ref')
                state0 = initResSol(G, 1*atm, [1, 0]);
            else
                state0 = initResSol(G, 1*atm, [0,1, 0]);
            end
        elseif ~isempty(simcase.gridcase)%not grid from deck
            if simcase.griddim == 2 %get initstate from extruded version
                copyStream = getByteStreamFromArray(simcase);
                simcase3d = getArrayFromByteStream(copyStream);%deep copy
                simcase3d.gridcase = replace(simcase.gridcase, '-2D', '');
                simcase3d.griddim = 3;
                simcase3d.pdisc = '';
                simcase3d.G = [];
                [state0, ~, ~, ~] = setupSim(simcase3d);
            else
                p_datum = 1.1e5;
        
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
            end
        elseif simcase.usedeck
            state0 = initStateDeck(model, deck);
        else
            state0 = initResSol(G, 1*atm, [1, 0]);
        end
    elseif strcmp(simcase.SPEcase, 'B') || strcmp(simcase.SPEcase, 'C')
        if ~isempty(simcase.gridcase) & (~simcase.nonStdGrid || contains(simcase.gridcase, 'tet_zx10'))
            p_datum = 19620000;
    
            rsvd = [0,0;1200,0];
            depth_datum = 0.0;
            F = griddedInterpolant(rsvd(:, 1), rsvd(:, 2), 'linear', 'nearest');
            rs = @(p, z) F(z);
            rv = [];
            
            act = [model.water & model.oil, model.oil & model.gas];
            contacts = [10000, -1000];
            contacts_pc = [0,0];
            numRegions = 6;
            regions = cell(numRegions, 1);
            for ireg = 1:numRegions
                cells = find(model.G.cells.tag == ireg);
                region = getInitializationRegionsBlackOil(model, contacts(act),...
                    'cells', cells, 'datum_pressure', p_datum, ...
                    'datum_depth', depth_datum, 'contacts_pc', contacts_pc(act), ...
                    'rs', rs, 'rv', rv);
                regions{ireg} = region;
            end
    
            state0 = initStateBlackOilAD(model, regions);

        elseif simcase.usedeck && ~simcase.nonStdGrid
            state0 = initStateDeck(model, deck);
        else
            %solve ode to get pressure and interpolate to get initial pressure
            rho = @(p) model.fluid.rhoOS/model.fluid.bO(p, 0, 1);
            % well1Depth = 900;
            % wellCells = [schedule.control(3).W.cells];
            % well1Depth = G.cells.centroids(wellCells(1),3);
            resTop = min(G.nodes.coords(:,3)); % top of reservoir
            % equil = ode23(@(z, p) 9.81 .*rho(p), [well1Depth, resTop], 300*barsa); %gives pressure at top is 2.0754e+07
            % topPressure = equil.y(end);
            topPressure = 19620000;%hardcode top pressure to have same start as others 
            equil = ode23(@(z, p) 9.81 .*rho(p), [resTop, sort(unique(G.cells.centroids(:, 3)'))], topPressure);
            z_values = equil.x;
            pressure_values = equil.y;
            pressure_interp_func = @(z) interp1(z_values, pressure_values, z, 'linear');
            state0.pressure = pressure_interp_func(G.cells.centroids(:,3));
            state0.rs = zeros(G.cells.num, 1);
            state0.s = [ones(G.cells.num, 1), zeros(G.cells.num, 1)];
        end
    end
    linearSolverArguments = {'BackslashThreshold', 10000};
    nls = getNonLinearSolver(model, 'LinearSolverArguments', linearSolverArguments);
    if direct_solver
        nls.LinearSolver = BackslashSolverAD();
    end
    nls.maxTimestepCuts = 20;
    nls.maxIterations = 12;
    nls.useRelaxation = true;

end