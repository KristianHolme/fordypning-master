function G = getBufferCells(G)
    %adds a field bufferCells to G
    assert(isfield(G.cells, 'tag'), "No tag on G.cells!")
    % if ~isfield(G.cells, 'tag')
    %     G.cells.tag = rock.regions.saturation;
    % end
    

    bf = boundaryFaces(G);
    
    tol = 1e-10;
    xlimit = max(G.faces.centroids(:,1));
    areaVolumeConstant = 5e4;

    G.bufferCells = [];

    for iface = 1:numel(bf)
        face = bf(iface);
        faceArea = G.faces.areas(face);
        if (abs(G.faces.centroids(face, 1)) < tol) || (abs(G.faces.centroids(face, 1) - xlimit) < tol)
            cell = max(G.faces.neighbors(face, :));
            facies = G.cells.tag(cell);
            assert(facies ~=6 )
            
            %tag all cells, even if added volume is zero
            G.bufferCells(end+1) = cell;
            
        end
    end
end
