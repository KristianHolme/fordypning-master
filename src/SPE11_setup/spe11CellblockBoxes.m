function cellBlocks = spe11CellblockBoxes(G, varargin)
opt = struct('SPEcase', 'B', ...
    'box', 'leftFaultEntry');

centroids = G.cells.centroids;

switch opt.box
    case 'leftFaultEntry'
        p1 = [1070, 840];
        p2 = [1360, 690];
end

cellsInX = centroids(:,1) < p2(1) & centroids(:,1) > p1(1);
cellsInZ = centroids(:,3) > p2(2) & centroids(:,3) < p1(2);

cellsInBox = find(cellsInX & cellsInZ);

cellBlocks = cell(2,1);

cellBlocks{1} = setdiff(1:G.cells.num, cellsInBox)';
cellBlocks{2} = cellsInBox;

end

