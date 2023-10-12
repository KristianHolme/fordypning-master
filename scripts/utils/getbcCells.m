function bcCells = getbcCells(simcase)
    %filter cells that are high up
    % cellIxs = find(G.cells.centroids(:, 3)< 0.3);
    
    G = simcase.G; 
    cellIxs = 1:G.cells.num;
    cellfaces = G.cells.faces(mcolon(G.cells.facePos(cellIxs)', G.cells.facePos(cellIxs+1)'-1));
    cellfaces = cellfun(@(x) G.cells.faces(G.cells.facePos(x):G.cells.facePos(x+1)-1), num2cell(cellIxs), 'UniformOutput', false);
    bf = [];
    if ~isempty(simcase.schedule)
        bf = simcase.schedule.control(1).bc.face;
    end
    
    % bf = boundaryFaces(G);
    % bf = bf(G.faces.centroids(bf, 3) < 1e-12);

    bcCells = cellIxs(find(cellfun(@(x) any(ismember(x, bf)), cellfaces)));
end