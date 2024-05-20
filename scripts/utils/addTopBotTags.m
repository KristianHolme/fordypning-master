function simcase = addTopBotTags(simcase)
tol = 1200/500;
switch simcase.SPEcase
    case 'B'
        topy = 0;
        boty = 1200;
    case 'C'
        topy = 0;
        boty = 1200;
        simcase.G.nodes.coords = SPE11CUnBend(simcase.G.nodes.coords);
        simcase.G = mcomputeGeometry(simcase.G);
end
G = simcase.G;

[bf, bfc] = boundaryFaces(G);

midbf = false(G.faces.num, 1);
midbf((G.faces.centroids(bf,1) > 1) & (G.faces.centroids(bf,1) < 8399) & (G.faces.centroids(bf,2) < 0.99) & (G.faces.centroids(bf,2) > 0.1)...
   & (G.faces.centroids(bf,3) < 1199) & (G.faces.centroids(bf,3) > 0.1)) = true;
wrongcell = unique(bfc(midbf));

bfsel = bf( G.faces.centroids(bf,3)>0.01 & G.faces.centroids(bf, 2)>0.1 & G.faces.centroids(bf, 2)<0.99 & (G.faces.centroids(bf,1) > 1) & (G.faces.centroids(bf,1) < 8399));
% clf;
% plotFaces(G, bfsel);view(10,10);
% plotGrid(G, 'facecolor', 'none');
% plotGrid(G, wrongcell);view(0,0);

bfnormals = G.faces.normals(bf,:);

bfflat = abs(bfnormals(:,3)) > abs(bfnormals(:,1)) + abs(bfnormals(:,2));

bfflatc = bfc(bfflat);

topcells = bfflatc(G.cells.centroids(bfflatc,3) < 165);
botcells = bfflatc(G.cells.centroids(bfflatc,3) > 600);

G.cells.topCells = topcells;
G.cells.botCells = botcells;
if strcmp(simcase.SPEcase, 'C')
    G.nodes.coords = SPE11CBend(G.nodes.coords);
    G = mcomputeGeometry(G);
end
% figure;
% plotGrid(G, [topcells;botcells])
% title('top and bottom cells');
simcase.G = G;
end
