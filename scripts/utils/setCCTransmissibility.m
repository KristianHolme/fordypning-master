function model = setCCTransmissibility(model, K_system)
    G = model.G;
    rock = model.rock;
    
    % K_system = 'xyz';

    N      = G.faces.neighbors;
    intInx = all(N ~= 0, 2);

    faceCenters = G.faces.centroids;
    % cellFaceCenters = faceCenters(G.cells.faces(:,1),:);

    F = faceCenters(intInx, :);
    A = G.cells.centroids(G.faces.neighbors(intInx,1),:);
    B = G.cells.centroids(G.faces.neighbors(intInx,2),:);
    N = G.faces.normals(intInx,:);

    t = dot(F-A, N, 2) ./ dot(B-A, N, 2);

    faceCenters(intInx,:) = A + ((B-A) .* t);

    cellFaceCenters = faceCenters(G.cells.faces(:,1),:);

    T = getFaceTransmissibility(G, rock, 'K_system', K_system, 'cellFaceCenters', cellFaceCenters);
    
    
    T_all = T;
    
    T     = T(intInx);

    model.operators.T = T;
    model.operators.T_all = T_all;
end