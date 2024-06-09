%%
geodata = readGeo('scripts\cutcell\geo\spe11a.geo', 'assignextra', true);
geodataRounded = geodata;
geodataRounded.Point = cellfun(@(point)round(point, 2), geodata.Point, UniformOutput=false);

G = cartGrid([280 120 1], [2.8, 1.2, 0.01]);
G = computeGeometry(G);


%%
Gcut = cutCellGeo(G, geodataRounded, 'presplit', false, 'save', false, 'waitbar', true);
%%
Gcut = tagbyFacies(Gcut, geodataRounded);
plotCellData(Gcut, Gcut.cells.tag);
%%
nx = 280;
ny = 120;
Gcut2 = generateCutCellGrid(nx, ny, 'presplit', true, 'save', false, ...
    'recombine', false, 'waitbar', true, 'verbose', true);
%%
% Gcut = tagbyFacies(Gcut2, geodataRounded);
figure;
plotCellData(Gcut2, Gcut2.cells.tag);
axis tight;