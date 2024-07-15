function [well1Ix, well2Ix] = getTransfaultInjCells(G, name)
    switch name
        case 'flat_tetra_subwell'
            injCoords1 = [1.4e4 0.6e4 290;1.4e4 0.6e4 290];
        
            injCoords2 = [1.4e4 0.6e4 150;1.4e4 0.6e4 150];
        otherwise
            num_interps = 50;
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
        
    well1Ix = findWellPathCells(G, well1Pth);
    well2Ix = findWellPathCells(G, well2Pth);
end