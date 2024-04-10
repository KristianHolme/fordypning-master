function [well1Index, well2Index, well1Coords, well2Coords] = getinjcells(G, SPEcase)
    % SPEcase = simcase.SPEcase;
    % G = simcase.G;
    if strcmp(SPEcase, 'A')
        [~, dim] = size(G.cells.centroids);
        if dim == 3
            well1Coords = [0.9, 0.005, 1.2-0.3];
            well2Coords = [1.7, 0.005, 1.2-0.7];
        else
            well1Coords = [0.9, 0.3];
            well2Coords = [1.7, 0.7];
        end
        [~,well1Index] = min(vecnorm(G.cells.centroids - well1Coords, 2, 2));
        [~,well2Index] = min(vecnorm(G.cells.centroids - well2Coords, 2, 2));
    elseif strcmp(SPEcase, 'B')
        [~, dim] = size(G.cells.centroids);
        if dim == 3
            well1Coords = [2700, 0.5, 1200-300];
            well2Coords = [5100, 0.5, 1200-700];
        else
            well1Coords = [2700, 300];
            well2Coords = [5100, 700];
        end
        [~,well1Index] = min(vecnorm(G.cells.centroids - well1Coords, 2, 2));
        [~,well2Index] = min(vecnorm(G.cells.centroids - well2Coords, 2, 2));
    elseif strcmp(SPEcase, 'C')
        well1Start = [2700, 1000, 1200-300];
        well1End = [2700, 4000, 1200-300];
        well1Pts = [well1Start;well1End];

        well2InterpPts = 100;
        well2Pts = repmat([5100,1000, 700], well2InterpPts,1);
        well2Pts(:,2) = linspace(1000, 4000, well2InterpPts);
        well2Pts = SPE11CBend(well2Pts);

        well1Pth = makeSingleWellpath(well1Pts);
        well2Pth = makeSingleWellpath(well2Pts);
        
        well1Index = findWellPathCells(G, well1Pth);
        well2Index = findWellPathCells(G, well2Pth);

    end
    
end