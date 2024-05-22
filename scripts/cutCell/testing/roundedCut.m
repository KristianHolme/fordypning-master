%%
geodata = readGeo('scripts\cutcell\geo\spe11a.geo', 'assignextra', true);
geodataRounded = geodata;
geodataRounded.Point = cellfun(@(point)round(point, 2), geodata.Point, UniformOutput=false);

G = cartGrid([280 120 1], [2.8, 1.2, 0.01]);
G = computeGeometry(G);


%%
Gcut = CutCellGeo(G, geodataRounded, 'presplit', false, 'save', false, 'waitbar', true);
%%
Gcut = TagbyFacies(Gcut, geodataRounded);
plotCellData(Gcut, Gcut.cells.tag);
%%
nx = 280;
ny = 120;
Gcut2 = GenerateCutCellGrid(nx, ny, 'presplit', true, 'save', false, ...
    'recombine', false, 'waitbar', true, 'verbose', true);
%%
% Gcut = TagbyFacies(Gcut2, geodataRounded);
figure;
plotCellData(Gcut2, Gcut2.cells.tag);
axis tight;