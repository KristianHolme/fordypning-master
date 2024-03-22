function G = getBufferCells(G)
    %adds a field bufferCells to G
    % assert(isfield(G.cells, 'tag'), "No tag on G.cells!")
    if ~isfield(G.cells, 'tag')
        warning("No fascies tags found, can't tag buffer volumes!" )
        return
    end
    

    bf = boundaryFaces(G);
    
    
    xlimit = max(G.faces.centroids(:,1));
    tol = 1e-10;

    G.bufferCells = [];
    G.bufferFaces = [];

    for iface = 1:numel(bf)
        face = bf(iface);
        if (abs(G.faces.centroids(face, 1)) < tol) || (abs(G.faces.centroids(face, 1) - xlimit) < tol)
            cell = max(G.faces.neighbors(face, :));
            facies = G.cells.tag(cell);
            assert(facies ~=6 )
            
            %tag all cells, even if added volume is zero
            G.bufferCells(end+1) = cell;
            G.bufferFaces(end+1) = face; 
        end
    end
    %Fix for triangle grids?
    if any(G.cells.centroids(:,1)>2000)
        sideCells = find(G.cells.centroids(:,1) > 8399 | G.cells.centroids(:,1) < 1);
    else
        sideCells = find(G.cells.centroids(:,1) > 8399/3000 | G.cells.centroids(:,1) < 1/3000);
    end
    newBdryCells = setdiff(sideCells, G.bufferCells);
    dispif(~isempty(newBdryCells), 'Adding bdryCells without bdryFaces!\n');
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
