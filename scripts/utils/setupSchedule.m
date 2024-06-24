function [schedule, simcase] = setupSchedule(simcase, varargin)

    schedulecase = simcase.schedulecase;
    
    experimental = strcmp(schedulecase, 'experimental');


    if ~isempty(schedulecase)
        switch schedulecase
            case {'simple-std', 'experimental'}
                injectionTimeStep = 10*minute;
                settleTimeStep    = 10*minute;
            case 'simple-coarse'
                injectionTimeStep = 30*minute;
                settleTimeStep    = 120*minute;
            otherwise
                injectionTimeStep = 10*minute;
                settleTimeStep    = 10*minute;
        end


        G = simcase.G;
        rock = simcase.rock;    
        
        endTime = 5*day;
        injInterval = 2.5*hour;
        
        [wells1, wells2, wells3] = setupWells(simcase, varargin{:}, 'experimental', experimental);
        bc = setupBC(G, 'experimental', experimental, 'SPEcase', simcase.SPEcase);
        Tsettle = endTime - 2* injInterval;
        Nsettle = ceil(Tsettle/settleTimeStep);
        Ninterval = injInterval/injectionTimeStep;
        timesteps = [injectionTimeStep*ones(2*Ninterval, 1); settleTimeStep*ones(Nsettle,1 )];
    
        schedule.step.val = timesteps;
        schedule.step.control = [ones(Ninterval, 1); 
                                2*ones(Ninterval, 1);
                                3*ones(Nsettle, 1)];
        
        schedule.control = struct('W', wells1, 'src', [], 'bc', bc);
        schedule.control(2).W = wells2;
        schedule.control(2).bc = bc;
        schedule.control(3).W = wells3;
        schedule.control(3).bc = bc;
        % schedule = simpleSchedule(dt, 'w', wells1);
   

    elseif simcase.usedeck
        deck = simcase.deck;
        
        if ~isempty(simcase.gridcase)%using non-deck grid with deck-schedule
            deck_simcase = Simcase('SPEcase', simcase.SPEcase, 'deckcase', simcase.deckcase, 'usedeck', true);
            deckmodel = deck_simcase.model;
            deck = simcase.deck;
            schedule = convertDeckScheduleToMRST(deckmodel, deck);
            [cell1, cell2] = simcase.getinjcells;
            %change cells in schedule, and keep everything else
            for i = 1:numel(schedule.control)
                schedule.control(i).W(1).cells = cell1;
                schedule.control(i).W(2).cells = cell2;
                % if strcmp(simcase.SPEcase, 'C')
                %     schedule.control(i).W(1).dir = 'Y';
                %     schedule.control(i).W(2).dir = 'Y';
                %     schedule.control(i).W(1).WI = repmat(schedule.control(i).W(1).WI, numel(cell1), 1);
                %     schedule.control(i).W(2).WI = repmat(schedule.control(i).W(2).WI, numel(cell2), 1);
                %     schedule.control(i).W(1).dZ = repmat(schedule.control(i).W(1).dZ, numel(cell1), 1);
                %     schedule.control(i).W(2).dZ = repmat(schedule.control(i).W(2).dZ, numel(cell2), 1);
                %     rateMult = 50/0.035;
                %     schedule.control(i).W(1).val = schedule.control(i).W(1).val*rateMult;
                %     schedule.control(i).W(2).val = schedule.control(i).W(2).val*rateMult;
                % 
                % end
            end
            if strcmp(simcase.SPEcase, 'C')
                rates1mult = [0,1, 1, 0];
                rates2mult = [0,0, 1, 0];
                w1 = [];
                w2 = [];
                w3 = [];
                w4 = [];
                simcase.G.cells.wellMassRate = cell(1,2);
                for ic = 1:numel(cell1)
                    c = cell1(ic);
                    cellFaces = gridCellFaces(simcase.G, c);
                    ymin = max(1000, min(simcase.G.faces.centroids(cellFaces,2)));
                    ymax = min(4000, max(simcase.G.faces.centroids(cellFaces,2)));
                    massRateVal = 50/3000* (ymax-ymin);
                    simcase.G.cells.wellMassRate{1}(ic) = massRateVal;
                    rateval = massRateVal *1/deckmodel.fluid.rhoGS;
                    w1 = addWell(w1, simcase.G, simcase.rock, c, 'type', 'rate', 'val', 0, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                    w2 = addWell(w2, simcase.G, simcase.rock, c, 'type', 'rate', 'val', rateval, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                    w3 = addWell(w3, simcase.G, simcase.rock, c, 'type', 'rate', 'val', rateval, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                    w4 = addWell(w4, simcase.G, simcase.rock, c, 'type', 'rate', 'val', 0, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                end
                wellLength = integral(@(y)well2ArcSPE11C(y), 1000,4000);
                for ic = 1:numel(cell2)
                    c = cell2(ic);
                    cellFaces = gridCellFaces(simcase.G, c);
                    ymin = max(1000, min(simcase.G.faces.centroids(cellFaces,2)));
                    ymax = min(4000, max(simcase.G.faces.centroids(cellFaces,2)));
                    L = integral(@(y)well2ArcSPE11C(y), ymin,ymax);
                    massRateVal = 50 * L/wellLength;
                    simcase.G.cells.wellMassRate{2}(ic) = massRateVal;
                    rateval = massRateVal*1/deckmodel.fluid.rhoGS;
                    w1 = addWell(w1, simcase.G, simcase.rock, c, 'type', 'rate', 'val', 0, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                    w2 = addWell(w2, simcase.G, simcase.rock, c, 'type', 'rate', 'val', 0, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                    w3 = addWell(w3, simcase.G, simcase.rock, c, 'type', 'rate', 'val', rateval, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                    w4 = addWell(w4, simcase.G, simcase.rock, c, 'type', 'rate', 'val', 0, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                end 
                wells = {w1, w2, w3, w4};
                for i = 1:numel(schedule.control)
                    schedule.control(i).W = wells{i};
                end
            end

        else
            model = simcase.model;
            schedule = convertDeckScheduleToMRST(model, deck);
            [cell1, cell2] = simcase.getinjcells;
            %change cells in schedule, and keep everything else
            for i = 1:numel(schedule.control)
                schedule.control(i).W(1).cells = cell1;
                schedule.control(i).W(2).cells = cell2;
            end
        end
        G = simcase.G;
        bf = boundaryFaces(G);

        if simcase.griddim == 2
            %adjust rate by multiplying with 100
            for i = 1:numel(schedule.control)
                multFactor = 100;
                for j = 1:numel(schedule.control(i).W)
                    schedule.control(i).W(j).val = schedule.control(i).W(j).val * multFactor;
                end
            end
        end
    
        %add more time steps
        timeStepMultiplier = 100;
        vals = schedule.step.val;
        ctrl = schedule.step.control;
        if numel(ctrl) == 4
            schedule.step.control = ctrl(1);
            schedule.step.val = vals(1);
            firstActiveControl = 2;
        else
            schedule.step.control = [];
            schedule.step.val = [];
            firstActiveControl = 1;
        end
        schedule.step.control = [schedule.step.control;
            repmat(ctrl(firstActiveControl), timeStepMultiplier,1);
            repmat(ctrl(firstActiveControl+1), timeStepMultiplier,1)
            repmat(ctrl(firstActiveControl+2), timeStepMultiplier,1)
            ];
        schedule.step.val = [schedule.step.val;
            repmat(vals(firstActiveControl)/timeStepMultiplier, timeStepMultiplier,1);
            repmat(vals(firstActiveControl+1)/timeStepMultiplier, timeStepMultiplier,1)
            repmat(vals(firstActiveControl+2)/timeStepMultiplier, timeStepMultiplier,1)
            ];
        
        bc = setupBC(G, 'experimental', experimental, 'SPEcase', simcase.SPEcase);
        for i = 1:numel(schedule.control)
            schedule.control(i).bc = bc;
        end
    else
        schedule = [];
        disp('No schedule assigned.')
    end
end
