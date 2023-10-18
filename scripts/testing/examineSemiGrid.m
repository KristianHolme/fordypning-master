clear all
close all
%%
load("11thSPE-CSP\geometries\11AFiles\spe11a_semi190x100_0.5_grid.mat")
%%
zeroAreaFaces = find(G.faces.areas <=0);
plotGrid(G, 'facealpha', 0, 'edgealpha', 0.2);axis tight;hold on;
for i =1:numel(zeroAreaFaces)
    face = zeroAreaFaces(i);
    nodes = G.faces.nodes(G.faces.nodePos(face):G.faces.nodePos(face+1)-1);
    nodecoords = G.nodes.coords(nodes,:);
    plot(nodecoords(:,1), nodecoords(:,2), 'color', 'r','LineWidth', 2);
end
hold off;
%%
[G, cellmap] = removeShortEdges(G, 1e-12);
%%
% plotGrid(Gr)
checkGrid(G)
%%
min(Gr.faces.areas)
%%
G = computeGeometry(G);