function bcCells = getbcCells(simcase)
    %filter cells that are high up
    G = simcase.G;
    cellIxs = find(G.cells.centroids(:, 3)< 0.3);

    cellfaces = G.cells.faces(mcolon(G.cells.facePos(cellIxs)', G.cells.facePos(cellIxs+1)'-1));
    cellfaces = cellfun(@(x) G.cells.faces(G.cells.facePos(x):G.cells.facePos(x+1)-1), num2cell(cellIxs), 'UniformOutput', false);
    bf = boundaryFaces(G);
    bf = bf(G.faces.centroids(bf, 3) < 1e-12);

    bcCells = cellIxs(find(cellfun(@(x) any(ismember(x, bf)), cellfaces)));
end