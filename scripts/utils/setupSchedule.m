function [schedule, simcase] = setupSchedule(simcase, varargin)
    opt = struct('rateMultiplier', 1);
    opt = merge_options(opt, varargin{:});
    schedulecase = simcase.schedulecase;
    if isempty(schedulecase)
        schedulecase = '';
    end
    experimental = strcmp(schedulecase, 'experimental');


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
        end
        if strcmp(simcase.SPEcase, 'C')
            w1 = [];
            w2 = [];
            w3 = [];
            w4 = [];
            simcase.G.cells.wellMassRate = cell(1,2);
            for ic = 1:numel(cell1)
                c = cell1(ic);
                
                massRateVal = getMassRate(simcase, 1, c, cell1, []);
                simcase.G.cells.wellMassRate{1}(ic) = massRateVal;
                rateval = massRateVal*1/deckmodel.fluid.rhoGS * opt.rateMultiplier;
                w1 = addWell(w1, simcase.G, simcase.rock, c, 'type', 'rate', 'val', 0, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                w2 = addWell(w2, simcase.G, simcase.rock, c, 'type', 'rate', 'val', rateval, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                w3 = addWell(w3, simcase.G, simcase.rock, c, 'type', 'rate', 'val', rateval, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
                w4 = addWell(w4, simcase.G, simcase.rock, c, 'type', 'rate', 'val', 0, 'radius', 0.15, 'dir', 'y', 'compi', [0,1], 'sign', 1, 'refDepth', simcase.G.cells.centroids(c, 3));
            end
            wellLength = integral(@(y)well2ArcSPE11C(y), 1000,4000);
            for ic = 1:numel(cell2)
                c = cell2(ic);

                massRateVal = getMassRate(simcase, 2, c, cell2, wellLength);
                
                simcase.G.cells.wellMassRate{2}(ic) = massRateVal;
                rateval = massRateVal*1/deckmodel.fluid.rhoGS * opt.rateMultiplier;
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
    % bf = boundaryFaces(G);

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
    switch schedulecase
        case 'animationFriendly'
            timeStepMultiplier = [18, 18, 684];
        case 'skipEquil'
            schedule.step.control = schedule.step.control(2:end);
            schedule.step.val = schedule.step.val(2:end);

            timeStepMultiplier = [100,100,100];

        otherwise
            timeStepMultiplier = [100,100,100];
    end
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
        repmat(ctrl(firstActiveControl), timeStepMultiplier(1),1);
        repmat(ctrl(firstActiveControl+1), timeStepMultiplier(2),1);
        repmat(ctrl(firstActiveControl+2), timeStepMultiplier(3),1)
        ];
    schedule.step.val = [schedule.step.val;
        repmat(vals(firstActiveControl)/timeStepMultiplier(1), timeStepMultiplier(1), 1);
        repmat(vals(firstActiveControl+1)/timeStepMultiplier(2), timeStepMultiplier(2), 1)
        repmat(vals(firstActiveControl+2)/timeStepMultiplier(3), timeStepMultiplier(3), 1)
        ];
    
    bc = setupBC(G, 'experimental', experimental, 'SPEcase', simcase.SPEcase);
    for i = 1:numel(schedule.control)
        schedule.control(i).bc = bc;
    end

end

function [ymin, ymax] = getWellCellYMinMax(simcase, c)
cellFaces = gridCellFaces(simcase.G, c);
if simcase.nonStdGrid
    ymin = -Inf;
    ymax = Inf;
else
    ymin = 1000;
    ymax = 4000;
end
ymin = max(ymin, min(simcase.G.faces.centroids(cellFaces,2)));
ymax = min(ymax, max(simcase.G.faces.centroids(cellFaces,2)));
end

function L = getWellLengthInCell(simcase, c, ymin, ymax)
if simcase.nonStdGrid
    L = ymax-ymin;
else
    L = integral(@(y)well2ArcSPE11C(y), ymin,ymax);
end
end

function massRateVal = getMassRate(simcase, well, cell, cells, wellLength)
G = simcase.G;
if simcase.nonStdGrid
    totalvolume = sum(G.cells.volumes(cells));
    volumeproportion = G.cells.volumes(cell)/totalvolume;
    totalMassRate = 50;
    massRateVal = totalMassRate*volumeproportion;
else
    switch well
        case 1
            [ymin, ymax] = getWellCellYMinMax(simcase, cell);
            massRateVal = 50/3000* (ymax-ymin);
        case 2
            [ymin, ymax] = getWellCellYMinMax(simcase, c);
            L = getWellLengthInCell(simcase, c, ymin, ymax);
            
            massRateVal = 50 * L/wellLength;
    end
end


end