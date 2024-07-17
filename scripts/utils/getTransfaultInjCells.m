function [well1Ix, well2Ix] = getTransfaultInjCells(G, name)
    num_interps = 50;
    switch name
        case 'flat_tetra_subwell'
            injCoords1 = [1.4e4 0.6e4 290;1.4e4 0.6e4 290];
        
            injCoords2 = [1.4e4 0.6e4 150;1.4e4 0.6e4 150];
        case 'flat_tetra'
            injCoords1 = [1.4e4 0.6e4 240;1.4e4 0.6e4 290];
        
            injCoords2 = [0.6e4 1.4e4 110;0.6e4 1.4e4 160];
            
            t = linspace(0, 1, num_interps)';
            injCoords1 = t * injCoords1(1,:) - (t-1)*injCoords1(2,:);
            injCoords2 = t * injCoords2(1,:) - (t-1)*injCoords2(2,:);
        case {'gmshCuboids', 'gmshCuboids-M', 'tet-C', 'tet-M', 'tet-F'}
            injCoords1 = [2700, 1000, 1200-300;
                          2700, 4000, 1200-300];
            injCoords2 = [5100, 1000, 1200-700;
                          5100, 4000, 1200-700];
            t = linspace(0, 1, num_interps)';
            injCoords1 = t * injCoords1(1,:) - (t-1)*injCoords1(2,:);
            injCoords2 = t * injCoords2(1,:) - (t-1)*injCoords2(2,:);
        otherwise
            
            I1RelCoordsStart = [0.3, 0.3, 0.2];
            I1RelCoordsEnd = [0.3, 0.7, 0.3];
            
            I2RelCoordsStart = [0.7, 0.4, 0.4];
            I2RelCoordsEnd = [0.8, 0.6, 0.4];
            
            
            injCoords1 = [getInterpolatedCoords(G, 'xrel', I1RelCoordsStart(1), 'yrel', I1RelCoordsStart(2), 'zrel', I1RelCoordsStart(3));...
                         getInterpolatedCoords(G, 'xrel', I1RelCoordsEnd(1), 'yrel', I1RelCoordsEnd(2), 'zrel', I1RelCoordsEnd(3))];
        
            injCoords2 = [getInterpolatedCoords(G, 'xrel', I2RelCoordsStart(1), 'yrel', I2RelCoordsStart(2), 'zrel', I2RelCoordsStart(3));...
                         getInterpolatedCoords(G, 'xrel', I2RelCoordsEnd(1), 'yrel', I2RelCoordsEnd(2), 'zrel', I2RelCoordsEnd(3))];
            t = linspace(0, 1, num_interps)';
            injCoords1 = t * injCoords1(1,:) - (t-1)*injCoords1(2,:);
            injCoords2 = t * injCoords2(1,:) - (t-1)*injCoords2(2,:);
        
    end
    
    
    well1Pth = makeSingleWellpath(injCoords1);
    well2Pth = makeSingleWellpath(injCoords2);
    
    %approximate
    well1Ix = findWellCells(G, injCoords1);
    well2Ix = findWellCells(G, injCoords2);

    %find candidates
    nbs1 = findCellNeighbors(G, well1Ix, 2);
    nbs2 = findCellNeighbors(G, well2Ix, 2);
    
    well1Ix = unique(findEnclosingCell(G, injCoords1, nbs1));
    well2Ix = unique(findEnclosingCell(G, injCoords2, nbs2));
    % well1Ix = findWellPathCells(G, well1Pth);
    % well2Ix = findWellPathCells(G, well2Pth);
end

function cells = findWellCells(G, pts)
cells = zeros(size(pts, 1), 1);
for i = 1:size(pts ,1)
    pt = pts(i,:);
    [~, cells(i)] = min(vecnorm(G.cells.centroids - pt, 2, 2));
end
cells = unique(cells);
end