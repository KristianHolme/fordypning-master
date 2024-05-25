GenerateCutCellGrid(500,40, 'presplit', true, 'partitionMethod', 'facearea', ...
    'type', 'cartesian', 'save', false)

CG = generateCoarseGrid(G, partition);
CG = coarsenGeometry(CG);
[maxCG, i] = max(CG.cells.volumes);
maxold = max(G.cells.volumes);
CG.cells.centroids(i,:)
[CGcellToGcutCell, IA] = unique(partition);
G = TagbyFacies(G, geodata, 'vertIx', 3);
CG.cells.tag = G.cells.tag(IA);

% VizCoarse(CG)z    
clf
plotCellData(G, G.cells.tag);view(0,0);
plotGrid(CG, i, 'facecolor', 'r');
set(gca, 'xlim', [3950, 4350], 'zlim', [440, 580]);