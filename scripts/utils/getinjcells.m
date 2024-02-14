function [well1Index, well2Index] = getinjcells(G, SPEcase)
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

    end
end