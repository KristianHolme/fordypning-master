function simcase = addTopBotTags(simcase)
tol = 1200/500;
switch simcase.SPEcase
    case 'B'
        topy = 0;
        boty = 1200;
end
G = simcase.G;

[bf, bfc] = boundaryFaces(G);

% midbf = false(G.faces.num, 1);
% midbf((G.faces.centroids(bf,1) > 1) & (G.faces.centroids(bf,1) < 8399) & (G.faces.centroids(bf,2) < 0.99) & (G.faces.centroids(bf,2) > 0.1)...
%     & (G.faces.centroids(bf,3) < 1199) & (G.faces.centroids(bf,3) > 0.1)) = true;
% wrongcell = bfc(find(midbf, 10));

bfnormals = G.faces.normals(bf,:);

bfflat = abs(bfnormals(:,3)) > abs(bfnormals(:,1)) + abs(bfnormals(:,2));

bfflatc = bfc(bfflat);

topcells = bfflatc(G.cells.centroids(bfflatc,3) < 165);
botcells = bfflatc(G.cells.centroids(bfflatc,3) > 600);

G.cells.topCells = topcells;
G.cells.botCells = botcells;
simcase.G = G;
end