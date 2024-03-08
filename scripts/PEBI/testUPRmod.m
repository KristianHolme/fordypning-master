clear all
close all
%%
gs = [0.2, 0.05];
pdims = [1,1];
faults = {[0.1, 0.2;0.8, 0.2], [0.7, 0.1;0.7,0.8]};

G = compositePebiGrid2D(gs, pdims, 'faceConstraints', faults, 'FCFactor', [5, 1]);
%%
plotCellData(G, (1:G.cells.num)')

%%
FCFactor = 0.53*ones(36, 1);
FCFactor([20]) = 1.0;
G = GeneratePEBIGrid(130, 62, 'save', false, 'FCFactor', FCFactor, 'earlyReturn', false);