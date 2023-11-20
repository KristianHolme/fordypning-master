function G = StretchGrid(G)
    %input: 3D grid that is in x-z plane with single layer in y-direction
    %scales from A-grids to B-grids
    G.nodes.coords(:,1) = G.nodes.coords(:,1)*3000;
    % G.nodes.coords(:,2) = G.nodes.coords(:,2)*100;%from 0.01 depth to 1,
    % not necessary bc. correct setup done in setupGrid
    G.nodes.coords(:,3) = G.nodes.coords(:,3)*1000;
    G.type{end+1} = 'stretchGrid';
    G = computeGeometry(G);
end