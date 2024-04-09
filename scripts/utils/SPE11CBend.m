function G = SPE11CBend(G)
v = G.nodes.coords(:,2);
w = G.nodes.coords(:,3);

z = w - 150*(1-(v/2500 - 1).^2) - v/500;
G.nodes.coords(:,3) = z;
G = mcomputeGeometry(G);
end