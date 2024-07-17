function G = flipFaces(G,faces)
nbs = G.faces.neighbors(faces,:);
flipped_nbs = nbs(:,2:-1:1);
G.faces.neighbors(faces,:) = flipped_nbs;
G = computeGeometry(G);
end