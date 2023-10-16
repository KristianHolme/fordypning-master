function neighborCells = findCellNeighbors(G, cell_ids, paddingLayers)
    % finds neighbores based on node sharing
    neighborCells = cell_ids;
    if isempty(cell_ids)
        return
    end
    if paddingLayers == 0
        return
    elseif paddingLayers == -1
        neighborCells = []; %if padding level is -1, then we dont have any tpfacells
        return
    end
    numCells = G.cells.num;
    cellsToNodes = cell(round(numCells), 1);
    for ic = 1:G.cells.num
        nodes = getNodes(G, ic);
        cellsToNodes{ic} = nodes;
    end

    
    for i=1:paddingLayers
        % newCells = [];
        newNeighbors = bruteForceNeighors(numCells, neighborCells, cellsToNodes);
        % for icell = 1:numel(neighborCells)
        %     cellId = neighborCells(icell);
        %     newNeighbors = bruteForceNeighors(numCells, cellId, cellsToNodes);
        %     % newNeighbors = getCellLayer(G, cellId);
        %     newCells = union(newCells, newNeighbors);
        % end
        neighborCells = union(neighborCells, newNeighbors);
    end
end

function neighBorsByNode = bruteForceNeighors(numCells, cellIds, cellsToNodes)
    neighBorsByNode = [];
    oldNodes = [];
    for ici = 1:numel(cellIds)
        cellId = cellIds(ici);
        oldNodes = union(oldNodes, cellsToNodes{cellId});
    end
    for ic = 1:numCells
        if ismember(ic, cellIds)
            continue
        end
        if numel(intersect(cellsToNodes{ic}, oldNodes)) > 1
            neighBorsByNode = union(neighBorsByNode, ic);
        end
    end
end

function cellLayer = getCellLayer(G, cellId)
    centerNodes = getNodes(G, cellId);
    
    neighborsByFace = getNeighborsByFace(G, cellId);
    
    cellLayer = neighborsByFace;
    nodeNeighborCandidates = [];

    for in = 1:numel(neighborsByFace)
        neighbor = neighborsByFace(in);
        neighborNeighbors = setdiff(getNeighborsByFace(G, neighbor), cellId);
        neighborNeighbors = setdiff(neighborNeighbors, neighborsByFace);
        nodeNeighborCandidates = union(nodeNeighborCandidates, neighborNeighbors);
    end
    nodeNeighborCandidates = unique(nodeNeighborCandidates);
    nodeNeighborCandidates = setdiff(nodeNeighborCandidates, neighborsByFace);
    for inn = 1:numel(nodeNeighborCandidates)
        neighborNeighbor = nodeNeighborCandidates(inn);

        nnNodes = getNodes(G, neighborNeighbor);
        sharedNodes = numel(intersect(nnNodes, centerNodes));
        assert(sharedNodes < 3, 'should only share two nodes');
        if sharedNodes == 2
            cellLayer = union(cellLayer, neighborNeighbor);
        end
    end
    cellLayer = unique(cellLayer);
        
end

function neighborsByFace = getNeighborsByFace(G, cellId)
    cellFaces = getFaces(G, cellId);
    neighborsByFace = G.faces.neighbors(cellFaces, :);
    neighborsByFace = setdiff(unique(neighborsByFace(:)), [cellId;0]);
end


function nodes = getNodes(G, cellId)
    faces = getFaces(G, cellId);
    nodes = unique(G.faces.nodes(mcolon(G.faces.nodePos(faces), G.faces.nodePos(faces+1)-1)));

end

function faces = getFaces(G, cellId)
    faces = G.cells.faces(G.cells.facePos(cellId):G.cells.facePos(cellId+1)-1);
end