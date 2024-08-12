clear all
close all
%%
[G, Pts, F] = compositePebiGrid2D([0.1, 0.1], [1,1], 'faceConstraints', [0.2, 0.2;0.8, 0.5;0.1, 0.8]);
%%
[G, G2D, G2Ds, Pts, F] = generatePEBIGrid(130, 62, 'save', false, 'earlyReturn', true, 'FCFactor', 0.53);
%%
plotGrid(G);
%%
nf = size(F.f.pts,1);
fxdPts = Pts(1:nf,:);
bgPts = Pts(nf+1:end, :);
Gc = CPG2D(bgPts, [0,0;1,0;1,12/84;0,12/84], 'fixedPts', fxdPts, 'storedVec', 20);
%%
plotGrid(Gc);