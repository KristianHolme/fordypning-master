clear all
close all
%%
simcase = Simcase('deckcase', 'B_ISO_SMALL', 'usedeck', true);
G = simcase.G;
geodata = readGeo('', 'assignExtra', true);
geodata = RotateGrid(geodata);
geodata = StretchGeo(geodata);
%% Presplit
Gpre = PointSplit(G, geodata.Point, 'dir', [0 1 0], 'verbose', true, 'waitbar', true);
%%
Gcut = CutCellGeo(Gpre, geodata, 'dir', [0 1 0], 'verbose', true);
