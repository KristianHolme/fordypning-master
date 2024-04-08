function G2D = removeLayeredGrid(G)
%inverse of makeLyeredGrid(G, 1)
if numel(unique(round(G.cells.centroids(:,1),12)))==1
    dir=[1,0,0];
elseif (numel(unique(round(G.cells.centroids(:,2),12)))==1)
    dir=[0,1,0];
elseif numel(unique(round(G.cells.centroids(:,3),12)))==1
    dir=[0,0,1];
end
% dirIx = find(dir);
tol = 1e-9;
dirFaces = abs(abs(G.faces.normals*dir')-G.faces.areas) <tol;
dirNodes = abs(G.nodes.coords(:,find(dir))) > tol;

G2D = G;
G2D.cells.centroids = G.cells.centroids(:,~dir);
G2D.faces.centroids = G.faces.centroids(:,~dir);
G2D.nodes.coords = G.nodes.coords(:,~dir);
G2D = removeFaces(G2D, dirFaces);
G2D = removeNodes(G2D, dirNodes);
G2D.griddim = 2;
G2D.nodes.coords(:,2) = max(G2D.nodes.coords(:,2)) - G2D.nodes.coords(:,2);

G2D = computeGeometry(G2D);

checkGrid(G2D);


end

function G = removeNodes(G, rmnodes)
%rmnodes: logical array
[G.faces.nodes, G.faces.nodePos] = removeFromPackedData(G.faces.nodePos, G.faces.nodes, rmnodes);

old2NewNodes = zeros(numel(rmnodes),1);
old2NewNodes(~rmnodes) = 1:sum(~rmnodes);
G.nodes.coords = G.nodes.coords(~rmnodes,:);
G.faces.nodes = old2NewNodes(G.faces.nodes);
G.nodes.num = sum(~rmnodes);
end




