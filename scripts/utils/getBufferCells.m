function G = getBufferCells(G)
    %adds a field bufferCells to G
    assert(isfield(G.cells, 'tag'), "No tag on G.cells!")
    % if ~isfield(G.cells, 'tag')
    %     G.cells.tag = rock.regions.saturation;
    % end
    

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
end
