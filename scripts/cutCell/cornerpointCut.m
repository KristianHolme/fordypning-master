clear all
close all
%%
set(groot, 'defaultAxesView', [0, 0]);

%%
simcase = Simcase('deckcase', 'B_ISO_SMALL', 'usedeck', true);
G = simcase.G;
geodata = readGeo('', 'assignExtra', true);
geodata = RotateGrid(geodata);
geodata = StretchGeo(geodata);
%% Presplit
Gpre = PointSplit(G, geodata.Point, 'dir', [0 1 0], 'verbose', true, 'waitbar', false);
%%
Gcut = CutCellGeo(Gpre, geodata, 'dir', [0 1 0], 'verbose', true, ...
    'extendSliceFactor', 0.01, ...
    'topoSplit', false);
Gcut = TagbyFacies(Gcut, geodata, 'vertIx', 3);
G = Gcut;
save('grid-files/cutcell/cp_pre_cut_130x62', "G");
%%
plotCellData(Gcut, Gcut.cells.tag);
%%
Gcutnopre = CutCellGeo(G, geodata, 'dir', [0 1 0], 'verbose', true, ...
    'extendSliceFactor', 0.01, ...
    'topoSplit', false);