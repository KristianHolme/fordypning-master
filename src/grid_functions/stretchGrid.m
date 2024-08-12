function G = stretchGrid(G)
    %input: 3D grid that is in x-z plane with single layer in y-direction
    %scales from A-grids to B-grids
    if isfield(G, 'parent') %coarsegrid
        nodes = G.parent.nodes;
    else
        nodes = G.nodes;
    end
    nodes.coords(:,1) = nodes.coords(:,1)*3000;
    if max(nodes.coords(:, 2)) < 0.5
        nodes.coords(:,2) = nodes.coords(:,2)*100;%from 0.01 depth to 1,
    end
    % not necessary bc. correct setup done in setupGrid
    nodes.coords(:,3) = nodes.coords(:,3)*1000;
    G.type{end+1} = 'stretchGrid';
    if isfield(G, 'parent') %coarsegrid
        G.parent.nodes = nodes;
        G = coarsenGeometry(G);
    else
        G.nodes = nodes;
        G = computeGeometry(G);
    end
end