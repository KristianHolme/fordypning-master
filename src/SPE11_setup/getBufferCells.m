function G = getBufferCells(G)
    %adds a field bufferCells to G

    

    bf = boundaryFaces(G);
    
    
    xlimit = max(G.faces.centroids(:,1));
    ylimit = max(G.faces.centroids(:,2));
    tol = 1e-10;
    caseC = max(G.cells.centroids(:,2) > 2500);

    G.bufferCells = [];
    G.bufferFaces = [];

    bufferFaces = (abs(G.faces.centroids(bf, 1)) < tol) | (abs(G.faces.centroids(bf, 1) - xlimit) < tol);
    if caseC
        frontbackBfs = (abs(G.faces.centroids(bf, 2)) < tol) | (abs(G.faces.centroids(bf, 2) - ylimit) < tol);
        bufferFaces = bufferFaces | frontbackBfs;
    end
    
    bufferCells = unique(max(G.faces.neighbors(bf(bufferFaces),:), [], 2));
    % facies = G.cells.tag(bufferCells);
    G.bufferCells = bufferCells';
    G.bufferFaces = bf(bufferFaces)';

    %Fix for triangle grids?
    if any(G.cells.centroids(:,1)>2000)
        sideCells = find(G.cells.centroids(:,1) > 8399 | G.cells.centroids(:,1) < 1);
    else
        sideCells = find(G.cells.centroids(:,1) > 8399/3000 | G.cells.centroids(:,1) < 1/3000);
    end
    newBdryCells = setdiff(sideCells, G.bufferCells);
    % dispif(~isempty(newBdryCells), 'Adding bdryCells without bdryFaces!\n');
    for inc = 1:numel(newBdryCells)
        cell = newBdryCells(inc);
        faces = gridCellFaces(G, cell);
        normals = G.faces.normals(faces, :);
        areas = G.faces.areas(faces);
        invector = [1;0;0]*sign(4200-G.cells.centroids(cell,1));
        [I, ~, ~] = find((G.faces.neighbors(faces,:) == cell)');
        insideFace = find(abs((normals.*sign(1.5 - I) * invector) - areas) < 1e-6);
        assert(numel(insideFace)==1, 'More than one bdryface detected!');

        G.bufferCells(end+1) = cell;
        G.bufferFaces(end+1) = insideFace;
    end
end
