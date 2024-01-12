clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa coarseGrid
%%
nx = 28;
ny = 12;
Gcut = loadCutCell(nx, ny);
%%
partition = processPartition(Gcut, Gcut.cells.tag);
CG = generateCoarseGrid(Gcut, partition);
plotCellData(Gcut, partition);
colormap('lines');
colorbar;

%%
volMax = max(Gcut.cells.volumes);
% histogram(Gcut.cells.volumes, 100)
% volLim = prctile(Gcut.cells.volumes, 40);
volLim = volMax/10;
smallcellsLog = Gcut.cells.volumes < volLim;

nbs = getNeighbourship(Gcut);
smallCells = find(smallcellsLog);
partition = 1:Gcut.cells.num';
for ism = 1:numel(smallCells)
    c = smallCells(ism);
    n = nbs(nbs(:, 1) == c | nbs(:, 2) == c, :);
    n = unique(n(:));
    n = n(n~=c);
    n = n(Gcut.cells.tag(n) == Gcut.cells.tag(c));
    if numel(n) == 1
        finalneighbor = n;
    else

        f = Gcut.cells.faces(Gcut.cells.facePos(c):Gcut.cells.facePos(c+1)-1);
        faceneighbors = Gcut.faces.neighbors(f,:);
        f = f( ismember( faceneighbors(:,1), n ) | ismember( faceneighbors(:,2), n ) );
        faceareas = Gcut.faces.areas(f);
        faceneighbors = Gcut.faces.neighbors(f,:);
        faceneighbors = faceneighbors(:,1) .* (faceneighbors(:,1) ~= c) + faceneighbors(:,2) .* (faceneighbors(:,2) ~= c);

        [~, sortorder] = sort(faceareas, 'descend');
        f = f(sortorder);
        faceneighbors = faceneighbors(sortorder);
        finalneighbor = faceneighbors(1);
    end

    partition(c) = partition(finalneighbor);
    clf(gcf);
    plotCellData(Gcut, Gcut.cells.tag);
    plotGrid(Gcut, [c, finalneighbor], 'facealpha', 0, 'linewidth', 3, 'edgecolor', 'red');
    ;
end
%%
CG = generateCoarseGrid(Gcut, partition');
CG = coarsenGeometry(CG);

%%
Greg = RegularizeCoarseGrid(CG);

%% Viz CoarseGrid
cla
plotCellData(CG, (1:CG.cells.num)', 'EdgeColor','w','EdgeAlpha',.5);
plotFaces(CG, (1:CG.faces.num)', 'FaceColor','none','LineWidth', 2);
%%
[u, ia, ic] = unique(partition);
numGroups = numel(u); % Find the number of groups
result = accumarray(partition(:), (1:numel(partition))', [], @(x) {sort(x')});
result = result(~cellfun(@isempty, result));
%%

for ipart = 1:numGroups
    part = result{ipart};
    clf(gcf);
    plotCellData(Gcut, Gcut.cells.tag);
    plotGrid(Gcut, part, 'facealpha', 0, 'linewidth', 3);
end
