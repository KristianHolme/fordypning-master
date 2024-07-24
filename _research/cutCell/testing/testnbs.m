G = simcase.G;
cell = randi(G.cells.num);

nbs = findCellNeighbors(G, cell, 5);