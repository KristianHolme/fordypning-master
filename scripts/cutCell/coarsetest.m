clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa coarsegrid
%%
geodata = readGeo('');
geodata.Facies{1} = [7, 8, 9, 32];
geodata.Facies{7} = [1, 31];
geodata.Facies{5} = [2, 3, 4, 5, 6];
geodata.Facies{4} = [10, 11, 12, 13, 14, 15, 22];
geodata.Facies{3} = [16, 17, 18, 19, 20, 21];
geodata.Facies{6} = [23, 24, 25];
geodata.Facies{2} = [26, 27, 28, 29, 30];
geodata.BoundaryLines = unique([1, 2, 12, 11, 9, 8, 10, 7, 6, 5, 3, 4, 24, 23, 22, 21, 20, 19, 18, 17, 16, 14, 15, 13]);
%%
nx = 144;
ny = 48;
Gcut = loadCutCell(nx, ny);
%%
t = tic();
partition = PartitionByTag(Gcut);
CG = generateCoarseGrid(Gcut, partition);
CG = coarsenGeometry(CG);
CG = TagbyFacies(CG, geodata);
t = toc(t);
fprintf("cut and coarsen in %0.2f s\n", t);

%%
Gsub = extractSubgrid(Gcut, [78, 211, 210, 219]);
plotGrid(Gsub);
Gsub = TagbyFacies(Gsub, geodata);
subp = PartitionByTag(Gsub);
CGsub = generateCoarseGrid(Gsub, subp);
CGsub = coarsenGeometry(CGsub);
VizCoarse(CGsub);

%%
[u, ia, ic] = unique(partition);
numGroups = numel(u); % Find the number of groups
result = accumarray(partition(:), (1:numel(partition))', [], @(x) {sort(x')});
result = result(~cellfun(@isempty, result));
cellnumberdifference = Gcut.cells.num - numGroups;
%%
[~, sortorder] = sort(CG.cells.centroids(:,2));
cla
for i = 1:CG.cells.num
    c = sortorder(i);
    faces = CG.cells.faces(CG.cells.facePos(c):CG.cells.facePos(c+1)-1);
    if isempty(faces)
        continue
    end
    plotCellData(CG, CG.cells.tag);
    plotFaces(CG, faces, 'facecolor', 'red');
    ;
end

%%


