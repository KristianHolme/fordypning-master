function G = transfaultGetBufferCells(G)
xmin = min(G.nodes.coords(:,1));
xmax = max(G.nodes.coords(:,1));
ymin = min(G.nodes.coords(:,2));
ymax = max(G.nodes.coords(:,2));

nodeCoords = G.nodes.coords;


tol = 1e-10;
bufferNodes = abs(nodeCoords(:,1)-xmin)<tol | abs(nodeCoords(:,1)-xmax)<tol | ...
              abs(nodeCoords(:,2)-ymin)<tol | abs(nodeCoords(:,2)-ymax)<tol;

[n, pos] = gridCellNodes(G, 1:G.cells.num);
cellNo = rldecode(1 : G.cells.num, diff(pos), 2) .';
nOnSides = bufferNodes(n);
bufferCells = unique(cellNo(nOnSides));

G.bufferCells = bufferCells;
eps = 34;
M = 1 + 5e4/eps;
G.cells.volumes(bufferCells) = G.cells.volumes(bufferCells).*M;
end
