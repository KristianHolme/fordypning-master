function [wells1, wells2, wells3] = setupWells11A(G, rock, varargin)
    [~, dim] = size(G.cells.centroids);
    if dim == 3
        well1Coords = [0.9, 0.05, 1.2-0.3];
        well2Coords = [1.7, 0.05, 1.2-0.7];
    else
        well1Coords = [0.9, 0.3];
        well2Coords = [1.7, 0.7];
    end

    testFactor = 1;
    wellRate = 1.7e-7/2.05864576494*testFactor;%FIXME correct rate??make dep on pressure?
    wellRadius = 9e-4;%m

    [~,well1Index] = min(vecnorm(G.cells.centroids - well1Coords, 2, 2));
    [~,well2Index]=  min(vecnorm(G.cells.centroids - well2Coords, 2, 2));

    wells = addWell([], G, rock, well1Index, 'Type', 'rate', 'val', wellRate, ...
        'radius', wellRadius, 'compi', [0, 1], 'name', 'INJE01', 'dir', 'z');
    
    %well2 inactive
    wells1 = addWell(wells, G, rock, well2Index, 'Type', 'rate', 'val', wellRate, ...
        'radius', wellRadius, 'compi', [0, 1], 'name', 'INJE02', 'dir', 'z', 'sign', 1, ...
        'status', false);
    %turn on well2
    wells2 = wells1;
    wells2(2).status = true;
    
    %turn off both wells
    wells3 = wells2;
    wells3(1).status = false;
    wells3(2).status = false;
    
    
    % wells2 = addWell(wells, G, rock, well2Index, 'Type', 'rate', 'val', wellRate, ...
    %     'radius', wellRadius, 'compi', [0, 1], 'name', 'Well 2', 'dir', 'y', 'sign', 1);
    % wells3 = wells1;
    % wells3(1).val = 0;
end