load("grid-files/cutcell/buff_horizon_presplit_cutcell_130x62.mat");


geodata = readGeo('./geo-files/spe11a-faults.geo', 'assignExtra', true);
geodata = RotateGrid(geodata);
geodata = StretchGeo(geodata);

%%
method = 'convexity';
[partition, failed] = PartitionByTag(G, 'method', method, ...
    'avoidBufferCells', true);
Gp = makePartitionedGrid(G, partition);
Gp = TagbyFacies(Gp, geodata, 'vertIx', 3);

%%
Gp = GenerateCutCellGrid(130, 62, 'type', 'cartesian', 'save', true, 'verbose', true);
%%
plotCellData(Gp, Gp.cells.tag);view(0,0)
