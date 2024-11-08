Lx = 1;
Ly = 1;
nx = 2;
ny = 2;
G = cartGrid([nx ny 1], [Lx, Ly 1]);
G = computeGeometry(G);

partition = [1 2 3 4]';
Gp = makePartitionedGrid(G, partition);
%%
compareGrids(G, Gp)

%%
load("data/grid-files/cutcell/horizon_presplit_cutcell_PG_28x12.mat")
e1 = [1 0 0];e2 = [0 1 0];e3 = [0 0 1];
bf = boundaryFaces(G);
normals = G.faces.normals ./ G.faces.areas;
f1 = abs(normals * e1') == 1;
f2 = abs(normals * e2') == 1;
f3 = abs(normals * e3') == 1;

faces = setdiff(bf, find(f3));
clf;
plotFaces(G, faces);view(0,0);

%% random
plotGrid(simcase.G, 'facealpha', 0);view(0,0);hold on;
for i =1:numel(simcase.G.bufferCells)
    plotGrid(simcase.G, simcase.G.bufferCells(i));
    ;
end

