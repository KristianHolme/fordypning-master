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
        well1Coords = [well1Start;well1End];

        % well2InterpPts = 100;
        well2Start = SPE11CBend([5100,1000, 1200-700]);
        layerSize = G.cells.num/G.numLayers;
        % well2End = SPE11CBend([5100,4000, 1200-700]);
        well2StartCell = findEnclosingCell(G, well2Start);
        well2Index = zeros(G.numLayers,1);
        well2Index(1) = well2StartCell;
        well2IndPos = 1;
        while min(G.faces.centroids(gridCellFaces(G,well2Index(well2IndPos)),2))<4000
            well2IndPos = well2IndPos + 1;
            well2Index(well2IndPos) = well2Index(well2IndPos-1) + layerSize;
        end
        well2Index = well2Index(1:find(well2Index==0, 1)-2);

        % well2Coords = repmat([5100,1000, 1200-700], well2InterpPts,1);
        % well2Coords(:,2) = linspace(1000, 4000, well2InterpPts);
        % well2Coords = SPE11CBend(well2Coords);

        well1Pth = makeSingleWellpath(well1Coords);
        % well2Pth = makeSingleWellpath(well2Coords);
        
        well1Index = findWellPathCells(G, well1Pth);
        ymin = arrayfun(@(c)min(G.faces.centroids(gridCellFaces(G, c),2)), well1Index);
        ymax = arrayfun(@(c)max(G.faces.centroids(gridCellFaces(G, c),2)), well1Index);
        inCells = ymin < 4000 & ymax > 1000;
        well1Index = well1Index(inCells);
        % plotGrid(G, well1Index);view(90,0);
    end
    
end