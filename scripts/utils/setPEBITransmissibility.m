function model = setPEBITransmissibility(model)
sites = model.G.sites;
sites = sites(model.G.cells.indexMap,:);
G = model.G;
rock = model.rock;


N      = G.faces.neighbors;
intInx = all(N ~= 0, 2);

faceCenters = G.faces.centroids;

F = faceCenters(intInx, :);
A = sites(G.faces.neighbors(intInx,1),:);
B = sites(G.faces.neighbors(intInx,2),:);
N = G.faces.normals(intInx,:);

t = dot(F-A, N, 2) ./ dot(B-A, N, 2); %where along the line is the intersection with the face?

faceCenters(intInx,:) = A + ((B-A) .* t); %get intersection by using the length aloing the line

cellFaceCenters = faceCenters(G.cells.faces(:,1),:);

T = getFaceTransmissibility(G, rock, 'cellCenters', sites, 'cellFaceCenters', cellFaceCenters);


T_all = T;

T     = T(intInx);

model.operators.T = T;
model.operators.T_all = T_all;